import SwiftUI
import CoreData

/// MARK: - Scroll offset preference key
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Tab Definition
struct AppTab {
    let index: Int
    let icon: String
    let label: String
}

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showLoginIntro = true

    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var blissManager: BlissContentManager

    private var tabs: [AppTab] {
        [
            AppTab(index: 0, icon: "house.fill",              label: "Home"),
            AppTab(index: 1, icon: "sparkles",                label: "Bliss"),
            AppTab(index: 2, icon: "person.crop.circle.fill", label: "You")
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // 0 — Home
                HomeView {
                    openProfile()
                }
                    .tag(0)
                    .ignoresSafeArea()

                // 1 — Bliss Reels
                BlissReelsView {
                    openProfile()
                }
                    .tag(1)
                    .ignoresSafeArea()

               
                // 2 — Profile
                ProfileView()
                    .tag(2)
                    .ignoresSafeArea()
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            LiquidGlassTabBar(
                tabs: tabs,
                selectedTab: $selectedTab
            )

            if showLoginIntro {
                LoginIntroView {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showLoginIntro = false
                    }
                }
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            healthManager.requestAuthorization()
        }
    }

    private func openProfile() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedTab = 2
        }
    }
}

// MARK: - Login Intro
struct LoginIntroView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F4F6FB")
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 80)

                Image("SouloLoginIntro")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320)
                    .padding(.horizontal, 34)

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color(hex: "2D2E36"))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 28)
                .padding(.bottom, 42)
            }
        }
    }
}

// MARK: - Liquid Glass Tab Bar
struct LiquidGlassTabBar: View {
    let tabs: [AppTab]
    @Binding var selectedTab: Int

    @Namespace private var indicatorNS

    private let selectedHeight: CGFloat = 58
    private let selectedWidth: CGFloat = 110
    private let iconSize: CGFloat = 27
    private let topPad: CGFloat = 14
    private let botPad: CGFloat = 14
    private let hPad: CGFloat = 18
    private let cornerR: CGFloat = 42

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(tabs, id: \.index) { tab in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            selectedTab = tab.index
                        }
                    } label: {
                        ZStack {
                            if selectedTab == tab.index {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: selectedWidth, height: selectedHeight)
                                    .offset(y: -3)
                                    .shadow(color: Color(hex: "A78BFA").opacity(0.35), radius: 10, x: 0, y: 4)
                                    .overlay {
                                        Capsule()
                                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                                            .blur(radius: 0.2)
                                    }
                                    .matchedGeometryEffect(id: "selectedTab", in: indicatorNS)
                            }

                            VStack(spacing: 5) {
                                if selectedTab == tab.index {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: iconSize, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(height: 25)
                                } else {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: iconSize, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.45))
                                        .frame(height: 25)
                                }

                                Text(tab.label)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedTab == tab.index ? .white : .white.opacity(0.42))
                            }
                            .frame(width: selectedWidth, height: selectedHeight)
                            .offset(y: selectedTab == tab.index ? -3 : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: selectedHeight)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        selectTab(at: value.location.x, totalWidth: geo.size.width)
                    }
            )
        }
        .frame(height: selectedHeight)
        .padding(.horizontal, hPad)
        .padding(.top, topPad)
        .padding(.bottom, botPad)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerR)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: cornerR)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.13),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: cornerR)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.42),
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerR))
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .shadow(color: .black.opacity(0.30), radius: 18, x: 0, y: 8)
        // Animate tab bar itself when tabs appear/disappear
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: tabs.count)
    }

    private func selectTab(at locationX: CGFloat, totalWidth: CGFloat) {
        guard !tabs.isEmpty, totalWidth > 0 else { return }

        let tabWidth = totalWidth / CGFloat(tabs.count)
        let clampedX = min(max(locationX, 0), totalWidth - 1)
        let tabPosition = min(Int(clampedX / tabWidth), tabs.count - 1)
        let newSelection = tabs[tabPosition].index

        guard selectedTab != newSelection else { return }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
            selectedTab = newSelection
        }
    }
}

// MARK: - Scale press style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}


// MARK: - FIX: Preview Option with Environment Objects
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HealthKitManager())
        .environmentObject(UserManager())
        .environmentObject(BlissContentManager())
}
