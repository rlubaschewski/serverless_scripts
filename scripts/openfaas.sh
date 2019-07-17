#!/bin/bash

wait_for_pod() {
  NAMESPACE=$1;
  LABEL=$2;
  PODNAME=$3;
  while [[ $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]] 
  do 
    echo "Waiting for $PODNAME Pod to be ready...";
    sleep 10; 
  done
}

wait_for_openfaas_pods() {
  openfaas_pods=("queue-worker" "gateway" "nats" "prometheus" "basic-auth-plugin" "alertmanager" "faas-idler");
  
  for i in "${openfaas_pods[@]}"
  do
    wait_for_pod openfaas app=$i $i;
  done
}

vm_driver="$1"

install() {
    echo "Setting up Minikube...";
    minikube start --vm-driver=${vm_driver:-hyperkit} -p openfaas;
    echo "Setting Minikube profile to openfaas...";
    minikube profile openfaas
    echo "Installing the OpenFaaS CLI...";
    brew install faas-cli;
    echo "Installing the helm CLI/client..."
    brew install kubernetes-helm;
    echo "Installing tiller...";
    kubectl -n kube-system create sa tiller \
    && kubectl create clusterrolebinding tiller \
    --clusterrole cluster-admin \
    --serviceaccount=kube-system:tiller;
    echo "Installing the server-side Tiller component on your cluster...";
    helm init --skip-refresh --upgrade --service-account tiller;
    echo "create namespace for OpenFaaS core services and for the Functions...";
    kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml;
    echo "Add the OpenFaaS helm chart...";
    helm repo add openfaas https://openfaas.github.io/faas-netes/;
    echo "Generate secrets so that we can enable basic authentication for the gateway..."
    PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
    OPENFAAS_URL="$(minikube ip):31112";
    mkdir -p ../output;
    echo "export PASSWORD=$PASSWORD" >> ../output/openfaas.txt;
    echo "export OPENFAAS_URL=$OPENFAAS_URL" >> ../output/openfaas.txt;
    kubectl -n openfaas create secret generic basic-auth \
    --from-literal=basic-auth-user=admin \
    --from-literal=basic-auth-password="$PASSWORD"
    wait_for_pod kube-system name=tiller Tiller; 
    echo "Deploy OpenFaaS to the Helm Chart Repo..."
    helm repo update \
    && helm upgrade openfaas --install openfaas/openfaas \
        --namespace openfaas  \
        --set basic_auth=true \
        --set functionNamespace=openfaas-fn \
        --set faasIdler.dryRun=false \
        --set faasIdler.inactivityDuration=5m
    wait_for_openfaas_pods;
    echo "Run Grafana in OpenFaaS Namespace...";
    kubectl -n openfaas run \
        --image=stefanprodan/faas-grafana:4.6.3 \
        --port=3000 grafana
    wait_for_pod openfaas run=grafana Grafana;
    echo "Expose Grafana with a NodePort...";
    kubectl -n openfaas expose deployment grafana \
        --type=NodePort \
        --name=grafana
    echo "export OPENFAAS_GRAFANA_URL=$(kubectl -n openfaas get svc grafana -o jsonpath="{.spec.ports[0].nodePort}")" >> ../output/openfaas.txt;
    echo "OpenFaaS was successfully installed!";
    echo "Add Environment Variables with:";
    echo "source ../output/openfaas.txt";
    echo "Login with:";
    echo "echo -n \$PASSWORD | faas-cli login -g \$OPENFAAS_URL -u admin --password-stdin";
}

install;
