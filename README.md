# Swift on AWS: Building your backend app with the AWS SDK for Swift

This sample application demonstrates using the **AWS SDK for Swift** in a AWS Lambda function. It uses Docker to compile and package the function into a Docker image. It then uses the AWS Cloud Development Kit (AWS CDK) to deploy the image and create the Lambda function in AWS.

The sample supports deploying your function as an **x86** based container or an **ARM** based container.  The latter leverages Lambda's new capability to run ARM based functions. If you are building this sample on an ARM machine, such as an Apple M1, make the specified tweaks to the app as specified below. The default configuration for the example is x86 and requires no changes.

## The Use Case
To illustrate these capabilities, we have a simple use case. The application monitors a Amazon Simple Storage Service (Amazon S3) bucket for new files.  When a user uploads a new file, Amazon S3 sends an event notification to the Lambda function.  The function retrieves metadata about the file and saves it to Amazon DynamoDB.  We will now explore the end-to-end tooling used to develop this application with Swift on AWS.

![Image description](images/architecture.jpg)

## Prerequisites

To deploy this application, you need an AWS account and the following tools on your development machine:

* [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (^2.1.32) the AWS CLI is used to configure the AWS credentials on your development machine.
* [Node.js](https://nodejs.org/en/download/current/) (^16.8.0) with NPM (^7.19.1)
* [Typescript](https://www.npmjs.com/package/typescript) (^4.2.4) Typescript is used with the AWS CDK.
* [Docker Desktop](https://www.docker.com/products/docker-desktop) (^3.5.2) The AWS CDK uses Docker to compile the Swift Lambda functions into a Docker image.
* [Swift](https://swift.org/getting-started/#installing-swift) (^5.4)

If you are building this sample on a Mac and have Xcode installed, you do not need to install Swift, as you already have it.

When you configure the AWS CLI, use credentials for a user with permissions to create, update, and delete AWS CloudFormation, AWS Identity and Access Management (IAM), Amazon S3, AWS Lambda, Amazon DynamoDB, and Amazon Elastic Container Registry resources. The AWS CDK will use these credentials to create the resources used in this sample in your AWS account.


## Clone this repository

```bash
$ git clone https://github.com/aws-samples/aws-lambda-with-aws-sdk-for-swift.git
```

Swich to the application folder and use the Node Package Manager (npm) to install the required AWS CDK modules.

```bash
$ cd aws-lambda-with-aws-sdk-for-swift
$ npm install
```

## Configure the function architecture

If you are running this sample on an ARM machine, such as an Apple M1, you must change the first line of the Lambda function's Dockerfile.  You must also make a change to the CDK stack file.

The Docker file is located at:

```
aws-lambda-with-aws-sdk-for-swift/lambda/functions/swift-lambda-function/Dockerfile
```

Open this file and ensure the first line reflects the architecture of the device you are using to build the sample:

**ARM**
```
FROM swiftarm/swift:5.4.1-amazonlinux-2 as builder
```

**x86**

```
FROM swift:5.4.3-amazonlinux2 as builder
```

The CDK stack file is located at:

```
aws-lambda-with-aws-sdk-for-swift/lib/aws-serverless-lambda-with-aws-swift-sdk-stack.ts
```

Open this file, locate the code that defines the Lambda function, and change the **architecture** parameter.

**ARM**

```typescript
const lambdaFunction = new Lambda.DockerImageFunction(this, "SwiftLambdaFunction", {
    code: Lambda.DockerImageCode.fromImageAsset(dockerfile, {
    buildArgs:{
        "TARGET_NAME": 'swift-lambda-function'
    }
    }),
    memorySize:1024,
    timeout:cdk.Duration.seconds(30),
    architecture: Lambda.Architecture.ARM_64,
    environment: {
    "TABLE_NAME": table.tableName,
    "REGION": this.region
    }
});
```

**x86**

```typescript
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
    "TABLE_NAME": table.tableName,
    "REGION": this.region
    }
});
```

## Deploy the application to AWS

If this is the first time you have used the AWS CDK in your AWS account, you must first *bootstrap* your account.

From the **root** folder of your project execute the following command:

```bash
$ npx cdk bootstrap
```

Now you can deploy the application stack.  The deployment step uses Docker on your local machine to build a Docker image from your Lambda code. It then generates a AWS CloudFormation template which defines the Amazon S3 bucket, DynamoDB table, and Lambda function, and deploys it to your account. This process can take several minutes.

```bash
$ npx cdk deploy
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
$ npx cdk destroy
```
