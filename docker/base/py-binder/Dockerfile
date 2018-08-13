# A Docker image for running a Stencila Python Host in a Binder container
# See https://github.com/stencila/images#run-stencila-in-a-binder

FROM python@sha256:0bd2adeb36f8e5a80b8561db7549f29cba2abc1bde36f576b1f4b7c6b6318521

RUN pip install --no-cache-dir \
    notebook==5.5.0 \
    git+git://github.com/stencila/nbstencilahostproxy.git@08ed4f7620197b91b0cd3535e42f597b843d57aa \
    git+git://github.com/stencila/py.git@91a05a139ac120a89fc001d9d267989f062ad374

RUN jupyter serverextension enable --sys-prefix --py nbstencilahostproxy

RUN useradd --create-home --uid 1000 jovyan
USER jovyan

RUN mkdir -p /home/jovyan/.jupyter \
 && echo "c.NotebookApp.token = ''\nc.NotebookApp.default_url = '/stencila-host/'" > /home/jovyan/.jupyter/jupyter_notebook_config.py

ENV STENCILA_AUTH false

CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
