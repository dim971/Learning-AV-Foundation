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

import AVFoundation

protocol THPlayerControllerDelegate: AnyObject {
    func playbackStopped()
    func playbackBegan()
}

class THPlayerController {
    var isPlaying: Bool = false
    weak var delegate: THPlayerControllerDelegate?

    // Global methods
    func play() {
        // To be implemented
    }

    func stop() {
        // To be implemented
    }

    func adjustRate(_ rate: Float) {
        // To be implemented
    }

    // Player-specific methods
    func adjustPan(_ pan: Float, forPlayerAtIndex index: Int) {
        // To be implemented
    }

    func adjustVolume(_ volume: Float, forPlayerAtIndex index: Int) {
        // To be implemented
    }
}
