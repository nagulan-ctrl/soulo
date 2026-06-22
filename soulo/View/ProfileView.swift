import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var selectedSection: ProfileSection = .overview
    @State private var showEditProfile   = false
    @State private var showSettings      = false
    @State private var showSOS           = false
    @State private var showPeriodTracker = false

    enum ProfileSection: String, CaseIterable {
        case overview = "Overview"
        case stats    = "Stats"
        case devices  = "Devices"
    }

    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHeader

                        // Period tracker — females only
                        if userManager.user.gender == .female {
                            Button(action: { showPeriodTracker = true }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(Color(hex: "EC4899"))
                                    Text("Open Cycle Tracker")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "EC4899").opacity(0.12))
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "EC4899").opacity(0.25), lineWidth: 1))
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                            }
                        }

                        // SOS shortcut
                        Button(action: { showSOS = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(Color(hex: "EF4444"))
                                Text("Heart Monitor & SOS")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Circle()
                                    .fill(Color(hex: "34D399"))
                                    .frame(width: 8, height: 8)
                                Text("Live")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(hex: "34D399"))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "EF4444").opacity(0.10))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "EF4444").opacity(0.2), lineWidth: 1))
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }

                        sectionPicker
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        switch selectedSection {
                        case .overview: overviewSection
                        case .stats:    statsSection
                        case .devices:  devicesSection
                        }

                        Spacer().frame(height: 100)
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile)   { EditProfileView() }
            .sheet(isPresented: $showSettings)      { SettingsView() }
            
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "A78BFA").opacity(0.3), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            
            VStack(spacing: 16) {
                // Settings button
                HStack {
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color(hex: "A78BFA").opacity(0.5), radius: 16)
                    
                    Text(userManager.user.avatarInitials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Edit button
                    Circle()
                        .fill(Color(hex: "1E1E3A"))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 32, y: 32)
                        .onTapGesture { showEditProfile = true }
                }
                
                VStack(spacing: 4) {
                    Text(userManager.user.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text(userManager.user.username)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                // Quick stats
                HStack(spacing: 0) {
                    ProfileQuickStat(value: "\(userManager.user.streakDays)", label: "Day Streak", icon: "🔥")
                    Divider().frame(height: 40).background(Color.white.opacity(0.1))
                    ProfileQuickStat(value: "\(userManager.user.blissPoints)", label: "Bliss Points", icon: "✨")
                    Divider().frame(height: 40).background(Color.white.opacity(0.1))
                    ProfileQuickStat(value: "14", label: "Goals Met", icon: "🎯")
                }
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Section Picker
    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(ProfileSection.allCases, id: \.self) { section in
                Button(action: { withAnimation(.spring()) { selectedSection = section } }) {
                    VStack(spacing: 6) {
                        Text(section.rawValue)
                            .font(.system(size: 14, weight: selectedSection == section ? .bold : .medium))
                            .foregroundColor(selectedSection == section ? .white : .white.opacity(0.4))
                        
                        Rectangle()
                            .fill(selectedSection == section ? Color(hex: "A78BFA") : Color.clear)
                            .frame(height: 2)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
        .overlay(Divider().offset(y: 14).foregroundColor(Color.white.opacity(0.1)))
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(spacing: 16) {
            // Personal Info
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Personal Info", icon: "person.fill", color: "A78BFA")
                    
                    InfoRow(label: "Age", value: "\(userManager.user.age) years")
                    InfoRow(label: "Height", value: "\(Int(userManager.user.height)) cm")
                    InfoRow(label: "Weight", value: "\(Int(userManager.user.weight)) kg")
                    InfoRow(label: "BMI", value: String(format: "%.1f (\(userManager.user.bmiCategory))", userManager.user.bmi))
                    InfoRow(label: "Member Since", value: formatDate(userManager.user.joinDate))
                }
            }
            .padding(.horizontal, 20)
            
            // Goals
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Daily Goals", icon: "target", color: "34D399")
                    
                    GoalRow(label: "Steps", current: healthManager.stepCount, goal: userManager.user.dailyStepGoal, color: "A78BFA")
                    GoalRow(label: "Calories", current: 1245, goal: userManager.user.dailyCalorieGoal, color: "F97316")
                }
            }
            .padding(.horizontal, 20)
            
            // Mood History
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Mood This Week", icon: "heart.fill", color: "EC4899")
                    
                    HStack(spacing: 8) {
                        ForEach(userManager.moodHistory) { entry in
                            VStack(spacing: 4) {
                                Text(entry.mood)
                                    .font(.system(size: 20))
                                MoodBarView(score: entry.score)
                                    .frame(width: 28, height: 60)
                                Text(dayLabel(entry.date))
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Premium Features Section
            GlassCard {
                VStack(spacing: 14) {
                    SectionTitle("Bliss Premium Features", icon: "sparkles", color: "F59E0B")
                    
                    PremiumFeatureRow(icon: "brain.fill", title: "AI Mood Coach", description: "Get personalized wellness advice daily", color: "A78BFA")
                    PremiumFeatureRow(icon: "chart.xyaxis.line", title: "Advanced Analytics", description: "Deep health trend analysis & reports", color: "60A5FA")
                    PremiumFeatureRow(icon: "person.2.fill", title: "Wellness Circles", description: "Connect with supportive community groups", color: "34D399")
                    PremiumFeatureRow(icon: "moon.stars.fill", title: "Sleep Optimization", description: "Personalized sleep schedule & tracking", color: "F59E0B")
                    PremiumFeatureRow(icon: "wind", title: "Guided Breathing", description: "100+ breathing & meditation exercises", color: "EC4899")
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            // Weekly steps chart
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Weekly Steps", icon: "chart.bar.fill", color: "A78BFA")
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(userManager.weeklySteps) { dayData in
                            WeeklyBarView(data: dayData)
                        }
                    }
                    .frame(height: 100)
                    
                    HStack {
                        Text("Weekly avg: \(Int(userManager.weeklySteps.map { Double($0.steps) }.reduce(0, +) / 7)) steps")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("Goal: \(userManager.user.dailyStepGoal.formatted())")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A78BFA"))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Health scores
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Today's Health Score", icon: "heart.text.square.fill", color: "34D399")
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        HealthScoreItem(label: "Activity", score: Int(Double(healthManager.stepCount) / Double(userManager.user.dailyStepGoal) * 100), color: "A78BFA")
                        HealthScoreItem(label: "Nutrition", score: 72, color: "F97316")
                        HealthScoreItem(label: "Stress", score: max(0, 100 - Int(healthManager.stressScore)), color: "34D399")
                        HealthScoreItem(label: "Bliss", score: 84, color: "EC4899")
                    }
                    
                    // Overall score
                    HStack {
                        Text("Overall Bliss Score")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("78 / 100")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Devices Section
    private var devicesSection: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Connected Devices", icon: "antenna.radiowaves.left.and.right", color: "60A5FA")
                    
                    ForEach(userManager.connectedDevices) { device in
                        DeviceRow(device: device)
                    }
                    
                    // Add device button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "60A5FA"))
                            Text("Add Device")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "60A5FA"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "60A5FA").opacity(0.1))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "60A5FA").opacity(0.3), lineWidth: 1))
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Health data permissions
            GlassCard {
                VStack(spacing: 16) {
                    SectionTitle("Health Data Access", icon: "lock.shield.fill", color: "34D399")
                    
                    PermissionRow(name: "Step Count", status: healthManager.isAuthorized, icon: "figure.walk")
                    PermissionRow(name: "Heart Rate", status: healthManager.isAuthorized, icon: "heart.fill")
                    PermissionRow(name: "HRV (Stress)", status: healthManager.isAuthorized, icon: "waveform.path.ecg")
                    PermissionRow(name: "Active Calories", status: healthManager.isAuthorized, icon: "flame.fill")
                    
                    if !healthManager.isAuthorized {
                        Button(action: { healthManager.requestAuthorization() }) {
                            Text("Grant Health Access")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(colors: [Color(hex: "34D399"), Color(hex: "60A5FA")], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views
struct ProfileQuickStat: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionTitle: View {
    let title: String
    let icon: String
    let color: String
    
    init(_ title: String, icon: String, color: String) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: color))
                .font(.system(size: 14))
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct GoalRow: View {
    let label: String
    let current: Int
    let goal: Int
    let color: String
    
    var progress: Double { min(Double(current) / Double(goal), 1.0) }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(current.formatted()) / \(goal.formatted())")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            ProgressBarView(progress: progress, colors: [color])
        }
    }
}

struct MoodBarView: View {
    let score: Double
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "EC4899"), Color(hex: "A78BFA")],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: geo.size.height * (score / 10))
            }
        }
    }
}

