// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fakelang",
    products: [
        .executable(name: "fakelang", targets: ["fakelang"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "fakelang",
            dependencies: ["interpreter", "analyser"]
        ),
        .target(
            name: "typed_ast",
            dependencies: []
        ),
        .target(
            name: "analyser",
            dependencies: ["parser", "common", "typed_ast"]
        ),
        .target(
            name: "common",
            dependencies: ["typed_ast"]
        ),
        .target(
            name: "interpreter",
            dependencies: ["common", "parser", "value"]
        ),
        .target(
            name: "scanner",
            dependencies: []
        ),
        .target(
            name: "parser",
            dependencies: ["scanner", "common"]
        ),
        .target(
            name: "value",
            dependencies: ["common"]
        ),
        .testTarget(
            name: "fakelangTests",
            dependencies: ["fakelang"]
        ),
        .testTarget(
            name: "ScannerTests",
            dependencies: ["scanner"]
        ),
    ]
)
