# A Docker image for running a Stencila Python Host in a Binder container
# This image meets Binder's requirements for custom Dockerfiles. See
# http://mybinder.readthedocs.io/en/latest/dockerfile.html

FROM python@sha256:0bd2adeb36f8e5a80b8561db7549f29cba2abc1bde36f576b1f4b7c6b6318521

RUN pip install --no-cache-dir \
    notebook==5.5.0 \
    nbserverproxy==0.8.3 \
    git+git://github.com/stencila/py.git@91a05a139ac120a89fc001d9d267989f062ad374

RUN jupyter serverextension enable --sys-prefix --py nbserverproxy

RUN adduser --disabled-password --uid 1000 guest
USER guest
WORKDIR /home/guest

RUN echo "STENCILA_AUTH=false python -m stencila run &\n jupyter notebook --ip 0.0.0.0" > cmd.sh
CMD ["bash", "cmd.sh"]
