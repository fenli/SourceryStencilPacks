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

protocol PluginConfiguration {
    associatedtype Value: Codable
    
    var key: String { get }
    var value: Value { get set }
}

protocol SourceryStencilPlugin: BuildToolPlugin {
    var name: String { get }
    
    func getImports(context: PluginContext) -> [String]
    
    func getTestableImports(context: PluginContext) -> [String]
}

extension SourceryStencilPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let templatesPath = getPluginRootPath().appending(path: "Templates").path
        guard FileManager.default.fileExists(atPath: templatesPath) else {
            Diagnostics.error("Could not find templates for Sourcery at: \(templatesPath)")
            return []
        }

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
        let sourceryExecutable = try context.tool(named: "sourcery")
        
        let sourcesArgs = ["--sources", target.directory.string]
        let templateArgs = ["--templates", templatesPath]
        let importArgs = ["--args", "imports=\(getImports(context: context))"]
        let testableImportArgs = ["--args", "testableImports=\(getTestableImports(context: context))"]
        let outputArgs = ["--output", outputDirectoryUrl.path]
        let cacheArgs = ["--cacheBasePath", cacheDirectoryUrl.path]
        let additionalArgs = ["--verbose"]
        
        let sourceryCommand = Command.prebuildCommand(
            displayName: "[\(name)] Generate sources for target: \(target)",
            executable: sourceryExecutable.url,
            arguments: sourcesArgs + templateArgs + importArgs + testableImportArgs + outputArgs + cacheArgs + additionalArgs,
            outputFilesDirectory: outputDirectoryUrl
        )

        return [cleanCommand, sourceryCommand]
    }
    
    func getPluginRootPath() -> URL {
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
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
