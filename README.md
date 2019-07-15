# Shell Scrips for starting up Minikube with Serverless Frameworks on MacOS

In order for the scripts to work make sure to have 
- a hypervisor installed (for example [virtualbox](https://www.virtualbox.org/wiki/Downloads))
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos) installed
- [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube) installed (make sure to use minikube 1.2.0 or higher)

To setup Minikube with your desired framework:
```
git clone https://github.com/rlubaschewski/serverless_scripts.git

cd serverless_scripts/scripts

sh ${desired_framework}.sh ${desired_driver}
```

See a list of the available drivers [here](https://kubernetes.io/docs/setup/learning-environment/minikube/#specifying-the-vm-driver)

Example:

```
sh openfaas.sh virtualbox
```

## OpenFaaS


Installation:
```shell
sh openfaas.sh virtualbox
```

After the installation is completed, add environment variables to current shell with:
```
source output/openfaas.txt
```


## Knative with Gloo

Start up a Cluster with Knative using Gloo by passing your desired hypervisor driver

Example:
```shell
sh knative.sh virtualbox
```

See a list of the available drivers [here](https://kubernetes.io/docs/setup/learning-environment/minikube/#specifying-the-vm-driver)

