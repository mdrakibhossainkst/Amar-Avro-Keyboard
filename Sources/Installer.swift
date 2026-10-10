//
//  AvroKeyboard
//
//  Copyright (c) 2012 OmicronLab. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

/// Offers to copy the app into `~/Library/Input Methods` when it is launched from
/// somewhere else (the DMG, Downloads, ...). This is how a user "installs" from the
/// disk image: double-click the app and accept the prompt.
@MainActor
enum Installer {
    private static let folderName = "Input Methods"

    private static var userFolder: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/\(folderName)")
    }

    /// True when the bundle already lives in a folder macOS scans for input methods.
    static var isInstalled: Bool {
        let parent = Bundle.main.bundleURL.deletingLastPathComponent().resolvingSymlinksInPath().path
        return [userFolder, URL(fileURLWithPath: "/Library/\(folderName)")]
            .contains { $0.resolvingSymlinksInPath().path == parent }
    }

    /// Prompts to install if the app is not already in an Input Methods folder. Returns
    /// only if the app should carry on starting as an input method; otherwise exits.
    static func offerIfNeeded() {
        #if DEBUG
        // Xcode runs debug builds from DerivedData; do not nag on every launch.
        return
        #else
        // A user may have copied the app into ~/Library/Input Methods manually.
        // In that case, still register/enable it instead of returning silently.
        if isInstalled {
            registerInputSource(at: Bundle.main.bundleURL)
            return
        }

        let destination = userFolder.appendingPathComponent(Bundle.main.bundleURL.lastPathComponent)
        let replacing = FileManager.default.fileExists(atPath: destination.path)

        // Input methods are background-only, so the app has to be made activatable
        // before a modal alert can come to the front.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = replacing ? "Update Amar Avro Keyboard?" : "Install Amar Avro Keyboard?"
        alert.informativeText = "Amar Avro Keyboard needs to live in your Input Methods folder before macOS can use it.\n\n"
            + (replacing
               ? "The copy already in ~/Library/Input Methods will be replaced with this one."
               : "It will be copied to ~/Library/Input Methods, for your user only.")
        alert.addButton(withTitle: replacing ? "Update" : "Install")
        alert.addButton(withTitle: "Quit")
        guard alert.runModal() == .alertFirstButtonReturn else { exit(0) }

        do {
            try install(to: destination)
        } catch {
            let failure = NSAlert(error: error)
            failure.messageText = "Amar Avro Keyboard could not be installed"
            failure.informativeText = error.localizedDescription
                + "\n\nYou can install it by hand: copy Amar Avro Keyboard into ~/Library/Input Methods, then log out and back in."
            failure.runModal()
            exit(1)
        }

        let done = NSAlert()
        done.messageText = replacing ? "Amar Avro Keyboard was updated" : "Amar Avro Keyboard was installed"
        done.informativeText = replacing
            ? "The new version is ready to use; no need to log out."
            : "It has been copied to ~/Library/Input Methods. Log out and log back in, then open System Preferences > Keyboard > Input Sources and use + to add it under Bangla or Other.\n\n"
              + "If it is still missing, restart the Mac and check that only one copy of Amar Avro Keyboard is installed."
        done.runModal()
        exit(0)
        #endif
    }

    private static func install(to destination: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: userFolder, withIntermediateDirectories: true)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        // ditto keeps the bundle intact (signature, resource forks) and --noqtn leaves the
        // quarantine flag behind so the installed copy is not app-translocated on launch.
        let ditto = Process()
        ditto.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        ditto.arguments = ["--noqtn", Bundle.main.bundlePath, destination.path]
        try ditto.run()
        ditto.waitUntilExit()
        guard ditto.terminationStatus == 0 else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileWriteUnknownError, userInfo: [
                NSLocalizedDescriptionKey: "Copying the app failed (ditto exited with \(ditto.terminationStatus)).",
            ])
        }

        // An older copy may still be running as the input method; stop it so macOS
        // launches the new one on demand instead of needing a logout.
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        let myPID = ProcessInfo.processInfo.processIdentifier
        for running in NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        where running.processIdentifier != myPID {
            if !running.forceTerminate() {
                NSLog("Could not terminate running Avro Keyboard (pid \(running.processIdentifier))")
            }
        }

        // Register and enable the copied bundle with macOS Text Input Sources.
        registerInputSource(at: destination)
    }

    /// Registers the installed bundle even when it was copied into Input Methods
    /// manually. Registration can report an "already registered" status, so always
    /// query the current source list afterward instead of returning on that status.
    private static func registerInputSource(at bundleURL: URL) {
        let status = TISRegisterInputSource(bundleURL as CFURL)
        if status != noErr {
            NSLog("Amar Avro Keyboard: TISRegisterInputSource returned \(status); checking existing registrations")
        }

        let bundleIdentifier = Bundle(url: bundleURL)?.bundleIdentifier
            ?? Bundle.main.bundleIdentifier
            ?? "app.aminul.inputmethod.AvroKeyboard"
        let filter = [kTISPropertyInputSourceID as String: bundleIdentifier] as CFDictionary

        // Text Input Sources can update asynchronously. Retry for a short period.
        for _ in 0..<50 {
            if let sources = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource],
               let source = sources.first {
                let enabled = TISEnableInputSource(source)
                if enabled != noErr {
                    NSLog("Amar Avro Keyboard: TISEnableInputSource returned \(enabled)")
                } else {
                    let selected = TISSelectInputSource(source)
                    if selected != noErr {
                        NSLog("Amar Avro Keyboard: TISSelectInputSource returned \(selected)")
                    }
                }
                return
            }
            Thread.sleep(forTimeInterval: 0.1)
        }

        NSLog("Amar Avro Keyboard: input source is not yet visible to Text Input Sources. Log out and back in, then check System Settings > Keyboard > Text Input > Edit.")
    }
}
