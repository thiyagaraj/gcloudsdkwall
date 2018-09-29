# Need to put in versioning
FROM centos:latest
RUN yum update -y && yum install -y curl which && \
    yum clean all

# uid and gid for mounted volumes can differ, using fixuid (url below)
RUN groupadd -g 1000 jenkins && \
    useradd -u 1000 -g jenkins -d /home/jenkins -s /bin/sh jenkins
    
# See https://github.com/boxboat/fixuid
RUN USER=jenkins && \
    GROUP=jenkins && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

USER jenkins:jenkins
WORKDIR /home/jenkins

RUN curl -sSL https://sdk.cloud.google.com | bash
RUN /home/jenkins/google-cloud-sdk/bin/gcloud config set disable_usage_reporting false
RUN /home/jenkins/google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true
ENV PATH $PATH:/home/jenkins/google-cloud-sdk/bin

# TODO: debug intermittent error about command not executing
ENTRYPOINT ["fixuid"]
