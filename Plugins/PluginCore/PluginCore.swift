//
// Copyright © 2025 Steven Lewi.
// All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import PackagePlugin

protocol PluginConfig: Decodable {
    static var defaultConfig: Self { get }
}

protocol SourceryStencilPlugin: BuildToolPlugin {
    associatedtype Config: PluginConfig

    var name: String { get }
    var configFileName: String { get }

    func getSources(target: Target) -> [URL]

    func getTemplates(context: PluginContext) -> [URL]

    func getImports(target: Target, config: Config) -> [String]

    func getTestableImports(target: Target, config: Config) -> [String]

    func getConfigArguments(target: Target, config: Config) -> [String]
}

extension SourceryStencilPlugin {

    func createBuildCommands(context: PluginContext, target: Target)
        async throws -> [Command]
    {
        let workDirectoryUrl = context.pluginWorkDirectoryURL
        let outputDirectoryUrl = workDirectoryUrl.appending(path: "Generated")
        let cacheDirectoryUrl = workDirectoryUrl.appending(path: "Cache")

        // Clean previously-generated codes
        let cleanArgs = ["-rf", outputDirectoryUrl.absoluteString]
        let cleanCommand = Command.prebuildCommand(
            displayName: "[\(name)] Clean previously-generated data",
            executable: .init(filePath: "/bin/rm")!,
            arguments: cleanArgs,
            outputFilesDirectory: workDirectoryUrl
        )

        // Generate codes from latest changes
        let config = parseConfig(target: target)
        let sourceryExecutable = try context.tool(named: "sourcery")
        let sourcesArgs = getSources(target: target).flatMap { url in
            ["--sources", url.path]
        }
        let templateArgs = getTemplates(context: context).flatMap { url in
            ["--templates", url.path]
        }
        let importArgs = [
            "--args", "imports=\(getImports(target: target, config: config))",
        ]
        let testableImportArgs = [
            "--args",
            "testableImports=\(getTestableImports(target: target, config: config))",
        ]
        let configArgs = getConfigArguments(target: target, config: config).flatMap { arg in
            ["--args", arg]
        }

        let outputArgs = ["--output", outputDirectoryUrl.path]
        let cacheArgs = ["--cacheBasePath", cacheDirectoryUrl.path]
        let extraArgs = ["--verbose"]

        let sourceryCommand = Command.prebuildCommand(
            displayName: "[\(name)] Generate sources for target: \(target)",
            executable: sourceryExecutable.url,
            arguments: sourcesArgs + templateArgs + importArgs
                + testableImportArgs + configArgs + outputArgs + cacheArgs
                + extraArgs,
            outputFilesDirectory: outputDirectoryUrl
        )

        return [cleanCommand, sourceryCommand]
    }

    func getPluginRootPath() -> URL {
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func parseConfig(target: Target) -> Config {
        let configFileURL = URL(fileURLWithPath: target.directory.string)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: configFileName)
        guard FileManager.default.fileExists(atPath: configFileURL.path) else {
            return Config.defaultConfig
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let data = try Data(contentsOf: configFileURL)
            return try decoder.decode(Config.self, from: data)
        } catch {
            Diagnostics.warning("Failed to load config with error: \(error)")
            return Config.defaultConfig
        }
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SourceryStencilPlugin {

        func createBuildCommands(
            context: XcodeProjectPlugin.XcodePluginContext,
            target: XcodeProjectPlugin.XcodeTarget
        ) throws -> [PackagePlugin.Command] {
            // TODO: will be implemented later
            return []
        }
    }
#endif

extension PackagePlugin.Target {
    func isTestTarget() -> Bool {
        return name.hasSuffix("Tests")
    }

    func getSources() -> [URL] {
        return [URL(fileURLWithPath: directory.string)]
    }
    
    func getDependenciesTargetNames() -> [String] {
        var deps: [String] = []
        for dep in dependencies {
            if case .target(let deptarget) = dep {
                deps.append(deptarget.name)
            }
        }
        return deps
    }

    func getDependenciesTargetSources() -> [URL] {
        var sources: [URL] = []
        for dep in dependencies {
            if case .target(let deptarget) = dep {
                sources.append(
                    URL(fileURLWithPath: deptarget.directory.string)
                )
            }
        }
        return sources
    }
}
