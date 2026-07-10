import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    let sleepPreventer = SleepPreventer()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        observeSleepState()
    }

    func applicationWillTerminate(_ notification: Notification) {
        sleepPreventer.stop()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem.button else { return }
        button.image = NSImage(
            systemSymbolName: "moon.zzz",
            accessibilityDescription: "NoSleep"
        )
        button.action = #selector(togglePopover(_:))
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 300)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = makeHostingController()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustPopoverSize),
            name: .popoverShouldResize,
            object: nil
        )
    }

    private func observeSleepState() {
        sleepPreventer.$isPreventingSleep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.updateIcon(isActive: isActive)
            }
            .store(in: &cancellables)
    }

    // MARK: - Popover Actions

    @objc func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }

        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            presentContextMenu(for: button)
            return
        }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.contentViewController = makeHostingController()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.adjustPopoverSize()
            }
        }
    }

    // MARK: - Sizing

    /// Adjust popover to fit its SwiftUI content.
    /// Called once on open and after language switches.
    @objc private func adjustPopoverSize() {
        guard let hostingView = popover.contentViewController?.view else { return }
        let fitting = hostingView.fittingSize
        let targetHeight = min(fitting.height + 8, 500)
        guard abs(popover.contentSize.height - targetHeight) > 1 else { return }
        popover.contentSize = NSSize(width: 320, height: targetHeight)
    }

    // MARK: - Context Menu

    private func presentContextMenu(for button: NSStatusBarButton) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: L10n.tr("menu_about"),
            action: #selector(showAbout),
            keyEquivalent: ""
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: L10n.tr("menu_quit"),
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))
        button.menu = menu
        button.performClick(nil)
        button.menu = nil
    }

    // MARK: - Helpers

    private func makeHostingController() -> NSHostingController<some View> {
        NSHostingController(
            rootView: ContentView().environmentObject(sleepPreventer)
        )
    }

    private func updateIcon(isActive: Bool) {
        guard let button = statusItem.button else { return }
        let name = isActive ? "moon.stars.fill" : "moon.zzz"
        button.image = NSImage(systemSymbolName: name, accessibilityDescription: "NoSleep")
    }

    // MARK: - Menu Actions

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "NoSleep"
        alert.informativeText = L10n.tr("about_text")
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
