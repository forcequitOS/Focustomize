import SwiftUI
import SystemImagePicker

struct ContentView: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var showingSymbolPicker = false
    @State private var symbol = ""
    @State private var selectedMode: FocusMode?
    @State private var showingAlert = false
    @State private var showingRenamePicker = false
    @State private var hasEdited = false
    @AppStorage("hasAppliedChanges") private var hasAppliedChanges = false
    @AppStorage("colorfulSidebar") public var colorfulSidebar = false
    @AppStorage("showAdvancedSettings") public var showAdvancedSettings = false
    private func updateModeNameIfNeeded(for mode: FocusMode?) {
        guard let mode = mode else { return }
        if !hasEdited {
            viewModel.newModeName = mode.name
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar remains unchanged
            List(viewModel.focusModes, selection: $selectedMode) { mode in
                NavigationLink(value: mode) {
                    Label {
                        Text(mode.name)
                    } icon: {
                        safeSystemImage(mode.symbolName.isEmpty ? "" : mode.symbolName)
                            .foregroundStyle(colorfulSidebar ? .white : (getColor(for: mode.colorName)))
                            .font(.system(size: 16))
                    }
                }
            }
            .frame(minWidth: 220)
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden)
            .accentColor(colorfulSidebar ? getColor(for: viewModel.selectedColor) : .gray)
        } detail: {
            if let mode = selectedMode {
                // Wrap the existing VStack in a ScrollView
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        // Preview Section
                        GroupBox {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(getColor(for: viewModel.selectedColor))
                                        .frame(width: 94, height: 94)
                                    safeSystemImage(mode.symbolName.isEmpty ? "" : mode.symbolName)
                                        .font(.system(size: 44))
                                        .foregroundStyle(.white)
                                }
                                
                                Text(viewModel.newModeName)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(getColor(for: viewModel.selectedColor))
                                    .onAppear {
                                        viewModel.selectedColor = mode.colorName
                                        symbol = mode.symbolName
                                        updateModeNameIfNeeded(for: mode)
                                    }
                                    .onChange(of: selectedMode) { newMode in
                                        updateModeNameIfNeeded(for: newMode)
                                    }
                                    .multilineTextAlignment(.center)
                                    .lineLimit(5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding(.horizontal)
                        
                        // Symbol Picker Section
                        GroupBox("Display") {
                            HStack(spacing: 12) {
                                Button("Rename \(mode.name)...") {
                                    showingRenamePicker = true
                                }
                                .popover(isPresented: $showingRenamePicker, arrowEdge: .top) {
                                    VStack(spacing: 16) {
                                        // Updated to use viewModel.newModeName
                                        Text("Rename \(mode.name)")
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .tint(getColor(for: viewModel.selectedColor))
                                            .lineLimit(1)
                
                                        TextEditor(text: $viewModel.newModeName)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(getColor(for: viewModel.selectedColor))
                                            .padding()
                                            .frame(width: 250, height: 150)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                            )
                                            .onAppear() {
                                                if hasEdited == false {
                                                    hasEdited = true
                                                }
                                            }
                                            .padding(.horizontal)
                                            .buttonStyle(.borderedProminent)
                                    }
                                    .cornerRadius(12)
                                    .frame(width: 250)
                                    .padding()
                                }
                                
                                Button("Edit Symbol...") {
                                    showingSymbolPicker = true
                                }
                                .systemImagePicker(
                                    isPresented: $showingSymbolPicker,
                                    selection: $symbol
                                )
                                .onChange(of: symbol) { newSymbol in
                                    if !newSymbol.isEmpty {
                                        viewModel.newSymbolName = newSymbol
                                    }
                                    updateModeNameIfNeeded(for: selectedMode)
                                }
                                .help(Text("Select to open a SF Symbol picker!"))
                                
                                Button("Remove Symbol") {
                                    symbol = "blank"
                                    viewModel.newSymbolName = "blank"
                                    viewModel.selectedMode?.symbolName = "blank"
                                }
                                .disabled(symbol.isEmpty && mode.symbolName.isEmpty)
                                .help(Text("Sets your Focus symbol to \"blank\""))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding(.horizontal)
                        
                        // Color Picker Section
                        GroupBox("Color") {
                            VStack(spacing: 15) {
                                ColorGroupSection(
                                    title: "System Colors",
                                    colors: [
                                        "systemRedColor", "systemOrangeColor", "systemYellowColor",
                                        "systemGreenColor", "systemMintColor", "systemTealColor",
                                        "systemCyanColor", "systemBlueColor", "systemIndigoColor",
                                        "systemPurpleColor", "systemPinkColor"
                                    ],
                                    selectedColor: $viewModel.selectedColor
                                )
                                
                                ColorGroupSection(
                                    title: "Neutral System Colors",
                                    colors: [
                                        "systemBrownColor",
                                        "systemGrayColor", "systemGray2Color", "systemGray3Color",
                                        "systemGray4Color", "systemGray5Color", "systemGray6Color"
                                    ],
                                    selectedColor: $viewModel.selectedColor
                                )
                                
                                ColorGroupSection(
                                    title: "Vibrant Colors",
                                    colors: [
                                        "redColor", "orangeColor", "yellowColor",
                                        "greenColor", "cyanColor", "blueColor",
                                        "purpleColor", "magentaColor"
                                    ],
                                    selectedColor: $viewModel.selectedColor
                                )
                                
                                ColorGroupSection(
                                    title: "Grayscale",
                                    colors: [
                                        "brownColor", "whiteColor", "lightGrayColor", "grayColor", "darkGrayColor", "blackColor", "clearColor"
                                    ],
                                    selectedColor: $viewModel.selectedColor
                                )
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                        
                        Toggle("Show Advanced Settings", isOn: $showAdvancedSettings)
                            .padding(.horizontal)
                        
                        // Add the new AdvancedSettingsView
                        if let mode = selectedMode {
                            AdvancedSettingsView(mode: mode)
                        }
                        
                        // Update Button
                        Button("Apply Changes") {
                            if !hasAppliedChanges {
                                // Show an alert the first time changes are applied
                                showingAlert = true
                            }
                            
                            // Preserve the current selection
                            let currentSelectedMode = selectedMode
                            
                            // Update the focus mode
                            viewModel.selectedMode = mode
                            viewModel.updateFocusMode()
                            
                            // Reload focus modes to ensure latest data
                            viewModel.loadFocusModes()
                            
                            // Restore the selection and force a name update
                            DispatchQueue.main.async {
                                if let updatedMode = self.viewModel.focusModes.first(where: { $0.id == currentSelectedMode?.id }) {
                                    self.selectedMode = updatedMode
                                } else {
                                    self.selectedMode = nil
                                }
                            }
                            
                            if hasEdited == false {
                                viewModel.newModeName = mode.name
                                updateModeNameIfNeeded(for: selectedMode)
                            }
                            if hasEdited == true {
                                hasEdited = false
                                updateModeNameIfNeeded(for: selectedMode)
                            }
                            
                            // Mark that changes have been applied
                            hasAppliedChanges = true
                        }
                        .help(Text("Apply your changes!"))
                        .keyboardShortcut(.return)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(
                            symbol == mode.symbolName &&
                            viewModel.selectedColor == mode.colorName &&
                            hasEdited == false
                        )
                        Spacer()
                    }
                    .padding(.vertical)
                    .frame(minWidth: 500)
                }
                .onAppear {
                    viewModel.selectedColor = mode.colorName
                    symbol = mode.symbolName
                    viewModel.newModeName = mode.name
                }
                .tint(getColor(for: viewModel.selectedColor))
            }
            else {
                VStack {
                    Text("Select a Focus Mode to edit")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("If no Focus Modes are displaying, ensure Focustomize has Full Disk Access permissions.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 20)
                }
                .frame(minWidth: 500)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 750, maxWidth: 1050, minHeight: 400, maxHeight: 800) // Apply here
        .onAppear() {
            NSWindow.allowsAutomaticWindowTabbing = false
        }
        .onDisappear() {
            exit(0)
        }
        .toolbar() {
            Button(action: {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Focus-Settings.extension")!)
            })
            {
                Label("System Settings", systemImage: "arrow.up.right.square")
            }
            Button(action: {
                viewModel.loadFocusModes()
            })
            {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .keyboardShortcut("r", modifiers: [.command])
        }
        .onChange(of: selectedMode) { newMode in
            if let mode = newMode {
                withAnimation(.snappy) {
                    viewModel.selectedColor = mode.colorName
                    symbol = mode.symbolName
                    viewModel.newModeName = mode.name
                    hasEdited = false
                }
            }
        }
        
        .alert("Syncing Focustomize Changes", isPresented: $showingAlert) {
            Button("Got it!", role: .none) {
                // Literally nothing.
            }
        } message: {
            Text("Focustomize can't currently sync any modifications to your other devices over iCloud. To sync changes, change any aspect about your \(viewModel.selectedMode?.name ?? "Unnamed") Focus from System Settings manually.")
        }

        .alert("Full Disk Access Required", isPresented: $viewModel.needsFullDiskAccess) {
            Button("Open System Settings...", role: .none) {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    exit(0)
                }
            }
            Button("Quit") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    exit(0)
                }
            }
        }
        message: {
            Text("Focustomize requires Full Disk Access permissions to modify your Focus Modes!")
        }
    }
    public func resetSettings() {
        showAdvancedSettings = false
        colorfulSidebar = false
    }
}

