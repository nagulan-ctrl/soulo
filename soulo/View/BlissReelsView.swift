import SwiftUI

struct BlissReelsView: View {
    var onOpenProfile: () -> Void = {}

    @EnvironmentObject var blissManager: BlissContentManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var dragOffset: CGFloat = 0
    @State private var showMoodPicker = false
    @State private var currentIndex = 0
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            Color(hex: "050510").ignoresSafeArea()
            
            if blissManager.currentReels.isEmpty {
                loadingView
            } else {
                reelCarousel
            }
            
            // Top overlay
            topOverlay
            
            // Mood picker sheet
            if showMoodPicker {
                MoodPickerOverlay(isShowing: $showMoodPicker) { state in
                    userManager.emotionalState = state
                    blissManager.refreshForMood(state)
                    withAnimation { showMoodPicker = false }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            blissManager.loadReels(for: userManager.emotionalState)
        }
    }
    
    // MARK: - Reel Carousel (vertical swipe)
    private var reelCarousel: some View {
        GeometryReader { geo in
            let reels = blissManager.currentReels
            ZStack {
                ForEach(Array(reels.enumerated().reversed()), id: \.element.id) { index, reel in
                    if abs(index - currentIndex) <= 1 {
                        ReelCardView(reel: reel, isActive: index == currentIndex)
                            .offset(y: CGFloat(index - currentIndex) * geo.size.height + dragOffset)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                            .animation(.interactiveSpring(), value: dragOffset)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 80
                        if value.translation.height < -threshold && currentIndex < reels.count - 1 {
                            currentIndex += 1
                            blissManager.currentIndex = currentIndex
                        } else if value.translation.height > threshold && currentIndex > 0 {
                            currentIndex -= 1
                            blissManager.currentIndex = currentIndex
                        }
                        dragOffset = 0
                    }
            )
        }
    }
    
    // MARK: - Top Overlay
    private var topOverlay: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bliss")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    if let reel = blissManager.currentReels[safe: currentIndex] {
                        Text("For you: \(reel.moodTag)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "A78BFA"))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: { withAnimation(.spring()) { showMoodPicker.toggle() } }) {
                        HStack(spacing: 6) {
                            Text(userManager.emotionalState.emoji)
                                .font(.system(size: 16))
                            Text(userManager.emotionalState.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        )
                    }

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
                                .frame(width: 38, height: 38)

                            Text(userManager.user.avatarInitials)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("Open profile")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            Spacer()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color(hex: "A78BFA"))
                .scaleEffect(1.5)
            Text("Curating your Bliss feed...")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Individual Reel Card
struct ReelCardView: View {
    let reel: BlissReel
    let isActive: Bool
    @EnvironmentObject var blissManager: BlissContentManager
    @State private var animate = false
    @State private var showAffirmation = false
    @State private var heartBurst = false
    @State private var localLiked = false
    @State private var localSaved = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Animated background
                animatedBackground(size: geo.size)
                
                // Content
                VStack {
                    Spacer()
                    
                    // Main reel content
                    reelContent
                    
                    Spacer().frame(height: 120) // Tab bar space
                }
                
                // Side actions
                sideActions
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 16)
                    .padding(.bottom, 130)
                
                // Heart burst animation
                if heartBurst {
                    ForEach(0..<8) { i in
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(hex: "EC4899"))
                            .font(.system(size: CGFloat.random(in: 14...28)))
                            .offset(
                                x: CGFloat.random(in: -80...80),
                                y: animate ? -CGFloat.random(in: 80...200) : 0
                            )
                            .opacity(animate ? 0 : 1)
                            .animation(.easeOut(duration: 0.8).delay(Double(i) * 0.05), value: animate)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = isActive
            localLiked = reel.isLiked
            localSaved = reel.isSaved
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring()) { showAffirmation = true }
            }
        }
        .onDisappear { showAffirmation = false }
    }
    
    // MARK: - Animated Background
    private func animatedBackground(size: CGSize) -> some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: reel.gradientColors.map { Color(hex: $0).opacity(0.8) } + [Color(hex: "050510")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Pattern overlay
            patternOverlay(for: reel.backgroundPattern, size: size)
            
            // Vignette
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.6)],
                center: .center,
                startRadius: size.width * 0.3,
                endRadius: size.width * 0.9
            )
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func patternOverlay(for pattern: BlissReel.BackgroundPattern, size: CGSize) -> some View {
        switch pattern {
        case .waves:
            WaveAnimation(isAnimating: isActive)
        case .stars:
            StarsAnimation(isAnimating: isActive)
        case .aurora:
            AuroraAnimation(isAnimating: isActive)
        default:
            EmptyView()
        }
    }
    
    // MARK: - Reel Content
    private var reelContent: some View {
        VStack(spacing: 20) {
            // Category badge
            Text(reel.category.rawValue.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.12)))
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 80, height: 80)
                    .blur(radius: 1)
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: 80, height: 80)
                Image(systemName: reel.icon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .animation(.spring(response: 0.5).delay(0.2), value: animate)
            }
            
            // Title and subtitle
            VStack(spacing: 8) {
                Text(reel.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(reel.subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // Affirmation card
            if showAffirmation {
                VStack(spacing: 6) {
                    Text("✨ Affirmation")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    Text(",\(reel.affirmation),")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
                .padding(.horizontal, 30)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Duration and creator
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                    Text(reel.duration)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.6))
                
                Text("by \(reel.creator)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    // MARK: - Side Actions
    private var sideActions: some View {
        VStack(spacing: 24) {
            // Like
            ReelActionButton(
                icon: localLiked ? "heart.fill" : "heart",
                count: reel.likes + (localLiked ? 1 : 0),
                color: localLiked ? "EC4899" : "FFFFFF"
            ) {
                localLiked.toggle()
                heartBurst = localLiked
                if heartBurst {
                    animate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        heartBurst = false
                        animate = false
                    }
                }
            }
            
            // Save
            ReelActionButton(
                icon: localSaved ? "bookmark.fill" : "bookmark",
                count: nil,
                color: localSaved ? "F59E0B" : "FFFFFF"
            ) {
                localSaved.toggle()
            }
            
            ShareLink(item: shareText) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 52, height: 52)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(hex: "60A5FA"))
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Play button
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
        }
    }

    private var shareText: String {
        """
        \(reel.title)

        \(reel.subtitle)

        Affirmation: \(reel.affirmation)

        Shared from Soulo.
        """
    }
}

