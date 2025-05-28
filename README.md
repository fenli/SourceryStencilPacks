# SourceryStencilPacks
Convenient way to use collections of Sourcery stencils as an SPM plugins and Xcode plugins.

[![](https://img.shields.io/github/v/release/fenli/SourceryStencilPacks?style=flat&label=Latest%20Release&color=blue)](https://github.com/fenli/SourceryStencilPacks/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffenli%2FSourceryStencilPacks%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/fenli/SourceryStencilPacks)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffenli%2FSourceryStencilPacks%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/fenli/SourceryStencilPacks)
[![](https://img.shields.io/github/license/fenli/SourceryStencilPacks?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.txt)

## How to install
### SPM
Add this configuration to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/fenli/SourceryStencilPacks", from: "0.1.0"),
],
```
Then add the plugins to your target:
```swift
.target(
    name: "MyPackage",
    plugins: [
        .plugin(name: "TestPack", package: "SourceryStencilPacks"),
        // other plugins
    ]
)
```

### XCode
-- coming soon --

# Plugins
## :rocket: TestPack
Utility for generating test doubles like mocks, stubs, and fakes (by generating random object).

#### How to use `Mockable` annotation to protocols and `Randomizable` to structs or enums 
```swift
// Generate ProductRepositoryMock() class
// sourcery: Mockable
protocol ProductRepository {
    
    func getAllProducts() async throws -> [Product]
}

// Generate Product.random() static function
// sourcery: Randomizable
struct Product: Equatable {
    let name: String
    let price: Double
    let variants: [ProductVariant]
}

// Generate ProductVariant.random() and [ProductVariant].random()
// sourcery: Randomizable=+array
struct ProductVariant: Equatable {
    let id: Int
    let name: String
}

// In Unit Test
import Testing
@testable import SamplePackage

struct ProductServiceTests {
    
    @Test
    func testGetAllProductsSuccess() async throws {
        // Generate fakes with random object
        let fakeGeneratedProducts = (0...5).map {_ in Product.random() }

        // Use generated mocks for mocking/stubbing protocols
        productRepository = ProductRepositoryMock()
        productRepository.getAllProductsProductReturnValue = fakeGeneratedProducts

        // Action
        // ...

        // Asserts
        #expect(...)
    }
}
```

    Mocks and Random object only available on DEBUG mode, so it's suitable for testing (not included in release binary). 
    For more sample usage, please see the SamplePackage.


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
