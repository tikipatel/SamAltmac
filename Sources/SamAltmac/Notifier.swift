import AppKit
import UserNotifications

/// Posts user notifications. Falls back to a beep + console log when running
/// outside an .app bundle (e.g. via `swift run`), where UNUserNotificationCenter
/// is unavailable.
final class Notifier: NSObject, UNUserNotificationCenterDelegate {
    private var isBundled: Bool { Bundle.main.bundleIdentifier != nil }

    func requestAuthorization() {
        guard isBundled else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error { NSLog("Notification authorization failed: \(error)") }
        }
    }

    func post(title: String, body: String) {
        guard isBundled else {
            NSSound.beep()
            print("[SamAltmac] \(title) — \(body)")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // Show banners even though this (menu bar) app is technically frontmost.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
