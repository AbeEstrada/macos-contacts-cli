// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "contacts",
    targets: [
        .executableTarget(
            name: "contacts",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("Contacts"),
                .linkedFramework("Foundation")
            ]),
    ]
)
