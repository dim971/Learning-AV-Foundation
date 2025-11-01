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

protocol THRecorderControllerDelegate: AnyObject {
    func interruptionBegan()
}

typealias THRecordingStopCompletionHandler = (Bool) -> Void
typealias THRecordingSaveCompletionHandler = (Bool, Any?) -> Void

class THRecorderController: NSObject {

    var formattedCurrentTime: String {
        return "00:00:00"
    }

    weak var delegate: THRecorderControllerDelegate?

    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    private var completionHandler: THRecordingStopCompletionHandler?

    override init() {
        super.init()
    }

    // MARK: - Recorder methods

    func record() -> Bool {
        return false
    }

    func pause() {

    }

    func stop(completionHandler handler: @escaping THRecordingStopCompletionHandler) {

    }

    func saveRecording(withName name: String, completionHandler handler: @escaping THRecordingSaveCompletionHandler) {

    }

    func levels() -> THLevelPair {
        return THLevelPair(level: 0.0, peakLevel: 0.0)
    }

    // MARK: - Player methods

    func playback(memo: THMemo) -> Bool {
        return false
    }
}

// MARK: - AVAudioRecorderDelegate

extension THRecorderController: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

    }
}
