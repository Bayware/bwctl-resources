FROM python:2.7.8-slim
MAINTAINER Roman Solokha <romansoloha@gmail.com>

RUN pip install --quiet elasticsearch-curator==5.5.1


#ENTRYPOINT curator --config /opt/curator-config/curator.yml /opt/curator-config/actions.yml
ENTRYPOINT while true; do curator --config /opt/curator-config/curator.yml /opt/curator-config/actions.yml; sleep 18000; done
