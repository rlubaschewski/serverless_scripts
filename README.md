# Shell Scrips for starting up Minikube with Serverless Frameworks on MacOS

In order for the scripts to work make sure to have 
- a hypervisor installed (for example [virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos) installed
- [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube) installed

## Knative with Gloo

Start up a Cluster with Knative using Gloo by passing your desired hypervisor driver

Example:
```shell
sh knative.sh "virtualbox"
```

See a list of the available drivers [here](https://kubernetes.io/docs/setup/learning-environment/minikube/#specifying-the-vm-driver)

## OpenFaaS

Start up a Cluster with OpenFaaS by passing your desired hypervisor driver

Example:
```shell
sh openfaas.sh "virtualbox"
```