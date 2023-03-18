1.This a terraform project where I used serverless service of Lambda, SNS, SQS and IAM

2.Objective was to have two lambdas communicating with each other via SNS and SQS

3.Dispatcher lambda will be triggered via S3 create event and it will send the event to SNS to which SQS is subscribed.

4.Lambda2 will poll from the SQS using event source mapping and will perform its task being loosely coupled.

5. Made use of modules to reusethe code as far as possible