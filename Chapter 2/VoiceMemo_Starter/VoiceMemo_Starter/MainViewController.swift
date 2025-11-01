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

private let CANCEL_BUTTON = 0
private let OK_BUTTON = 1

private let MEMO_CELL = "memoCell"
private let MEMOS_ARCHIVE = "memos.archive"

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var levelMeterView: THLevelMeterView!

    private var memos: [THMemo] = []
    private var levelTimer: CADisplayLink?
    private var timer: Timer?
    private var controller: THRecorderController!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        controller = THRecorderController()
        controller.delegate = self
        memos = []
        stopButton.isEnabled = false

        let recordImage = UIImage(named: "record")?.withRenderingMode(.alwaysOriginal)
        let pauseImage = UIImage(named: "pause")?.withRenderingMode(.alwaysOriginal)
        let stopImage = UIImage(named: "stop")?.withRenderingMode(.alwaysOriginal)

        recordButton.setImage(recordImage, for: .normal)
        recordButton.setImage(pauseImage, for: .selected)
        stopButton.setImage(stopImage, for: .normal)

        if let data = try? Data(contentsOf: archiveURL()) {
            if let unarchivedMemos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [THMemo] {
                memos = unarchivedMemos
            }
        }
    }

    // MARK: - Recorder Control

    @IBAction func record(_ sender: UIButton) {
        stopButton.isEnabled = true
        if !sender.isSelected {
            startMeterTimer()
            startTimer()
            controller.record()
        } else {
            stopMeterTimer()
            stopTimer()
            controller.pause()
        }
        sender.isSelected = !sender.isSelected
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateTimeDisplay),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func updateTimeDisplay() {
        timeLabel.text = controller.formattedCurrentTime
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @IBAction func stopRecording(_ sender: Any) {
        stopMeterTimer()
        recordButton.isSelected = false
        stopButton.isEnabled = false
        controller.stop { [weak self] result in
            let delayInSeconds = 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                self?.showSaveDialog()
            }
        }
    }

    private func showSaveDialog() {
        let alertController = UIAlertController(
            title: "Save Recording",
            message: "Please provide a name",
            preferredStyle: .alert
        )

        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("My Recording", comment: "Login")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let self = self,
                  let filename = alertController.textFields?.first?.text else { return }

            self.controller.saveRecording(withName: filename) { success, object in
                if success, let memo = object as? THMemo {
                    self.memos.append(memo)
                    self.saveMemos()
                    self.tableView.reloadData()
                } else if let error = object as? Error {
                    print("Error saving file: \(error.localizedDescription)")
                }
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Memo Archiving

    private func saveMemos() {
        if let fileData = try? NSKeyedArchiver.archivedData(withRootObject: memos, requiringSecureCoding: false) {
            try? fileData.write(to: archiveURL())
        }
    }

    private func archiveURL() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = paths[0]
        let archivePath = (docsDir as NSString).appendingPathComponent(MEMOS_ARCHIVE)
        return URL(fileURLWithPath: archivePath)
    }

    // MARK: - Level Metering

    private func startMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        levelTimer?.preferredFramesPerSecond = 12
        levelTimer?.add(to: .current, forMode: .default)
    }

    private func stopMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        levelMeterView.resetLevelMeter()
    }

    @objc private func updateMeter() {
        let levels = controller.levels()
        levelMeterView.level = CGFloat(levels.level)
        levelMeterView.peakLevel = CGFloat(levels.peakLevel)
        levelMeterView.setNeedsDisplay()
    }
}

// MARK: - THRecorderControllerDelegate

extension MainViewController: THRecorderControllerDelegate {
    func interruptionBegan() {
        recordButton.isSelected = false
        stopMeterTimer()
        stopTimer()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MEMO_CELL, for: indexPath) as! THMemoCell
        let memo = memos[indexPath.row]
        cell.titleLabel.text = memo.title
        cell.dateLabel.text = memo.dateString
        cell.timeLabel.text = memo.timeString
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        controller.playback(memo: memo)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memo = memos[indexPath.row]
            memo.deleteMemo()
            memos.remove(at: indexPath.row)
            saveMemos()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
