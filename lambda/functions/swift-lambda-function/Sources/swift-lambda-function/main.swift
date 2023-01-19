// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// import the packages required by our function
import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
import AWSDynamoDB


// define a structure for returning an error from our function
enum FunctionError: Error {
    case envError
}

@main
struct SwiftLambdaFunction: SimpleLambdaHandler {
    
    // function handler
    // The function's event parameter contains the event triggered from S3
    func handle(_ event: S3Event, context: LambdaContext) async throws -> Void {
    
        // create a client to interact with DynamoDB
        let client = try await DynamoDBClient()

        // retrieve the DynamoDB table name of our application from the Lambda environment variable set in the CDK
        guard let tableName = ProcessInfo.processInfo.environment["TABLE_NAME"] else {
            throw FunctionError.envError
        }

        // use the event information to create an input record for DynamoDB with the S3 object's metadata
        let id = "\(event.records[0].s3.bucket.name)/\(event.records[0].s3.object.key)"
        let name = event.records[0].s3.object.key
        let size = event.records[0].s3.object.size!
        
        let input = PutItemInput(item: ["id": .s(id), "name": .s(name), "size": .n(String(size))], tableName: tableName)

        _ = try await client.putItem(input: input)
    }
}
