#!/bin/bash
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..

PROJECT=$(oc config view --minify -o 'jsonpath={..namespace}')

PATCH_NS="$(printf '.items[].metadata.namespace="%q"' $PROJECT)" 

# Fetch all default build pipelines and install into current namespace 
#oc get pipelines -n build-templates -o yaml  | yq  e "$PATCH_NS" - 
oc get pipelines -n build-templates -o yaml  | yq  e "$PATCH_NS" - | oc apply -f -
#oc get tasks -n build-templates -o yaml  | yq  e "$PATCH_NS" - 
oc get tasks -n build-templates -o yaml  | yq  e "$PATCH_NS" - | oc apply -f -
oc get pvc -n build-templates -o yaml  | yq  e "$PATCH_NS" - | oc apply -f -
