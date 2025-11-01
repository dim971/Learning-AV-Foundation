//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

private func clamp(_ intensity: CGFloat) -> CGFloat {
    if intensity < 0.0 {
        return 0.0
    } else if intensity >= 1.0 {
        return 1.0
    } else {
        return intensity
    }
}

class THLevelMeterView: UIView {

    var level: CGFloat = 0.0
    var peakLevel: CGFloat = 0.0

    private var ledCount: Int = 0
    private var ledBackgroundColor: UIColor!
    private var ledBorderColor: UIColor!
    private var colorThresholds: [THLevelMeterColorThreshold] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        ledCount = 20

        ledBackgroundColor = UIColor(white: 0.0, alpha: 0.35)
        ledBorderColor = .black

        let greenColor = UIColor(red: 0.458, green: 1.000, blue: 0.396, alpha: 1.000)
        let yellowColor = UIColor(red: 1.000, green: 0.930, blue: 0.315, alpha: 1.000)
        let redColor = UIColor(red: 1.000, green: 0.325, blue: 0.329, alpha: 1.000)

        colorThresholds = [
            THLevelMeterColorThreshold.colorThreshold(maxValue: 0.5, color: greenColor, name: "green"),
            THLevelMeterColorThreshold.colorThreshold(maxValue: 0.8, color: yellowColor, name: "yellow"),
            THLevelMeterColorThreshold.colorThreshold(maxValue: 1.0, color: redColor, name: "red")
        ]
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.translateBy(x: 0, y: bounds.height)
        context.rotate(by: CGFloat(-Double.pi / 2))
        let bounds = CGRect(x: 0.0, y: 0.0, width: self.bounds.height, height: self.bounds.width)

        var lightMinValue: CGFloat = 0.0

        var peakLED = -1

        if peakLevel > 0.0 {
            peakLED = Int(peakLevel * CGFloat(ledCount))
            if peakLED >= ledCount {
                peakLED = ledCount - 1
            }
        }

        for ledIndex in 0..<ledCount {
            var ledColor = colorThresholds[0].color

            let ledMaxValue = CGFloat(ledIndex + 1) / CGFloat(ledCount)

            for colorIndex in 0..<(colorThresholds.count - 1) {
                let currThreshold = colorThresholds[colorIndex]
                let nextThreshold = colorThresholds[colorIndex + 1]
                if currThreshold.maxValue <= ledMaxValue {
                    ledColor = nextThreshold.color
                }
            }

            let height = bounds.height
            let width = bounds.width

            let ledRect = CGRect(x: 0.0, y: height * (CGFloat(ledIndex) / CGFloat(ledCount)), width: width, height: height * (1.0 / CGFloat(ledCount)))

            // Fill background color
            context.setFillColor(ledBackgroundColor.cgColor)
            context.fill(ledRect)

            // Draw Light
            let lightIntensity: CGFloat
            if ledIndex == peakLED {
                lightIntensity = 1.0
            } else {
                lightIntensity = clamp((level - lightMinValue) / (ledMaxValue - lightMinValue))
            }

            var fillColor: UIColor? = nil
            if lightIntensity == 1.0 {
                fillColor = ledColor
            } else if lightIntensity > 0.0 {
                fillColor = ledColor.withAlphaComponent(lightIntensity)
            }

            if let fillColor = fillColor {
                context.setFillColor(fillColor.cgColor)
            }
            let fillPath = UIBezierPath(roundedRect: ledRect, cornerRadius: 2.0)
            context.addPath(fillPath.cgPath)

            // Stroke border
            context.setStrokeColor(ledBorderColor.cgColor)
            let strokePath = UIBezierPath(roundedRect: ledRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2.0)
            context.addPath(strokePath.cgPath)

            context.drawPath(using: .fillStroke)

            lightMinValue = ledMaxValue
        }
    }

    func resetLevelMeter() {
        level = 0.0
        peakLevel = 0.0
        setNeedsDisplay()
    }
}
