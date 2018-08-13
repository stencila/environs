# A Docker image for running a Stencila R Host in a Binder container
# See https://github.com/stencila/images#run-stencila-in-a-binder

FROM ubuntu:16.04

ENV R_VERSION 3.4.3

RUN apt-get update \
 && apt-get install -y \
      apt-transport-https \
      software-properties-common \
 && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial/' \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
 && apt-get update \
 && apt-get install -y \
      git \
      python3 \
      python3-pip \
      r-base=${R_VERSION}-* \
      r-base-dev=${R_VERSION}-* \
      r-recommended=${R_VERSION}-* \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    notebook==5.5.0 \
    git+git://github.com/stencila/nbstencilahostproxy.git@08ed4f7620197b91b0cd3535e42f597b843d57aa

RUN jupyter serverextension enable --sys-prefix --py nbstencilahostproxy

RUN useradd --create-home --uid 1001 jovyan
USER jovyan

RUN mkdir -p /home/jovyan/.jupyter \
 && echo "c.NotebookApp.token = ''\nc.NotebookApp.default_url = '/stencila-host/'" > /home/jovyan/.jupyter/jupyter_notebook_config.py

ENV STENCILA_AUTH false

CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
