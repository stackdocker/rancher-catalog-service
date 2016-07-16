# Build and Try

## Build

* To build rancher-catalog-service

`./build-docker-image.sh` or `./build-docker-image.sh catalog`

* To build rancher-server

`./build-docker-image.sh server`

## Try

### Run rancher-catalog-service

    [vagrant@localhost rancher-catalog-service]$ docker run -ti tangfeixiong/rancher-catalog-service
    INFO[0000] Starting Rancher Catalog service             
    INFO[2016-06-09T21:32:07Z] Using catalog library=file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git 
    INFO[2016-06-09T21:32:07Z] Using catalog community=file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git 
    INFO[2016-06-09T21:32:07Z] Cloning the catalog from git URL file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git 
    Cloning into './DATA/library'...
    remote: Counting objects: 59, done.
    remote: Compressing objects: 100% (56/56), done.
    Receiving objects: 100% (59/59), 17.62 KiB | 0 bytes/s, done.
    remote: Total 59 (delta 16), reused 0 (delta 0)
    Resolving deltas: 100% (16/16), done.
    Checking connectivity... done.
    INFO[2016-06-09T21:32:07Z] Cloning the catalog from git URL file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git 
    Cloning into './DATA/community'...
    remote: Counting objects: 618, done.
    remote: Compressing objects: 100% (543/543), done.
    remote: Total 618 (delta 70), reused 618 (delta 70)
    Receiving objects: 100% (618/618), 606.35 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (70/70), done.
    Checking connectivity... done.

key "^-pq" to detach tty

* REST service

Container Address

    [vagrant@localhost rancher-catalog-service]$ docker inspect -f {{.NetworkSettings.IPAddress}} $(docker ps | grep rancher-catalog-service | awk '{print $1}') 
    172.17.0.14

    [vagrant@localhost rancher-catalog-service]$ curl http://172.17.0.14:8088/v1-catalog/catalogs/community
    {"actions":{},"description":"","id":"community","lastUpdated":"Thursday, 09-Jun-16 21:32:08 UTC","links":{"self":"http://172.17.0.14:8088/v1-catalog/catalogs/community"},"message":"","state":"active","type":"catalog","uri":"file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git"}

    [vagrant@localhost rancher-catalog-service]$ curl http://172.17.0.14:8088/v1-catalog/templates/community:kubernetes*MongoDB:0
    {"actions":{},"catalogId":"community","category":"Databases","defaultVersion":"3.2-rancher1","description":"MongoDB Replica Set","files":{"mongo-controller.yaml":"kind: ReplicationController\napiVersion: v1\nmetadata:\n  name: mongo-rc\nspec:\n  replicas: ${sec_no}\n  selector:\n    name: mongo-sec\n  template:\n    spec:\n      containers:\n      - name: mongo-sec\n        image: husseingalal/mongo-k8s\n        ports:\n          - containerPort: 27017\n        volumeMounts:\n          - name: mongo-ephermal-storage\n            mountPath: /data/db\n        command:\n          - /run.sh\n          - mongod\n          - \"--replSet\"\n          - rs0\n          - \"--smallfiles\"\n          - \"--noprealloc\"\n      volumes:\n        - name: mongo-ephermal-storage\n          emptyDir: {}\n    metadata:\n      labels:\n        secondary: \"true\"\n      name: mongo-sec\n","mongo-master.yaml":"apiVersion: v1\nkind: Service\nmetadata:\n  labels:\n    name: mongo-primary\n  name: mongo-primary\nspec:\n  ports:\n    - port: 27017\n      targetPort: 27017\n  selector:\n    name: mongo-master\n---\napiVersion: v1\nkind: Pod\nmetadata:\n  labels:\n          name: mongo-master\n name: mongo-master\nspec:\n  containers:\n    - name: mongo-master\n      image: \"husseingalal/mongo-k8s\"\n      env:\n        - name: PRIMARY\n          value: \"true\"\n      ports:\n        - containerPort: 27017\n      command:\n        - /run.sh\n        - mongod\n        - \"--replSet\"\n        - rs0\n        - \"--smallfiles\"\n        - \"--noprealloc\"\n      volumeMounts:\n        - mountPath: /data/db\n          name: mongo-primary-ephermal-storage\n  volumes:\n    - name: mongo-primary-ephermal-storage\n      emptyDir: {}\n","mongo-sec-service.yaml":"apiVersion: v1\nkind: Service\nmetadata:\n  labels:\n    name: mongo-sec\n  name: mongo-sec\nspec:\n  ports:\n    - port: 27017\n  selector:\n    secondary: \"true\"\n","rancher-compose.yml":".catalog:\n  name: MongoDB\n  version: 3.2-rancher1\n  description: MongoDB Replica Set\n  questions:\n    - variable: \"sec_no\"\n      label: \"Number of Secondary nodes\"\n      required: true\n      type: int\n      default: 2\n      description: \"should be even number\"\n"},"iconLink":"community:kubernetes*MongoDB?image","id":"community:kubernetes*MongoDB:0","isSystem":"","license":"","links":{"icon":"http://172.17.0.14:8088/v1-catalog/templates/community:kubernetes*MongoDB?image","readme":"http://172.17.0.14:8088/v1-catalog/templates/community:kubernetes*MongoDB:0?readme","self":"http://172.17.0.14:8088/v1-catalog/templates/community:kubernetes*MongoDB:0"},"maintainer":"","minimumRancherVersion":"","name":"MongoDB","path":"community/kubernetes*MongoDB/0","projectURL":"","questions":[{"default":"2","description":"should be even number","group":"","invalidChars":"","label":"Number of Secondary nodes","max":0,"maxLength":0,"min":0,"minLength":0,"options":null,"required":true,"type":"int","validChars":"","variable":"sec_no"}],"readmeLink":"community:kubernetes*MongoDB:0?readme","templateBase":"kubernetes","type":"templateVersion","upgradeVersionLinks":{},"version":"3.2-rancher1","versionLinks":{}}

