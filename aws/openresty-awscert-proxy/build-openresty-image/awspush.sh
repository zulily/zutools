#!/bin/bash

set -e

IMGNAME=openresty-awscert-proxy
AWS_PROJECT_ID=REPLACE_WITH_AWS_ACCOUNTID
REGION=REPLACE_WITH_AWS_REGION
VERSION=1.0

docker build -t ${IMGNAME}:$VERSION .


. ./env
$(aws ecr get-login --region ${REGION})

# Set Policy for new shared repository
POLICY=$(cat <<WOT
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "zu_allow_access",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${AWS_PROJECT_ID}:root"
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

docker tag ${IMGNAME}:${VERSION} ${AWS_PROJECT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMGNAME}:latest
docker tag ${IMGNAME}:${VERSION} ${AWS_PROJECT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMGNAME}:${VERSION}

docker push ${AWS_PROJECT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMGNAME}:latest
docker push ${AWS_PROJECT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMGNAME}:${VERSION}

