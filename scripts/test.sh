#!/bin/bash

wait_for_pod() {
  NAMESPACE=$1;
  LABEL=$2;
  PODNAME=$3;
  while [[ $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" && 
  $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True" ]] 
  do 
    echo "waiting for $PODNAME pod to be ready...";
    sleep 10; 
  done
}

wait_for_istio_pods() {
  istio_pods=("cluster-local-gateway" "citadel" "galley" "ingressgateway" "pilot" "sidecar-injector");

  for i in "${istio_pods[@]}"
  do
    wait_for_pod istio-system istio=$i $i;
  done
  wait_for_pod istio-system istio-mixer-type=policy policy;
  wait_for_pod istio-system istio-mixer-type=telemetry telemetry;
}

wait_for_istio_pods;