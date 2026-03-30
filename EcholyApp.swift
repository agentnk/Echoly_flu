import SwiftUI
import AppKit

@main
struct EcholyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 450)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating 
            window.title = "Echoly"
            
            // Restore saved window frame
            let hide = UserDefaults.standard.bool(forKey: "hideFromScreenSharing")
            window.sharingType = hide ? .none : .readOnly
            
            if let frameStr = UserDefaults.standard.string(forKey: "windowFrame") {
                let frame = NSRectFromString(frameStr)
                if frame.width > 0 { window.setFrame(frame, display: true) }
            }
            
            // Save window position on move/resize
            NotificationCenter.default.addObserver(forName: NSWindow.didMoveNotification, object: window, queue: .main) { _ in
                UserDefaults.standard.set(NSStringFromRect(window.frame), forKey: "windowFrame")
            }
            NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: window, queue: .main) { _ in
                UserDefaults.standard.set(NSStringFromRect(window.frame), forKey: "windowFrame")
            }
        }
        
        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: "Echoly")
            button.action = #selector(toggleWindow)
            button.target = self
        }

        // Keyboard shortcuts
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 36 { // Enter/Return
                NotificationCenter.default.post(name: NSNotification.Name("ManualScroll"), object: nil)
                return nil
            } else if event.keyCode == 49 { // Spacebar
                NotificationCenter.default.post(name: NSNotification.Name("TogglePlay"), object: nil)
                return nil 
            } else if event.keyCode == 126 { // Up
                NotificationCenter.default.post(name: NSNotification.Name("SpeedUp"), object: nil)
                return nil
            } else if event.keyCode == 125 { // Down
                NotificationCenter.default.post(name: NSNotification.Name("SpeedDown"), object: nil)
                return nil
            }
            return event
        }
    }
    
    @objc func toggleWindow() {
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Echoly" }) {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}
