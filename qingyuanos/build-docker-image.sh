#!/bin/bash
set -e

REGISTRY="tangfeixiong"
REPO="rancher-catalog-service"
TAG="0.6.1"

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

SCRIPTFS=$(dirname "${BASH_SOURCE}")
ROOTFS=$SCRIPTFS/..

#go build -a -v -tags netgo -o $tgt/rancher-catalog-service $ROOTFS/main.go
go build -v -tags netgo -o $tgt/rancher-catalog-service $ROOTFS/main.go

cp -r $SCRIPTFS/cloned-catalog $tgt

if [[ ${REPO} == "rancher-catalog-service" ]]; then
	cp $SCRIPTFS/Dockerfile.alpine $tgt/Dockerfile
else
	cp $SCRIPTFS/Dockerfile $tgt
	sed -i 's%^CMD.*$%CMD ["/usr/bin/s6-svscan", "/service"]%1' $tgt/Dockerfile
fi

docker build -t ${REGISTRY}/${REPO}:${TAG} $tgt

rm -rf $tgt
