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

    func getSources(target: PackagePlugin.Target) -> [URL] {
        if target.isTestTarget() {
            // Tests target will use dependencies target source
            return target.getDependenciesTargetSources()
        } else {
            // Regular target
            return target.getSources()
        }
    }

    func getTemplates(context: PackagePlugin.PluginContext) -> [URL] {
        let pluginPath = getPluginRootPath()
        return [
            pluginPath.appending(path: "Stencils/Mockable.stencil"),
            pluginPath.appending(path: "Stencils/Randomizable.stencil"),
            pluginPath.appending(path: "Stencils/MockSwift.stencil"),
        ]
    }

    func getImports(target: Target, config: Config) -> [String] {
        config.imports
    }

    func getTestableImports(target: Target, config: Config) -> [String] {
        if target.isTestTarget() {
            return target.getDependenciesTargetNames() + config.testableImports
        } else {
            return config.testableImports
        }
    }

    func getConfigArguments(target: Target, config: Config) -> [String] {
        return [
            "debugOnly=\(config.debugOnly)",
            "randomStdLib=\(config.randomStdLib)",
            "randomStdLibProtection=\(config.randomStdLibProtection)",
        ]
    }
}
