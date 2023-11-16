//
//  ContentView.swift
//  ItDepartment
//
//  Created by Luo Sheng on 2023/11/16.
//

import SwiftUI

struct ContentView: View {
    @State private var animating = false
    
    private var logo: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(.system(size: 100))
            .imageScale(.large)
            .foregroundStyle(.tint)
            .tint(.indigo)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            if #available(macOS 14, *) {
                logo
                    .symbolEffect(.pulse, options: .repeat(Int.max), value: animating)
            } else {
                logo
            }
            Text("Hello, IT")
                .font(.largeTitle)
                .bold()
        }
        .frame(width: 300, height: 300)
        .padding()
        .task {
            setupScript()
            withAnimation {
                animating = true
            }
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
