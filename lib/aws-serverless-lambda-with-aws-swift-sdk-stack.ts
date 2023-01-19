// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import { Construct } from 'constructs';
import * as cdk from 'aws-cdk-lib';
import * as path from "path"
import { aws_dynamodb as dynamodb } from 'aws-cdk-lib'
import { aws_lambda as Lambda } from 'aws-cdk-lib';
import { aws_s3 as s3 } from 'aws-cdk-lib'
import { aws_s3_notifications as s3n } from 'aws-cdk-lib';

export class AwsServerlessLambdaWithAwsSwiftSdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    //create the DynamoDB table
    const table = new dynamodb.Table(this, 'SwiftLambdaTable', {
      partitionKey: { name: 'id', type: dynamodb.AttributeType.STRING },
      removalPolicy:cdk.RemovalPolicy.DESTROY
    });

    // output the table name so it can be identified after the stack deploys
    new cdk.CfnOutput(this, "DynamoDBTableName", {
      value: table.tableName
    });

    //create the Amazon S3 bucket
    const bucket = new s3.Bucket(this, 'SwiftLambdaBucket', {
        versioned:false,
        encryption:s3.BucketEncryption.S3_MANAGED,
        removalPolicy:cdk.RemovalPolicy.DESTROY,
        blockPublicAccess:s3.BlockPublicAccess.BLOCK_ALL
      }
    )

    // output the bucket name so it can be identified after the stack deploys
    new cdk.CfnOutput(this, "BucketName", {
      value: bucket.bucketName
    });

    // create the Docker image based Lambda function
    // pass in the DynamoDB table name as environment variable
    let dockerfile = path.join(__dirname, "../lambda/functions/swift-lambda-function/");

    const lambdaFunction = new Lambda.DockerImageFunction(this, "SwiftLambdaFunction", {
      code: Lambda.DockerImageCode.fromImageAsset(dockerfile, {
        buildArgs:{
          "TARGET_NAME": 'swift-lambda-function'
        }
      }),
      memorySize:1024,
      timeout:cdk.Duration.seconds(30),
      architecture: Lambda.Architecture.X86_64,
      environment: {
        "TABLE_NAME": table.tableName
      }
    });

    // output the function name so it can be identified after the stack deploys
    new cdk.CfnOutput(this, "FunctionName", {
      value: lambdaFunction.functionName
    });

    //grant function permissions to write to the DynamoDB table
    table.grantWriteData(lambdaFunction)

    // create the Amazon S3 event notification for new files created
    bucket.addEventNotification(s3.EventType.OBJECT_CREATED, new s3n.LambdaDestination(lambdaFunction));
  }
}