FROM alpine

ARG HELM_VERSION=2.11.0
ARG SOPS_VERSION=3.1.1
ARG KUBECTL_VERSION=1.12.0-rc.2

RUN \
    apk add --no-cache --update \
        ca-certificates \
        curl \
        jq \
        git \
        bash \
        gpgme \
        make

RUN HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/tags | jq -r ".[0] .name" | tr -d v) \
    && curl -fSlL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -C /bin -zx -f - -O linux-amd64/helm -O > /bin/helm \
    && chmod +x /bin/helm

RUN helm init --client-only

RUN SOPS_VERSION=$(curl -s https://api.github.com/repos/mozilla/sops/tags | jq -r ".[0] .name" | tr -d v) \
    && curl -fSlL https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux > /bin/sops \
    && chmod +x /bin/sops

RUN \
    helm plugin install https://github.com/futuresimple/helm-secrets && \
    helm plugin install https://github.com/chartmuseum/helm-push

RUN helm repo remove local

RUN curl -fSlL https://dl.k8s.io/v${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -C /bin -zx -f - -O kubernetes/client/bin/kubectl -O > /bin/kubectl \
   && chmod +x /bin/kubectl
