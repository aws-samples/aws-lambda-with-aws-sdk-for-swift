// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import PackageDescription

let package = Package(
    name: "swift-lambda-function",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", branch: "main"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events", branch: "main"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "0.9.0")
    ],
    targets: [
        .executableTarget(
            name: "swift-lambda-function",
            dependencies: [
                .product(name: "AWSLambdaRuntime",package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "AWSDynamoDB", package: "aws-sdk-swift")
            ]
            ),
        .testTarget(
            name: "swift-lambda-functionTests",
            dependencies: ["swift-lambda-function"]),
    ]
)