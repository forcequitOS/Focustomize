//
//  Models.swift
//  Focustomize
//
//  Created by Taj C on 11/25/24.
//

import SwiftUI

// MARK: - Models
struct FocusMode: Identifiable, Hashable {
    let id: String
    var name: String
    var symbolName: String
    var colorName: String
    var modeIdentifier: String
    var isVisible: Bool
    var semanticType: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ModeConfiguration: Codable {
    var mode: Mode
    
    struct Mode: Codable {
        var name: String
        var symbolImageName: String
        var tintColorName: String
        var modeIdentifier: String
        var visibility: Int
    }
}

// MARK: - View Models
class FocusViewModel: ObservableObject {
    @Published var focusModes: [FocusMode] = []
    @Published var selectedMode: FocusMode?
    @Published var newSymbolName: String = ""
    @Published var selectedColor: String = ""
    @Published var newModeName: String = "" // New property for custom mode name
    public var needsFullDiskAccess: Bool = false
    
    let availableColors = [
        // GROUP 1
        "systemRedColor", "systemOrangeColor", "systemYellowColor",
        "systemGreenColor", "systemMintColor", "systemTealColor",
        "systemCyanColor", "systemBlueColor", "systemIndigoColor",
        "systemPurpleColor", "systemPinkColor",
        // GROUP 2
        "systemBrownColor",
        "systemGrayColor", "systemGray2Color", "systemGray3Color",
        "systemGray4Color", "systemGray5Color", "systemGray6Color",
        // GROUP 3
        "redColor", "orangeColor", "yellowColor", "greenColor", "cyanColor", "blueColor", "purpleColor", "magentaColor",
        // Please display clearColor as just the outline circle
        // GROUP 4
        "brownColor", "whiteColor", "lightGrayColor", "grayColor", "darkGrayColor", "blackColor", "clearColor"
    ]
    
    init() {
        loadFocusModes()
    }
    
    private func getConfigurationPath() throws -> URL {
        guard let configPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("DoNotDisturb/DB/ModeConfigurations.json") else {
            throw NSError(domain: "FocusViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Cannot find configuration path"])
        }
        return configPath
    }
    
    func loadFocusModes() {
        guard let configPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("DoNotDisturb/DB/ModeConfigurations.json") else {
            print("Cannot find configuration path")
            return
        }
        
        do {
            let data = try Data(contentsOf: configPath)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let jsonData = json?["data"] as? [[String: Any]],
                  let modeConfigs = jsonData.first?["modeConfigurations"] as? [String: [String: Any]] else {
                print("Invalid JSON structure")
                return
            }
            
            focusModes = modeConfigs.compactMap { (key, value) -> FocusMode? in
                guard let mode = value["mode"] as? [String: Any],
                      let name = mode["name"] as? String,
                      let symbolName = mode["symbolImageName"] as? String,
                      let colorName = mode["tintColorName"] as? String,
                      let modeIdentifier = mode["modeIdentifier"] as? String,
                      let visibility = mode["visibility"] as? Int else {
                    return nil
                }
                
                // Skip modes with visibility set to 1
                guard visibility != 1 else {
                    return nil
                }
                
                return FocusMode(
                    id: key,
                    name: name,
                    symbolName: symbolName,
                    colorName: colorName,
                    modeIdentifier: modeIdentifier,
                    isVisible: visibility == 0,
                    semanticType: modeConfigs[key]?["semanticType"] as? Int ?? 5
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        } catch let error as NSError {
            print("Uh-oh! There was an error trying to read the configuration. Error: \(error)")
            if error.code == 257 {
                needsFullDiskAccess = true
            }
        }
    }
    
    func updateFocusMode() {
        guard let selectedMode = selectedMode,
              let configPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
                .appendingPathComponent("DoNotDisturb/DB/ModeConfigurations.json")
        else {
            return
        }
        
        do {
            let data = try Data(contentsOf: configPath)
            var json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard var jsonData = json?["data"] as? [[String: Any]],
                  var modeConfigs = jsonData.first?["modeConfigurations"] as? [String: [String: Any]] else {
                return
            }
            
            // Update the mode configuration
            if var config = modeConfigs[selectedMode.id],
               var mode = config["mode"] as? [String: Any] {
                // Update symbol if a new one is provided
                mode["symbolImageName"] = newSymbolName.isEmpty ? selectedMode.symbolName : newSymbolName
                
                // Update color
                mode["tintColorName"] = selectedColor
                
                // Update name if a new name is provided
                mode["name"] = newModeName
                
                config["mode"] = mode
                modeConfigs[selectedMode.id] = config
                jsonData[0]["modeConfigurations"] = modeConfigs
                json?["data"] = jsonData
                
                // Write back to file
                let updatedData = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                try updatedData.write(to: configPath)
                
                // Restart required services
                restartServices()
                // Reset the new name field
                newModeName = ""
                
                DispatchQueue.main.async {
                    self.loadFocusModes()
                }
            }
        } catch {
            print("Error updating configuration: \(error)")
        }
    }
    
    private func restartServices() {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["bash", "-c", "killall ControlCenter && killall donotdisturbd && killall \"System Settings\" && killall FocusSettingsExtension"]
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error restarting services: \(error)")
        }
    }
}

extension FocusViewModel {
    // MARK: - Mode Identifier Management
    
