# Build Openresty Proxy docker image
This docker image of openresty is intended to be built and pushed to AWS ECR for use in your AWS kubernetes cluster. The basic process is:

* In the `env` file, modify the `AWS_PROFILE` value to match the AWS credentials profile tag of an account with  full access to AWS EC2 ECR.
* In the `awspush.sh` file, modify:
	* `AWS_PROJECT_ID` value to match the AWS Account ID that contains the ECR.
	* `REGION` value to the region you want for your ECR.

Run the `awspush.sh` in your AWS development environment (with docker and AWS CLI).