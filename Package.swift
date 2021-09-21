// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Services",
            targets: ["Services"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(name: "Ion", url: "https://github.com/rosberry/ion", .branch("master")),
      .package(name: "Base", url: "https://github.com/rosberry/Base-iOS", .branch("master")),
      .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
      .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.3.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Services",
            dependencies: ["Ion", "Base", "KeychainAccess", "PhoneNumberKit"],
            path: "Sources"),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["Services"],
            path: "Tests"),
    ]
)
