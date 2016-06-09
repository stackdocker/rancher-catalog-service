#!/bin/bash
set -e

REGISTRY="tangfeixiong"
REPO="rancher-catalog-service"
if [[ $# == 0 || $1 == "catalog" ]]; then
	echo "Begin to build ${REPO}" >/dev/stdout
elif [[ $1 == "server" ]]; then
        REPO="rancher-server"
	echo "Begin to build ${REPO}" >/dev/stdout
else
	echo "Usage: $0 [catalog|server]" >/dev/stderr
	exit 1
fi

tgt=$(mktemp -d)

mkdir -p $tgt

ROOTFS=$(dirname "${BASH_SOURCE}")

go build -v -o $tgt/rancher-catalog-service $ROOTFS/main.go

cp $ROOTFS/Dockerfile $tgt
if [[ ${REPO} != "rancher-catalog-service" ]]; then
	sed -i 's%^CMD.*$%CMD ["/usr/bin/s6-svscan", "/service"]%1' $tgt/Dockerfile
fi

cp -r $ROOTFS/cloned-catalog $tgt

docker build -t ${REGISTRY}/${REPO} $tgt

rm -rf $tgt
