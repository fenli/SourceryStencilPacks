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
    
    var debugOnly: Bool = true
    var randomStdLib: Bool = true
    var randomStdLibProtection: String = "fileprivate"
    var imports: [String] = []
    var testableImports: [String] = []
}

@main
struct TestPackPlugin: SourceryStencilPlugin {
    var name: String = "TestPack"
    
    func getSources(target: PackagePlugin.Target) -> [URL] {
        [URL(fileURLWithPath: target.directory.string)]
    }
    
    func getTemplates(context: PackagePlugin.PluginContext) -> [URL] {
        let pluginPath = getPluginRootPath()
        return [
            pluginPath.appending(path: "Stencils/Mockable.stencil"),
            pluginPath.appending(path: "Stencils/Randomizable.stencil"),
        ]
    }
    
    func getImports(context: PluginContext, config: Config) -> [String] {
        config.imports
    }
    
    func getTestableImports(context: PluginContext, config: Config) -> [String] {
        config.testableImports
    }
    
    func getConfigArguments(config: TestPackPluginConfig) -> [String] {
        return [
            "debugOnly=\(config.debugOnly)",
            "randomStdLib=\(config.randomStdLib)",
            "randomStdLibProtection=\(config.randomStdLibProtection)"
        ]
    }
}
