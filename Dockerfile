# This is about 600 megs in total, need to optimize
FROM centos:7
RUN yum update -y && yum install -y \
                    curl \
                    which && \
    yum clean all
RUN useradd -ms /bin/bash jenkins
WORKDIR /home/jenkins
USER jenkins
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/home/jenkins/google-cloud-sdk/bin
