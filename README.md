# Swift on AWS: Building your backend app with the AWS SDK for Swift
![Image description](images/banner.png)

This sample application demonstrates using the [AWS SDK for Swift](https://aws.amazon.com/sdk-for-swift/) and [Swift AWS Lambda Runtime](https://github.com/swift-server/swift-aws-lambda-runtime) to build a AWS Lambda function. It uses Docker to compile and package the function into a Docker image. It then uses the [AWS Cloud Development Kit (AWS CDK)](https://aws.amazon.com/cdk/) to deploy the image and create the Lambda function in AWS.

The sample implements Swift Concurrency (async / await) to allow for asynchronous calls to the AWS cloud resources.

## The Use Case
To illustrate these capabilities, we have a simple event-driven use case. The application monitors an Amazon Simple Storage Service (Amazon S3) bucket for new files.  When a user uploads a new file, Amazon S3 sends an event notification to the Lambda function.  The function retrieves metadata about the file and saves it to Amazon DynamoDB.

![Image description](images/architecture.jpg)

## Prerequisites

To deploy this application, you need an AWS account and the following tools on your development machine. While it may work with alternative versions, we recommend you deploy the specified minimum version.

* [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (^2.4.19) the AWS CLI is used to configure the AWS credentials on your development machine.
* [Node.js](https://nodejs.org/en/download/current/) (^16.8.1) with NPM (^8.12.2)
* [Docker Desktop](https://www.docker.com/products/docker-desktop) (^4.15) The AWS CDK uses Docker to compile the Swift Lambda functions into a Docker image.

## Clone this repository

```bash
$ git clone https://github.com/aws-samples/aws-lambda-with-aws-sdk-for-swift.git
```

Swich to the application folder and use the Node Package Manager (npm) to install the required AWS CDK modules.

```bash
$ cd aws-lambda-with-aws-sdk-for-swift
$ npm install
```

## Deploy the application to AWS

If this is the first time you have used the AWS CDK in your AWS account, you must first *bootstrap* your account.

From the **root** folder of your project execute the following command:

```bash
$ npx aws-cdk bootstrap
```

Now you can deploy the application stack.  The deployment step uses Docker on your local machine to build a Docker image from your Lambda code. It then generates a AWS CloudFormation template which defines the Amazon S3 bucket, DynamoDB table, and Lambda function, and deploys it to your account. This process can take several minutes.

```bash
$ npx aws-cdk deploy
```

When the deployment has completed, it will ouput the name of the Amazon S3 bucket, DynamoDB table, and Lambda function that was created. For example:

```bash
Outputs:
AwsServerlessLambdaWithAwsSwiftSdkStack.BucketName = swift-lambda-bucket
AwsServerlessLambdaWithAwsSwiftSdkStack.DynamoDBTableName = swift-lambda-table
AwsServerlessLambdaWithAwsSwiftSdkStack.FunctionName = swift-lambda-function
```

## Run the application
Once the deployment process has completed, logon to the AWS Management Console to view the new resources created in your AWS account.  To test out the application:

- navigate to the Amazon S3 service in the console and locate the Amazon S3 bucket created by the AWS CDK.  
- upload a file to this Amazon S3 bucket
- navigate to the DynamoDB service in the console and select the table created by the AWS CDK

You should see a record in the table that specifies the Amazon S3 bucket, object key, name, and size of the file you uploaded.

## Cleanup

Once you finish using the application, you can remove all the resources created by the AWS CDK with the *destroy* command.

*Note - you must first empty the Amazon S3 Bucket before you run the destroy command otherwise it results in an error. The AWS CDK does not remove buckets that contain objects.*

```bash
$ npx aws-cdk destroy
```
