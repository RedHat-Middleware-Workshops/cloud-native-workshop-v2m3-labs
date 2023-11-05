#!/bin/bash

USERXX=$1
DELAY=$2

if [ -z $USERXX ]
  then
    echo "Usage: Input your username like deploy-inventory.sh user1"
    exit;
fi

echo Your username is $USERXX
echo Deploy Inventory service........

oc project $USERXX-inventory || oc new-project $USERXX-inventory
oc delete dc,deployment,bc,build,svc,route,pod,is --all

echo "Waiting 30 seconds to finialize deletion of resources..."
sleep 30

oc new-app -e POSTGRESQL_USER=inventory \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=inventory registry.redhat.io/rhel9/postgresql-15 \
  --name=inventory-database

mvn clean package -DskipTests -f $PROJECT_SOURCE/inventory

oc delete route inventory

oc label deployment/inventory-database app.openshift.io/runtime=postgresql --overwrite && \
oc label deployment/inventory app.kubernetes.io/part-of=inventory --overwrite && \
oc label deployment/inventory-database app.kubernetes.io/part-of=inventory --overwrite && \
oc annotate deployment/inventory app.openshift.io/connects-to=inventory-database --overwrite && \
oc annotate deployment/inventory app.openshift.io/vcs-ref=ocp-4.14 --overwrite