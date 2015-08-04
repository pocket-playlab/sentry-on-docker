FROM python:2.7

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ruby \
  && rm -rf /var/lib/apt/lists/*

WORKDIR .
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY requirements.txt requirements.txt 
RUN pip install -r requirements.txt
RUN gem install etcd-env
COPY . /usr/src/app
ENTRYPOINT [ "etcd-env", "/sentry" ]
CMD ["newrelic-admin run-program sentry --config=sentry.conf.py start"]
