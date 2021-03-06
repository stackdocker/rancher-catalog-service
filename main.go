package main

import (
	"fmt"
	"net/http"

	log "github.com/Sirupsen/logrus"
	"github.com/rancher/rancher-catalog-service/manager"
	"github.com/rancher/rancher-catalog-service/service"
)

func main() {
	log.Infof("Starting Rancher Catalog service")
	router := service.NewRouter()
	handler := service.MuxWrapper{false, router}

	manager.SetEnv()
	go manager.Init()
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", *manager.Port), &handler))
}
