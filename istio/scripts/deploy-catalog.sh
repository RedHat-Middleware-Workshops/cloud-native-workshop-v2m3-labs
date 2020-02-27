#!/bin/bash

USERXX=$1
DELAY=$2

if [ -z "$USERXX" -o "$USERXX" = "userXX" ]
  then
    echo "Usage: Input your username like deploy-catalog.sh user1"
    exit;
fi


echo Your username is $USERXX

echo Deploy Catalog service........

oc project $USERXX-catalog || oc new-project $USERXX-catalog

oc delete dc,bc,build,svc,route,pod,is --all

echo "Waiting 30 seconds to finialize deletion of resources..."
sleep 30

rm -rf /projects/cloud-native-workshop-v2m3-labs/catalog/src/main/resources/application-default.properties
cp /projects/cloud-native-workshop-v2m3-labs/istio/scripts/application-default.properties /projects/cloud-native-workshop-v2m3-labs/catalog/src/main/resources/
sed -i "s/userXX/${USERXX}/g" /projects/cloud-native-workshop-v2m3-labs/catalog/src/main/resources/application-default.properties

cd /projects/cloud-native-workshop-v2m3-labs/catalog/

oc new-app -e POSTGRESQL_USER=catalog \
             -e POSTGRESQL_PASSWORD=mysecretpassword \
             -e POSTGRESQL_DATABASE=catalog \
             openshift/postgresql:10 \
             --name=catalog-database

mvn clean package spring-boot:repackage -DskipTests

oc new-build registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.5 --binary --name=catalog-springboot -l app=catalog-springboot

if [ ! -z $DELAY ]
  then
    echo Delay is $DELAY
    sleep $DELAY
fi

oc start-build catalog-springboot --from-file=target/catalog-1.0.0-SNAPSHOT.jar --follow
oc new-app catalog-springboot
oc expose service catalog-springboot

clear
echo "Done! Verify by accessing in your browser:"
echo
echo "http://$(oc get route catalog-springboot -o=go-template --template='{{ .spec.host }}')"
echo