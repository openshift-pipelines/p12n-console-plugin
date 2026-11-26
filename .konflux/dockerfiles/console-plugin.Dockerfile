ARG NJS_BUILDER=registry.access.redhat.com/ubi10/nodejs-24:latest@sha256:228c8675a62feb55f88dc9dee94d5a82e6f0e887ec47bd8f5e524a797a0984d7
ARG NGX_RUNTIME=registry.access.redhat.com/ubi10/nginx-126:latest@sha256:8e85a835878b40710c812342de5a05d3e40d494440157962c9b17f4b04fef096

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
