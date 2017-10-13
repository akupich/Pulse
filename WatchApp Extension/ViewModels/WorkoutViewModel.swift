//
//  WorkoutViewModel.swift
//  WatchApp Extension
//
//  Created by Andriy Kupich on 10/10/17.
//  Copyright © 2017 Remit. All rights reserved.
//

import HealthKit

class WorkoutViewModel: NSObject {
    
    private var session : HKWorkoutSession?
    private let healthStore = HKHealthStore()
    
    
    //State of the app - is the workout activated
    private var workoutActive = false
    var isActive:Bool {
        get {
            return workoutActive
        }
    }
    var heartRateQuery: HKQuery? {
        didSet {
            if let heartRateQuery = heartRateQuery {
                healthStore.execute(heartRateQuery)
            } else if let oldHeartRateQuery = oldValue {
                healthStore.stop(oldHeartRateQuery)
            }
        }
    }
    
    public var didStart: ((Date) -> ())?
    public var didEnd: ((Date) -> ())?
    
    override init() {
        super.init()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            print ("Health data is not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            print ("Health data is not available")
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) in
            if success == false {
                print ("Health data is not available")
            }
        }
    }
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        guard session == nil else {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .crossTraining
        workoutConfiguration.locationType = .indoor
        
        do {
            self.session = try HKWorkoutSession(configuration: workoutConfiguration)
            session?.delegate = self
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(session!)
    }
    
    func stopWorkout() {
        if let workoutSession = self.session {
            healthStore.end(workoutSession)
        }
        heartRateQuery = nil
    }
}

extension WorkoutViewModel: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        print("Workout error")
    }
    
    func workoutDidStart(_ date : Date) {
        workoutActive = true
        didStart?(date)
    }
    
    func workoutDidEnd(_ date : Date) {
        workoutActive = false
        didEnd?(date)
        session = nil
    }
}
