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

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin
#endif

struct PluginTarget {
    let name: String
    let rootDirectory: URL
    let sourcesDirectory: URL
    let dependencies: [String]
    let dependenciesSources: [URL]
    let isTest: Bool

    init(target: PackagePlugin.Target) {
        self.name = target.name
        self.rootDirectory = URL(fileURLWithPath: target.directory.string)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        self.sourcesDirectory = target.getSourcesDirectory()
        self.dependencies = target.getDependenciesTargetNames()
        self.dependenciesSources = target.getDependenciesTargetSources()
        self.isTest = target.isTestTarget()
    }
}

#if canImport(XcodeProjectPlugin)
    extension PluginTarget {
        init(
            context: XcodeProjectPlugin.XcodePluginContext,
            target: XcodeProjectPlugin.XcodeTarget
        ) {
            self.name = target.displayName
            self.rootDirectory = context.xcodeProject.directoryURL
            self.sourcesDirectory = target.getSourcesDirectory()
            self.dependencies = target.getDependenciesTargetNames(
                context: context
            )
            self.dependenciesSources = target.getDependenciesTargetSources(
                context: context
            )
            self.isTest = target.isTestTarget()
        }
    }
#endif

protocol PluginConfig: Decodable {
    static var defaultConfig: Self { get }
}

protocol SourceryStencilPlugin: BuildToolPlugin {
    associatedtype Config: PluginConfig

    var name: String { get }
    var configFileName: String { get }

    func getSources(target: PluginTarget) -> [URL]

    func getTemplates() -> [URL]

    func getImports(target: PluginTarget, config: Config) -> [String]

    func getTestableImports(target: PluginTarget, config: Config) -> [String]

    func getConfigArguments(target: PluginTarget, config: Config) -> [String]
}

extension SourceryStencilPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) async throws -> [Command] {
        return [
            createCleanCommand(
                targetName: target.name,
                workDirectoryUrl: context.pluginWorkDirectoryURL
            ),
            createSourceryBuildCommand(
                sourceryExecutable: try context.tool(named: "sourcery"),
                workDirectoryUrl: context.pluginWorkDirectoryURL,
                target: .init(target: target)
            ),
        ]
    }

    /// Clean previously-generated codes
    private func createCleanCommand(
        targetName: String,
        workDirectoryUrl: URL
    ) -> Command {
        let outputDirectoryUrl = workDirectoryUrl.appending(path: "Generated")
        let cleanArgs = ["-rf", outputDirectoryUrl.absoluteString]
        return .prebuildCommand(
            displayName:
                "[\(name)] Clean previously-generated data for \(targetName)",
            executable: .init(filePath: "/bin/rm")!,
            arguments: cleanArgs,
            outputFilesDirectory: workDirectoryUrl
        )
    }

    /// Generate codes from latest changes
    private func createSourceryBuildCommand(
        sourceryExecutable: PackagePlugin.PluginContext.Tool,
        workDirectoryUrl: URL,
        target: PluginTarget,
    ) -> Command {
        let outputDirectoryUrl = workDirectoryUrl.appending(path: "Generated")
        let cacheDirectoryUrl = workDirectoryUrl.appending(path: "Cache")

        let config = parseConfig(
            configFileURL: target.rootDirectory.appending(path: configFileName)
        )
        let sourcesArgs = getSources(target: target).flatMap { url in
            ["--sources", url.path]
        }
        let templateArgs = getTemplates().flatMap { url in
            ["--templates", url.path]
        }
        let importArgs = [
            "--args", "imports=\(getImports(target: target, config: config))",
        ]
        let testableImportArgs = [
            "--args",
            "testableImports=\(getTestableImports(target: target, config: config))",
        ]
        let configArgs = getConfigArguments(target: target, config: config)
            .flatMap { arg in
                ["--args", arg]
            }

        let outputArgs = ["--output", outputDirectoryUrl.path]
        let cacheArgs = ["--cacheBasePath", cacheDirectoryUrl.path]
        let extraArgs = ["--verbose"]

        return .prebuildCommand(
            displayName: "[\(name)] Generate sources for target: \(target)",
            executable: sourceryExecutable.url,
            arguments: sourcesArgs + templateArgs + importArgs
                + testableImportArgs + configArgs + outputArgs + cacheArgs
                + extraArgs,
            outputFilesDirectory: outputDirectoryUrl
        )
    }

    func getPluginRootPath() -> URL {
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func parseConfig(configFileURL: URL) -> Config {
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

extension PackagePlugin.Target {
    func isTestTarget() -> Bool {
        return name.hasSuffix("Tests")
    }

    func getSourcesDirectory() -> URL {
        return URL(fileURLWithPath: directory.string)
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

#if canImport(XcodeProjectPlugin)
    extension SourceryStencilPlugin {

        func createBuildCommands(
            context: XcodeProjectPlugin.XcodePluginContext,
            target: XcodeProjectPlugin.XcodeTarget
        ) throws -> [PackagePlugin.Command] {
            return [
                createCleanCommand(
                    targetName: target.displayName,
                    workDirectoryUrl: context.pluginWorkDirectoryURL
                ),
                createSourceryBuildCommand(
                    sourceryExecutable: try context.tool(named: "sourcery"),
                    workDirectoryUrl: context.pluginWorkDirectoryURL,
                    target: .init(
                        context: context,
                        target: target
                    )
                ),
            ]
        }
    }

    extension XcodeProjectPlugin.XcodeTarget {
        func isTestTarget() -> Bool {
            guard let kind = product?.kind else { return false }
            if case .other(let name) = kind {
                return name == "com.apple.product-type.bundle.unit-test"
            }
            return false
        }

        func getSourcesDirectory() -> URL {
            let allPaths = inputFiles.map(\.url).filter {
                $0.pathExtension == "swift"
            }
            let commonPrefix =
                allPaths
                .map { $0.path }
                .reduce(allPaths.first?.path ?? "") { prefix, path in
                    String(prefix.commonPrefix(with: path))
                }

            return URL(fileURLWithPath: commonPrefix, isDirectory: true)
        }

        func getDependenciesTargetNames(
            context: XcodeProjectPlugin.XcodePluginContext
        ) -> [String] {
            var deps: [String] = []
            for target in context.xcodeProject.targets {
                if case .application = target.product?.kind {
                    deps.append(target.displayName)
                }
            }
            for dep in dependencies {
                if case .target(let deptarget) = dep {
                    deps.append(deptarget.displayName)
                }
            }
            return deps
        }

        func getDependenciesTargetSources(
            context: XcodeProjectPlugin.XcodePluginContext
        ) -> [URL] {
            var sources: [URL] = []
            for target in context.xcodeProject.targets {
                if case .application = target.product?.kind {
                    sources.append(
                        target.getSourcesDirectory()
                    )
                }
            }
            for dep in dependencies {
                if case .target(let deptarget) = dep {
                    sources.append(
                        deptarget.getSourcesDirectory()
                    )
                }
            }
            return sources
        }
    }
#endif
