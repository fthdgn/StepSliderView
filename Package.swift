// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "StepSliderView",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "StepSliderView",
            targets: ["StepSliderView"]
        ),
    ],
    targets: [
        .target(
            name: "StepSliderView",
            dependencies: []
        ),
    ]
)