struct ReelActionButton: View {
    let icon: String
    let count: Int?
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: color))
                }
                if let count = count {
                    Text(formatCount(count))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func formatCount(_ n: Int) -> String {
        if n >= 1000 { return "\(String(format: "%.1f", Double(n)/1000))K" }
        return "\(n)"
    }
}

// MARK: - Mood Picker Overlay
struct MoodPickerOverlay: View {
    @Binding var isShowing: Bool
    let onSelect: (UserManager.EmotionalState) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { isShowing = false }
            
            VStack(spacing: 20) {
                Text("How are you feeling?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Bliss will personalize your feed")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(UserManager.EmotionalState.allCases, id: \.self) { state in
                        Button(action: { onSelect(state) }) {
                            VStack(spacing: 8) {
                                Text(state.emoji)
                                    .font(.system(size: 36))
                                Text(state.rawValue)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(state.reelTheme)
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.4))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.12), lineWidth: 1))
            )
            .padding(20)
        }
    }
}

// MARK: - Background Animations
struct WaveAnimation: View {
    let isAnimating: Bool
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { context, size in
                let waves = 3
                for i in 0..<waves {
                    var path = Path()
                    let amplitude: CGFloat = 20 + CGFloat(i) * 10
                    let frequency: CGFloat = 0.02 - CGFloat(i) * 0.003
                    let offset = CGFloat(i) * 40
                    
                    path.move(to: CGPoint(x: 0, y: size.height * 0.4 + offset))
                    for x in stride(from: 0, through: size.width, by: 2) {
                        let y = size.height * 0.4 + offset + amplitude * sin(frequency * x + phase + CGFloat(i) * 2)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()
                    
                    context.fill(path, with: .color(Color.white.opacity(0.03 - Double(i) * 0.005)))
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

struct StarsAnimation: View {
    let isAnimating: Bool
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
            }
        }
        .ignoresSafeArea()
    }
}

struct AuroraAnimation: View {
    let isAnimating: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "A78BFA").opacity(0.15))
                .frame(width: 300, height: 150)
                .blur(radius: 40)
                .offset(x: animate ? -30 : 30, y: -100)
            
            Ellipse()
                .fill(Color(hex: "60A5FA").opacity(0.12))
                .frame(width: 250, height: 120)
                .blur(radius: 30)
                .offset(x: animate ? 60 : -60, y: 50)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Safe array subscript
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
//
//  BlissReelsView.swift
//  bliss
//
//  Created by Nagulan Vijayakumar on 21/06/26.
//