### Recycle

    [vagrant@localhost rancher-catalog-service]$ ID=$(docker ps | grep rancher-catalog-service | awk '{print $1}'); docker stop $ID && docker rm $ID
    b37b531358a3
    b37b531358a3

### Run rancher-server

    [vagrant@localhost rancher-catalog-service]$ docker run -ti tangfeixiong/rancher-server
    160609 22:10:21 [Note] /usr/sbin/mysqld (mysqld 5.5.47-0ubuntu0.14.04.1) starting as process 27 ...
    Uptime: 2  Threads: 1  Questions: 2  Slow queries: 0  Opens: 33  Flush tables: 1  Open tables: 26  Queries per second avg: 1.000
    Setting up database
    Importing schema
    CATTLE_AGENT_PACKAGE_AGENT_BINARIES_URL=/usr/share/cattle/artifacts/agent-binaries.tar.gz
    CATTLE_AGENT_PACKAGE_CADVISOR_URL=/usr/share/cattle/artifacts/cadvisor.tar.gz
    CATTLE_AGENT_PACKAGE_HOST_API_URL=/usr/share/cattle/artifacts/host-api.tar.gz
    CATTLE_AGENT_PACKAGE_NODE_AGENT_URL=/usr/share/cattle/artifacts/node-agent.tar.gz
    CATTLE_AGENT_PACKAGE_PYTHON_AGENT_URL=/usr/share/cattle/artifacts/python-agent.tar.gz
    CATTLE_AGENT_PACKAGE_RANCHER_DNS_URL=/usr/share/cattle/artifacts/rancher-dns.tar.gz
    CATTLE_AGENT_PACKAGE_RANCHER_METADATA_URL=/usr/share/cattle/artifacts/rancher-metadata.tar.gz
    CATTLE_AGENT_PACKAGE_RANCHER_NET_URL=/usr/share/cattle/artifacts/rancher-net.tar.gz
    CATTLE_CATTLE_VERSION=v0.162.1
    CATTLE_DB_CATTLE_DATABASE=mysql
    CATTLE_DB_CATTLE_MYSQL_HOST=localhost
    CATTLE_DB_CATTLE_MYSQL_NAME=cattle
    CATTLE_DB_CATTLE_MYSQL_PORT=3306
    CATTLE_DB_CATTLE_USERNAME=cattle
    CATTLE_GRAPHITE_HOST=
    CATTLE_GRAPHITE_PORT=
    CATTLE_HOME=/var/lib/cattle
    CATTLE_HOST_API_PROXY_MODE=embedded
    CATTLE_LOGBACK_OUTPUT_GELF_HOST=
    CATTLE_LOGBACK_OUTPUT_GELF_PORT=
    CATTLE_RANCHER_COMPOSE_VERSION=v0.8.3
    CATTLE_RANCHER_SERVER_IMAGE=v1.1.0-dev4
    CATTLE_USE_LOCAL_ARTIFACTS=true
    DEFAULT_CATTLE_API_UI_INDEX=//releases.rancher.com/ui/1.1.4
    DEFAULT_CATTLE_CATALOG_EXECUTE=true
    DEFAULT_CATTLE_CATALOG_URL=library=file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git,community=file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git
    DEFAULT_CATTLE_COMPOSE_EXECUTOR_EXECUTE=true
    DEFAULT_CATTLE_MACHINE_EXECUTE=true
    DEFAULT_CATTLE_RANCHER_COMPOSE_DARWIN_URL=https://releases.rancher.com/compose/v0.8.3/rancher-compose-darwin-amd64-v0.8.3.tar.gz
    DEFAULT_CATTLE_RANCHER_COMPOSE_LINUX_URL=https://releases.rancher.com/compose/v0.8.3/rancher-compose-linux-amd64-v0.8.3.tar.gz
    DEFAULT_CATTLE_RANCHER_COMPOSE_WINDOWS_URL=https://releases.rancher.com/compose/v0.8.3/rancher-compose-windows-386-v0.8.3.zip
    22:10:44.563 [main] WARN  o.e.jetty.security.SecurityHandler - ServletContext@o.e.j.w.WebAppContext@6c521576{/,file:/usr/share/cattle/3c21fe838dfcc6b7636bf16fd0648a5d/,STARTING}{file:/usr/share/cattle/3c21fe838dfcc6b7636bf16fd0648a5d/} has uncovered http methods for path: /
    22:10:46.807 [main] INFO  ConsoleStatus - [1/6] [1ms] [1ms] Loading config-bootstrap
    22:10:47.205 [main] INFO  ConsoleStatus - [2/6] [400ms] [384ms] Loading base-config
    22:10:47.771 [main] INFO  ConsoleStatus - [3/6] [966ms] [564ms] Loading config
    22:10:47.790 [main] INFO  ConsoleStatus - [4/6] [985ms] [17ms] Starting config-bootstrap
    22:10:49.053 [main] INFO  ConsoleStatus - [5/6] [2248ms] [1224ms] Starting base-config
    22:10:49.055 [main] INFO  ConsoleStatus - [6/6] [2250ms] [0ms] Starting config
    2016-06-09 22:10:49,619 INFO    [main] [ConsoleStatus] [1/32] [0ms] [0ms] Loading bootstrap 
    2016-06-09 22:10:49,780 INFO    [main] [ConsoleStatus] [2/32] [161ms] [159ms] Loading config-defaults 
    2016-06-09 22:10:56,632 WARN    [main] [liquibase] modifyDataType will lose primary key/autoincrement/not null settings for mysql.  Use <sql> and re-specify all configuration if this is the case 
    2016-06-09 22:11:15,767 INFO    [main] [ConsoleStatus] [3/32] [26148ms] [25985ms] Loading system 
    2016-06-09 22:11:15,856 INFO    [main] [ConsoleStatus] [4/32] [26237ms] [87ms] Loading defaults 
    2016-06-09 22:11:16,374 INFO    [main] [ConsoleStatus] [5/32] [26755ms] [517ms] Loading types 
    2016-06-09 22:11:22,146 INFO    [main] [ConsoleStatus] [6/32] [32527ms] [5770ms] Loading system-services 
    2016-06-09 22:11:22,623 INFO    [main] [ConsoleStatus] [7/32] [33004ms] [477ms] Loading agent-server 
    2016-06-09 22:11:23,124 INFO    [main] [ConsoleStatus] [8/32] [33505ms] [499ms] Loading allocator-server 
    2016-06-09 22:11:25,318 INFO    [main] [ConsoleStatus] [9/32] [35699ms] [2192ms] Loading api-server 
    2016-06-09 22:11:28,575 INFO    [main] [ConsoleStatus] [10/32] [38956ms] [3257ms] Loading iaas-api 
    2016-06-09 22:11:28,799 INFO    [main] [ConsoleStatus] [11/32] [39180ms] [222ms] Loading archaius 
    2016-06-09 22:11:29,302 INFO    [main] [ConsoleStatus] [12/32] [39683ms] [503ms] Loading core-model 
    2016-06-09 22:11:29,335 INFO    [main] [ConsoleStatus] [13/32] [39716ms] [31ms] Loading core-object-defaults 
    2016-06-09 22:11:29,381 INFO    [main] [ConsoleStatus] [14/32] [39762ms] [43ms] Loading encryption 
    2016-06-09 22:11:32,537 INFO    [main] [ConsoleStatus] [15/32] [42918ms] [3155ms] Loading process 
    2016-06-09 22:11:32,674 INFO    [main] [ConsoleStatus] [16/32] [43055ms] [135ms] Loading redis 
    2016-06-09 22:11:32,780 INFO    [main] [ConsoleStatus] [17/32] [43161ms] [104ms] Starting bootstrap 
    2016-06-09 22:11:32,793 INFO    [main] [ConsoleStatus] [18/32] [43174ms] [0ms] Starting config-defaults 
    2016-06-09 22:11:32,795 INFO    [main] [ConsoleStatus] [19/32] [43176ms] [0ms] Starting system 
    2016-06-09 22:11:32,797 INFO    [main] [ConsoleStatus] [20/32] [43178ms] [1ms] Starting defaults 
    2016-06-09 22:11:32,798 INFO    [main] [ConsoleStatus] [21/32] [43179ms] [0ms] Starting types 
    2016-06-09 22:11:39,809 INFO    [main] [ConsoleStatus] [22/32] [50190ms] [7009ms] Starting system-services 
    2016-06-09 22:11:39,811 INFO    [main] [ConsoleStatus] [23/32] [50192ms] [0ms] Starting agent-server 
    2016-06-09 22:11:39,813 INFO    [main] [ConsoleStatus] [24/32] [50194ms] [0ms] Starting allocator-server 
    2016-06-09 22:11:42,281 INFO    [main] [ConsoleStatus] [25/32] [52662ms] [2466ms] Starting api-server 
    2016-06-09 22:11:43,978 INFO    [main] [ConsoleStatus] [26/32] [54359ms] [1695ms] Starting iaas-api 
    2016-06-09 22:11:43,980 INFO    [main] [ConsoleStatus] [27/32] [54361ms] [0ms] Starting archaius 
    2016-06-09 22:11:43,982 INFO    [main] [ConsoleStatus] [28/32] [54363ms] [0ms] Starting core-model 
    2016-06-09 22:11:43,984 INFO    [main] [ConsoleStatus] [29/32] [54365ms] [1ms] Starting core-object-defaults 
    2016-06-09 22:11:43,985 INFO    [main] [ConsoleStatus] [30/32] [54366ms] [0ms] Starting encryption 
    2016-06-09 22:11:43,991 INFO    [main] [ConsoleStatus] [31/32] [54372ms] [4ms] Starting process 
    2016-06-09 22:11:43,993 INFO    [main] [ConsoleStatus] [32/32] [54374ms] [0ms] Starting redis 
    22:11:44.248 [main] INFO  ConsoleStatus - [DONE ] [61502ms] Startup Succeeded, Listening on port 8081
    INFO[0000] Starting websocket proxy. Listening on [:8080], Proxying to cattle API at [localhost:8081], Monitoring parent pid [8]. 
    INFO[0000] Downloading certificate from http://localhost:8081/v1/credentials/1c1/certificate 
    INFO[0000] Starting Rancher Catalog service             
    INFO[2016-06-09T22:11:46Z] Using catalog library=file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git 
    INFO[2016-06-09T22:11:46Z] Using catalog community=file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git 
    INFO[2016-06-09T22:11:46Z] Cloning the catalog from git URL file:///tmp/cloned-catalog/github.com/rancher/rancher-catalog/.git 
    Cloning into './DATA/library'...
    INFO[0000] Setting log level                             logLevel=info
    INFO[0000] Starting go-machine-service...                gitcommit=v0.31.4
    INFO[0000] Waiting for handler registration (1/2)       
    INFO[0000] Starting rancher-compose-executor             version=v0.8.3
    remote: Counting objects: 59, done.
    remote: Compressing objects: 100% (56/56), done.
    Receiving objects: 100% (59/59), 17.62 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (16/16), done.
    remote: Total 59 (delta 16), reused 0 (delta 0)
    Checking connectivity... done.
    INFO[2016-06-09T22:11:47Z] Cloning the catalog from git URL file:///tmp/cloned-catalog/github.com/rancher/community-catalog/.git 
    Cloning into './DATA/community'...
    remote: Counting objects: 618, done.
    remote: Compressing objects: 100% (543/543), done.
    remote: Total 618 (delta 70), reused 618 (delta 70)
    Receiving objects: 100% (618/618), 606.35 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (70/70), done.
    Checking connectivity... done.
    INFO[0001] Initializing event router                     workerCount=10
    INFO[0002] Connection established                       
    INFO[0003] Initializing event router                     workerCount=10
    INFO[0003] Connection established                       
    INFO[0003] Waiting for handler registration (2/2)       
    INFO[0004] Initializing event router                     workerCount=10
    INFO[0004] Connection established                       
    INFO[0004] Installing builtin drivers                   
    INFO[0004] Activating driver packet                     
    INFO[0005] Activating driver amazonec2                  
    INFO[0005] Event                                         eventId=7bc118df-4718-4afd-8657-d82ce2274ca0 name=machinedriver.activate;handler=goMachineService-machine resourceId=1md1
    INFO[0005] Download https://github.com/packethost/docker-machine-driver-packet/releases/download/v0.1.2/docker-machine-driver-packet_linux-amd64.zip 
    INFO[0005] Activating driver azure                      
    INFO[0005] Event                                         eventId=79ae612e-9808-43d1-86d4-e8f80c2893bf name=machinedriver.activate;handler=goMachineService-machine resourceId=1md2
    INFO[0005] Activating driver digitalocean               
    INFO[0005] Event                                         eventId=4f4888d1-6139-44fe-9421-a9c8372b4714 name=machinedriver.activate;handler=goMachineService-machine resourceId=1md3
    INFO[0005] Installing builtin driver exoscale           
    INFO[0006] Event                                         eventId=aceed857-4251-4318-bd6c-c1219c3a5b43 name=machinedriver.activate;handler=goMachineService-machine resourceId=1md4
    INFO[0006] Installing builtin driver generic            
    INFO[0007] Installing builtin driver google             
    INFO[0007] Installing builtin driver hyperv             
    INFO[0007] Installing builtin driver openstack          
    INFO[0007] Installing builtin driver rackspace          
    INFO[0007] Creating schema amazonec2Config, roles [service member owner project admin user readAdmin readonly restricted]  id=1ds1
    INFO[0007] Installing builtin driver softlayer          
    INFO[0008] Installing builtin driver vmwarevcloudair    
    INFO[0008] Installing builtin driver vmwarevsphere      
    INFO[0008] Downloading all drivers                      
    INFO[0008] Updating machine jsons for  [amazonec2 packet amazonec2 azure digitalocean] 
    INFO[0008] Done downloading all drivers                 
    INFO[0008] Creating schema machine, roles [service]      id=1ds2
    INFO[0009] Creating schema machine, roles [project member owner]  id=1ds3
    INFO[0009] Creating schema machine, roles [admin user readAdmin]  id=1ds4
    INFO[0010] Creating schema machine, roles [readonly]     id=1ds5
    INFO[0010] Creating schema digitaloceanConfig, roles [service member owner project admin user readAdmin readonly restricted]  id=1ds6
    INFO[0010] Updating machine jsons for  [digitalocean packet amazonec2 azure digitalocean] 
    INFO[0011] Creating schema machine, roles [service]      id=1ds7
    INFO[0012] Creating schema machine, roles [project member owner]  id=1ds8
    INFO[0012] Creating schema machine, roles [admin user readAdmin]  id=1ds9
    INFO[0012] Creating schema machine, roles [readonly]     id=1ds10
    INFO[0013] Creating schema azureConfig, roles [service member owner project admin user readAdmin readonly restricted]  id=1ds11
    INFO[0013] Updating machine jsons for  [azure packet amazonec2 azure digitalocean] 
    INFO[0014] Creating schema machine, roles [service]      id=1ds12
    INFO[0014] Creating schema machine, roles [project member owner]  id=1ds13
    INFO[0015] Creating schema machine, roles [admin user readAdmin]  id=1ds14
    INFO[0015] Creating schema machine, roles [readonly]     id=1ds15
    INFO[0026] Found driver docker-machine-driver-packet    
    INFO[0026] Copying /var/lib/cattle/machine-drivers/1f7058341420e2f525168052818c3f819ff78e9ca5f57d5a650a049bcd5945e9-docker-machine-driver-packet => /usr/local/bin/docker-machine-driver-packet 

    [vagrant@localhost rancher-catalog-service]$ docker inspect -f {{.NetworkSettings.IPAddress}} $(docker ps -a | grep rancher-server | awk '{print $1}')
    172.17.0.14

    [vagrant@localhost rancher-catalog-service]$ curl http://172.17.0.14:8080
    {"type":"collection","resourceType":"apiVersion","links":{"self":"http://172.17.0.14:8080/","latest":"http://172.17.0.14:8080/v1"},"createTypes":{},"actions":{},"data":[{"id":"v1","type":"apiVersion","links":{"self":"http://172.17.0.14:8080/v1"},"actions":{}}],"sortLinks":{},"pagination":null,"sort":null,"filters":{},"createDefaults":{}}

    [vagrant@localhost rancher-catalog-service]$ curl http://172.17.0.14:8088
    {"data":[{"actions":{},"id":"v1-catalog","links":{"self":"http://172.17.0.14:8088/v1-catalog"},"type":"apiVersion"}],"links":{"latest":"http://172.17.0.14:8088/v1-catalog","self":"http://172.17.0.14:8088/"},"resourceType":"apiVersion","type":"collection"}

    [vagrant@localhost rancher-catalog-service]$ ID=$(docker ps -a | grep rancher-server | awk '{print $1}'); docker stop $ID && docker rm $ID
    be737c0e4549
    be737c0e4549 