struct WeeklyBarView: View {
    let data: DaySteps
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            data.progress >= 1.0
                            ? LinearGradient(colors: [Color(hex: "34D399"), Color(hex: "60A5FA")], startPoint: .bottom, endPoint: .top)
                            : LinearGradient(colors: [Color(hex: "A78BFA").opacity(0.5), Color(hex: "A78BFA")], startPoint: .bottom, endPoint: .top)
                        )
                        .frame(height: geo.size.height * min(data.progress, 1.0))
                }
            }
            Text(data.day)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

struct HealthScoreItem: View {
    let label: String
    let score: Int
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(Color(hex: color), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(score)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
    }
}

struct DeviceRow: View {
    let device: ConnectedDevice
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "60A5FA").opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: device.type == .appleWatch ? "applewatch" : "iphone")
                    .foregroundColor(Color(hex: "60A5FA"))
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text("Last sync: just now")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: "34D399"))
                        .frame(width: 6, height: 6)
                    Text("Connected")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "34D399"))
                }
                HStack(spacing: 4) {
                    Image(systemName: "battery.75percent")
                        .font(.system(size: 10))
                    Text("\(device.battery)%")
                        .font(.system(size: 11))
                }
                .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.vertical, 4)
    }
}

struct PermissionRow: View {
    let name: String
    let status: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(status ? Color(hex: "34D399") : .white.opacity(0.3))
                .font(.system(size: 14))
                .frame(width: 20)
            Text(name)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(status ? Color(hex: "34D399") : Color(hex: "EF4444").opacity(0.6))
                .font(.system(size: 16))
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .font(.system(size: 15))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundColor(.white.opacity(0.2))
                .font(.system(size: 12))
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    
    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("Edit Profile")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Save") {
                        if !name.isEmpty { userManager.user.name = name }
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "A78BFA"))
                    .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                VStack(spacing: 16) {
                    EditField(label: "Name", placeholder: userManager.user.name, text: $name)
                    EditField(label: "Age", placeholder: "\(userManager.user.age)", text: $age)
                    EditField(label: "Weight (kg)", placeholder: "\(Int(userManager.user.weight))", text: $weight)
                    EditField(label: "Height (cm)", placeholder: "\(Int(userManager.user.height))", text: $height)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct EditField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
        }
    }
}
