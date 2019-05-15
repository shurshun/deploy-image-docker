FROM alpine

ARG HELM_VERSION=2.13.1
ARG SOPS_VERSION=3.1.1

RUN \
    apk add --no-cache --update \
        ca-certificates \
        curl \
        jq \
        git \
        bash \
        gpgme \
        make

RUN curl -fSlL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -C /bin -zx -f - -O linux-amd64/helm -O > /bin/helm \
    && chmod +x /bin/helm

RUN helm init --client-only

RUN curl -fSlL https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux > /bin/sops \
    && chmod +x /bin/sops

RUN \
    helm plugin install https://github.com/futuresimple/helm-secrets && \
    helm plugin install https://github.com/chartmuseum/helm-push

RUN helm repo remove local

RUN KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -fSlL https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -C /bin -zx -f - -O kubernetes/client/bin/kubectl -O > /bin/kubectl && \
    chmod +x /bin/kubectl

COPY bin/ /bin
RUN chmod +x /bin/slack-msg