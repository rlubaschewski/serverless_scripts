print_with_color() {
  GREEN='\033[0;32m';
  NOCOLOR='\033[0m';
  echo "${GREEN}$1${NOCOLOR}";
}

install() {
    minikube start --vm-driver=$1
    brew install faas-cli;
    brew install kubernetes-helm;
    kubectl -n kube-system create sa tiller \
    && kubectl create clusterrolebinding tiller \
    --clusterrole cluster-admin \
    --serviceaccount=kube-system:tiller;
    helm init --skip-refresh --upgrade --service-account tiller;
    print_with_color "create namespace for OpenFaaS core services and for the Functions...";
    kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml;
    print_with_color "Add the OpenFaaS helm chart...";
    helm repo add openfaas https://openfaas.github.io/faas-netes/;
    print_with_color "Generate secrets so that we can enable basic authentication for the gateway..."
    PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
    kubectl -n openfaas create secret generic basic-auth \
    --from-literal=basic-auth-user=admin \
    --from-literal=basic-auth-password="$PASSWORD"
    print_with_color "Deploy OpenFaaS to the Helm Chart Repo..."
    helm repo update \
    && helm upgrade openfaas --install openfaas/openfaas \
        --namespace openfaas  \
        --set basic_auth=true \
        --set functionNamespace=openfaas-fn
}

install