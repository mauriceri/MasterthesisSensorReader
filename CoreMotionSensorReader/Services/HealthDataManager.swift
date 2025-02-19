//
//  HealtDataManager.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 10.07.24.
//

import Foundation
import HealthKit
import WidgetKit

@Observable
class HealthDataManager {
    static let shared = HealthDataManager()
    
    private var healthStore = HKHealthStore()
    
    var stepCountToday: Int = 0
    var restingHearthRate: Int = 0
    var caloriesBurnedToday: Int = 0
    var walkingDistance: Double = 0
    
    var thisWeekSteps: [Int: Int] = [1: 0, 2: 0, 3: 0,
                                     4: 0, 5: 0, 6: 0, 7: 0]
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        /*
        let toReads = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        ])
         */
        
        let toReads = Set([
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        ])
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("health data not available!")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: toReads) {
            success, error in
            if success {
                self.fetchAllData()
            } else {
                print("\(String(describing: error))")
            }
        }
    }
    
    
    func fetchAllData() {
        readStepCountToday()
        readRestingHearthRate()
        readCalorieCountToday()
        readDistanceWalkingRunningToday()
    }
    
    func readStepCountToday() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        
        let now = Date()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let startDate = calendar.date(from: components)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        print("attempting to get step count from \(startDate)")
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            print("Fetched your steps today: \(steps)")
            
            
            
            DispatchQueue.main.async {
                self.stepCountToday = steps // Update on the main thread
            }
        }
        healthStore.execute(query)
    }
    
    func readRestingHearthRate() {
        guard let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: restingHeartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { query, results, error in
            guard let results = results else {
                print("Failed to read resting heart rate: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            
            var averageHeartRateBPM: Int = 0
            for sample in results {
                guard let quantitySample = sample as? HKQuantitySample else { continue }
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                averageHeartRateBPM += Int(quantitySample.quantity.doubleValue(for: heartRateUnit))
            }
            
            if results.count > 0 {
                averageHeartRateBPM /= results.count
            }
            
            print("Fetched your resting heart rate: \(averageHeartRateBPM) BPM")
            
            DispatchQueue.main.async {
                self.restingHearthRate = averageHeartRateBPM // Update on the main thread
            }
        }
        
        healthStore.execute(query)
    }
    
    func readCalorieCountToday() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        print("attempting to get calories burned from \(startDate)")
        
        let query = HKSampleQuery(sampleType: calorieType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
            guard let samples = results as? [HKQuantitySample] else {
                print("No calorie burn samples found.")
                return
            }
            
            // Retrieve the total calories burned for today
            let totalCalories = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            
            // Process the total calories burned
            print("Total calories burned today: \(totalCalories) kcal")
            
            DispatchQueue.main.async {
                self.caloriesBurnedToday = Int(totalCalories)
            }
        }
        
        healthStore.execute(query)
    }
    
    func readDistanceWalkingRunningToday() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print("Distance walking or running data is not available.")
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to read distance walking or running: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let distanceInMeters = sum.doubleValue(for: HKUnit.meter())
            print("Walking distance: \(distanceInMeters)")
            DispatchQueue.main.async {
                self.walkingDistance = distanceInMeters
            }
            
        }
        
        healthStore.execute(query)
    }
}