    /// Get the ModeIdentifier for a specific Focus mode
    func getModeIdentifier(for focusMode: FocusMode) -> String {
        return focusMode.modeIdentifier
    }
    
    /// Update the ModeIdentifier for a specific Focus mode
    func updateModeIdentifier(for focusMode: FocusMode, newIdentifier: String) {
        guard let index = focusModes.firstIndex(where: { $0.id == focusMode.id }) else {
            print("Focus mode not found")
            return
        }
        
        do {
            let configPath = try getConfigurationPath()
            var json = try loadJSONConfiguration(from: configPath)
            
            guard var jsonData = json["data"] as? [[String: Any]],
                  var modeConfigs = jsonData[0]["modeConfigurations"] as? [String: [String: Any]] else {
                print("Invalid JSON structure")
                return
            }
            
            if var config = modeConfigs[focusMode.id],
               var mode = config["mode"] as? [String: Any] {
                mode["modeIdentifier"] = newIdentifier
                config["mode"] = mode
                modeConfigs[focusMode.id] = config
                jsonData[0]["modeConfigurations"] = modeConfigs
                json["data"] = jsonData
                
                try saveJSONConfiguration(json, to: configPath)
                
                // Update local array
                focusModes[index].modeIdentifier = newIdentifier
                
                restartServices()
            }
        } catch {
            print("Error updating mode identifier: \(error)")
        }
    }
    
    // MARK: - Semantic Type Management
    
    /// Update the Semantic Type for a specific Focus mode
    func updateSemanticType(for focusMode: FocusMode, semanticType: Int) {
        guard focusModes.firstIndex(where: { $0.id == focusMode.id }) != nil else {
            print("Focus mode not found")
            return
        }
        
        do {
            let configPath = try getConfigurationPath()
            var json = try loadJSONConfiguration(from: configPath)
            
            guard var jsonData = json["data"] as? [[String: Any]],
                  var modeConfigs = jsonData[0]["modeConfigurations"] as? [String: [String: Any]] else {
                print("Invalid JSON structure")
                return
            }
            
            if var config = modeConfigs[focusMode.id] {
                config["semanticType"] = semanticType
                modeConfigs[focusMode.id] = config
                jsonData[0]["modeConfigurations"] = modeConfigs
                json["data"] = jsonData
                
                try saveJSONConfiguration(json, to: configPath)
                
                restartServices()
            }
        } catch {
            print("Error updating semantic type: \(error)")
        }
    }
    
    // MARK: - Focus Mode Visibility
    
