print_with_color() {
  GREEN='\033[0;32m';
  NOCOLOR='\033[0m';
  echo "${GREEN}$1${NOCOLOR}";
}

print_with_color "Setting up Minikube...";
minikube start --memory=16384 --cpus=4 \
  --kubernetes-version=v1.14.2 \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook";
print_with_color "Installing Gloo...";
curl -sL https://run.solo.io/gloo/install | sh;
print_with_color "Adding Gloo to path...";
export PATH=$HOME/.gloo/bin:$PATH;
print_with_color "install gloo's function gateway functionality into the 'gloo-system' namespace"
glooctl install gateway;
print_with_color "install very basic Kubernetes Ingress support with Gloo into namespace gloo-system"
glooctl install ingress;
print_with_color "install gloo and knative on kubernetes cluster...";
glooctl install knative;
print_with_color "installing knative-monitoring components..."
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring-metrics-prometheus.yaml;
print_with_color "watch these components until all are completed or running..."
kubectl get pods --namespace knative-serving;
kubectl get pods --namespace knative-monitoring;
print_with_color "use 'kubectl get pods --namespace knative-serving --watch' and 'kubectl get pods --namespace knative-monitoring --watch'"





