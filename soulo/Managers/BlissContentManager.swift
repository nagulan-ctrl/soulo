import Foundation
import SwiftUI
import Combine

class BlissContentManager: ObservableObject {
    @Published var currentReels: [BlissReel] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var userMood: UserMoodContext = UserMoodContext()
    
    init() {
        loadReels(for: .content)
    }
    
    func loadReels(for emotionalState: UserManager.EmotionalState) {
        isLoading = true
        // Simulated content loading based on emotional state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentReels = BlissReel.generateReels(for: emotionalState)
            self?.isLoading = false
        }
    }
    
    func refreshForMood(_ state: UserManager.EmotionalState) {
        loadReels(for: state)
    }
    
    var currentReel: BlissReel? {
        guard currentIndex < currentReels.count else { return nil }
        return currentReels[currentIndex]
    }
    
    func nextReel() {
        if currentIndex < currentReels.count - 1 {
            currentIndex += 1
        }
    }
    
    func likeCurrentReel() {
        guard currentIndex < currentReels.count else { return }
        currentReels[currentIndex].isLiked.toggle()
        if currentReels[currentIndex].isLiked {
            currentReels[currentIndex].likes += 1
        } else {
            currentReels[currentIndex].likes -= 1
        }
    }
    
    func saveCurrentReel() {
        guard currentIndex < currentReels.count else { return }
        currentReels[currentIndex].isSaved.toggle()
    }
}

struct UserMoodContext {
    var stressScore: Double = 0
    var emotionalState: UserManager.EmotionalState = .content
    var recentMoods: [Double] = [7, 8, 6, 7.5, 8]
    
    var averageMood: Double {
        recentMoods.isEmpty ? 5.0 : recentMoods.reduce(0, +) / Double(recentMoods.count)
    }
}

