//
//  FocustomizeApp.swift
//  Focustomize
//
//  Created by Taj C on 11/24/24.
//

import SwiftUI
import Summit

var appVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown Version"
}
let appType = "\"The Finale\""
var xcodeVersion: String {
    guard let dtxcodeString = Bundle.main.object(forInfoDictionaryKey: "DTXcode") as? String,
          let dtxcode = Int(dtxcodeString) else { return "Unknown" }
    let major = dtxcode / 100
    let minor = (dtxcode % 100) / 10
    return "\(major).\(minor)"
}
var xcodeBuild: String {
    Bundle.main.object(forInfoDictionaryKey: "DTXcodeBuild") as? String ?? "???"
}

@main
struct FocustomizeApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var viewModel = FocusViewModel()
    @AppStorage("colorfulSidebar") private var colorfulSidebar = false
    @AppStorage("showAdvancedSettings") private var showAdvancedSettings = false
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commandsRemoved()
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    openWindow(id: "about")
                }, label: {
                    Text("About Focustomize")
                })
            }
        }
        Window("About Focustomize", id: "about") {
            SummitView(
                links: [
                    ButtonLink(label: "Visit GitHub...", url: URL(string: "https://github.com/forcequitOS/Focustomize")!),
                ],
                fields: [
                    MultiField(label: "Crafted by", values: "@forcequitOS", "ChatGPT", "Claude", "Copilot", "Gemini", "Siri", "Cortana", "Apple Intelligence", "Bixby"),
                    Field(label: "Named by", value: "@dootskyre"),
                    Field(label: "Research help", value: "@dootskyre"),
                    MultiField(label: "Version", values: appVersion, appType),
                    MultiField(label: "Compiled with", values: "Xcode \(xcodeVersion)", "Xcode \(xcodeVersion) (\(xcodeBuild))")
                ],
                footers: [
                    "I beg of you to send me feedback please."
                ],
                subHeading: "I spent way too long on this."
            )
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        Settings() {
            SettingsView(colorfulSidebar: $colorfulSidebar, showAdvancedSettings: $showAdvancedSettings)
        }
    }
}
