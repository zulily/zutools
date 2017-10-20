# Using Openresty Proxy with AWS Certificate Manager
This proxy uses AWS Certs for external authentication with an [openresty proxy image](https://github.com/zulily/zutools/tree/master/aws/openresty-awscert-proxy/build-openresty-image).  After generating [AWS Certificates] (http://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html), the basic process is:

 - Optionally, generate a self-signed certificate if you want your ELB <-> proxy traffic encrypted.
 - Deploy your proxy service on kubernetes, choosing whether or not you want backend traffic encrypted.
 - Update your ELB with the AWS Certificates.
 - Optionally, add the public key of the self-signed certificate to encrypt the backend traffic.

Choose one of the two following Proxy setups, based on whether you require encrypted backend traffic. You will need the correct AWS IAM permissions for the AWS CLI commands and `configure-be-ssl.sh` script.

## Proxy with Encrypted Backend Traffic
### Prepare Self-signed certificate

To generate the secrets needed for encryption (and basic auth, if desired):

* Run the script `create-certs.sh`  to generate the files needed, as well as the secrets YAML, to configure backend TLS.
	* If you want to use basic auth, you will have a chance to enter the username and password to be encrypted and store as a secret.
	* Copy the output of the script and add it to  `secret-template.yaml`.
* If you are using your own certs, you'll need to:
	* Generate the dhparam file found in the `create-certs.sh`.
	* Base64 encode your certs and paste that encoded value in the yaml to apply as a secret in the `secret-template.yaml` file.
* If you use namespaces, add the "namespace:" key and value in the `metadata` section of the YAML.

Create the secrets using `kubectl create -f secret-template.yaml`.

### Prep and Run the Nginx Deployment YAML

In the `deploy-nginx-proxy-BE-SSL.yaml` file:

* If you have multiple deployments of this proxy, ensure the `labels.app` metadata value is unique to each deployment, and is shared with the service yaml (`labels.app` and `selector.app`) in the same deployment.
* Modify the `TARGET_SERVICE` value to match the host:ip you want to proxy.
* If you use namespaces, add the "namespace:" key and value in the `metadata` section of the YAML.
* Modify the rate limiting values if you don't want the default 1 request/sec (per IP) enabled.

Create the deployment using `kubectl create -f deploy-nginx-proxy-BE-SSL.yaml`.

### Prep and Run the Nginx Service YAML

In the `service-nginx-proxy-BE-SSL.yaml` file:

* Determine the CertificateArn for the desired AWS Certificate by running the AWS CLI command `aws acm list-certificates`, using the value to replace the `REPLACE_WITH_CERT_ARN` value.
* If this service is to be deployed on an internal network, uncomment the `aws-load-balancer-internal` annotation.
* Modify the `spec.loadBalancerSourceRanges` value(s) to restrict the clients that can access your service by network CIDR.
* If you use namespaces, add the "namespace:" key and value in the `metadata` section of the YAML.

Create the service using `kubectl create -f service-nginx-proxy-BE-SSL.yaml`.

### Update the AWS ELB to load the correct certificate for backend communication

In the the `configure-be-ssl.sh` script:

* Determine the service's LoadBalancerName by running `aws elb describe-load-balancers`, replacing the `"REPLACE_WITH_CORRECT_LoadBalancerName"` value.

Run the `configure-be-ssl.sh` script to set the policies enabling backend encryption for the given load balancer.

### Update Route53 DNS to alias the domain name on the AWS Cert to the ELB's DNS address.

Use the AWS Console UI to do this, as it is currently simpler than using the AWS CLI.

## Proxy with Unencrypted Backend Traffic
If encryption is not required between ELB and NGINX (e.g., to optimize performance), use the following sections after creating the certificate in AWS Certificate Manager.

### Prep the Nginx Deployment YAML

In the `deploy-nginx-proxy.yaml` file:

* If you have multiple deployments of this proxy, ensure the `labels.app` metadata value is unique to each deployment, and is shared with the service yaml (`labels.app` and `selector.app`) in the same deployment.
* Modify the `TARGET_SERVICE` value to match the host:ip you want to proxy.
* If you use namespaces, add the "namespace:" key and value in the `metadata` section of the YAML.
* Modify the rate limiting values if you don't want the default 1 request/sec (per IP) enabled.

Create the deployment using `kubectl create -f deploy-nginx-proxy.yaml`.

### Prep the Nginx Service YAML

In the `service-nginx-proxy.yaml` file:

* Determine the CertificateArn for the desired AWS Certificate by running the AWS CLI command `aws acm list-certificates`, using the value to replace the `REPLACE_WITH_CERT_ARN` value.
* If this service is to be deployed on an internal network, uncomment the `aws-load-balancer-internal` annotation.
* Modify the `spec.loadBalancerSourceRanges` value(s) to restrict the clients that can access your service by network CIDR.
* If you use namespaces, add the "namespace:" key and value in the `metadata` section of the YAML.

Create the service using `kubectl create -f service-nginx-proxy.yaml`.

### Update Route53 DNS to alias the domain name on the AWS Cert to the ELB's DNS address.

Use the AWS Console UI to do this, as it is currently simpler than using the AWS CLI.