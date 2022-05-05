FROM python:3.7-buster

RUN pip install pex==2.1.47

RUN mkdir /app
WORKDIR /app