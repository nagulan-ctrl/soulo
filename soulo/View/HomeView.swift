//
//  HomeView.swift
//  bliss
//
//  Created by Nagulan Vijayakumar on 21/06/26.
//

import SwiftUI

struct HomeView: View {
    var onOpenProfile: () -> Void = {}

    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var userManager: UserManager
    @State private var showCalorieScan = false
    @State private var greeting = ""
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                        .padding(.top, 60)
                    
                    // Steps Card
                    StepsCard()
                        .padding(.horizontal, 20)
                    
                    // Calories Card
                    CaloriesCard(showScan: $showCalorieScan)
                        .padding(.horizontal, 20)
                    
                    // Stress Monitor
                    StressMonitorCard()
                        .padding(.horizontal, 20)
                    
                    // Daily Insight
                    DailyInsightCard()
                        .padding(.horizontal, 20)
                    
                    // Bottom padding for tab bar
                    Spacer().frame(height: 100)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showCalorieScan) {
            CalorieScannerView()
        }
        .onAppear {
            setGreeting()
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(userManager.user.name.components(separatedBy: " ").first ?? "Friend")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color(hex: "F97316"))
                        .font(.system(size: 12))
                    Text("\(userManager.user.streakDays) day streak")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "F97316"))
                }
            }
            
            Spacer()
            
            Button(action: onOpenProfile) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(hex: "A78BFA").opacity(0.5), radius: 10)
                    
                    Text(userManager.user.avatarInitials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("Open profile")
        }
        .padding(.horizontal, 20)
    }
    
    private func setGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: greeting = "Good Morning ☀️"
        case 12..<17: greeting = "Good Afternoon 🌤"
        case 17..<21: greeting = "Good Evening 🌅"
        default: greeting = "Good Night 🌙"
        }
    }
}

// MARK: - Steps Card
struct StepsCard: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var userManager: UserManager
    
    var progress: Double {
        min(Double(healthManager.stepCount) / Double(userManager.user.dailyStepGoal), 1.0)
    }
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "A78BFA").opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "figure.walk")
                                .foregroundColor(Color(hex: "A78BFA"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        Text("Steps Today")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Goal: \(userManager.user.dailyStepGoal.formatted())")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text(healthManager.stepCount.formatted())
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("steps")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 8)
                    
                    Spacer()
                    
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 6)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: progress)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 56, height: 56)
                }
                
                // Progress bar
                ProgressBarView(progress: progress, colors: ["A78BFA", "60A5FA"])
                
                // Stats row
                HStack(spacing: 0) {
                    StepStatItem(label: "Distance", value: String(format: "%.1f km", Double(healthManager.stepCount) * 0.0007))
                    Divider().frame(height: 30).background(Color.white.opacity(0.1))
                    StepStatItem(label: "Calories", value: "\(Int(Double(healthManager.stepCount) * 0.04)) kcal")
                    Divider().frame(height: 30).background(Color.white.opacity(0.1))
                    StepStatItem(label: "Active Min", value: "\(healthManager.stepCount / 100) min")
                }
                .padding(.top, 4)
            }
        }
    }
}

struct StepStatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Calories Card
struct CaloriesCard: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var userManager: UserManager
    @Binding var showScan: Bool
    @State private var lastScannedMeal: NutritionResult? = nil
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "F97316").opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "fork.knife")
                                .foregroundColor(Color(hex: "F97316"))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text("Calories")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    
                    Button(action: { showScan = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                            Text("Scan Food")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "F97316").opacity(0.3))
                                .overlay(Capsule().stroke(Color(hex: "F97316").opacity(0.5), lineWidth: 1))
                        )
                    }
                }
                
                // Calorie ring
                HStack(spacing: 24) {
                    let consumed = lastScannedMeal?.calories ?? 1245
                    let goal = userManager.user.dailyCalorieGoal
                    let burned = Int(healthManager.activeCaloriesBurned)
                    let remaining = max(0, goal - Int(consumed) + burned)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 14)
                        Circle()
                            .trim(from: 0, to: min(Double(consumed) / Double(goal), 1.0))
                            .stroke(Color(hex: "F97316"), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 2) {
                            Text("\(remaining)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("remaining")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .frame(width: 110, height: 110)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        CalorieStatRow(label: "Consumed", value: "\(consumed) kcal", color: "F97316")
                        CalorieStatRow(label: "Burned", value: "\(burned) kcal", color: "34D399")
                        CalorieStatRow(label: "Goal", value: "\(goal) kcal", color: "A78BFA")
                    }
                }
                
                // Macros
                VStack(alignment: .leading, spacing: 8) {
                    Text("Macronutrients")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 8) {
                        MacroChip(label: "Carbs", value: lastScannedMeal?.carbs ?? 156, unit: "g", color: "F59E0B")
                        MacroChip(label: "Protein", value: lastScannedMeal?.protein ?? 68, unit: "g", color: "34D399")
                        MacroChip(label: "Fats", value: lastScannedMeal?.fat ?? 42, unit: "g", color: "EF4444")
                        MacroChip(label: "Fibre", value: lastScannedMeal?.fiber ?? 22, unit: "g", color: "60A5FA")
                    }
                }
            }
        }
    }
}