    /// Set the visibility of a Focus mode
    func setFocusModeVisibility(for focusMode: FocusMode, isVisible: Bool) {
        guard let index = focusModes.firstIndex(where: { $0.id == focusMode.id }) else {
            print("Focus mode not found")
            return
        }
        
        do {
            let configPath = try getConfigurationPath()
            var json = try loadJSONConfiguration(from: configPath)
            
            guard var jsonData = json["data"] as? [[String: Any]],
                  var firstDataDict = jsonData.first,
                  var modeConfigs = firstDataDict["modeConfigurations"] as? [String: [String: Any]] else {
                print("Invalid JSON structure")
                return
            }
            
            if var config = modeConfigs[focusMode.id],
               var mode = config["mode"] as? [String: Any] {
                // Set visibility: 0 for visible, 1 for hidden
                mode["visibility"] = isVisible ? 0 : 1
                config["mode"] = mode
                modeConfigs[focusMode.id] = config
                
                firstDataDict["modeConfigurations"] = modeConfigs
                jsonData[0] = firstDataDict
                json["data"] = jsonData
                
                try saveJSONConfiguration(json, to: configPath)
                
                // Update local array
                focusModes[index].isVisible = isVisible
                
                restartServices()
            }
        } catch {
            print("Error updating focus mode visibility: \(error)")
        }
    }

    func duplicateFocusMode(_ focusMode: FocusMode) {
        do {
            let configPath = try getConfigurationPath()
            var json = try loadJSONConfiguration(from: configPath)
            
            guard var jsonData = json["data"] as? [[String: Any]],
                  var firstDataDict = jsonData.first,
                  var modeConfigs = firstDataDict["modeConfigurations"] as? [String: [String: Any]] else {
                print("Invalid JSON structure")
                return
            }
            
            // Generate a new UUID for the duplicated mode
            let newId = UUID().uuidString
            
            // Create a copy of the existing mode configuration
            if let existingConfig = modeConfigs[focusMode.id] {
                var newConfig = existingConfig
                
                // Modify the name to indicate it's a duplicate
                if var mode = newConfig["mode"] as? [String: Any] {
                    mode["name"] = "\(focusMode.name) (Copy)"
                    newConfig["mode"] = mode
                }
                
                // Add the new mode to configurations
                modeConfigs[newId] = newConfig
                
                firstDataDict["modeConfigurations"] = modeConfigs
                jsonData[0] = firstDataDict
                json["data"] = jsonData
                
                try saveJSONConfiguration(json, to: configPath)
                
                restartServices()
                
                // Reload focus modes to reflect the changes
                DispatchQueue.main.async {
                    self.loadFocusModes()
                }
            }
        } catch {
            print("Error duplicating focus mode: \(error)")
        }
    }

    func addNewFocusMode(name: String, symbolName: String, colorName: String, semanticType: Int = 5) {
        do {
            let configPath = try getConfigurationPath()
            var json = try loadJSONConfiguration(from: configPath)
            
            guard var jsonData = json["data"] as? [[String: Any]],
                  var firstDataDict = jsonData.first,
                  var modeConfigs = firstDataDict["modeConfigurations"] as? [String: [String: Any]] else {
                print("Invalid JSON structure")
                return
            }
            
            // Generate a new UUID
            let newId = UUID().uuidString
            
            // Create a new mode configuration
            let newConfig: [String: Any] = [
                "mode": [
                    "name": name,
                    "symbolImageName": symbolName,
                    "tintColorName": colorName,
                    "modeIdentifier": "com.apple.focus.\(name.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    "visibility": 0 // Default to visible
                ],
                "semanticType": semanticType,
                "created": Date().timeIntervalSince1970,
                "lastModified": Date().timeIntervalSince1970,
                "automaticallyGenerated": false,
                "hasSecureData": false,
                "resolvedCompatibilityVersion": 3
            ]
            
            // Add the new mode to configurations
            modeConfigs[newId] = newConfig
            
            firstDataDict["modeConfigurations"] = modeConfigs
            jsonData[0] = firstDataDict
            json["data"] = jsonData
            
            try saveJSONConfiguration(json, to: configPath)
            
            restartServices()
            
            // Reload focus modes to reflect the changes
            DispatchQueue.main.async {
                self.loadFocusModes()
            }
        } catch {
            print("Error adding new focus mode: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Load JSON configuration from file
    private func loadJSONConfiguration(from path: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: path)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "FocusViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }
        return json
    }
    
    /// Save JSON configuration to file
    private func saveJSONConfiguration(_ json: [String: Any], to path: URL) throws {
        let updatedData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try updatedData.write(to: path)
    }
}
