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

    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var blissManager: BlissContentManager

    // Build tab list dynamically — period tab only for females
    private var tabs: [AppTab] {
        var list = [
            AppTab(index: 0, icon: "house.fill",              label: "Home"),
            AppTab(index: 1, icon: "sparkles",                label: "Bliss"),
        ]
        if userManager.user.gender == .female {
            list.append(AppTab(index: 2, icon: "drop.fill", label: "Cycle"))
        }
        // Profile tab is always last — its index shifts based on gender
        let profileIndex = userManager.user.gender == .female ? 3 : 2
        list.append(AppTab(index: profileIndex, icon: "person.crop.circle.fill", label: "You"))
        return list
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // 0 — Home
                HomeView()
                    .tag(0)
                    .ignoresSafeArea()

                // 1 — Bliss Reels
                BlissReelsView()
                    .tag(1)
                    .ignoresSafeArea()

               
                // Profile — tag 3 for females, tag 2 for everyone else
                ProfileView()
                    .tag(userManager.user.gender == .female ? 3 : 2)
                    .ignoresSafeArea()
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            LiquidGlassTabBar(
                tabs: tabs,
                selectedTab: $selectedTab
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            healthManager.requestAuthorization()
        }
        // When gender changes, snap back to Home so index is never orphaned
        .onChange(of: userManager.user.gender) {
            withAnimation(.spring()) { selectedTab = 0 }
        }
    }
}

// MARK: - Liquid Glass Tab Bar
struct LiquidGlassTabBar: View {
    let tabs: [AppTab]
    @Binding var selectedTab: Int

    @Namespace private var indicatorNS

    private let pillW: CGFloat = 48
    private let pillH: CGFloat = 30
    private let iconSize: CGFloat = 19
    private let labelOpacity: Double = 1
    private let topPad: CGFloat = 20
    private let botPad: CGFloat = 7
    private let hPad: CGFloat = 14
    private let cornerR: CGFloat = 22

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.index) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab.index
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == tab.index {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        // Pink pill for Cycle tab, purple-blue for others
                                        tab.icon == "drop.fill"
                                        ? LinearGradient(
                                            colors: [Color(hex: "EC4899"), Color(hex: "A78BFA")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(
                                            colors: [Color(hex: "A78BFA"), Color(hex: "60A5FA")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: pillW, height: pillH)
                                    .shadow(
                                        color: tab.icon == "drop.fill"
                                               ? Color(hex: "EC4899").opacity(0.55)
                                               : Color(hex: "A78BFA").opacity(0.55),
                                        radius: 8, x: 0, y: 3
                                    )
                                    .matchedGeometryEffect(id: "pill", in: indicatorNS)
                            }

                            Image(systemName: tab.icon)
                                .font(.system(size: iconSize, weight: .semibold))
                                .foregroundColor(
                                    selectedTab == tab.index ? .white : .white.opacity(0.45)
                                )
                                .frame(width: pillW, height: pillH)
                        }

                        Text(tab.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(
                                selectedTab == tab.index
                                ? (tab.icon == "drop.fill"
                                   ? Color(hex: "EC4899")
                                   : Color(hex: "A78BFA"))
                                : .white.opacity(0.35)
                            )
                            .opacity(labelOpacity)
                            .frame(height: labelOpacity < 0.05 ? 0 : nil)
                            .clipped()
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
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
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 2)
        .offset(x:0,y: -10)
        .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: -2)
        // Animate tab bar itself when tabs appear/disappear
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: tabs.count)
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
