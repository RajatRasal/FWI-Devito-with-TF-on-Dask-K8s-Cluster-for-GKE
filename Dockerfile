FROM python:3.6
MAINTAINER Rajat Rasal <rrr2417@ic.ac.uk>

# Configure environment
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

ADD https://github.com/opesci/devito/archive/v3.2.0.tar.gz . 
RUN tar -xzf v3.2.0.tar.gz
RUN mv devito-3.2.0/* . 
RUN rm -rf v3.2.0.tar.gz devito-3.2.0

COPY config config
COPY dask_kubernetes_demo.ipynb dask_kubernetes_demo.ipynb 

# Install Tini that necessary to properly run the notebook service in docker
# http://jupyter-notebook.readthedocs.org/en/latest/public_server.html#docker-cmd
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
# for further interaction with kubernetes
ADD https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl /usr/sbin/kubectl
RUN chmod +x /usr/bin/tini && chmod 0500 /usr/sbin/kubectl

RUN apt-get update && apt-get install -y -q \ 
    mpich \ 
    libmpich-dev

WORKDIR /

RUN python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip && \
    /venv/bin/pip install --no-cache-dir jupyter && \
    /venv/bin/pip install --no-cache-dir -r /app/requirements.txt && \
    /venv/bin/pip install --no-cache-dir dask-kubernetes 


ENV DEVITO_ARCH="gcc-4.9"
ENV DEVITO_OPENMP="0"

EXPOSE 8888
ENTRYPOINT ["/usr/bin/tini", "--"]
