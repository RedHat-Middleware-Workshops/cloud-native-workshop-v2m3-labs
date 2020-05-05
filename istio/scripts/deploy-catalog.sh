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
oc delete dc,deployment,bc,build,svc,route,pod,is --all

echo "Waiting 30 seconds to finialize deletion of resources..."
sleep 30

sed -i "s/userXX/${USERXX}/g" $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m3-labs/catalog/src/main/resources/application-openshift.properties
mvn clean install spring-boot:repackage -DskipTests -f $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m3-labs/catalog

oc new-app -e POSTGRESQL_USER=catalog \
             -e POSTGRESQL_PASSWORD=mysecretpassword \
             -e POSTGRESQL_DATABASE=catalog \
             openshift/postgresql:latest \
             --name=catalog-database

oc new-build java:8 --binary --name=catalog-springboot -l app=catalog-springboot

if [ ! -z $DELAY ]
  then
    echo Delay is $DELAY
    sleep $DELAY
fi

oc start-build catalog-springboot --from-file $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m3-labs/catalog/target/catalog-1.0.0-SNAPSHOT.jar --follow
oc new-app catalog-springboot -e JAVA_OPTS_APPEND='-Dspring.profiles.active=openshift'

oc label dc/catalog-database app.openshift.io/runtime=postgresql --overwrite && \
oc label dc/catalog-springboot app.openshift.io/runtime=spring --overwrite && \
oc label dc/catalog-springboot app.kubernetes.io/part-of=catalog --overwrite && \
oc label dc/catalog-database app.kubernetes.io/part-of=catalog --overwrite && \
oc annotate dc/catalog-springboot app.openshift.io/connects-to=catalog-database --overwrite && \
oc annotate dc/catalog-springboot app.openshift.io/vcs-uri=https://github.com/RedHat-Middleware-Workshops/cloud-native-workshop-v2m3-labs.git --overwrite && \
oc annotate dc/catalog-springboot app.openshift.io/vcs-ref=ocp-4.4 --overwrite
