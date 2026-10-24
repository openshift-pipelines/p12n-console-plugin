ARG NJS_BUILDER=registry.access.redhat.com/ubi10/nodejs-24:latest@sha256:27642e4cbbadca93c8f748971b5cedff05d5fed809ae7e46750fcc1416835cac
ARG NGX_RUNTIME=registry.access.redhat.com/ubi10/nginx-126:latest@sha256:a9fa54017b7d1dc4454d6934ad28c3dfa776d1346e51fee78fe600e77e65b53d

FROM $NJS_BUILDER AS builder-ui

WORKDIR /go/src/github.com/openshift-pipelines/console-plugin
COPY upstream .
#Install Yarn
RUN if [[ -d /cachi2/output/deps/npm/ ]]; then \
      npm install -g /cachi2/output/deps/npm/yarnpkg-cli-dist-4.6.0.tgz; \
      YARN_ENABLE_NETWORK=0; \
    else \
      npm install -g corepack; \
      corepack enable ;\
      corepack prepare yarn@4.6.0 --activate;  \
    fi

# Install dependencies & build
USER root
RUN CYPRESS_INSTALL_BINARY=0 yarn install --immutable && \
    yarn build


FROM $NGX_RUNTIME

COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/dist /usr/share/nginx/html
COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/nginx.conf /etc/nginx/nginx.conf

USER 1001

ENTRYPOINT ["nginx", "-g", "daemon off;"]

LABEL \
    com.redhat.component="openshift-pipelines-console-plugin-rhel10-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:nightly::el10" \
    description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.k8s.description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.k8s.display-name="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    io.openshift.tags="tekton,openshift,console-plugin,console-plugin" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-console-plugin-rhel10" \
    summary="Red Hat OpenShift Pipelines console-plugin console-plugin" \
    version="nightly"
