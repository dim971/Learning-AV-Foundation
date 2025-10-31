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

class THPlayerController: NSObject {
    var isPlaying: Bool = false
    weak var delegate: THPlayerControllerDelegate?

    private var players: [AVAudioPlayer] = []

    // MARK: - Initialization

    override init() {
        super.init()

        guard let guitarPlayer = playerForFile("guitar"),
              let bassPlayer = playerForFile("bass"),
              let drumsPlayer = playerForFile("drums") else {
            return
        }

        guitarPlayer.delegate = self

        players = [guitarPlayer, bassPlayer, drumsPlayer]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    private func playerForFile(_ name: String) -> AVAudioPlayer? {
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: "caf") else {
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.numberOfLoops = -1 // loop indefinitely
            player.enableRate = true
            player.prepareToPlay()
            return player
        } catch {
            print("Error creating player: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Global playback control methods

    func play() {
        if !isPlaying {
            let delayTime = players[0].deviceCurrentTime + 0.01
            for player in players {
                player.play(atTime: delayTime)
            }
            isPlaying = true
        }
    }

    func stop() {
        if isPlaying {
            for player in players {
                player.stop()
                player.currentTime = 0.0
            }
            isPlaying = false
        }
    }

    func adjustRate(_ rate: Float) {
        for player in players {
            player.rate = rate
        }
    }

    // MARK: - Player-specific methods

    func adjustPan(_ pan: Float, forPlayerAtIndex index: Int) {
        if isValidIndex(index) {
            let player = players[index]
            player.pan = pan
        }
    }

    func adjustVolume(_ volume: Float, forPlayerAtIndex index: Int) {
        if isValidIndex(index) {
            let player = players[index]
            player.volume = volume
        }
    }

    private func isValidIndex(_ index: Int) -> Bool {
        return index == 0 || index < players.count
    }

    // MARK: - Route Change Handler

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        if reason == .oldDeviceUnavailable {
            guard let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
                  let previousOutput = previousRoute.outputs.first else {
                return
            }

            let portType = previousOutput.portType

            if portType == .headphones {
                stop()
                delegate?.playbackStopped()
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension THPlayerController: AVAudioPlayerDelegate {
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        stop()
        delegate?.playbackStopped()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        if flags == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
            play()
            delegate?.playbackBegan()
        }
    }
}
