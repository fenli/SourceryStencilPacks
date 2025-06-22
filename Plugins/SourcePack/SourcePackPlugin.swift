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

struct SourcePackPluginConfig: PluginConfig {
    static var defaultConfig: SourcePackPluginConfig {
        SourcePackPluginConfig()
    }

    var debugOnly: Bool = false
    var imports: [String] = []
}

@main
struct SourcePackPlugin: SourceryStencilPlugin {
    var name: String = "SourcePack"
    var configFileName: String = ".sourcepack.json"
    typealias Config = SourcePackPluginConfig

    func getSources(target: PluginTarget) -> [URL] {
        return [target.sourcesDirectory]
    }

    func getTemplates() -> [URL] {
        let pluginPath = getPluginRootPath()
        return [
            pluginPath.appending(path: "Stencils/Copyable.stencil"),
            pluginPath.appending(path: "Stencils/Equatable.stencil"),
            pluginPath.appending(path: "Stencils/Hashable.stencil"),
            pluginPath.appending(path: "Stencils/Describable.stencil"),
        ]
    }

    func getImports(target: PluginTarget, config: Config) -> [String] {
        config.imports
    }

    func getTestableImports(target: PluginTarget, config: Config) -> [String] {
        return []
    }

    func getConfigArguments(target: PluginTarget, config: Config) -> [String] {
        return [
            "debugOnly=\(config.debugOnly)"
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SourcePackPlugin: XcodeBuildToolPlugin {}
#endif
