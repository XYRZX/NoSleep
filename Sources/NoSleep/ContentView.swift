import SwiftUI

// MARK: - Layout Constants
private enum NSLayout {
    static let panelWidth: CGFloat = 320
    static let cardRadius: CGFloat = 10
    static let cardStroke: CGFloat = 0.5
    static let iconSize: CGFloat = 20
    static let headerIconSize: CGFloat = 26
    static let sectionPaddingH: CGFloat = 12
    static let sectionPaddingV: CGFloat = 10
    static let groupSpacing: CGFloat = 12
}

// MARK: - Reusable Components

/// macOS-style grouped card with subtle border
private struct NSCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: NSLayout.cardRadius)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: NSLayout.cardRadius)
                    .stroke(Color.primary.opacity(0.06), lineWidth: NSLayout.cardStroke)
            )
    }
}

/// SF Symbol inside a subtle circular badge
private struct NSIconBadge: View {
    let name: String
    let size: CGFloat
    var foreground: Color? = nil

    var body: some View {
        Image(systemName: name)
            .font(.system(size: size))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(foreground ?? .secondary)
            .frame(width: NSLayout.iconSize)
    }
}

/// A custom iOS/macOS-style toggle that bypasses system Toggle bugs in popovers
private struct CustomToggle: View {
    @Binding var isOn: Bool

    private let trackW: CGFloat = 32
    private let trackH: CGFloat = 20
    private let knob: CGFloat = 16
    private let pad: CGFloat = 2

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            RoundedRectangle(cornerRadius: trackH / 2)
                .fill(isOn
                    ? Color(nsColor: .controlAccentColor)
                    : Color(nsColor: .separatorColor))
                .frame(width: trackW, height: trackH)

            Circle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                .frame(width: knob, height: knob)
                .padding(pad)
        }
        .frame(width: trackW, height: trackH)
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOn)
    }
}

// MARK: - Main View

struct ContentView: View {
    @EnvironmentObject var sleepPreventer: SleepPreventer
    @State private var currentLang = L10n.preferredLanguage
    @State private var refreshID = 0

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            VStack(spacing: NSLayout.groupSpacing) {
                toggleSection
                languageSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Spacer(minLength: 0)

            quitButton
                .padding(.top, 10)
                .padding(.bottom, 18)
        }
        .frame(width: NSLayout.panelWidth)
        .background(Color(nsColor: .windowBackgroundColor))
        .environment(\.layoutDirection, L10n.isRTL ? .rightToLeft : .leftToRight)
        .id(refreshID)
    }
}

// MARK: - Sections

private extension ContentView {

    var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: sleepPreventer.isPreventingSleep
                  ? "moon.stars.fill"
                  : "moon.zzz")
                .font(.system(size: NSLayout.headerIconSize))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, value: sleepPreventer.isPreventingSleep)
                .padding(.top, 16)

            Text("NoSleep")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)

            Text(sleepPreventer.isPreventingSleep
                 ? L10n.tr("header_active")
                 : L10n.tr("header_inactive"))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 14)
    }

    var toggleSection: some View {
        NSCard {
            VStack(spacing: 0) {
                toggleRow
                if sleepPreventer.isPreventingSleep {
                    Divider()
                    statusRow
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: sleepPreventer.isPreventingSleep)
    }

    var toggleRow: some View {
        HStack(spacing: 12) {
            NSIconBadge(
                name: sleepPreventer.isPreventingSleep ? "bolt.fill" : "bolt.slash",
                size: 13,
                foreground: Color(nsColor: .controlAccentColor)
            )

            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.tr("toggle_title"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                Text(L10n.tr("toggle_subtitle"))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CustomToggle(isOn: Binding(
                get: { sleepPreventer.isPreventingSleep },
                set: { $0 ? sleepPreventer.start() : sleepPreventer.stop() }
            ))
        }
        .padding(.horizontal, NSLayout.sectionPaddingH)
        .padding(.vertical, NSLayout.sectionPaddingV)
    }

    var statusRow: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)

            Text(L10n.tr("status_running"))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, NSLayout.sectionPaddingH)
        .padding(.vertical, 8)
    }

    var languageSection: some View {
        NSCard {
            HStack(spacing: 12) {
                NSIconBadge(name: "globe", size: 13)

                VStack(alignment: .leading, spacing: 1) {
                    Text(L10n.tr("lang_title"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(L10n.currentDisplayName())
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                LanguagePicker(currentLang: $currentLang, refreshID: $refreshID)
            }
            .padding(.horizontal, NSLayout.sectionPaddingH)
            .padding(.vertical, NSLayout.sectionPaddingV)
        }
    }

    var quitButton: some View {
        Button(action: { NSApp.terminate(nil) }) {
            Text(L10n.tr("quit_button"))
                .font(.system(size: 12))
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Language Picker (extracted to reduce view body complexity)

private struct LanguagePicker: View {
    @Binding var currentLang: String
    @Binding var refreshID: Int

    var body: some View {
        Picker("", selection: Binding(
            get: { currentLang },
            set: { newLang in
                guard newLang != currentLang else { return }
                L10n.preferredLanguage = newLang
                currentLang = newLang
                refreshID += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    NotificationCenter.default.post(name: .popoverShouldResize, object: nil)
                }
            }
        )) {
            ForEach(L10n.supportedLanguages, id: \.locale) { lang in
                Text(lang.label).tag(lang.locale)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .fixedSize()
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let popoverShouldResize = Notification.Name("popoverShouldResize")
}
