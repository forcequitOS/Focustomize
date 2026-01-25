//
//  SettingsView.swift
//  Focustomize
//
//  Created by Taj C on 11/26/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var colorfulSidebar: Bool
    @Binding var showAdvancedSettings: Bool
    @State private var showingResetAlert = false

    var body: some View {
        Form {
            Section {
                Toggle("Use Colorful Sidebar", isOn: $colorfulSidebar)
            }
            Section {
                Toggle("Show Advanced Settings", isOn: $showAdvancedSettings)
            }
            
            Section {
                Button(role: .destructive, action: {
                    // Show the confirmation dialog
                    showingResetAlert = true
                }) {
                    Text("Reset All Settings")
                }
            }
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset All Settings"),
                    message: Text("This will reset all Focustomize settings and alerts, are you sure you want to continue?"),
                    primaryButton: .destructive(Text("Reset")) {
                        // Call resetSettings to update bindings
                        ContentView().resetSettings()
                        // A horribly hacky method to close the Settings window (After a 0.5 second delay for the animation, of course!)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let preferencesWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                                preferencesWindow.close()
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle("Settings")
        .padding(20)
        .frame(width: 250)
        .willRestore(false)
        .onAppear {
            if let preferencesWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                preferencesWindow.center()
            }
        }
    }
}

// Disables window restoration behavior
struct WillRestore: ViewModifier {
    let restore: Bool

    func body(content: Content) -> some View {
    content
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification), perform: { output in
            let window = output.object as! NSWindow
            window.isRestorable = restore
        })
    }
}

// Helps with disabling window restoration behavior, or something like that
extension View {
    func willRestore(_ restoreState: Bool = true) -> some View {
        modifier(WillRestore(restore: restoreState))
    }
}
