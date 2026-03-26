import SwiftUI
import AppKit

@main
struct EcholyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 450)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating 
            window.isOpaque = false
            window.backgroundColor = .clear
            window.title = "Echoly"
            
            // Screen sharing check
            let hide = UserDefaults.standard.bool(forKey: "hideFromScreenSharing")
            window.sharingType = hide ? .none : .readOnly
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 36 { // Enter / Return
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
}
