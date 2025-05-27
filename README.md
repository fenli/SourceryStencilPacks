# SourceryStencilPacks
Convenient way to use collections of Sourcery stencils as an SPM plugins and Xcode plugins

### How to use from `Package.swift`:
```swift
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(name: "MyPackage", targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/fenli/SourceryStencilPacks", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: [],
            plugins: [
                .plugin(name: "TestPack", package: "SourceryStencilPacks"),
                // other plugins
            ]
        ),
        .testTarget(
            name: "MyPackageTests",
            dependencies: ["MyPackage"]
        ),
    ]
)
```

# Plugins
## :rocket: TestPack
Utility for generating test doubles like mocks, stubs, and fakes (by generating random object).

### How to `Mockable` annotation to protocols and `Randomizable` to structs or enums 
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

// In unit test
import Testing
@testable import SamplePackage

struct ProductServiceTests {
    
    @Test
    func testGetAllProductsSuccess() async throws {
        let fakeGeneratedProducts = (0...5).map {_ in Product.random() }
        productRepositoryMock.getAllProductsProductReturnValue = fakeGeneratedProducts

        let actualResult = productService.getAllProducts()
        
        #expect(actualResult == fakeGeneratedProducts)
    }
}
```

#### Notes:
- Mocks and Random object only available on DEBUG mode, so it's suitable for testing (not included in release binary)
- For more sample usage, please see the `SamplePackage`


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
