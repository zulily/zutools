# Disksnap
* This container is used to snapshot all google compute engine disks that match the regex provided in the yaml, daily.  It was created to backup mongo instances after the mongodump command had issues (~125GB).

## Compute disk snapshot

* After building docker image, start the pod using the yaml below.


## Restoration

* Start a new instance using the desired image snapshot.

## Kubernetes YAML

### Disksnap YAML
*  Replace value with hostname prefix, leaving the `.*` suffix for the regex match.

```YAML
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: disksnap
  name: disksnap
  namespace: REPLACE_WITH_NAMESPACE
spec:
  containers:
  - env:
    - name: HOST_REGEX
      value: "REPLACE_WITH_HOSTNAME_PREFIX.*"
    image: disksnap
    imagePullPolicy: Always
    name: disksnap
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "1"
```
