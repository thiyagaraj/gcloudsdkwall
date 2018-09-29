# gcloudsdkwall
This is a simple container image that jenkins can be configured with to run Google cloud SDK commands(gcloud SDK) without persisting credential or configuration on the host filesystem.

## Why?
The gcloud SDK persists credentials and other configuration in the home directory, this can create problems in a shared environment such as jenkins, where multiple automated tasks may be sharing the same system account/filesystem for processing CI/CD deployments. Since there is shared state in the filesystem, concurrent workloads cannot be run as you need to activate/deactivate specific accounts prior to use and this necessitates an isolated solution.

This solution(workaround) leverages the [Jenkins Docker Pipeline Plugin](https://jenkins.io/doc/book/pipeline/docker/) to initialize and execute commands from within a docker container that this project provides. I was unable to use the official Google SDK container image as it is configured to mount the `/.config` directory which we had to avoid. Mounting a "secret-file" jenkins credential(service account) would mask the true location of the credential while at the same time allowing the container to use injected credentials.

## Usage
This is an example snippet for a scripted pipeline (Jenkinsfile). The secret file that has the service account key(json) is injected into the container by mounting it as a volume i.e: `docker.image().inside("-v hostVol:containerVol")`
```
withCredentials(file(credentialsId: "jenkinsCredentialId", variable: "GCP_CREDS_FILE_PATH")]) {
        docker.withRegistry("https://hub.docker.com/", "docker_credentials_if_private_repo") {
            docker.image("thiyag/gcloudsdkwall:latest").inside("-v ${GCP_CREDS_FILE_PATH}:${GCP_CREDS_FILE_PATH}") {
                sh "gcloud auth activate-service-account --key-file ${GCP_CREDS_FILE_PATH}" //This is persisted within the container
                sh "more commands" //runs within the container
                sh "./shellScript" //Workspace is mounted by jenkins implicitly from the host system, so this script can e in the workspace
            } //Container is automatically destroyed after this block runs
        }
 }
 ```
 All the "sh" commands run in the context of the container.
 
## Dependencies
https://github.com/boxboat/fixuid to fix uid/gid issues since jenkins is mounted the workspace and the uid/gid might differ leading to permission issues

## Docker hub location
https://hub.docker.com/r/thiyag/gcloudsdkwall/