struct CalorieStatRow: View {
    let label: String
    let value: String
    let color: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct MacroChip: View {
    let label: String
    let value: Double
    let unit: String
    let color: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(value))\(unit)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: color).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stress Monitor Card
struct StressMonitorCard: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var showAdvice = false
    @State private var breatheAnimate = false
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: stressColor).opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(Color(hex: stressColor))
                                .font(.system(size: 15))
                        }
                        Text("Stress Monitor")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("via Heart Rate")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        ZStack {
                            if healthManager.stressScore > 60 {
                                Circle()
                                    .fill(Color(hex: stressColor).opacity(0.2))
                                    .frame(width: 90, height: 90)
                                    .scaleEffect(breatheAnimate ? 1.15 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: breatheAnimate)
                            }
                            
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 8)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: healthManager.stressScore / 100)
                                .stroke(Color(hex: stressColor), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 80, height: 80)
                                .animation(.spring(), value: healthManager.stressScore)
                            
                            VStack(spacing: 0) {
                                Text(healthManager.stressLevel.emoji)
                                    .font(.system(size: 22))
                                Text("\(Int(healthManager.stressScore))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(healthManager.stressLevel.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: stressColor))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            VStack(alignment: .leading) {
                                Text("\(Int(healthManager.heartRate)) BPM")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Heart Rate")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(Color(hex: "60A5FA"))
                                .font(.system(size: 12))
                            VStack(alignment: .leading) {
                                Text("\(Int(healthManager.hrv))ms HRV")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Variability")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        Button(action: { showAdvice.toggle() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 11))
                                Text(healthManager.stressScore > 50 ? "Take a break" : "View tips")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: stressColor).opacity(0.25))
                                    .overlay(Capsule().stroke(Color(hex: stressColor).opacity(0.4), lineWidth: 1))
                            )
                        }
                    }
                }
                
                if showAdvice {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color(hex: stressColor))
                            .font(.system(size: 14))
                        Text(healthManager.stressLevel.advice)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: stressColor).opacity(0.12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: stressColor).opacity(0.25), lineWidth: 1))
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.spring(), value: showAdvice)
                }
            }
        }
        .onAppear { breatheAnimate = true }
    }
    
    private var stressColor: String {
        healthManager.stressLevel.color
    }
}

// MARK: - Daily Insight Card
struct DailyInsightCard: View {
    private let insights = [
        ("Walking 8000+ steps reduces mortality risk by 50%", "figure.walk", "A78BFA"),
        ("HRV above 40ms indicates good recovery today", "waveform.path.ecg", "34D399"),
        ("Fiber intake improves gut health within 24 hours", "leaf.fill", "10B981"),
        ("5 minutes of breathing can lower cortisol by 20%", "wind", "60A5FA")
    ]
    
    @State private var currentInsight = 0
    
    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: insights[currentInsight].2).opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: insights[currentInsight].1)
                        .foregroundColor(Color(hex: insights[currentInsight].2))
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Insight ✨")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: insights[currentInsight].2))
                    Text(insights[currentInsight].0)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        currentInsight = (currentInsight + 1) % insights.count
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 22))
                }
            }
        }
    }
}

// MARK: - Reusable Components
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

struct ProgressBarView: View {
    let progress: Double
    let colors: [String]
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: colors.map { Color(hex: $0) },
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(progress), height: 8)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 8)
    }
}

struct AnimatedGradientBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A1A")
                .ignoresSafeArea()
            
            Circle()
                .fill(Color(hex: "A78BFA").opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: animate ? 60 : -60, y: animate ? -100 : -160)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(Color(hex: "60A5FA").opacity(0.12))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: animate ? -80 : 80, y: animate ? 200 : 300)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
