//
//  HeartRateViewModel.swift
//  WatchApp Extension
//
//  Created by Andriy Kupich on 10/11/17.
//  Copyright © 2017 Remit. All rights reserved.
//

import HealthKit

class HeartRateAnalyzer {
    
    var currentQuery: HKQuery?
    let heartRateUnit = HKUnit(from: "count/min")
    var didUpdate: ((Double, String)->())?
    
    init?(date:Date) {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: date, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { [weak self] (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self?.heartRateDidUpdate(sampleObjects)
        }
        heartRateQuery.updateHandler = { [weak self] (query, samples, deleteObjects, newAnchor, error) -> Void in
            self?.heartRateDidUpdate(samples)
        }
        currentQuery = heartRateQuery
    }
    
    private func heartRateDidUpdate (_ samples:[HKSample]?) {
        guard
            let heartRateSamples = samples as? [HKQuantitySample],
            let sample = heartRateSamples.first
            else {
                return
        }
        let value = sample.quantity.doubleValue(for: heartRateUnit)
        let deviceName = sample.sourceRevision.source.name
        didUpdate?(value, deviceName)
    }
}
