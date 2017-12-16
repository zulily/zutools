#!/bin/sh

set -e

# test for AWS variable count
if [ $# -ne 3 ]; then
    exit 1
fi    

IMGNAME=$1
REGION=$2
AWS_PROJECT_ID=$3

# Set Policy for new shared repository
#  ... one row per account sharing image
POLICY=$(cat <<WOT
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "allow_access",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::<AWS_PROJECT_ID_1>:root",
                    "arn:aws:iam::<AWS_PROJECT_ID_2>:root",
                    "arn:aws:iam::<AWS_PROJECT_ID_3>:root",
                    "arn:aws:iam::<AWS_PROJECT_ID_4>:root"
                ]
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
WOT
)

aws ecr describe-repositories --repository-name ${IMGNAME} --region ${REGION} || \
	aws ecr create-repository --repository-name ${IMGNAME} --region ${REGION} && \
	aws ecr set-repository-policy --registry-id ${AWS_PROJECT_ID} --repository-name ${IMGNAME} --region ${REGION} --policy-text "${POLICY}"
