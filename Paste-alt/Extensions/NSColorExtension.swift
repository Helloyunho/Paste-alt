import AppKit

extension NSColor {
    var isDarkText: Bool {
        let clcolor = CIColor(color: self)!
        let red = clcolor.red <= 0.03928 ? clcolor.red / 12.92 : pow(((clcolor.red + 0.055) / 1.055), 2.4)
        let green = clcolor.green <= 0.03928 ? clcolor.green / 12.92 : pow(((clcolor.green + 0.055) / 1.055), 2.4)
        let blue = clcolor.blue <= 0.03928 ? clcolor.blue / 12.92 : pow(((clcolor.blue + 0.055) / 1.055), 2.4)
        
        let L = (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
        
        return L > 0.179
    }

    func darker(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjustBrightness(by: -abs(percentage))
    }

    func lighter(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjustBrightness(by: abs(percentage))
    }

    func adjustBrightness(by percentage: CGFloat = 30.0) -> NSColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if b < 1.0 {
            let newB: CGFloat = max(min(b + (percentage / 100.0) * b, 1.0), 0.0)
            return NSColor(hue: h, saturation: s, brightness: newB, alpha: a)
        } else {
            let newS: CGFloat = min(max(s - (percentage / 100.0) * s, 0.0), 1.0)
            return NSColor(hue: h, saturation: newS, brightness: b, alpha: a)
        }
    }
    
    func invertColor() -> NSColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return NSColor(hue: 1.0 - h, saturation: 1.0 - s, brightness: 1.0 - b, alpha: a)
    }
}
