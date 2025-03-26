FROM python:3.13.0 AS build

WORKDIR /opt/mining_rig_monitor_document_src
COPY . /opt/mining_rig_monitor_document_src
RUN pip install -r requirements.txt
RUN mkdocs build -c

FROM scratch AS release
COPY --from=build /opt/mining_rig_monitor_document_src/site /
