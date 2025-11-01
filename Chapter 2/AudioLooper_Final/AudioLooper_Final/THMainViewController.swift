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

class THMainViewController: UIViewController {

    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var rateKnob: THControlKnob!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet var panKnobs: [THControlKnob]!
    @IBOutlet var volumeKnobs: [THControlKnob]!

    var controller: THPlayerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        controller = THPlayerController()
        controller.delegate = self

        rateKnob.minimumValue = 0.5
        rateKnob.maximumValue = 1.5
        rateKnob.value = 1.0
        rateKnob.defaultValue = 1.0

        // Panning L = -1, C = 0, R = 1
        for knob in panKnobs {
            knob.minimumValue = -1.0
            knob.maximumValue = 1.0
            knob.value = 0.0
            knob.defaultValue = 0.0
        }

        // Volume Ranges from 0..1
        for knob in volumeKnobs {
            knob.minimumValue = 0.0
            knob.maximumValue = 1.0
            knob.value = 1.0
            knob.defaultValue = 1.0
        }
    }

    @IBAction func play(_ sender: UIButton) {
        if !controller.isPlaying {
            controller.play()
            playLabel.text = NSLocalizedString("Stop", comment: "")
        } else {
            controller.stop()
            playLabel.text = NSLocalizedString("Play", comment: "")
        }
        playButton.isSelected = !playButton.isSelected
    }

    @IBAction func adjustRate(_ sender: THControlKnob) {
        controller.adjustRate(sender.value)
    }

    @IBAction func adjustPan(_ sender: THControlKnob) {
        controller.adjustPan(sender.value, forPlayerAtIndex: sender.tag)
    }

    @IBAction func adjustVolume(_ sender: THControlKnob) {
        controller.adjustVolume(sender.value, forPlayerAtIndex: sender.tag)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - THPlayerControllerDelegate

extension THMainViewController: THPlayerControllerDelegate {

    func playbackStopped() {
        playButton.isSelected = false
        playLabel.text = NSLocalizedString("Play", comment: "")
    }

    func playbackBegan() {
        playButton.isSelected = true
        playLabel.text = NSLocalizedString("Stop", comment: "")
    }
}
