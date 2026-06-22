import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var stepCount: Int = 0
    @Published var stepGoal: Int = 10000
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0 // Heart Rate Variability for stress
    @Published var stressLevel: StressLevel = .calm
    @Published var stressScore: Double = 0 // 0-100
    @Published var isAuthorized: Bool = false
    @Published var activeCaloriesBurned: Double = 0
    
    // Refresh timer
    private var refreshTimer: Timer?
    
    enum StressLevel {
        case calm, low, moderate, high, veryHigh
        
        var label: String {
            switch self {
            case .calm: return "Calm"
            case .low: return "Relaxed"
            case .moderate: return "Moderate"
            case .high: return "Elevated"
            case .veryHigh: return "High Stress"
            }
        }
        
        var color: String {
            switch self {
            case .calm: return "34D399"
            case .low: return "6EE7B7"
            case .moderate: return "FBBF24"
            case .high: return "F97316"
            case .veryHigh: return "EF4444"
            }
        }
        
        var emoji: String {
            switch self {
            case .calm: return "😌"
            case .low: return "🙂"
            case .moderate: return "😐"
            case .high: return "😰"
            case .veryHigh: return "😫"
            }
        }
        
        var advice: String {
            switch self {
            case .calm: return "You're in a great state. Keep it up!"
            case .low: return "Feeling good! A short walk would maintain this."
            case .moderate: return "Take a 5-minute breathing break."
            case .high: return "Consider stepping away and resting soon."
            case .veryHigh: return "Please rest now. Your body needs recovery."
            }
        }
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            // Simulator fallback
            loadMockData()
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchAllData()
                    self?.startRefreshTimer()
                } else {
                    self?.loadMockData()
                }
            }
        }
    }
    
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchAllData()
        }
    }
    
    func fetchAllData() {
        fetchStepCount()
        fetchHeartRate()
        fetchHRV()
        fetchActiveCalories()
    }
    
    // MARK: - Step Count
    func fetchStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            DispatchQueue.main.async {
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                self?.stepCount = Int(steps)
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Heart Rate
    func fetchHeartRate() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            DispatchQueue.main.async {
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self?.heartRate = bpm
                self?.calculateStress()
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - HRV (Heart Rate Variability)
    func fetchHRV() {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 5, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else { return }
            let avgHRV = samples.map { $0.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) }.reduce(0, +) / Double(samples.count)
            DispatchQueue.main.async {
                self?.hrv = avgHRV
                self?.calculateStress()
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Active Calories
    func fetchActiveCalories() {
        guard let calType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            DispatchQueue.main.async {
                let cals = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                self?.activeCaloriesBurned = cals
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Stress Calculation
    // Stress is calculated using HRV (lower HRV = more stress) and HR (higher HR = more stress)
    private func calculateStress() {
        var score: Double = 50 // baseline
        
        // HRV contribution (0-100ms range typical; higher = less stress)
        if hrv > 0 {
            let hrvScore = min(hrv / 60.0, 1.0) // normalize 0-60ms to 0-1
            score -= (hrvScore * 30) // reduce stress score with good HRV
        }
        
        // Heart rate contribution (60-100 bpm normal)
        if heartRate > 0 {
            let hrScore = (heartRate - 60) / 40 // normalize excess above 60 bpm
            score += min(hrScore * 20, 30)
        }
        
        score = max(0, min(100, score))
        
        DispatchQueue.main.async {
            self.stressScore = score
            switch score {
            case 0..<20: self.stressLevel = .calm
            case 20..<40: self.stressLevel = .low
            case 40..<60: self.stressLevel = .moderate
            case 60..<80: self.stressLevel = .high
            default: self.stressLevel = .veryHigh
            }
        }
    }
    
    // MARK: - Mock Data for Simulator
    func loadMockData() {
        stepCount = 6842
        heartRate = 72
        hrv = 38
        stressScore = 35
        stressLevel = .low
        activeCaloriesBurned = 312
        calculateStress()
    }
}
