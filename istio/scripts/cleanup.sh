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
oc patch dc/catalog-springboot --type=json -p='[{"op":"remove", "path": "/spec/template/metadata/annotations"}]'

echo Complete to clean up.........