struct BlissReel: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var category: ReelCategory
    var gradientColors: [String]
    var icon: String
    var duration: String
    var creator: String
    var likes: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var affirmation: String
    var backgroundPattern: BackgroundPattern
    var moodTag: String
    
    enum ReelCategory: String {
        case breathingExercise = "Breathing"
        case meditation = "Meditation"
        case affirmation = "Affirmation"
        case nature = "Nature"
        case motivation = "Motivation"
        case gratitude = "Gratitude"
        case movement = "Movement"
        case music = "Music & Sound"
        case comedy = "Lighthearted"
        case wisdom = "Wisdom"
    }
    
    enum BackgroundPattern {
        case waves, bubbles, stars, leaves, geometric, aurora, gradient
    }
    
    static func generateReels(for state: UserManager.EmotionalState) -> [BlissReel] {
        switch state {
        case .joyful:
            return joyfulReels
        case .content:
            return contentReels
        case .neutral:
            return motivationalReels
        case .anxious:
            return calmingReels
        case .sad:
            return comfortingReels
        case .stressed:
            return relaxingReels
        }
    }
    
    static let calmingReels: [BlissReel] = [
        BlissReel(title: "4-7-8 Breathing", subtitle: "Release anxiety in 2 minutes", category: .breathingExercise, gradientColors: ["60A5FA", "A78BFA"], icon: "wind", duration: "2:00", creator: "Bliss Wellness", likes: 24821, affirmation: "With every breath, I release tension and invite calm.", backgroundPattern: .waves, moodTag: "Anxiety Relief"),
        BlissReel(title: "You Are Safe", subtitle: "Grounding affirmations", category: .affirmation, gradientColors: ["34D399", "60A5FA"], icon: "heart.fill", duration: "1:30", creator: "Inner Peace", likes: 18423, affirmation: "Right now, in this moment, I am safe and I am enough.", backgroundPattern: .leaves, moodTag: "Calming"),
        BlissReel(title: "Ocean Sounds", subtitle: "5 minutes of pure peace", category: .nature, gradientColors: ["0EA5E9", "6366F1"], icon: "water.waves", duration: "5:00", creator: "Nature Bliss", likes: 31205, affirmation: "Peace is always available to me.", backgroundPattern: .bubbles, moodTag: "Anxiety Relief"),
        BlissReel(title: "Box Breathing", subtitle: "Navy SEAL stress technique", category: .breathingExercise, gradientColors: ["8B5CF6", "EC4899"], icon: "square.fill", duration: "3:00", creator: "Calm Method", likes: 14202, affirmation: "I breathe in strength. I breathe out fear.", backgroundPattern: .geometric, moodTag: "Calming"),
        BlissReel(title: "5-4-3-2-1 Grounding", subtitle: "Anchor yourself to now", category: .meditation, gradientColors: ["F59E0B", "EF4444"], icon: "anchor.fill", duration: "2:30", creator: "Mindful Moments", likes: 22110, affirmation: "I am here. I am present. I am grounded.", backgroundPattern: .stars, moodTag: "Anxiety Relief")
    ]
    
    static let comfortingReels: [BlissReel] = [
        BlissReel(title: "You Are Not Alone", subtitle: "A gentle reminder", category: .affirmation, gradientColors: ["EC4899", "A78BFA"], icon: "heart.fill", duration: "2:00", creator: "Bliss Care", likes: 45210, affirmation: "Millions of hearts are healing alongside yours today.", backgroundPattern: .aurora, moodTag: "Comfort"),
        BlissReel(title: "Rain on Leaves", subtitle: "Healing nature sounds", category: .nature, gradientColors: ["34D399", "0EA5E9"], icon: "cloud.rain.fill", duration: "8:00", creator: "Nature Bliss", likes: 38901, affirmation: "This feeling, too, shall pass like clouds after rain.", backgroundPattern: .leaves, moodTag: "Comfort"),
        BlissReel(title: "Sadness is Wisdom", subtitle: "Reframing difficult emotions", category: .wisdom, gradientColors: ["6366F1", "8B5CF6"], icon: "lightbulb.fill", duration: "2:30", creator: "Soulful Thoughts", likes: 29340, affirmation: "My feelings are valid. I honor my heart's journey.", backgroundPattern: .stars, moodTag: "Healing"),
        BlissReel(title: "Morning Will Come", subtitle: "Hope for dark nights", category: .affirmation, gradientColors: ["F59E0B", "EC4899"], icon: "sunrise.fill", duration: "1:45", creator: "Hope Studio", likes: 52100, affirmation: "Every storm runs out of rain. Brighter days are coming.", backgroundPattern: .gradient, moodTag: "Hope"),
        BlissReel(title: "Gentle Body Scan", subtitle: "Comfort from within", category: .meditation, gradientColors: ["A78BFA", "60A5FA"], icon: "figure.stand", duration: "5:00", creator: "Inner Peace", likes: 19804, affirmation: "I send love to every part of my body and being.", backgroundPattern: .waves, moodTag: "Healing")
    ]
    
    static let relaxingReels: [BlissReel] = [
        BlissReel(title: "Progressive Relaxation", subtitle: "Release muscle tension", category: .meditation, gradientColors: ["34D399", "6366F1"], icon: "figure.mind.and.body", duration: "8:00", creator: "Bliss Wellness", likes: 33421, affirmation: "I allow every muscle to soften and release.", backgroundPattern: .waves, moodTag: "Stress Relief"),
        BlissReel(title: "Forest Bathing", subtitle: "Shinrin-yoku in audio", category: .nature, gradientColors: ["10B981", "34D399"], icon: "tree.fill", duration: "10:00", creator: "Nature Bliss", likes: 41023, affirmation: "Nature is my refuge and my reset button.", backgroundPattern: .leaves, moodTag: "Relaxation"),
        BlissReel(title: "Stress Is Temporary", subtitle: "Science-backed perspective", category: .wisdom, gradientColors: ["60A5FA", "A78BFA"], icon: "clock.fill", duration: "2:00", creator: "Mind Science", likes: 27108, affirmation: "This stress is not permanent. I am handling it.", backgroundPattern: .geometric, moodTag: "Stress Relief"),
        BlissReel(title: "Binaural Calm", subtitle: "432Hz healing frequency", category: .music, gradientColors: ["8B5CF6", "60A5FA"], icon: "music.note", duration: "15:00", creator: "Sound Therapy", likes: 58203, affirmation: "Sound and silence both bring me peace.", backgroundPattern: .aurora, moodTag: "Relaxation"),
        BlissReel(title: "5-Minute Yoga Flow", subtitle: "Desk stress stretches", category: .movement, gradientColors: ["F59E0B", "10B981"], icon: "figure.yoga", duration: "5:00", creator: "Bliss Move", likes: 36901, affirmation: "Movement is medicine. I take care of my body.", backgroundPattern: .gradient, moodTag: "Stress Relief")
    ]
    
    static let contentReels: [BlissReel] = [
        BlissReel(title: "Gratitude Practice", subtitle: "3 things that made you smile", category: .gratitude, gradientColors: ["F59E0B", "EC4899"], icon: "sun.max.fill", duration: "2:00", creator: "Gratitude Daily", likes: 41023, affirmation: "Gratitude turns what I have into more than enough.", backgroundPattern: .aurora, moodTag: "Gratitude"),
        BlissReel(title: "Mindful Morning", subtitle: "Start the day with intention", category: .meditation, gradientColors: ["60A5FA", "34D399"], icon: "sunrise.fill", duration: "5:00", creator: "Bliss Wellness", likes: 28304, affirmation: "Today I choose presence, peace, and purpose.", backgroundPattern: .waves, moodTag: "Mindfulness"),
        BlissReel(title: "Joy in Small Things", subtitle: "Finding everyday wonder", category: .wisdom, gradientColors: ["A78BFA", "EC4899"], icon: "sparkles", duration: "1:30", creator: "Simple Living", likes: 22109, affirmation: "Magic exists in ordinary moments.", backgroundPattern: .stars, moodTag: "Joy"),
        BlissReel(title: "Sunset Meditation", subtitle: "End the day beautifully", category: .nature, gradientColors: ["F97316", "EC4899"], icon: "sunset.fill", duration: "7:00", creator: "Nature Bliss", likes: 35621, affirmation: "I release the day with grace and welcome rest.", backgroundPattern: .gradient, moodTag: "Peace"),
        BlissReel(title: "You're Doing Great", subtitle: "A gentle pat on the back", category: .affirmation, gradientColors: ["34D399", "60A5FA"], icon: "hand.thumbsup.fill", duration: "1:00", creator: "Bliss Daily", likes: 67104, affirmation: "I am proud of how far I have come.", backgroundPattern: .bubbles, moodTag: "Self-Love")
    ]
    
    static let joyfulReels: [BlissReel] = [
        BlissReel(title: "Dance Break! 💃", subtitle: "3 minutes of pure fun", category: .movement, gradientColors: ["EC4899", "F59E0B"], icon: "figure.dance", duration: "3:00", creator: "Joy Movement", likes: 89204, affirmation: "My joy is contagious and I share it freely!", backgroundPattern: .aurora, moodTag: "Energy"),
        BlissReel(title: "Laughter Yoga", subtitle: "Laugh for no reason at all", category: .comedy, gradientColors: ["FBBF24", "F97316"], icon: "face.smiling.fill", duration: "4:00", creator: "Laugh Life", likes: 56021, affirmation: "Laughter is my superpower!", backgroundPattern: .bubbles, moodTag: "Joy"),
        BlissReel(title: "Uplift Someone Today", subtitle: "Spread joy like confetti", category: .gratitude, gradientColors: ["34D399", "60A5FA"], icon: "gift.fill", duration: "1:30", creator: "Kindness Lab", likes: 43219, affirmation: "The more joy I give, the more I receive.", backgroundPattern: .stars, moodTag: "Connection"),
        BlissReel(title: "Power Affirmations", subtitle: "Own the day!", category: .affirmation, gradientColors: ["8B5CF6", "EC4899"], icon: "bolt.fill", duration: "2:00", creator: "Bliss Power", likes: 71308, affirmation: "I am magnetic, powerful, and full of potential!", backgroundPattern: .geometric, moodTag: "Motivation"),
        BlissReel(title: "Nature Wonders", subtitle: "Earth's beautiful surprises", category: .nature, gradientColors: ["10B981", "60A5FA"], icon: "leaf.fill", duration: "3:30", creator: "World Beauty", likes: 38104, affirmation: "I am part of something beautiful and vast.", backgroundPattern: .leaves, moodTag: "Wonder")
    ]
    
    static let motivationalReels: [BlissReel] = [
        BlissReel(title: "1% Better Daily", subtitle: "The compound effect of growth", category: .motivation, gradientColors: ["6366F1", "A78BFA"], icon: "chart.line.uptrend.xyaxis", duration: "2:00", creator: "Growth Lab", likes: 44302, affirmation: "Small steps consistently taken lead to giant leaps.", backgroundPattern: .geometric, moodTag: "Growth"),
        BlissReel(title: "Atomic Habits Tip", subtitle: "Change your environment", category: .wisdom, gradientColors: ["F59E0B", "EF4444"], icon: "atom", duration: "1:45", creator: "Habit Science", likes: 38201, affirmation: "I design my environment for success.", backgroundPattern: .stars, moodTag: "Productivity"),
        BlissReel(title: "Purpose Walk", subtitle: "Walk with intention today", category: .movement, gradientColors: ["34D399", "0EA5E9"], icon: "figure.walk", duration: "3:00", creator: "Mindful Motion", likes: 21904, affirmation: "Each step I take moves me toward my purpose.", backgroundPattern: .leaves, moodTag: "Momentum"),
        BlissReel(title: "Morning Cold Exposure", subtitle: "2-minute ice challenge", category: .motivation, gradientColors: ["0EA5E9", "6366F1"], icon: "snowflake", duration: "2:00", creator: "Ice Lab", likes: 52109, affirmation: "Discomfort is the price of growth — I pay it gladly.", backgroundPattern: .waves, moodTag: "Resilience"),
        BlissReel(title: "Ikigai", subtitle: "Find your reason to wake up", category: .wisdom, gradientColors: ["EC4899", "F59E0B"], icon: "circle.grid.cross.fill", duration: "3:00", creator: "Life Design", likes: 63021, affirmation: "My unique gifts have a purpose in this world.", backgroundPattern: .aurora, moodTag: "Purpose")
    ]
}
