// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// import the packages required by our function
import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
import AWSDynamoDB

// define the structure for our function output
// inherit from Codable so it can be translated to json
struct Output: Codable {
    let statusCode:Int
    let body: String
}

// define a structure for returning an error from our function
enum FunctionError: Error {
    case envError
}

// retrieve the region in which our function is executing from a Lambda environment variable
let region = try getEnvVariable(name: "REGION")

// create a client to interact with DynamoDB
let config = try! DynamoDbClient.DynamoDbClientConfiguration(region: region)
let client = DynamoDbClient(config: config)

// The Lambda.run method is invoked by the Lambda service
// The function's event parameter contains the event triggered from S3
Lambda.run { (context, event: S3.Event, callback: @escaping (Result<Output, Error>) -> Void) in
  
    do {

        // retrieve the DynamoDB table name of our application from a Lambda environment variable
        let tableName = try getEnvVariable(name: "TABLE_NAME")
        
        // use the event information to create an input record for DynamoDB with the S3 object's metadata
        let id = "\(event.records[0].s3.bucket.name)/\(event.records[0].s3.object.key)"
        let name = event.records[0].s3.object.key
        let size = event.records[0].s3.object.size!

        let input = PutItemInput(item: ["id": .s(id), "name": .s(name), "size": .n(String(size))], tableName: tableName)
        
        // use the DynamoDB client to insert the record into the table
        client.putItem(input: input) { (result) in
            switch(result) {
            case .success:
                callback(.success(Output(statusCode: 200, body: "File info record added")))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    } catch let err {
        callback(.failure(err))
    }
}

// function to retrieve the function environment variables by name
func getEnvVariable(name: String) throws -> String {
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    throw FunctionError.envError
}
