import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var healthManager: HealthKitManager
    @Environment(\.dismiss) var dismiss

    @State private var showDeleteAlert  = false
    @State private var showLogoutAlert  = false
    @State private var showAbout        = false

    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()

            // Soft glow
            Circle()
                .fill(Color(hex: "A78BFA").opacity(0.08))
                .frame(width: 300).blur(radius: 60)
                .offset(x: -60, y: -200)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 18, weight: .semibold))
                        }
                        Spacer()
                        Text("Settings")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white.opacity(0.3))
                            .font(.system(size: 18))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Profile mini card
                    profileCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // Sections
                    SettingsSection(title: "Account") {
                        SettingsNavRow(icon: "person.crop.circle.fill", color: "A78BFA", title: "Personal Info") {
                            PersonalInfoSettings()
                        }
                        SettingsNavRow(icon: "lock.fill", color: "60A5FA", title: "Privacy & Security") {
                            PrivacySettings()
                        }
                        SettingsNavRow(icon: "creditcard.fill", color: "F59E0B", title: "Subscription & Plans") {
                            SubscriptionSettings()
                        }
                    }

                    SettingsSection(title: "Health & Wellness") {
                        SettingsNavRow(icon: "figure.walk", color: "34D399", title: "Daily Goals") {
                            GoalsSettings()
                        }
                        SettingsNavRow(icon: "heart.fill", color: "EF4444", title: "SOS & Emergency") {
                            SOSSettings()
                        }
                        SettingsToggleRow(
                            icon: "heart.text.square.fill",
                            color: "EF4444",
                            title: "Heart Rate Alerts",
                            isOn: $userManager.settings.heartRateAlerts
                        )
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("HR Alert Above")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(userManager.settings.heartRateThreshold)) BPM")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "EF4444"))
                            }
                            Slider(value: $userManager.settings.heartRateThreshold, in: 90...180, step: 5)
                                .tint(Color(hex: "EF4444"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }

                    SettingsSection(title: "Notifications") {
                        SettingsToggleRow(
                            icon: "bell.fill",
                            color: "A78BFA",
                            title: "All Notifications",
                            isOn: $userManager.settings.notificationsEnabled
                        )
                        SettingsToggleRow(
                            icon: "drop.fill",
                            color: "EC4899",
                            title: "Period Reminders",
                            isOn: $userManager.settings.periodReminders
                        )
                        SettingsToggleRow(
                            icon: "sun.max.fill",
                            color: "F59E0B",
                            title: "Daily Check-in Reminder",
                            isOn: $userManager.settings.dailyCheckInReminder
                        )
                        if userManager.settings.dailyCheckInReminder {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Color(hex: "F59E0B"))
                                    .font(.system(size: 14))
                                    .frame(width: 28)
                                DatePicker("Reminder Time",
                                           selection: $userManager.settings.checkInTime,
                                           displayedComponents: .hourAndMinute)
                                    .foregroundColor(.white)
                                    .colorScheme(.dark)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                    }

                    SettingsSection(title: "App Preferences") {
                        SettingsToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            color: "60A5FA",
                            title: "Haptic Feedback",
                            isOn: $userManager.settings.hapticFeedback
                        )
                        SettingsToggleRow(
                            icon: "faceid",
                            color: "34D399",
                            title: "Biometric Lock",
                            isOn: $userManager.settings.biometricLock
                        )

                        // Units picker
                        VStack {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8).fill(Color(hex: "A78BFA").opacity(0.2)).frame(width: 32, height: 32)
                                    Image(systemName: "ruler.fill").foregroundColor(Color(hex: "A78BFA")).font(.system(size: 14))
                                }
                                Text("Units")
                                    .font(.system(size: 15)).foregroundColor(.white)
                                Spacer()
                                Picker("", selection: $userManager.settings.units) {
                                    ForEach(AppSettings.UnitSystem.allCases, id: \.self) { u in
                                        Text(u.rawValue).tag(u)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color(hex: "A78BFA"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }

                    SettingsSection(title: "Data & Privacy") {
                        SettingsToggleRow(
                            icon: "chart.bar.doc.horizontal.fill",
                            color: "60A5FA",
                            title: "Anonymous Data Sharing",
                            isOn: $userManager.settings.dataSharing
                        )
                        Button(action: { healthManager.requestAuthorization() }) {
                            SettingsActionRow(icon: "heart.text.square.fill", color: "EF4444", title: "Manage Health Permissions", showChevron: true)
                        }
                        Button(action: {}) {
                            SettingsActionRow(icon: "arrow.down.circle.fill", color: "34D399", title: "Export My Data", showChevron: true)
                        }
                    }

                    SettingsSection(title: "Support") {
                        Button(action: { showAbout = true }) {
                            SettingsActionRow(icon: "info.circle.fill", color: "60A5FA", title: "About Bliss", showChevron: true)
                        }
                        Button(action: {}) {
                            SettingsActionRow(icon: "questionmark.circle.fill", color: "A78BFA", title: "Help & FAQ", showChevron: true)
                        }
                        Button(action: {
                            if let url = URL(string: "mailto:support@blissapp.io") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            SettingsActionRow(icon: "envelope.fill", color: "F59E0B", title: "Contact Support", showChevron: false)
                        }
                        Button(action: {
                            if let url = URL(string: "https://apps.apple.com/app") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            SettingsActionRow(icon: "star.fill", color: "F59E0B", title: "Rate Bliss on App Store", showChevron: false)
                        }
                    }

                    // Version info
                    Text("Bliss v1.0.0 • Made with ❤️ for Hackathon 2026")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.2))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)

                    // Danger zone
                    VStack(spacing: 10) {
                        Button(action: { showLogoutAlert = true }) {
                            Text("Sign Out")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "F97316"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "F97316").opacity(0.1)))
                        }

                        Button(action: { showDeleteAlert = true }) {
                            Text("Delete Account")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "EF4444"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "EF4444").opacity(0.08)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {}
        } message: {
            Text("This will permanently delete all your Bliss data. This cannot be undone.")
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Text(userManager.user.avatarInitials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(userManager.user.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(userManager.user.username)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("✨ \(userManager.user.blissPoints)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "F59E0B"))
                    Text("Bliss Points")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - Settings Section Wrapper
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title   = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.35))
                .tracking(1.2)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04)))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 0.8))
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Row Types
struct SettingsNavRow<Destination: View>: View {
    let icon: String
    let color: String
    let title: String
    let destination: Destination

