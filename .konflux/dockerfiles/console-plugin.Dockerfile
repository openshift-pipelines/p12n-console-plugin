ARG BUILDER=registry.redhat.io/ubi9/nodejs-20@sha256:89d0be288e9e76dc42bb2b1f76cd9cc619dde6e5e28c05cfeb3dcf4249b55450
ARG RUNTIME=registry.redhat.io/ubi9/nginx-124@sha256:b9c2c8657761ea521f49ade5b330e5f81ac03372a093588f142de736e13336af

FROM $BUILDER AS builder-ui

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


FROM $RUNTIME
ARG VERSION=console-plugin-1.22

COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/dist /usr/share/nginx/html
COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/nginx.conf /etc/nginx/nginx.conf

USER 1001

ENTRYPOINT ["nginx", "-g", "daemon off;"]

LABEL \
      com.redhat.component="openshift-pipelines-console-plugin-rhel9-container" \
      cpe="cpe:/a:redhat:openshift_pipelines:1.22::el9" \
      description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
      io.k8s.description="Red Hat OpenShift Pipelines console-plugin console-plugin" \
      io.k8s.display-name="Red Hat OpenShift Pipelines console-plugin console-plugin" \
      io.openshift.tags="tekton,openshift,console-plugin,console-plugin" \
      maintainer="pipelines-extcomm@redhat.com" \
      name="openshift-pipelines/pipelines-console-plugin-rhel9" \
      summary="Red Hat OpenShift Pipelines console-plugin console-plugin" \
      version="v1.22.0"
