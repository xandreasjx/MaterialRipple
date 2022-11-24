// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MaterialRipple",
    platforms: [
       .iOS(.v9),
    ],
    products: [
        .library(
            name: "MaterialRipple",
            targets: ["MaterialRipple"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MaterialRipple",
            dependencies: [],
            path: "src"),
    ]
)
