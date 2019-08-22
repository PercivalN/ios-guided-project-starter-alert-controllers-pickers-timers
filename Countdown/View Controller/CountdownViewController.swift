//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var resetButton: UIButton!
	@IBOutlet weak var countdownPicker: UIPickerView!
    
    // MARK: - Properties
    
	// Lazy property is not initialized until it is accessed. The code will not run until the property is run
	lazy private var countdownPickerData: [[String]] = {
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
		// This initialize an array from 0 to 60; map is used to map each integer in the array to be a string. $0 is the placeholder for the current value.
		let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
		// this is a 2 dimensional array, which means that each element of the array is itself an array
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()

	// Date formatter
	var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss:SS"
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		return formatter
	// The things inside the curly brace is initialized
	}()

	private var duration: TimeInterval {
		// Convert from minutes + seconds to total seconds
		let minuteString = countdownPicker.selectedRow(inComponent: 0)
		let secondString = countdownPicker.selectedRow(inComponent: 2)

		let minutes = Int(minuteString)
		let seconds = Int(secondString)

		let totalSeconds = TimeInterval(minutes * 60 + seconds)
		return totalSeconds
	}

	// Think of this as a model controller
	private let countdown = Countdown()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

		// It is very important what order the viewDidLoad statements are in

		// This sets up the dataSource and delegate for the countdownPicker
		countdownPicker.dataSource = self
		countdownPicker.delegate = self

		countdownPicker.selectRow(1, inComponent: 0, animated: false)
		countdownPicker.selectRow(30, inComponent: 2, animated: false)

		countdown.delegate = self
		countdown.duration = duration

		// This changes the fonts to monospace
		timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .medium)

		startButton.layer.cornerRadius = 4.0
		resetButton.layer.cornerRadius = 4.0

		updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
		countdown.start()
	}
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
		updateViews()
    }
    
    // MARK: - Privateb

	// Step 1 - Shows an alert message.
    private func showAlert() {
        let alert = UIAlertController(title: "Timer Finished", message: "Your countdown is over.", preferredStyle: .actionSheet)
		// The handler is for specifying an action.
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		// nil means the completion shouldn't do anything.
		present(alert, animated: true, completion: nil)
    }
    
    private func updateViews() {
		startButton.isEnabled = true

		switch countdown.state {
		case .started:
			timeLabel.text = convertToString(from: countdown.timeRemaining)
			startButton.isEnabled = false
		case .finished:
			timeLabel.text = convertToString(from: 0)
		case .reset:
			timeLabel.text = convertToString(from: countdown.duration)
		}
    }
    
    private func timerFinished(_ timer: Timer) {

    }
    
    private func convertToString(from duration: TimeInterval) -> String {
		// this as a message to self
        // #warning("return a string value derived from the time interval passed in")
		let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }
}

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
		updateViews()
    }
    
    func countdownDidFinish() {
		updateViews()
        showAlert()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
	// The component is the spinner of a picker view and works the same way as a tableView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return countdownPickerData.count
    }

	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		return 50
	}
    // This is the number of rows for each component/spinner
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

		#warning("what does the brackets mean")
		return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let timeValue = countdownPickerData[component][row]
		return timeValue
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		countdown.duration = duration
		updateViews()
	}
}
