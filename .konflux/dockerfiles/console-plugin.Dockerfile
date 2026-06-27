ARG BUILDER=registry.redhat.io/ubi9/nodejs-22@sha256:47213fcf4e339356548f96af3ef7617e02a285f59ebfc5aaa82e47c70740d7c1
ARG RUNTIME=registry.access.redhat.com/ubi9/nginx-124@sha256:36e29ae4cc5778800882bf1f18525b0edfcde25354491b5fcdfa60b6cb42df86

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
ARG VERSION=1.21

COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/dist /usr/share/nginx/html
COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/nginx.conf /etc/nginx/nginx.conf

USER 1001

ENTRYPOINT ["nginx", "-g", "daemon off;"]

LABEL \
    com.redhat.component="openshift-pipelines-console-plugin-rhel9-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:1.21::el9" \
    description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.k8s.description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.k8s.display-name="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.openshift.tags="tekton,openshift,console-plugin,console-plugin" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-console-plugin-rhel9" \
    summary="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    version="v1.21.3"