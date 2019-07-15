#!/bin/bash

print_with_color() {
  GREEN='\033[0;32m';
  NOCOLOR='\033[0m';
  echo "$GREEN$1$NOCOLOR";
}

wait_for_pod() {
  NAMESPACE=$1;
  LABEL=$2;
  PODNAME=$3;
  while [[ $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do print_with_color "Waiting for $PODNAME Pod to be ready..." && sleep 10; done
}

wait_for_openfaas_pods() {
  wait_for_pod openfaas app=queue-worker Queue-Worker;
  wait_for_pod openfaas app=gateway Gateway;
  wait_for_pod openfaas app=nats Nats;
  wait_for_pod openfaas app=prometheus Prometheus;
  wait_for_pod openfaas app=basic-auth-plugin Auth-Plugin;
  wait_for_pod openfaas app=alertmanager Alertmanager;
  wait_for_pod openfaas app=faas-idler FaaS-Idler;
}

vm_driver="$1"

install() {
    print_with_color "Setting up Minikube...";
    minikube start --vm-driver="$vm_driver" -p openfaas;
    print_with_color "Setting Minikube profile to openfaas...";
    minikube profile openfaas
    print_with_color "Installing the OpenFaaS CLI...";
    brew install faas-cli;
    print_with_color "Installing the helm CLI/client..."
    brew install kubernetes-helm;
    print_with_color "Installing tiller...";
    kubectl -n kube-system create sa tiller \
    && kubectl create clusterrolebinding tiller \
    --clusterrole cluster-admin \
    --serviceaccount=kube-system:tiller;
    print_with_color "Installing the server-side Tiller component on your cluster...";
    helm init --skip-refresh --upgrade --service-account tiller;
    print_with_color "create namespace for OpenFaaS core services and for the Functions...";
    kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml;
    print_with_color "Add the OpenFaaS helm chart...";
    helm repo add openfaas https://openfaas.github.io/faas-netes/;
    print_with_color "Generate secrets so that we can enable basic authentication for the gateway..."
    PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
    OPENFAAS_URL="$(minikube ip):31112";
    echo "export PASSWORD=$PASSWORD" >> ../output/openfaas.txt;
    echo "export OPENFAAS_URL=$OPENFAAS_URL" >> ../output/openfaas.txt;
    kubectl -n openfaas create secret generic basic-auth \
    --from-literal=basic-auth-user=admin \
    --from-literal=basic-auth-password="$PASSWORD"
    wait_for_pod kube-system name=tiller Tiller; 
    print_with_color "Deploy OpenFaaS to the Helm Chart Repo..."
    helm repo update \
    && helm upgrade openfaas --install openfaas/openfaas \
        --namespace openfaas  \
        --set basic_auth=true \
        --set functionNamespace=openfaas-fn \
        --set faasIdler.dryRun=false \
        --set faasIdler.inactivityDuration=5m
    wait_for_openfaas_pods;
    print_with_color "Run Grafana in OpenFaaS Namespace...";
    kubectl -n openfaas run \
        --image=stefanprodan/faas-grafana:4.6.3 \
        --port=3000 grafana
    wait_for_pod openfaas run=grafana Grafana;
    print_with_color "Expose Grafana with a NodePort...";
    kubectl -n openfaas expose deployment grafana \
        --type=NodePort \
        --name=grafana
    echo "export OPENFAAS_GRAFANA_URL=$(kubectl -n openfaas get svc grafana -o jsonpath="{.spec.ports[0].nodePort}")" >> ../output/openfaas.txt;
    print_with_color "OpenFaaS was successfully installed!";
    print_with_color "Add Environment Variables with:";
    print_with_color "source output/openfaas.txt";
    print_with_color "Login with:";
    print_with_color "echo -n \$PASSWORD | faas-cli login -g \$OPENFAAS_URL -u admin --password-stdin";
}

install;
