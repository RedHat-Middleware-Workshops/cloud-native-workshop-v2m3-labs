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

oc project $USERXX-inventory

mvn clean -f $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m3-labs/inventory package -DskipTests

oc new-app -e POSTGRESQL_USER=inventory \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=inventory openshift/postgresql:latest \
  --name=inventory-database

oc new-build registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.5 --binary --name=inventory-quarkus -l app=inventory-quarkus

if [ ! -z $DELAY ]
  then
    echo Delay is $DELAY
    sleep $DELAY
fi

oc start-build inventory-quarkus --from-file $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m3-labs/inventory/target/*-runner.jar --follow
oc new-app inventory-quarkus -e QUARKUS_PROFILE=prod