extension ContentView {
    @ViewBuilder
    func AdvancedSettingsView(mode: FocusMode) -> some View {
        if showAdvancedSettings {
            GroupBox("Advanced Mode Management") {
                VStack(alignment: .leading, spacing: 15) {
                    // Mode Identifier Management
                    HStack {
                        Text("Mode Identifier")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(mode.modeIdentifier)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    
                    Divider()
                    
                    // Semantic Type Management
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Semantic Type")
                            .fontWeight(.medium)
                        
                        Picker("Semantic Type", selection: Binding(
                            get: { semanticTypeToIndex(mode.semanticType) },
                            set: { newIndex in
                                let semanticType = indexToSemanticType(newIndex)
                                viewModel.updateSemanticType(for: mode, semanticType: semanticType)
                            }
                        )) {
                            Text("Default").tag(0)
                            Text("Work").tag(1)
                            Text("Personal").tag(2)
                            Text("Fitness").tag(3)
                            Text("Gaming").tag(4)
                            Text("Other").tag(5)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider()
                    
                    // Visibility Toggle
                    Toggle("Visible in System Settings", isOn: Binding(
                        get: { mode.isVisible },
                        set: { newVisibility in
                            viewModel.setFocusModeVisibility(for: mode, isVisible: newVisibility)
                        }
                    ))
                    
                    Divider()
                    
                    // Duplicate and Delete Buttons
                    HStack {
                        Button("Duplicate Mode") {
                            viewModel.duplicateFocusMode(mode)
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Delete Mode") {
                            // Implement deletion logic
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .transition(.slide)
        }
    }
    
    // Helpers for Semantic Type Conversion
    private func semanticTypeToIndex(_ semanticType: Int?) -> Int {
        switch semanticType {
        case -1: return -1  // Default
        case 1: return 1  // Work
        case 2: return 2  // Personal
        case 3: return 3  // Fitness
        case 4: return 4  // Gaming
        default: return 5 // Other
        }
    }
    
    private func indexToSemanticType(_ index: Int) -> Int {
        switch index {
        case -1: return -1   // Default
        case 1: return 1   // Work
        case 2: return 2   // Personal
        case 3: return 3   // Fitness
        case 4: return 4   // Gaming
        default: return 5  // Other
        }
    }
}

@ViewBuilder
private func safeSystemImage(_ name: String) -> some View {
    if let _ = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
        Image(systemName: name)
    } else {
        Image(_internalSystemName: name)
            .accessibilityHidden(true)
    }
}
