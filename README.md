# SourceryStencilPacks
Convenient way to use collections of Sourcery stencils as an SPM plugins and Xcode plugins. Learn more about it from the [Sourcery repository](https://github.com/krzysztofzablocki/Sourcery).

[![](https://img.shields.io/github/v/release/fenli/SourceryStencilPacks?style=flat&label=Latest%20Release&color=blue)](https://github.com/fenli/SourceryStencilPacks/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffenli%2FSourceryStencilPacks%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/fenli/SourceryStencilPacks)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffenli%2FSourceryStencilPacks%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/fenli/SourceryStencilPacks)
[![](https://img.shields.io/github/license/fenli/SourceryStencilPacks?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.txt)

## How to install
### SPM
Add this configuration to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/fenli/SourceryStencilPacks", from: "0.1.1"),
],
```
Then add the plugins to your target:
```swift
.target(
    name: "MyPackage",
    plugins: [
        // Regular target plugins
    ]
)
.testTarget(
    name: "MyPackageTests",
    dependencies: ["MyPackage"],
    plugins: [
        // Test target plugins
        .plugin(name: "TestPack", package: "SourceryStencilPacks")
    ]
),
```

### XCode
-- coming soon --

# Plugins
## :rocket: TestPack
Utility for generating test doubles like mocks, stubs, and fakes (by generating random object).

#### How to generate mocks and fakes 
Use `Mockable` annotation to protocols to generate mocks/stubs and `Randomizable` to structs or enums to generate random fakes
```swift
// Generate ProductServiceMock() class
// sourcery: Mockable
class ProductService {
    let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = productRepository
    }
    
    func getProducts() async throws -> [Product] {
        return try await repository.getAllProducts()
    }
}

// Generate ProductRepositoryMock() class
// sourcery: Mockable
protocol ProductRepository {
    
    func getAllProducts() async throws -> [Product]
}

// Generate Product.random() static function
// sourcery: Randomizable
struct Product: Equatable {
    let name: String // String.random() automatically generated
    let price: Double // Double.random() automatically generated
    let variants: [ProductVariant] // Need to annotate also on ProductVariant
}

// Generate ProductVariant.random() and [ProductVariant].random()
// sourcery: Randomizable=+array
struct ProductVariant: Equatable {
    let id: Int
    let name: String
}
```
```swift
import Testing
@testable import SamplePackage

struct ProductServiceTests {
    
    private var productRepositoryMock: ProductRepositoryMock!
    private var service: ProductService!
    
    init() {
        productRepositoryMock = ProductRepositoryMock()
        service = ProductService(productRepository: productRepositoryMock)
    }

    @Test
    func testGetAllProductsSuccess() async throws {
        // Generate fakes with random object
        let fakeProducts = (0...5).map {_ in Product.random() }

        // Use generated mocks for mocking/stubbing
        productRepositoryMock.getAllProductsProductReturnValue = fakeProducts

        // Action
        let result = try await service.getProducts()
        
        // Asserts
        #expect(result == fakeProducts)
    }
}
```

    For primitive and standard types, random extension automatically generated like String.random(), Int.random(), Double.random(), etc.

    If plugins is applied in .testTarget, the Mocks and Random object only available from unit test. But, if you prefer to apply on regular .target please use config debug_only=true so it's not included in release binary. 

    For more sample usage, please see the [SamplePackage](./Sample/SamplePackage).

#### Optional: Custom configuration
Default plugin configuration should be suitable on most cases, but in case you need to customize it you can create `.testpack.json` inside your package directory (same level as `Package.swift`). All configuration keys here should be present otherwise it will use default value for all config.
```json
{
    "debug_only": true,
    "random_std_lib": true,
    "random_std_lib_protection": "fileprivate",
    "imports": [],
    "testable_imports": []
}
```
| Key                        | Default Value  | Description |
|----------------------------|----------------|-------------|
| `debug_only`               | `false`        | Generate mocks/random for Debug build only. Default to `false` if applied on test target. If target is regular, then it's recommended to set as `true` |
| `random_std_lib`           | `true`         | Generate std lib random extension |
| `random_std_lib_protection`| `internal`     | Protection level of std lib random extension. If target is regular, then it's recommended to set as `fileprivate` |
| `imports`                  | `[]`           | List of additional imports to generated sources |
| `testable_imports`         | `[]`           | List of additional @testable imports to generated sources. Dependencies target is automatically added if target is test target. |


## License

    Copyright (C) 2025 Steven Lewi

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
