//
//  SVGPath.swift
//  把 SVG 的 path data（d 字符串）解析成 SwiftUI 的 Path。
//
//  覆盖 Lucide 用到的全部命令：M L H V C S Q T A Z（大小写＝绝对/相对）。
//  难点是 A（椭圆弧）——SVG 用端点参数化，这里按规范 F.6.5 转成圆心参数化，
//  再切成 ≤90° 的小段各自用三次贝塞尔逼近。
//

import SwiftUI

enum SVGPath {

    static func parse(_ d: String) -> Path {
        var path = Path()
        var p = Scanner(d)

        var cur = CGPoint.zero    // 当前点
        var sub = CGPoint.zero    // 当前子路径起点，Z 用
        var lastCubic: CGPoint?   // 上一段三次贝塞尔的第二控制点，S 用
        var lastQuad: CGPoint?    // 上一段二次贝塞尔的控制点，T 用

        while let cmd = p.nextCommand() {
            let rel = cmd.isLowercase

            switch Character(cmd.uppercased()) {

            case "M":
                var first = true
                repeat {
                    let x = p.number(), y = p.number()
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    if first {
                        path.move(to: pt)
                        sub = pt
                        first = false
                    } else {
                        // 后续坐标对按规范视作隐式 L
                        path.addLine(to: pt)
                    }
                    cur = pt
                } while p.hasNumber
                lastCubic = nil; lastQuad = nil

            case "L":
                repeat {
                    let x = p.number(), y = p.number()
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    path.addLine(to: pt)
                    cur = pt
                } while p.hasNumber
                lastCubic = nil; lastQuad = nil

            case "H":
                repeat {
                    let x = p.number()
                    let pt = CGPoint(x: rel ? cur.x + x : x, y: cur.y)
                    path.addLine(to: pt)
                    cur = pt
                } while p.hasNumber
                lastCubic = nil; lastQuad = nil

            case "V":
                repeat {
                    let y = p.number()
                    let pt = CGPoint(x: cur.x, y: rel ? cur.y + y : y)
                    path.addLine(to: pt)
                    cur = pt
                } while p.hasNumber
                lastCubic = nil; lastQuad = nil

            case "C":
                repeat {
                    let x1 = p.number(), y1 = p.number()
                    let x2 = p.number(), y2 = p.number()
                    let x = p.number(), y = p.number()
                    let c1 = rel ? CGPoint(x: cur.x + x1, y: cur.y + y1) : CGPoint(x: x1, y: y1)
                    let c2 = rel ? CGPoint(x: cur.x + x2, y: cur.y + y2) : CGPoint(x: x2, y: y2)
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    path.addCurve(to: pt, control1: c1, control2: c2)
                    lastCubic = c2; lastQuad = nil
                    cur = pt
                } while p.hasNumber

            case "S":
                repeat {
                    let x2 = p.number(), y2 = p.number()
                    let x = p.number(), y = p.number()
                    let c2 = rel ? CGPoint(x: cur.x + x2, y: cur.y + y2) : CGPoint(x: x2, y: y2)
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    // 第一控制点是上一段第二控制点关于当前点的对称
                    let c1 = lastCubic.map { CGPoint(x: 2 * cur.x - $0.x, y: 2 * cur.y - $0.y) } ?? cur
                    path.addCurve(to: pt, control1: c1, control2: c2)
                    lastCubic = c2; lastQuad = nil
                    cur = pt
                } while p.hasNumber

            case "Q":
                repeat {
                    let x1 = p.number(), y1 = p.number()
                    let x = p.number(), y = p.number()
                    let c = rel ? CGPoint(x: cur.x + x1, y: cur.y + y1) : CGPoint(x: x1, y: y1)
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    addQuad(&path, from: cur, control: c, to: pt)
                    lastQuad = c; lastCubic = nil
                    cur = pt
                } while p.hasNumber

            case "T":
                repeat {
                    let x = p.number(), y = p.number()
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    let c = lastQuad.map { CGPoint(x: 2 * cur.x - $0.x, y: 2 * cur.y - $0.y) } ?? cur
                    addQuad(&path, from: cur, control: c, to: pt)
                    lastQuad = c; lastCubic = nil
                    cur = pt
                } while p.hasNumber

            case "A":
                repeat {
                    let rx = p.number(), ry = p.number()
                    let rot = p.number()
                    let large = p.flag(), sweep = p.flag()
                    let x = p.number(), y = p.number()
                    let pt = rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
                    addArc(&path, from: cur, rx: rx, ry: ry, rotation: rot,
                           largeArc: large, sweep: sweep, to: pt)
                    cur = pt
                } while p.hasNumber
                lastCubic = nil; lastQuad = nil

            case "Z":
                path.closeSubpath()
                cur = sub
                lastCubic = nil; lastQuad = nil

            default:
                break
            }
        }
        return path
    }

