# A Docker container for building Stencila base images

FROM ubuntu:16.04

RUN apt-get update \
 && apt-get install -y docker.io cron curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/

COPY . /usr/app/
RUN chmod +x /usr/app/run.sh

COPY crontab /etc/cron.d/builder
RUN chmod 0644 /etc/cron.d/builder

RUN touch /var/log/cron.log

CMD cron -f -L15
