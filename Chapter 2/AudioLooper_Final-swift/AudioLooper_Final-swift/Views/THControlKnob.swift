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
//  This component is based on Matthijs Hollemans' excellent MHRotaryKnob.
//  https://github.com/hollance/MHRotaryKnob
//
//  I have added some custom drawing and made some modifications to fit the
//  needs of this demo app.
//

import UIKit
import QuartzCore

let kMaxAngle: Float = 120.0
let kScalingFactor: Float = 4.0

class THControlKnob: UIControl {

    var maximumValue: Float = 1.0
    var minimumValue: Float = -1.0
    var defaultValue: Float = 0.0

    var value: Float {
        get {
            return _value
        }
        set {
            setValue(newValue, animated: false)
        }
    }

    private var _value: Float = 0.0
    private var angle: Float = 0.0
    private var touchOrigin: CGPoint = .zero
    private var indicatorView: THIndicatorLight!

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

        angle = 0.0
        defaultValue = 0.0
        minimumValue = -1.0
        maximumValue = 1.0
        _value = defaultValue

        indicatorView = THIndicatorLight(frame: bounds)
        indicatorView.lightColor = indicatorLightColor()
        addSubview(indicatorView)

        valueDidChange(from: defaultValue, to: defaultValue, animated: false)
    }

    func indicatorLightColor() -> UIColor {
        return .white
    }

    // MARK: - Data Model

    private func clampAngle(_ angle: Float) -> Float {
        if angle < -kMaxAngle {
            return -kMaxAngle
        } else if angle > kMaxAngle {
            return kMaxAngle
        }
        return angle
    }

    private func angleForValue(_ value: Float) -> Float {
        return ((value - minimumValue) / (maximumValue - minimumValue) - 0.5) * (kMaxAngle * 2.0)
    }

    private func valueForAngle(_ angle: Float) -> Float {
        return (angle / (kMaxAngle * 2.0) + 0.5) * (maximumValue - minimumValue) + minimumValue
    }

    private func valueForPosition(_ point: CGPoint) -> Float {
        let delta = Float(touchOrigin.y - point.y)
        let newAngle = clampAngle(delta * kScalingFactor + angle)
        return valueForAngle(newAngle)
    }

    func setValue(_ newValue: Float, animated: Bool) {
        let oldValue = _value

        if newValue < minimumValue {
            _value = minimumValue
        } else if newValue > maximumValue {
            _value = maximumValue
        } else {
            _value = newValue
        }

        valueDidChange(from: oldValue, to: _value, animated: animated)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        touchOrigin = point
        angle = angleForValue(value)
        isHighlighted = true
        setNeedsDisplay()
        return true
    }

    private func handleTouch(_ touch: UITouch) -> Bool {
        if touch.tapCount > 1 {
            setValue(defaultValue, animated: true)
            return false
        }
        let point = touch.location(in: self)
        value = valueForPosition(point)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if handleTouch(touch) {
            sendActions(for: .valueChanged)
        }
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch = touch {
            handleTouch(touch)
        }
        sendActions(for: .valueChanged)
        isHighlighted = false
        setNeedsDisplay()
    }

    private func valueDidChange(from oldValue: Float, to newValue: Float, animated: Bool) {
        let newAngle = angleForValue(newValue)

        if animated {
            let oldAngle = angleForValue(oldValue)

            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.2

            animation.values = [
                oldAngle * .pi / 180.0,
                (newAngle + oldAngle) / 2.0 * .pi / 180.0,
                newAngle * .pi / 180.0
            ]

            animation.keyTimes = [0.0, 0.5, 1.0]

            animation.timingFunctions = [
                CAMediaTimingFunction(name: .easeIn),
                CAMediaTimingFunction(name: .easeOut)
            ]

            indicatorView.layer.add(animation, forKey: nil)
        }

        indicatorView.transform = CGAffineTransform(rotationAngle: CGFloat(newAngle * .pi / 180.0))
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Set up Colors
        let strokeColor = UIColor(white: 0.06, alpha: 1.0)
        var gradientLightColor = UIColor(red: 0.101, green: 0.100, blue: 0.103, alpha: 1.000)
        var gradientDarkColor = UIColor(red: 0.237, green: 0.242, blue: 0.242, alpha: 1.000)

        if isHighlighted {
            gradientLightColor = gradientLightColor.darkerColor() ?? gradientLightColor
            gradientDarkColor = gradientDarkColor.darkerColor() ?? gradientDarkColor
        }

        let gradientColors = [gradientLightColor.cgColor, gradientDarkColor.cgColor] as CFArray
        let locations: [CGFloat] = [0, 1]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: locations) else {
            return
        }

        let insetRect = rect.insetBy(dx: 2.0, dy: 2.0)

        // Draw Bezel
        context.setFillColor(strokeColor.cgColor)
        context.fillEllipse(in: insetRect)

        let midX = insetRect.midX
        let midY = insetRect.midY

        // Draw Bezel Light Shadow Layer
        context.addArc(center: CGPoint(x: midX, y: midY), radius: insetRect.width / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.setShadow(offset: CGSize(width: 0.0, height: 0.5), blur: 2.0, color: UIColor.darkGray.cgColor)
        context.fillPath()

        // Add Clipping Region for Knob Background
        context.addArc(center: CGPoint(x: midX, y: midY), radius: (insetRect.width - 6) / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.clip()

        let startPoint = CGPoint(x: midX, y: insetRect.maxY)
        let endPoint = CGPoint(x: midX, y: insetRect.minY)

        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }
}

class THGreenControlKnob: THControlKnob {
    override func indicatorLightColor() -> UIColor {
        return UIColor(red: 0.226, green: 1.000, blue: 0.226, alpha: 1.000)
    }
}

class THOrangeControlKnob: THControlKnob {
    override func indicatorLightColor() -> UIColor {
        return UIColor(red: 1.000, green: 0.718, blue: 0.000, alpha: 1.000)
    }
}
