# Backup/Restore
* This pair of containers is used to backup and restore either a specific mongo db, or mysql instance.

## Backup

* Will use the Persistent volume /backup to:
   * connect to the named mysql/mongo host
   * dump the [database || all-databases (mysql only) ] to a file/directory, and if mongo, tar the directory to a file
   * encrypt the dump/tar file using a secret defined in the namespace
   * copy the encrypted dump/tar file to Google Storage location 

## Restore

* Will use the Persistent volume /restore to:
   * copy the latest encrypted dump/tar file from a Google Storage location 
   * decrypt the dump/tar file using a secret defined in the namespace
   * connect to the named mysql/mongo host
   * restore  the [database || all-databases (mysql only) ] from the file/directory

## Kubernetes YAML

### Secrets YAML (required before starting a backup/restore pod)
* Generate phrase by base64 encoding desired phrase (trimming newlines)
* Generate key from Google service account (JSON) creation, and base64 encoding (trimming newlines)
* secrets template:

```YAML
apiVersion: v1
kind: Secret
metadata:
  name: backupsecrets
  namespace: REPLACE_WITH_NAMESPACE 
type: Opaque
data:
  phrase: REPLACE_WITH_GENERATED_BASE64_ENCODED_PHRASE
  key: REPLACE_WITH_GENERATED_BASE64_ENCODED_SERVICE_ACCOUNT_WITH_GOOGLE_STORAGE_WRITE_ACCESS
```

### Backup YAML
* Generate persistent volume before starting.
* backup (mongo db example) template:

```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: autobackup-pv1-claim
  namespace: REPLACE_WITH_NAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: REPLACE_WITH_SIZE_2.5X_DB
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: autobackup
  name: autobackup
  namespace: REPLACE_WITH_NAMESPACE
spec:
  containers:
  - env:
    - name: BACKUP_TYPE
      value: mongo
    - name: PORT
      value: "27017"
    - name: HOST
      value: REPLACE_WITH_MONGO_HOST
    - name: USER
      value: REPLACE_WITH_MONGO_ACCOUNT
    - name: PASS
      value: REPLACE_WITH_MONGO_PASSWORD
    - name: DB
      value: REPLACE_WITH_MONGO_DBNAME
    - name: ACCT
      value: REPLACE_WITH_GOOGLE_SERVICE_ACCOUNT_EMAIL
    - name: BUCKET
      value: gs://REPLACE_WITH_BUCKETNAME
    - name: SECRET_PHRASE
      valueFrom:
        secretKeyRef:
          name: backupsecrets
          key: phrase
    image: backup
    imagePullPolicy: Always
    name: autobackup
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "1"
    volumeMounts:
    - mountPath: /backup
      name: mnt-backup
    - mountPath: /secrets
      name: secrets
      readOnly: true
  volumes:
  - name: mnt-backup
    persistentVolumeClaim:
      claimName: autobackup-pv1-claim
  - name: secrets
    secret:
      secretName: backupsecrets
```

### Restore YAML
* Generate persistent volume before starting.
* restore (mysql all-databases) template:

```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: autorestore-pv1-claim
  namespace: REPLACE_WITH_NAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: REPLACE_WITH_SIZE_2.5X_DB
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: autorestore
  name: autorestore
  namespace: REPLACE_WITH_NAMESPACE
spec:
  containers:
  - env:
    - name: BACKUP_TYPE
      value: mysql
    - name: PORT
      value: "3306"
    - name: HOST
      value: REPLACE_WITH_MYSQL_HOST
    - name: USER
      value: REPLACE_WITH_MYSQL_USER
    - name: PASS
      value: REPLACE_WITH_MYSQL_PASSWORD
    - name: DB
      value: REPLACE_WITH_MYSQL_DBNAME_OPTIONALLY
    - name: ACCT
      value: REPLACE_WITH_GOOGLE_SERVICE_ACCOUNT_EMAIL
    - name: BUCKET
      value: gs://REPLACE_WITH_BUCKETNAME
    - name: SECRET_PHRASE
      valueFrom:
        secretKeyRef:
          name: backupsecrets
          key: phrase
    image: restore
    imagePullPolicy: Always
    name: autorestore
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "1"
    volumeMounts:
    - mountPath: /restore
      name: mnt-restore
    - mountPath: /secrets
      name: secrets
      readOnly: true
  volumes:
  - name: mnt-restore
    persistentVolumeClaim:
      claimName: autorestore-pv1-claim
  - name: secrets
    secret:
      secretName: backupsecrets
```
