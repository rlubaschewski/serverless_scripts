print_with_color() {
  GREEN='\033[0;32m';
  NOCOLOR='\033[0m';
  echo "${GREEN}$1${NOCOLOR}";
}

vm_driver="$1"

install_cli() {
  cp ./binaries/knctl-* /usr/local/bin/knctl;
  chmod +x /usr/local/bin/knctl;
}

install() {
  print_with_color "Installing the Knative CLI...";
  install_cli;
  print_with_color "Setting up Minikube...";
  minikube start --memory=16384 --cpus=4 --vm-driver=$vm_driver -p knative_gloo;
  print_with_color "Installing Gloo...";
  curl -sL https://run.solo.io/gloo/install | sh;
  print_with_color "Setting knative to the desired minikube profile...";
  minikube profile knative_gloo;
  # print_with_color "Enabling ingress on minikube...";
  # minikube addons enable ingress;
  print_with_color "Adding Gloo to path...";
  export PATH=$HOME/.gloo/bin:$PATH;
  print_with_color "Installing gloo's function gateway functionality into the 'gloo-system' namespace"
  glooctl install gateway;
  print_with_color "Installing very basic Kubernetes Ingress support with Gloo into namespace gloo-system"
  glooctl install ingress;
  print_with_color "Installing gloo and knative on kubernetes cluster...";
  glooctl install knative;
  print_with_color "Installing knative-monitoring components..."
  kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring-metrics-prometheus.yaml;
  print_with_color "watch these components until all are completed or running..."
  kubectl get pods --namespace knative-serving;
  kubectl get pods --namespace knative-monitoring;
  print_with_color "use 'kubectl get pods --namespace knative-serving --watch' and 'kubectl get pods --namespace knative-monitoring --watch'"
}

install;






