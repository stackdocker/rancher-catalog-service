FROM rancher/server

ADD rancher-catalog-service /usr/bin/rancher-catalog-service

ADD cloned-catalog /tmp/cloned-catalog

ENV DEFAULT_CATTLE_CATALOG_URL="library=file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git,community=file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git"

EXPOSE 8088

VOLUME /tmp/cloned-catalog

CMD ["rancher-catalog-service", "-catalogUrl", "library=file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git,community=file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git", "-refreshInterval", "604800"]