    init(icon: String, color: String, title: String, @ViewBuilder destination: () -> Destination) {
        self.icon        = icon
        self.color       = color
        self.title       = title
        self.destination = destination()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: color).opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: color))
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.25))
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 60)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let color: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .font(.system(size: 14))
            }
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(Color(hex: color))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 60)
    }
}

struct SettingsActionRow: View {
    let icon: String
    let color: String
    let title: String
    let showChevron: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .font(.system(size: 14))
            }
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.25))
                    .font(.system(size: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 60)
    }
}

// MARK: - Sub-settings pages

struct PersonalInfoSettings: View {
    @EnvironmentObject var userManager: UserManager
    @State private var name     = ""
    @State private var age      = ""
    @State private var height   = ""
    @State private var weight   = ""
    @State private var gender   = Gender.female

    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(spacing: 14) {
                            EditField(label: "Full Name", placeholder: userManager.user.name, text: $name)
                            EditField(label: "Age", placeholder: "\(userManager.user.age)", text: $age)
                            EditField(label: "Height (cm)", placeholder: "\(Int(userManager.user.height))", text: $height)
                            EditField(label: "Weight (kg)", placeholder: "\(Int(userManager.user.weight))", text: $weight)
                        }
                    }
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Gender")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            Picker("Gender", selection: $gender) {
                                ForEach(Gender.allCases, id: \.self) { g in
                                    Text(g.rawValue).tag(g)
                                }
                            }
                            .pickerStyle(.segmented)
                            .colorScheme(.dark)
                        }
                    }
                    Button(action: {
                        if !name.isEmpty   { userManager.user.name   = name }
                        if let a = Int(age)          { userManager.user.age    = a }
                        if let h = Double(height)    { userManager.user.height = h }
                        if let w = Double(weight)    { userManager.user.weight = w }
                        userManager.user.gender = gender
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(LinearGradient(colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Personal Info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { gender = userManager.user.gender }
    }
}

struct SOSSettings: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(spacing: 14) {
                            SettingsToggleRow(icon: "sos", color: "EF4444", title: "Enable SOS Detection", isOn: $userManager.settings.sosEnabled)
                            SettingsToggleRow(icon: "heart.fill", color: "EF4444", title: "Heart Attack Alerts", isOn: $userManager.settings.heartRateAlerts)
                        }
                    }

                    GlassCard {
                        VStack(spacing: 14) {
                            EditField(label: "Emergency Contact Name", placeholder: userManager.user.emergencyContact.isEmpty ? "e.g. Sarah Johnson" : userManager.user.emergencyContact, text: .constant(""))
                            EditField(label: "Emergency Phone", placeholder: userManager.user.emergencyPhone.isEmpty ? "+1 555 000 0000" : userManager.user.emergencyPhone, text: .constant(""))
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("HR Alert Threshold")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            HStack {
                                Text("Alert when heart rate exceeds:")
                                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Text("\(Int(userManager.settings.heartRateThreshold)) BPM")
                                    .font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: "EF4444"))
                            }
                            Slider(value: $userManager.settings.heartRateThreshold, in: 90...180, step: 5)
                                .tint(Color(hex: "EF4444"))
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("SOS & Emergency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettings: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(spacing: 0) {
                            SettingsToggleRow(icon: "faceid", color: "34D399", title: "Biometric Lock", isOn: $userManager.settings.biometricLock)
                            SettingsToggleRow(icon: "chart.bar.doc.horizontal.fill", color: "60A5FA", title: "Anonymous Analytics", isOn: $userManager.settings.dataSharing)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your data is encrypted and never sold.")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Bliss uses end-to-end encryption for all health data. Period and pregnancy data is stored only on your device and iCloud.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GoalsSettings: View {
    @EnvironmentObject var userManager: UserManager
    @State private var stepGoal: Double = 10000
    @State private var calGoal: Double  = 2000

    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Daily Steps Goal")
                                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("\(Int(stepGoal).formatted())")
                                        .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "A78BFA"))
                                }
                                Slider(value: $stepGoal, in: 2000...20000, step: 500)
                                    .tint(Color(hex: "A78BFA"))
                            }

                            Divider().background(Color.white.opacity(0.08))

                            VStack(spacing: 8) {
                                HStack {
                                    Text("Daily Calories Goal")
                                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("\(Int(calGoal)) kcal")
                                        .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "F97316"))
                                }
                                Slider(value: $calGoal, in: 1200...4000, step: 50)
                                    .tint(Color(hex: "F97316"))
                            }
                        }
                    }

                    Button(action: {
                        userManager.user.dailyStepGoal    = Int(stepGoal)
                        userManager.user.dailyCalorieGoal = Int(calGoal)
                    }) {
                        Text("Save Goals")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(LinearGradient(colors: [Color(hex: "34D399"), Color(hex: "60A5FA")], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Daily Goals")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            stepGoal = Double(userManager.user.dailyStepGoal)
            calGoal  = Double(userManager.user.dailyCalorieGoal)
        }
    }
}

struct SubscriptionSettings: View {
    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Current plan
                    GlassCard {
                        VStack(spacing: 8) {
                            Text("✨ Free Plan")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("Upgrade to unlock all features")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    // Plans
                    ForEach([
                        ("Bliss Plus", "$4.99/mo", "Unlimited reels · AI food scanner · Mood history", "60A5FA"),
                        ("Bliss Pro", "$9.99/mo", "Everything + AI Coach · Sleep · Wellness Circles", "A78BFA")
                    ], id: \.0) { plan in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(plan.0)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(plan.1)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: plan.3))
                                }
                                Text(plan.2)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.5))

                                Button(action: {}) {
                                    Text("Upgrade to \(plan.0)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: plan.3).opacity(0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0A0A1A").ignoresSafeArea()
            VStack(spacing: 24) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Text("✨")
                    .font(.system(size: 60))

                Text("Bliss")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Text("v1.0.0 · Hackathon 2026")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))

                GlassCard {
                    Text("Bliss is a holistic wellness app combining step tracking, AI nutrition analysis, HRV-based stress monitoring, emotional wellness reels and period tracking — all in one beautiful, ad-free experience.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}
