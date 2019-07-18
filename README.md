# Shell Scrips for starting up Minikube with Serverless Frameworks on MacOS

In order for the scripts to work make sure to have 
- a hypervisor installed (for example [Hyperkit](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver))

Install Hyperkit:

```
brew install hyperkit
```

Hyperkit driver for Minikube:
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit \
&& sudo install -o root -g wheel -m 4755 docker-machine-driver-hyperkit /usr/local/bin/
```

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos) installed
```
brew install kubernetes-cli
```
- [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube) installed (make sure to use minikube 1.2.0 or higher)
```
brew cask install minikube
```

To setup Minikube with your desired framework:
```
git clone https://github.com/rlubaschewski/serverless_scripts.git

cd serverless_scripts/scripts

chmod +x ${desired_framework}.sh

./${desired_framework}.sh ${desired_driver}
```

See a list of the available drivers [here](https://kubernetes.io/docs/setup/learning-environment/minikube/#specifying-the-vm-driver).

Example:

```
chmod +x ./openfaas.sh
./openfaas.sh
```

Not passing any hypervisor driver will default the driver to ```hyperkit```


## OpenFaaS


Installation:
```shell
chmod +x openfaas.sh
./openfaas.sh
```

After the installation is completed, add environment variables to current shell with:
```
source ../output/openfaas.txt
```
Then you can login with:
```
echo -n $PASSWORD | faas-cli login -g $OPENFAAS_URL -u admin --password-stdin
```
Complete the [assignments](https://github.com/rlubaschewski/serverless_scripts/blob/master/docs/assignments/openfaas.md) and fill out the [survey](https://docs.google.com/forms/d/e/1FAIpQLSdYn0lkUgtiH7VqgNXOnachXUJaqtCJtYcibiPCeUL6yYMHDw/viewform?usp=sf_link).

## Knative

Start up a Cluster with Knative by passing your desired hypervisor driver

**Note:** Knative is known to run slowly and inconsistently using virtualbox for MacOS Users. Recommendation: use [Hyperkit](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver)

Example:
```shell
chmod +x knative.sh
./knative.sh
```
After the installation is completed, add environment variables to current shell with:

```
source ../output/knative.txt
```

Complete the [assignments](https://github.com/rlubaschewski/serverless_scripts/blob/master/docs/assignments/knative.md) and fill out the [survey](https://docs.google.com/forms/d/e/1FAIpQLSdP-Sd-CBBGkNBc_sZtsF9Tp39ytKKH7FWh86oMNS6VQydjXg/viewform).