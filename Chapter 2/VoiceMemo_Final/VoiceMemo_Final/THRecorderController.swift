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
typealias THRecordingSaveCompletionHandler = (Bool, Any) -> Void

class THRecorderController: NSObject {

    var formattedCurrentTime: String {
        let time = Int(recorder.currentTime)
        let hours = time / 3600
        let minutes = (time / 60) % 60
        let seconds = time % 60

        let format = "%02i:%02i:%02i"
        return String(format: format, hours, minutes, seconds)
    }

    weak var delegate: THRecorderControllerDelegate?

    private var player: AVAudioPlayer!
    private var recorder: AVAudioRecorder!
    private var completionHandler: THRecordingStopCompletionHandler?
    private var meterTable: THMeterTable!

    override init() {
        super.init()

        let tmpDir = NSTemporaryDirectory()
        let filePath = (tmpDir as NSString).appendingPathComponent("memo.caf")
        let fileURL = URL(fileURLWithPath: filePath)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleIMA4),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        meterTable = THMeterTable()
    }

    func record() -> Bool {
        return recorder.record()
    }

    func pause() {
        recorder.pause()
    }

    func stop(completionHandler handler: @escaping THRecordingStopCompletionHandler) {
        completionHandler = handler
        recorder.stop()
    }

    func saveRecording(name: String, completionHandler handler: @escaping THRecordingSaveCompletionHandler) {
        let timestamp = Date.timeIntervalSinceReferenceDate
        let filename = String(format: "%@-%f.m4a", name, timestamp)

        let docsDir = documentsDirectory()
        let destPath = (docsDir as NSString).appendingPathComponent(filename)

        let srcURL = recorder.url
        let destURL = URL(fileURLWithPath: destPath)

        do {
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            handler(true, THMemo.memo(title: name, url: destURL))
            recorder.prepareToRecord()
        } catch {
            handler(false, error)
        }
    }

    private func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }

    func levels() -> THLevelPair {
        recorder.updateMeters()
        let avgPower = recorder.averagePower(forChannel: 0)
        let peakPower = recorder.peakPower(forChannel: 0)
        let linearLevel = meterTable.value(power: avgPower)
        let linearPeak = meterTable.value(power: peakPower)
        return THLevelPair.levels(level: linearLevel, peakLevel: linearPeak)
    }

    func playback(memo: THMemo) -> Bool {
        player?.stop()
        do {
            player = try AVAudioPlayer(contentsOf: memo.url)
            player.play()
            return true
        } catch {
            return false
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension THRecorderController: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully success: Bool) {
        if let handler = completionHandler {
            handler(success)
        }
    }

    // This method is now deprecated. You should use AVAudioSession notification handlers instead.
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        delegate?.interruptionBegan()
    }
}