    // MARK: - 二次贝塞尔 → 三次

    private static func addQuad(_ path: inout Path, from p0: CGPoint, control c: CGPoint, to p1: CGPoint) {
        let k = 2.0 / 3.0
        let c1 = CGPoint(x: p0.x + k * (c.x - p0.x), y: p0.y + k * (c.y - p0.y))
        let c2 = CGPoint(x: p1.x + k * (c.x - p1.x), y: p1.y + k * (c.y - p1.y))
        path.addCurve(to: p1, control1: c1, control2: c2)
    }

    // MARK: - 椭圆弧 → 三次贝塞尔（SVG 规范 F.6.5 端点参数化 → 圆心参数化）

    private static func addArc(_ path: inout Path,
                               from p0: CGPoint, rx rxIn: CGFloat, ry ryIn: CGFloat,
                               rotation rotDeg: CGFloat, largeArc: Bool, sweep: Bool,
                               to p1: CGPoint) {
        var rx = abs(rxIn), ry = abs(ryIn)

        // 退化情形按直线处理
        if rx == 0 || ry == 0 { path.addLine(to: p1); return }
        if p0 == p1 { return }

        let phi = rotDeg * .pi / 180
        let cosPhi = cos(phi), sinPhi = sin(phi)

        // 步骤 1：把两端点挪到以椭圆中心为原点的坐标系
        let dx2 = (p0.x - p1.x) / 2, dy2 = (p0.y - p1.y) / 2
        let x1p =  cosPhi * dx2 + sinPhi * dy2
        let y1p = -sinPhi * dx2 + cosPhi * dy2

        // 步骤 2：半径不够大就按比例放大
        let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
        if lambda > 1 {
            let s = sqrt(lambda)
            rx *= s; ry *= s
        }

        // 步骤 3：求圆心
        let sign: CGFloat = (largeArc == sweep) ? -1 : 1
        let den = rx * rx * y1p * y1p + ry * ry * x1p * x1p
        var num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
        if num < 0 { num = 0 }   // 浮点误差兜底
        let coef = sign * sqrt(num / den)
        let cxp =  coef * rx * y1p / ry
        let cyp = -coef * ry * x1p / rx

        let cx = cosPhi * cxp - sinPhi * cyp + (p0.x + p1.x) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (p0.y + p1.y) / 2

        // 步骤 4：起始角与扫过的角度
        func angle(_ ux: CGFloat, _ uy: CGFloat, _ vx: CGFloat, _ vy: CGFloat) -> CGFloat {
            let dot = ux * vx + uy * vy
            let len = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
            var a = acos(max(-1, min(1, dot / len)))
            if ux * vy - uy * vx < 0 { a = -a }
            return a
        }

        let ux = (x1p - cxp) / rx, uy = (y1p - cyp) / ry
        let vx = (-x1p - cxp) / rx, vy = (-y1p - cyp) / ry
        let theta1 = angle(1, 0, ux, uy)
        var dTheta = angle(ux, uy, vx, vy)
        if !sweep && dTheta > 0 { dTheta -= 2 * .pi }
        if  sweep && dTheta < 0 { dTheta += 2 * .pi }

        // 步骤 5：切段，每段用三次贝塞尔逼近
        let segments = max(1, Int(ceil(abs(dTheta) / (.pi / 2))))
        let delta = dTheta / CGFloat(segments)
        let t = 4.0 / 3.0 * tan(delta / 4)

        func mapPoint(_ ex: CGFloat, _ ey: CGFloat) -> CGPoint {
            CGPoint(x: cx + cosPhi * rx * ex - sinPhi * ry * ey,
                    y: cy + sinPhi * rx * ex + cosPhi * ry * ey)
        }

        var theta = theta1
        for _ in 0..<segments {
            let theta2 = theta + delta
            let cos1 = cos(theta),  sin1 = sin(theta)
            let cos2 = cos(theta2), sin2 = sin(theta2)

            let start = mapPoint(cos1, sin1)
            let end   = mapPoint(cos2, sin2)

            // 椭圆上参数点处的切向量
            let c1 = CGPoint(x: start.x + t * (-cosPhi * rx * sin1 - sinPhi * ry * cos1),
                             y: start.y + t * (-sinPhi * rx * sin1 + cosPhi * ry * cos1))
            let c2 = CGPoint(x: end.x - t * (-cosPhi * rx * sin2 - sinPhi * ry * cos2),
                             y: end.y - t * (-sinPhi * rx * sin2 + cosPhi * ry * cos2))

            path.addCurve(to: end, control1: c1, control2: c2)
            theta = theta2
        }
    }
}

