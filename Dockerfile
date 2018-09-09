FROM docker:18.09.0-ce-tp6 as docker
FROM ubuntu:14.04
COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker
MAINTAINER lukewpatterson@gmail.com

RUN apt-get update

RUN apt-get install --yes curl
RUN curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

RUN apt-get -y install wget git

RUN apt-get install -q -y openjdk-7-jre-headless && apt-get clean

RUN echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

RUN apt-get install --yes curl

VOLUME /var/lib/jenkins
ENV JENKINS_HOME /var/lib/jenkins

EXPOSE 8080

ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

ENV FLEET_VERSION 0.9.0
ENV FLEET_FOLDER fleet-v${FLEET_VERSION}-linux-amd64
ENV FLEET_ARCHIVE fleet-v${FLEET_VERSION}-linux-amd64.tar.gz
RUN mkdir --parents /downloads \
  && cd /downloads \
  && wget https://github.com/coreos/fleet/releases/download/v${FLEET_VERSION}/${FLEET_ARCHIVE} \
  && tar --ungzip --extract --verbose --file ${FLEET_ARCHIVE}
ENV PATH $PATH:/downloads/${FLEET_FOLDER}

ENV ETCD_VERSION 2.0.0
ENV ETCD_FOLDER etcd-v${ETCD_VERSION}-linux-amd64
ENV ETCD_ARCHIVE etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
RUN mkdir --parents /downloads \
  && cd /downloads \
  && wget https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/${ETCD_ARCHIVE} \
  && tar --ungzip --extract --verbose --file ${ETCD_ARCHIVE}
ENV PATH $PATH:/downloads/${ETCD_FOLDER}


CMD /usr/local/bin/run
