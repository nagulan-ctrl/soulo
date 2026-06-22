import Foundation
import SwiftUI
import Combine

class UserManager: ObservableObject {
    @Published var user: BlissUser = BlissUser.mock
    @Published var moodHistory: [MoodEntry] = MoodEntry.mockHistory
    @Published var connectedDevices: [ConnectedDevice] = ConnectedDevice.mockDevices
    @Published var weeklySteps: [DaySteps] = DaySteps.mockWeek
    @Published var emotionalState: EmotionalState = .content

    // Period tracking data — only used when user.gender == .female
    @Published var periodData: PeriodData = PeriodData()

    // Settings
    @Published var settings: AppSettings = AppSettings()

    enum EmotionalState: String, CaseIterable {
        case joyful = "Joyful"
        case content = "Content"
        case neutral = "Neutral"
        case anxious = "Anxious"
        case sad = "Sad"
        case stressed = "Stressed"

        var emoji: String {
            switch self {
            case .joyful:  return "😄"
            case .content: return "😊"
            case .neutral: return "😐"
            case .anxious: return "😰"
            case .sad:     return "😢"
            case .stressed:return "😤"
            }
        }

        var reelTheme: String {
            switch self {
            case .joyful:  return "Uplifting & Fun"
            case .content: return "Peaceful & Inspiring"
            case .neutral: return "Motivational"
            case .anxious: return "Calming & Reassuring"
            case .sad:     return "Comforting & Hopeful"
            case .stressed:return "Relaxing & Mindful"
            }
        }
    }
}

// MARK: - Gender
enum Gender: String, CaseIterable {
    case male   = "Male"
    case female = "Female"
    case other  = "Prefer not to say"

    var icon: String {
        switch self {
        case .male:   return "person.fill"
        case .female: return "person.fill"
        case .other:  return "person.fill"
        }
    }
}

// MARK: - BlissUser
struct BlissUser: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var username: String
    var avatarColor: String
    var avatarInitials: String
    var age: Int
    var height: Double
    var weight: Double
    var gender: Gender = .female
    var dailyStepGoal: Int
    var dailyCalorieGoal: Int
    var joinDate: Date
    var streakDays: Int
    var blissPoints: Int
    var emergencyContact: String = ""
    var emergencyPhone: String   = ""

    var bmi: Double {
        let h = height / 100
        return weight / (h * h)
    }

    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Healthy"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    static let mock = BlissUser(
        name: "Nagulan vijayakumar",
        username: "@Nan_lan",
        avatarColor: "A78BFA",
        avatarInitials: "NV",
        age: 28,
        height: 175,
        weight: 65,
        gender: .male,
        dailyStepGoal: 10000,
        dailyCalorieGoal: 2000,
        joinDate: Date().addingTimeInterval(-60 * 86400),
        streakDays: 14,
        blissPoints: 2840,
        emergencyContact: "Sarah",
        emergencyPhone: "+1 555 000 1234"
    )
}

// MARK: - Period Data
struct PeriodData {
    var lastPeriodStartDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    var cycleLength: Int  = 28   // days
    var periodLength: Int = 5    // days
    var isPregnancyMode: Bool = false
    var conceptionDate: Date? = nil
    var periodHistory: [PeriodEntry] = PeriodEntry.mockHistory

    // MARK: Computed dates
    var nextPeriodDate: Date {
        Calendar.current.date(byAdding: .day, value: cycleLength, to: lastPeriodStartDate) ?? Date()
    }

    var ovulationDate: Date {
        // Ovulation typically occurs 14 days before next period
        Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: lastPeriodStartDate) ?? Date()
    }

    var fertileWindowStart: Date {
        Calendar.current.date(byAdding: .day, value: -2, to: ovulationDate) ?? Date()
    }

    var fertileWindowEnd: Date {
        Calendar.current.date(byAdding: .day, value: 2, to: ovulationDate) ?? Date()
    }

    var daysUntilNextPeriod: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: nextPeriodDate).day ?? 0
        return max(0, days)
    }

    var currentCycleDay: Int {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodStartDate, to: Date()).day ?? 0
        return (days % cycleLength) + 1
    }

    var currentPhase: CyclePhase {
        let day = currentCycleDay
        let ovDay = cycleLength - 14
        switch day {
        case 1...periodLength:              return .menstrual
        case (periodLength+1)...(ovDay-3): return .follicular
        case (ovDay-2)...(ovDay+2):        return .ovulation
        default:                            return .luteal
        }
    }

    // Pregnancy week if in pregnancy mode
    var pregnancyWeek: Int? {
        guard isPregnancyMode, let conception = conceptionDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: conception, to: Date()).day ?? 0
        return (days / 7) + 1
    }

    var estimatedDueDate: Date? {
        guard isPregnancyMode, let conception = conceptionDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: 280, to: conception)
    }

    enum CyclePhase: String {
        case menstrual  = "Menstrual"
        case follicular = "Follicular"
        case ovulation  = "Ovulation"
        case luteal     = "Luteal"

        var color: String {
            switch self {
            case .menstrual:  return "EF4444"
            case .follicular: return "F59E0B"
            case .ovulation:  return "34D399"
            case .luteal:     return "A78BFA"
            }
        }

        var description: String {
            switch self {
            case .menstrual:
                return "Your period is here. Rest, hydrate and be gentle with yourself."
            case .follicular:
                return "Energy rising! Great time to start new goals and exercise."
            case .ovulation:
                return "Peak fertility window. You may feel your most confident today."
            case .luteal:
                return "Wind-down phase. Focus on self-care and calming activities."
            }
        }

        var icon: String {
            switch self {
            case .menstrual:  return "drop.fill"
            case .follicular: return "leaf.fill"
            case .ovulation:  return "sparkles"
            case .luteal:     return "moon.fill"
            }
        }
    }
}

