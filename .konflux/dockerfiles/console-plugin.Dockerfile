ARG BUILDER=registry.redhat.io/ubi9/nodejs-22@sha256:57ad03c5db9382cd266af665819f60e5b1490fc27ee589320159df59f9eb453b
ARG RUNTIME=registry.access.redhat.com/ubi9/nginx-124@sha256:d40ea11bb6174cda50424f4b0f25326a5d04335ae9008191a0194488d3c94444

FROM $BUILDER AS builder-ui

WORKDIR /go/src/github.com/openshift-pipelines/console-plugin
COPY upstream .
#Install Yarn
RUN if [[ -d /cachi2/output/deps/npm/ ]]; then \
      npm install -g /cachi2/output/deps/npm/yarnpkg-cli-dist-4.6.0.tgz; \
      YARN_ENABLE_NETWORK=0; \
    else \
      echo "ERROR: Hermetic npm deps not injected"; \
      exit 1; \
    fi

# Install dependencies & build
USER root
RUN CYPRESS_INSTALL_BINARY=0 yarn install --immutable && \
    yarn build


FROM $RUNTIME
ARG VERSION=1.24

COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/dist /usr/share/nginx/html
COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/nginx.conf /etc/nginx/nginx.conf

USER 1001

ENTRYPOINT ["nginx", "-g", "daemon off;"]

LABEL \
    com.redhat.component="openshift-pipelines-console-plugin-rhel9-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:1.24::el9" \
    description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.k8s.description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.k8s.display-name="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.openshift.tags="tekton,openshift,console-plugin,console-plugin" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-console-plugin-rhel9" \
    summary="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    version="v1.24.0-RC-1"