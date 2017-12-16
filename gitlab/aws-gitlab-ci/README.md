# Build Container

This directory, when saved as a gitlab repo, builds a docker build container, useful for build automation when building containers pushed to AWS ECR. It contains:

* Docker
* [klar](https://github.com/optiopay/klar) binary, used with your [clair](https://github.com/coreos/clair/tree/v2.0.1) service.
* kubernetes helper scripts
* AWS ECR creation helper script