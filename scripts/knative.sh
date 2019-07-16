#!/bin/bash

print_with_color() {
  GREEN='\033[0;32m';
  NOCOLOR='\033[0m';
  echo "${GREEN}$1${NOCOLOR}";
}

wait_for_pod() {
  NAMESPACE=$1;
  LABEL=$2;
  PODNAME=$3;
  while [[ $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" && 
  $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True" ]] 
  do 
    print_with_color "waiting for $PODNAME pod to be ready...";
    sleep 10; 
  done
}

wait_for_istio_pods() {
  istio_pods=("citadel" "galley" "ingressgateway" "pilot" "sidecar-injector" "cluster-local-gateway");

  for i in "${istio_pods[@]}"
  do
    wait_for_pod istio-system istio=$i $i;
  done
  wait_for_pod istio-system istio-mixer-type=policy policy;
  wait_for_pod istio-system istio-mixer-type=telemetry telemetry;
}

wait_for_knative_pods() {

  serving_pods=("activator" "autoscaler" "controller" "networking-istio" "webhook");
  monitoring_pods=("elasticsearch-logging" "grafana" "kibana-logging" "kube-state-metrics" "node-exporter" "prometheus");

  # knative-serving
  for i in "${serving_pods[@]}"
  do
    wait_for_pod knative-serving app=$i $i;
  done

  # knative-monitoring
  for i in "${monitoring_pods}"
  do
    wait_for_pod knative-monitoring app=$i $i;
  done
}

vm_driver="$1"

install_cli() {
  cp ../binaries/knctl-* /usr/local/bin/knctl;
  echo "copied knctl to /usr/local/bin";
  chmod +x /usr/local/bin/knctl;
}

install() {
  print_with_color "Installing the Knative CLI...";
  install_cli;
  print_with_color "Setting up Minikube...";
  minikube start --vm-driver=${vm_driver:-hyperkit} --memory=16384 --cpus=6 -p knative --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook";
  print_with_color "Setting knative to the desired minikube profile...";
  minikube profile knative;
  print_with_color "Installing Istio...";
  kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.7.0/third_party/istio-1.1.7/istio-crds.yaml &&
  curl -L https://raw.githubusercontent.com/knative/serving/v0.7.0/third_party/istio-1.1.7/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
  kubectl label namespace default istio-injection=enabled;
  wait_for_istio_pods;
  print_with_color "Installing Knative...";
  kubectl apply --selector knative.dev/crd-install=true \
  --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml \
  --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
  kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
  wait_for_knative_pods;
  echo "export KNATIVE_GATEWAY=\$(minikube ip):\$(kubectl get svc \$INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')" >> ../output/knative.txt;
  print_with_color "Knative was successfully installed!";
  print_with_color "Add Environmental Variables with:"
  print_with_color "source ../output/knative.txt";
}

install;