struct PeriodEntry: Identifiable {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var symptoms: [String]
    var flow: FlowLevel

    enum FlowLevel: String, CaseIterable {
        case light = "Light", medium = "Medium", heavy = "Heavy"
    }

    static let mockHistory: [PeriodEntry] = [
        PeriodEntry(startDate: Date().addingTimeInterval(-56*86400), endDate: Date().addingTimeInterval(-51*86400), symptoms: ["Cramps", "Fatigue"], flow: .medium),
        PeriodEntry(startDate: Date().addingTimeInterval(-28*86400), endDate: Date().addingTimeInterval(-23*86400), symptoms: ["Bloating"], flow: .light),
        PeriodEntry(startDate: Date().addingTimeInterval(-14*86400), endDate: Date().addingTimeInterval(-9*86400),  symptoms: ["Cramps", "Headache"], flow: .heavy)
    ]
}

// MARK: - App Settings
struct AppSettings {
    var notificationsEnabled: Bool    = true
    var periodReminders: Bool         = true
    var sosEnabled: Bool              = true
    var heartRateAlerts: Bool         = true
    var heartRateThreshold: Double    = 120  // bpm — alert above this
    var hrvLowThreshold: Double       = 20   // ms — alert below this
    var darkMode: Bool                = true
    var hapticFeedback: Bool          = true
    var dailyCheckInReminder: Bool    = true
    var checkInTime: Date             = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    var units: UnitSystem             = .metric
    var language: String              = "English"
    var dataSharing: Bool             = false
    var biometricLock: Bool           = false

    enum UnitSystem: String, CaseIterable {
        case metric   = "Metric (kg, cm)"
        case imperial = "Imperial (lbs, ft)"
    }
}

// MARK: - Supporting models (unchanged)
struct MoodEntry: Identifiable {
    var id = UUID()
    var date: Date
    var mood: String
    var score: Double

    static let mockHistory: [MoodEntry] = [
        MoodEntry(date: Date().addingTimeInterval(-6*86400), mood: "😔", score: 5),
        MoodEntry(date: Date().addingTimeInterval(-5*86400), mood: "😐", score: 6),
        MoodEntry(date: Date().addingTimeInterval(-4*86400), mood: "🙂", score: 7),
        MoodEntry(date: Date().addingTimeInterval(-3*86400), mood: "😊", score: 7.5),
        MoodEntry(date: Date().addingTimeInterval(-2*86400), mood: "😄", score: 8.5),
        MoodEntry(date: Date().addingTimeInterval(-1*86400), mood: "🙂", score: 7),
        MoodEntry(date: Date(),                              mood: "😊", score: 8)
    ]
}

struct ConnectedDevice: Identifiable {
    var id = UUID()
    var name: String
    var type: DeviceType
    var isConnected: Bool
    var battery: Int
    var lastSync: Date

    enum DeviceType: String {
        case appleWatch = "applewatch"
        case fitbit     = "Fitbit"
        case garmin     = "Garmin"
        case iPhone     = "iphone"
    }

    static let mockDevices: [ConnectedDevice] = [
        ConnectedDevice(name: "Apple Watch Series 9", type: .appleWatch, isConnected: true, battery: 72, lastSync: Date().addingTimeInterval(-300)),
        ConnectedDevice(name: "iPhone 16 Pro",        type: .iPhone,     isConnected: true, battery: 89, lastSync: Date())
    ]
}

struct DaySteps: Identifiable {
    var id = UUID()
    var day: String
    var steps: Int
    var goal: Int

    var progress: Double { Double(steps) / Double(goal) }

    static let mockWeek: [DaySteps] = [
        DaySteps(day: "Mon", steps: 8200,  goal: 10000),
        DaySteps(day: "Tue", steps: 11500, goal: 10000),
        DaySteps(day: "Wed", steps: 6800,  goal: 10000),
        DaySteps(day: "Thu", steps: 9200,  goal: 10000),
        DaySteps(day: "Fri", steps: 10400, goal: 10000),
        DaySteps(day: "Sat", steps: 7600,  goal: 10000),
        DaySteps(day: "Sun", steps: 6842,  goal: 10000)
    ]
}
