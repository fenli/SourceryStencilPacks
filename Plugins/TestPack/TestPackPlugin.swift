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

struct TestPackPluginConfig: PluginConfig {
    static var defaultConfig: TestPackPluginConfig { TestPackPluginConfig() }

    var debugOnly: Bool = false
    var randomStdLib: Bool = true
    var randomStdLibProtection: String = "internal"
    var imports: [String] = []
    var testableImports: [String] = []
}

@main
struct TestPackPlugin: SourceryStencilPlugin {
    var name: String = "TestPack"
    var configFileName: String = ".testpack.json"
    typealias Config = TestPackPluginConfig

    func getSources(target: PluginTarget) -> [URL] {
        if target.isTest {
            // Tests target will use dependencies target source
            return target.dependenciesSources
        } else {
            // Regular target
            return [target.sourcesDirectory]
        }
    }

    func getTemplates() -> [URL] {
        let pluginPath = getPluginRootPath()
        return [
            pluginPath.appending(path: "Stencils/Mockable.stencil"),
            pluginPath.appending(path: "Stencils/Randomizable.stencil"),
            pluginPath.appending(path: "Stencils/MockSwift.stencil"),
        ]
    }

    func getImports(target: PluginTarget, config: Config) -> [String] {
        config.imports
    }

    func getTestableImports(target: PluginTarget, config: Config) -> [String] {
        if target.isTest {
            return target.dependencies + config.testableImports
        } else {
            return config.testableImports
        }
    }

    func getConfigArguments(target: PluginTarget, config: Config) -> [String] {
        return [
            "debugOnly=\(config.debugOnly)",
            "randomStdLib=\(config.randomStdLib)",
            "randomStdLibProtection=\(config.randomStdLibProtection)",
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension TestPackPlugin: XcodeBuildToolPlugin {}
#endif
