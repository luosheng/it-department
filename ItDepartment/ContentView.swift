//
//  ContentView.swift
//  ItDepartment
//
//  Created by Luo Sheng on 2023/11/16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            setupScript()
        }
    }
    
    private func setupScript() {
        guard let scriptPath = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        let killScriptPath = scriptPath
            .deletingLastPathComponent()
            .appending(path: "com.pop-tap.ItDepartment.FinderExtension")
            .appending(path: "kill-scim.scpt")
        print(killScriptPath.path(percentEncoded: false))
        guard !FileManager.default.fileExists(atPath: killScriptPath.path(percentEncoded: false)) else {
            return
        }
        let killScript = """
tell application "Finder"
    activate
    do shell script "pkill -9 SCIM"
    do shell script "pkill -9 SCIM_Extension"
end tell
"""
        do {
            try killScript.write(to: killScriptPath, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing string to file: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
