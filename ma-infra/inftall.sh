#!/bin/sh

# Globale Variable
ROT='\033[0;31m'
BLAU='\033[0;34m'
GELB='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="logging"

sep()
{
echo " "
echo "${BLAU}  ###########################################################${NC}"
echo "${GELB}  $1${NC}"
echo " "
}

err()
{
echo " "
echo "${ROT}  ###########################################################${NC}"
echo "${ROT}  $1${NC}"
echo " "
}

#set environment vars.
. ./env_unx

sep "start minikube"

minikube start --memory 8192 --cpus 4 --nodes 2 -p muno

STATUS=$?
if [ $STATUS -eq 0 ]; then
  sep "Minikube gestartet"
else
  err "minikube start Failed!"
  exit
fi

sep "create namespace"

kubectl create namespace $NAMESPACE

if kubectl get ns | grep -q "logging"; then
    sep "Der Namespace $NAMESPACE existiert."
else
    err "Der Namespace $NAMESPACE existiert nicht."
fi

kubectl create -f kubernetes/elastic.yaml -n $NAMESPACE

MINIKUBE_IP=$(minikube -p muno ip)
minikube -p muno addons enable ingress
echo -e "$MINIKUBE_IP elastic.minikube.dev" | sudo tee -a /etc/hosts
