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
// This code is based on Apple's MeterTable.cpp code used by the avTouch and SpeakHere
// sample projects.  It creates an internal table storing the precomputed db -> linear
// values.

import Foundation

private let MIN_DB: Float = -60.0
private let TABLE_SIZE = 300

private func dbToAmp(_ dB: Float) -> Float {
    return powf(10.0, 0.05 * dB)
}

class THMeterTable: NSObject {

    private var scaleFactor: Float = 0.0
    private var meterTable: [Float] = []

    override init() {
        super.init()

        let dbResolution = MIN_DB / Float(TABLE_SIZE - 1)

        meterTable = [Float](repeating: 0.0, count: TABLE_SIZE)
        scaleFactor = 1.0 / dbResolution

        let minAmp = dbToAmp(MIN_DB)
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange

        for i in 0..<TABLE_SIZE {
            let decibels = Float(i) * dbResolution
            let amp = dbToAmp(decibels)
            let adjAmp = (amp - minAmp) * invAmpRange
            meterTable[i] = adjAmp
        }
    }

    func value(power: Float) -> Float {
        if power < MIN_DB {
            return 0.0
        } else if power >= 0.0 {
            return 1.0
        } else {
            let index = Int(power * scaleFactor)
            return meterTable[index]
        }
    }
}
