// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-lambda-function",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(name: "swift-aws-lambda-runtime", url: "https://github.com/swift-server/swift-aws-lambda-runtime", from: "0.5.1"),
        .package(name: "AWSSwiftSDK", url: "https://github.com/awslabs/aws-sdk-swift", from: "0.0.11")
    ],
    targets: [
        .executableTarget(
            name: "swift-lambda-function",
            dependencies: [
                .product(name: "AWSLambdaRuntime",package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSDynamoDB", package: "AWSSwiftSDK")
            ]
            ),
        .testTarget(
            name: "swift-lambda-functionTests",
            dependencies: ["swift-lambda-function"]),
    ]
)