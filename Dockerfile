# This is about 600 megs in total, need to optimize
FROM centos:7
RUN yum update -y && yum install -y \
                    curl \
                    which && \
    yum clean all
USER jenkins
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin
