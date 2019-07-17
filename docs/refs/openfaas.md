# OpenFaaS


### 1. Create Function from Store Template with scale to zero and min/max Replicas set to 1 and 10.
[Scale to Zero Deployment with faas-idler](https://github.com/openfaas-incubator/faas-idler#activating-a-function-for-scale-to-zero)

[Min/Max Replicas](https://docs.openfaas.com/architecture/autoscaling/#minmax-replicas)
```
faas-cli store deploy figlet --label "com.openfaas.scale.zero=true" --label "com.openfaas.scale.min=1" --label "co
m.openfaas.scale.max=10"
```
This will deploy a function to Kubernetes which scales to zero and auto-scales between 1 and 10 Replicas.

### 2. Invoke the Function

[Function Invokation](https://docs.openfaas.com/cli/templates/#50-ruby)
(Scroll down to "Now you can invoke the function")
```
echo 'OpenFaaS' | faas-cli invoke figlet
```

### 3. Access logs for the function

No documentation available for the CLI log command ([Issue](https://github.com/openfaas/docs/issues/162)) .
```
faas-cli log figlet
```
Access logs with [kubectl](https://docs.openfaas.com/deployment/troubleshooting/#find-a-functions-logs_1)
```
kubectl logs -n openfaas-fn deploy/figlet
```
### 4. Access Grafana Dashboard

Use Grafana URL to open Dashboard. Login with admin credentials. [Reference](https://github.com/stefanprodan/faas-grafana#kubernetes)

### 5. Remove the Deployed Function

[Reference](https://docs.openfaas.com/tutorials/cli-with-node/#remove-the-function)

```
faas-cli rm figlet
```