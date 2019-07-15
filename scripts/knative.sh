print_with_color() {
  GREEN='\033[0;32m';
  NOCOLOR='\033[0m';
  echo "${GREEN}$1${NOCOLOR}";
}

wait_for_pod() {
  NAMESPACE=$1;
  LABEL=$2;
  PODNAME=$3;
  while [[ $(kubectl get pods -n "$NAMESPACE" -l "$LABEL" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do print_with_color "Waiting for $PODNAME Pod to be ready..." && sleep 10; done
}

wait_for_gloo_pods() {
  gloo_pods = ( "clusteringress-proxy" "discovery" "gateway" "gateway-proxy" "gloo" "ingress" "ingress-proxy" );

  for i in "${gloo_pods[@]}"
  do
    wait_for_pod gloo-system gloo=$i $i;
  done
}

wait_for_knative_pods() {

  serving_pods = ( "activator" "autoscaler" "controller" "networking-certmanager" "webhook" );
  monitoring_pods = ( "grafana" "kube-state-metrics" "node-exporter" "prometheus" );

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
  minikube start --memory=8192 --cpus=4 --vm-driver=$vm_driver -p knative_gloo --extra-config=apiserver.enable-admission-plugins="MutatingAdmissionWebhook";
  print_with_color "Installing Gloo...";
  curl -sL https://run.solo.io/gloo/install | sh;
  print_with_color "Setting knative to the desired minikube profile...";
  minikube profile knative_gloo;
  print_with_color "Adding Gloo to path...";
  export PATH=$HOME/.gloo/bin:$PATH;
  print_with_color "Installing gloo and knative on kubernetes cluster...";
  glooctl install ingress;
  glooctl install gateway;
  glooctl install knative;
  wait_for_gloo_pods;
  print_with_color "Installing knative-monitoring components..."
  kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring-metrics-prometheus.yaml;
  wait_for_knative_pods
}

install;






