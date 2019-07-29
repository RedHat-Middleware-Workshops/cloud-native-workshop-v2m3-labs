#!/bin/bash

USERXX=$1

if [ -z $USERXX ]
  then
    echo "Usage: Input your username like cleanup.sh user1"
    exit;
fi

echo Your username is $USERXX

echo Clean up Catalog service........

oc project $USERXX-catalog

oc delete policy/auth-policy

oc patch dc/catalog-database --type=json -p='[{"op":"remove", "path": "/spec/template/metadata/annotations"}]'

sed -i '/sidecar/d' /projects/cloud-native-workshop-v2m3-labs/catalog/src/main/fabric8/catalog-deployment.yml
sed -i '/annotations/d' /projects/cloud-native-workshop-v2m3-labs/catalog/src/main/fabric8/catalog-deployment.yml

echo Complete to clean up.........
