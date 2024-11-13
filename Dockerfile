FROM ghcr.io/jqlang/jq:latest as jq
FROM docker.io/mikefarah/yq as yq

FROM registry.access.redhat.com/ubi9/ubi:latest

COPY --from=jq /jq /usr/local/bin/jq
COPY --from=yq /usr/bin/yq /usr/local/bin/yq

RUN dnf -y --setopt=tsflags=nodocs install xz && \
    dnf clean all

WORKDIR /app

ARG OKD_VERSION

RUN <<EOF
set -euo pipefail

if [ -z "${OKD_VERSION:-}" ]; then \
  RELEASE_URL="https://api.github.com/repos/okd-project/okd/releases/latest"
else
  RELEASE_URL="https://api.github.com/repos/okd-project/okd/releases/tags/${OKD_VERSION}"
fi

DOWNLOAD_URL="$(curl -fsSL "$RELEASE_URL" | jq -r --arg arch "$(uname -i)" \
  '.assets[] | select(
    (.name | startswith("openshift-install-linux")) and (.name | contains("arm64") == ($arch != "x86_64"))
  ).browser_download_url'
)"

curl -L "$DOWNLOAD_URL" | tar -xzv -C /usr/local/bin openshift-install
EOF

ENTRYPOINT ["/usr/local/bin/openshift-install"]
