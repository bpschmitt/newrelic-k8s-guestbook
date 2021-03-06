# newrelic-k8s-guestbook
## Kubernetes Guestbook application
This repository contains all information to build a Kubernetes sample application. This work is based on previous work of Drew Decker (https://github.com/wreckedred/) and Clay Smith (https://github.com/smithclay/).

This is still a simple application, but it has some more services:
* **Frontend service**: Node.js app serving the UI
* **Parser service**: Node.js app responsable for parsing a message and sending it to RabbitMQ
* **Worker service**: Node.js app listening to RabbitMQ and pushing the message to Redis
* **Redis service**: For storing the message in Redis
* **Queue service**: RabbitMQ as message bus

![architecture](https://user-images.githubusercontent.com/45029322/53344050-00f8a300-3912-11e9-9b9f-d4ea0bdbc49e.png)

## Pre-requisites
You need a Kubernetes cluster to deploy this applicaton.

For Minikube: start minikube and make sure we can connect to Minikube's Docker daemon
```
minikube start
eval $(minikube docker-env) # Do this in every terminal window you are using
```

## Build the Docker images
* Navigate to the frontend/ directory:
`docker build -t nrlabs/newrelic-k8s-guestbook-frontend .`
* Navigate to the parser/ directory:
`docker build -t nrlabs/newrelic-k8s-guestbook-parser .`
* Navigate to the worker/ directory:
`docker build -t nrlabs/newrelic-k8s-guestbook-worker .`

## Create a Kubernetes secret with your New Relic license key
`kubectl create secret generic guestbook-secret --from-literal=new_relic_license_key='<YOUR KEY HERE>'`

## Install the APM metadata injection
* Navigate to the k8s/metadata folder: `kubectl apply -f .`
* Wait until the metadata-setup job is completed: `kubectl get pods`
```
newrelic-metadata-injection-deployment-56dbf48c6-wkbnc   1/1     Running     0          17s
newrelic-metadata-setup-zw8sl                            0/1     Completed   0          18s
```

## Create the Kubernetes cluster
* Navigate to the k8s/ folder: `kubectl apply -f .`

* Check where frontend is running: `kubectl describe service frontend`

**-> Look for 'NodePort 31811', we need this PORT**

* `kubectl cluster-info`

**-> Look for 'master IP: 192.168.64.3', we need this IP**

**Open IP:PORT in your browser**

*Wait until RabbitMQ is up and running before trying the app (see kubectl logs)*

## Debugging
```
watch kubectl logs -l tier=frontend --tail=20
watch kubectl logs -l tier=parser --tail=20
watch kubectl logs -l tier=worker --tail=20
watch kubectl logs -l tier=queue --tail=20
```

## Clean-up
`kubectl delete -f . # ATTENTION, this will delete everything from the yaml files in the current folder`

## Scale a deployment
`kubectl scale --replicas=2 deployment/parser`