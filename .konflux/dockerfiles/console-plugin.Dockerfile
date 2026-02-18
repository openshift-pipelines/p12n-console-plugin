ARG BUILDER=registry.redhat.io/ubi9/nodejs-20@sha256:b45e1ba00ca4bda7575f3ef2a5000ea679e64b9892daa1d8ec850ae38f1d9259
ARG RUNTIME=registry.redhat.io/ubi9/nginx-124@sha256:ece0c2d70199f0bcd3316d6913ef4b8e815d0229693156dee4bad8d69b13edc6

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
