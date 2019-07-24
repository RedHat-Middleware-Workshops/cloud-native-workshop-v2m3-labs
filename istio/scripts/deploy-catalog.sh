#!/bin/bash

USERXX=$1

if [ -z $USERXX ]
  then
    echo "Usage: Input your username like cloud-native-app-deploy.sh user1"
    exit;
fi

echo Your username is $USERXX

echo Deploy Catalog service........

oc project $USERXX-catalog

sed -i "s/userXX/${USERXX}/g" cloud-native-workshop-v2m3-labs/catalog/src/main/resources/application-openshift.properties

cd cloud-native-workshop-v2m3-labs/catalog/

oc new-app -e POSTGRESQL_USER=catalog \
             -e POSTGRESQL_PASSWORD=mysecretpassword \
             -e POSTGRESQL_DATABASE=catalog \
             openshift/postgresql:latest \
             --name=catalog-database
             
mvn package fabric8:deploy -Popenshift -DskipTests
