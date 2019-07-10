FROM python:3.7.4-alpine3.10

RUN apk add build-base
RUN apk add libffi-dev
RUN apk add openssl-dev

RUN mkdir /src
RUN mkdir /output
RUN mkdir /output/scoutsuite-report

WORKDIR    /src
COPY audit /src

COPY ScoutSuite /src/ScoutSuite
#RUN git clone git@github.com:nccgroup/ScoutSuite.git

WORKDIR    /src/ScoutSuite
#RUN virtualenv -p python3 venv
#RUN source venv/bin/activate
RUN pip install -r requirements.txt

WORKDIR    /src

CMD ["aws", "--no-browser", "--force", "--timestamp", "--report-dir", "/output/scoutsuite-report"]

ENTRYPOINT ["./ScoutSuite/scout.py"]

