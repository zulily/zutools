#!/bin/bash

# script to configure backend ssl using self-signed certificate
DIR="secrets"

LoadBalancerName="REPLACE_WITH_CORRECT_LoadBalancerName"


PubKey=$(openssl x509 -in ${DIR}/selfsigned.crt -pubkey -noout | egrep -v "\----")

aws elb create-load-balancer-policy --load-balancer-name ${LoadBalancerName} --policy-name ${LoadBalancerName}-PublicKey-policy \
       	--policy-type-name PublicKeyPolicyType --policy-attributes AttributeName=PublicKey,AttributeValue="${PubKey}"

aws elb create-load-balancer-policy --load-balancer-name ${LoadBalancerName} --policy-name ${LoadBalancerName}-authentication-policy \
	--policy-type-name BackendServerAuthenticationPolicyType \
	--policy-attributes AttributeName=PublicKeyPolicyName,AttributeValue=${LoadBalancerName}-PublicKey-policy

aws elb set-load-balancer-policies-for-backend-server --load-balancer-name ${LoadBalancerName} --instance-port 443 \
	--policy-names ${LoadBalancerName}-authentication-policy