// MARK: - 词法扫描

/// 把 d 字符串切成「命令 + 数字」的流。
/// 数字之间可以用空格或逗号分隔，负号本身也是分隔符（如 `m21 21-4.34-4.34`）。
private struct Scanner {
    private let chars: [Character]
    private var i = 0

    init(_ s: String) { chars = Array(s) }

    private mutating func skipSeparators() {
        while i < chars.count {
            let c = chars[i]
            if c == " " || c == "," || c == "\n" || c == "\t" || c == "\r" {
                i += 1
            } else {
                break
            }
        }
    }

    /// 后面还有没有数字——用来判断命令的参数是否重复出现
    var hasNumber: Bool {
        var j = i
        while j < chars.count, chars[j] == " " || chars[j] == "," { j += 1 }
        guard j < chars.count else { return false }
        let c = chars[j]
        return c.isNumber || c == "-" || c == "+" || c == "."
    }

    mutating func nextCommand() -> Character? {
        skipSeparators()
        guard i < chars.count, chars[i].isLetter else { return nil }
        defer { i += 1 }
        return chars[i]
    }

    mutating func number() -> CGFloat {
        skipSeparators()
        let start = i
        if i < chars.count, chars[i] == "-" || chars[i] == "+" { i += 1 }

        var sawDigit = false
        while i < chars.count, chars[i].isNumber { i += 1; sawDigit = true }
        if i < chars.count, chars[i] == "." {
            i += 1
            while i < chars.count, chars[i].isNumber { i += 1; sawDigit = true }
        }

        guard sawDigit else { i = start; return 0 }   // 只有符号没有数字，回退

        // 科学计数法（Lucide 不用，但 SVG 允许）
        if i < chars.count, chars[i] == "e" || chars[i] == "E" {
            let save = i
            i += 1
            if i < chars.count, chars[i] == "-" || chars[i] == "+" { i += 1 }
            if i < chars.count, chars[i].isNumber {
                while i < chars.count, chars[i].isNumber { i += 1 }
            } else {
                i = save
            }
        }

        return CGFloat(Double(String(chars[start..<i])) ?? 0)
    }

    /// 弧命令的旗标：规范里是单独的 0/1 字符，可以和后续数字紧挨着写
    mutating func flag() -> Bool {
        skipSeparators()
        guard i < chars.count else { return false }
        if chars[i] == "0" { i += 1; return false }
        if chars[i] == "1" { i += 1; return true }
        return number() != 0
    }
}
