# Demo Clair container scanning in gitlab-ci

This is a simple demo of how to use gitlab CI via .gitlab-ci.yml to:

  - build your ubuntu images
  - scan your image for vulnerabilities automatically during the build process
  - store your image in the gitlab local container registry
  - deploy your image to the AWS container registry (ECR)


## Pre-requisites
### Build Container
This demo uses a (docker) [build container](../aws-gitlab-ci) which has:

- Docker
- klar binary
- kubernetes helper scripts
- AWS ECR creation helper script

### Clair/Klar
[Clair](https://github.com/coreos/clair) is a service which pulls the latest container vulnerability signatures every two hours, and provides them to clients for container image verification.

You will need to run an instance of the Clair service, available for build verification, selected by the `$CLAIR_ADDR` variable, set in the "Secret variables" section in your gitlab project's "Settings" -> "Pipelines" menu.

[Klar](https://github.com/optiopay/klar) is a binary, built into the build-container, that calls the Clair service for each docker image layer.

### ECR User
First we're going to set up the AWS IAM user in the "Secret variables" section in your project's "Settings" -> "Pipelines" menu:

  - `ECR_ACCESS_ID` : contains your AWS credentials Access Key ID (which has ECR r/w privileges)
  - `ECR_ACCESS_SECRET` : contains your AWS credentials Access Secret Key ID (for the Access key)

### gitlab User
This demo automatically pushes containers to the gitlab repository. It requires gitlab user credentials, of at least "Developer" rights in the repository group.  In the given gitlab user, select the "(Username)" -> Settings -> "Access Tokens" menu to create a Personal Access Token that can access the api and read_registry. Save the token as the `GITLAB_PASSWORD` in the the "Secret variables" section in your gitlab project's "Settings" -> "Pipelines" menu.

## Building using gitlab-ci.yml

Set the variables in your `gitlab-ci.yml`:

  - `REGISTRY_ID`:  "<REPLACE_WITH_AWS_ACCOUNT>" - the AWS Account used for its ECR.
  - `AWS_ECR_REGION`: "<RELPACE_WITH_REGION>" - co-located with our AWS EC2 instances.
  - `CLAIR_OUTPUT` : "High" - allows vulnerabilities with severities of "Medium, Low, Negligible, or Unknown".
  - `DOCKERFILE` : Replace with the Dockerfile filename(s).
  - `MYDATE`, `VERSION` : You may want to modify precision (adding hour, minute, etc.), or replace with build hash `$CI_BUILD_REF`, which is the git commit hash of the current/last git check-in, if date is not important.
  - `CI_DEBUG_TRACE` : Set to "true" to enable verbose logging in the gitlab build log.

Each push triggers a build (running .gitlab-ci.yml).  Modify "Settings" -> "General" ("Sharing & Permissions" section), changing "Pipelines" to "Disabled" (and selecting "Save Changes" button), to turn off builds when necessary.

To force a build on a given frequency (useful when you are pulling from public images), set in the "Pipelines" -> "Schedules" menu.

Something to note -- in gitlab-ci.yml, jobs with the same `stage` designation are run in parallel.