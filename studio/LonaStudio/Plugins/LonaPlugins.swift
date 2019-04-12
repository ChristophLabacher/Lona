//
//  LonaPlugins.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

struct LonaPluginConfig: Decodable {
    var main: String
    var activationEvents: [LonaPluginActivationEvent]?
    var command: String?
}

class LonaPlugins {
    typealias SubscriptionHandle = () -> Void

    class Handler {
        var callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
    }

    struct PluginFile {

        // MARK: Public

        let url: URL

        var name: String {
            return url.lastPathComponent
        }

        func run(onSuccess: (String) -> Void) {
            guard let config = config else { return }

            let rpcService = RPCService()

            var arguments: [String] = []

            if let command = config.command {
                arguments.append(url.appendingPathComponent(command).path)
            }

            if LonaPlugins.nodeDebuggerIsEnabled {
                arguments.append("--inspect-brk")
            }

            arguments.append(url.appendingPathComponent(config.main).path)

            let sendData = LonaNode.launch(
                arguments: arguments,
                currentDirectoryPath: url.path,
                onData: rpcService.handleData,
                onSuccess: { output in
                    Swift.print("Output", String(data: output, encoding: String.Encoding.utf8) ?? "")

//                    DispatchQueue.main.async {
//                        let alert = NSAlert()
//                        alert.messageText = "Finished running \(self.name)"
//                        alert.informativeText = output ?? ""
//                        alert.runModal()
//                    }
            })

            rpcService.sendData = sendData
        }

        // MARK: Private

        var config: LonaPluginConfig? {
            let configUrl = url.appendingPathComponent("lonaplugin.json", isDirectory: false)
            guard let contents = try? Data(contentsOf: configUrl) else { return nil }
            return try? JSONDecoder().decode(LonaPluginConfig.self, from: contents)
        }
    }

    let urls: [URL]

    private static var handlers: [LonaPluginActivationEvent: [Handler]] = [:]

    init(urls: [URL]) {
        self.urls = urls
    }

    func pluginFiles() -> [PluginFile] {
        return urls.flatMap { LonaPlugins.pluginFiles(in: $0) }
    }

    func pluginFile(named name: String) -> PluginFile? {
        return pluginFiles().first(where: { arg in arg.name == name })
    }

    func pluginFilesActivatingOn(eventType: LonaPluginActivationEvent) -> [PluginFile] {
        return pluginFiles().filter({ file in
            file.config?.activationEvents?.contains(eventType) ?? false
        })
    }

    // MARK: - STATIC

    // this is the list of the plugins in:
    // - the `/plugins` folder of the current workspace
    // - the `~/Library/Application Support/${BUNDLE_IDENFIFIER}/plugins` folder
    static var current: LonaPlugins {
        do {
            let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
            let commonPluginsfolder = applicationSupportFolderURL.appendingPathComponent("\(appName)/plugins", isDirectory: true)
            if !FileManager.default.fileExists(atPath: commonPluginsfolder.path) {
                try FileManager.default.createDirectory(at: commonPluginsfolder, withIntermediateDirectories: true, attributes: nil)
            }

            return LonaPlugins(urls: [
                commonPluginsfolder,
                CSUserPreferences.workspaceURL.appendingPathComponent("plugins", isDirectory: true)
            ])
        } catch {
            print(error)
            return LonaPlugins(urls: [
                CSUserPreferences.workspaceURL.appendingPathComponent("plugins", isDirectory: true)
            ])
        }
    }

    static func pluginFiles(in workspace: URL) -> [PluginFile] {
        var files: [PluginFile] = []

        let fileManager = FileManager.default
        let keys = [URLResourceKey.isSymbolicLinkKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]
        let ignoreList = [".git", "node_modules"]

        var stack: [URL] = [workspace]
        var visited: [URL] = []

        while let url = stack.popLast() {
            visited.append(url)

            guard let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: options,
                errorHandler: {(_, _) -> Bool in true }) else { continue }

            outer: while let file = enumerator.nextObject() as? URL {
                for ignore in ignoreList where file.path.contains(ignore) {
                    enumerator.skipDescendants()
                    continue outer
                }

                let isSymlink = ((try? file.resourceValues(forKeys: [URLResourceKey.isSymbolicLinkKey]).isSymbolicLink) as Bool??)

                if isSymlink == true, !visited.contains(file) {
                    stack.append(file.resolvingSymlinksInPath())
                }

                if file.lastPathComponent == "lonaplugin.json" {
                    files.append(PluginFile(url: file.deletingLastPathComponent()))
                }
            }
        }

        return files
    }

    private static var nodeDebuggerIsEnabledKey = "Node debugger enabled"

    static var nodeDebuggerIsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: nodeDebuggerIsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nodeDebuggerIsEnabledKey)
        }
    }
}
