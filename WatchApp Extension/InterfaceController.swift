//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by Andriy Kupich on 10/5/17.
//  Copyright © 2017 Remit. All rights reserved.
//

import WatchKit

class InterfaceController: WKInterfaceController {

    @IBOutlet private weak var rateLabel: WKInterfaceLabel!
    @IBOutlet private weak var watchNameLabel : WKInterfaceLabel!
    @IBOutlet private weak var heart: WKInterfaceImage!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!
    
    var workoutVM: WorkoutViewModel?
    var heartVM: HeartRateAnalyzer?
    let conectivityClient = ConnectivityManager ()
    
    override func willActivate() {
        super.willActivate()
        
        setupWorkoutSession()
    }
    
    func setupWorkoutSession () {
        workoutVM = WorkoutViewModel()
        workoutVM?.didStart = { [weak self] date in
            self?.setupHeartRateStreaming(with: date)
        }
        workoutVM?.didEnd = { [weak self] date in
            DispatchQueue.main.async { [weak self] in
                self?.rateLabel.setText("---")
            }
        }
    }
    
    func setupHeartRateStreaming (with date:Date) {
        if let heartVM = HeartRateAnalyzer(date: date) {
            heartVM.didUpdate = { [weak self] (heartRate, device) in
                DispatchQueue.main.async { [weak self] in
                    self?.updated(with: heartRate, from: device)
                }
            }
            self.heartVM = heartVM
            self.workoutVM?.heartRateQuery = heartVM.currentQuery
        } else {
            print ("HeartRateStreaming error")
            workoutVM?.stopWorkout()
        }
    }
    
    func updated(with heartRateValue: Double, from deviceName:String) {
        if heartRateValue > Constants.kHeartRateAccessValue {
            startClick()
            return
        }
        
        conectivityClient.sendInfo(heartRateValue, for: Constants.kHeartRateKey)
        rateLabel.setText(String(UInt16(heartRateValue)))
        watchNameLabel.setText(deviceName)
        animateHeart()
    }
    
    // MARK: - Actions
    @IBAction func startClick() {
        if let workout = workoutVM, workout.isActive {
            //finish the current workout
            workoutVM?.stopWorkout()
            heartVM = nil
            self.startStopButton.setTitle("Start")
        } else {
            workoutVM?.startWorkout()
            self.startStopButton.setTitle("Stop")
        }
    }
}

// MARK: UI
extension InterfaceController {
    func animateHeart() {
        self.animate(withDuration: 0.5) { [weak self] in
            self?.heart.setWidth(48)
            self?.heart.setHeight(43)
        }
        
        let when = DispatchTime.now() + Double(Int64(0.5 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: when) {
                self?.animate(withDuration: 0.5, animations: {
                    self?.heart.setWidth(38)
                    self?.heart.setHeight(33)
                })
            }
        }
    }
}
