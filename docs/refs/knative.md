# Knative


### 1. Create Function from Store Template with scale to zero and min/max Replicas set to 0 and 10.
Scale to Zero is enabled by default in Knative

[Min/Max Replicas](https://github.com/knative/docs/tree/master/docs/serving/samples/autoscale-go#analysis)
```
knctl deploy -a autoscaling.knative.dev/minScale=0 -a autoscaling.knative.dev/maxScale=10 --service hello --image gcr.io
/knative-samples/helloworld-go --env TARGET=World
```
This will deploy a function to Kubernetes which scales to zero and auto-scales between 0 and 10 Replicas.

### 2. Invoke the Function

Function Invocation is not working with gloo using the CLI command. Possible with ```curl```
[Reference](https://knative.dev/docs/install/knative-with-gloo/)

Get the Domain of your function with:
```
kubectl get ksvc hello --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
```
Then invoke the function with:
```
curl -H "Host: hello.default.example.com" ${GATEWAY_URL}
```

### 3. Access logs for the function

[Reference](https://github.com/cppforlife/knctl/blob/master/docs/basic-workflow.md)
```
knctl logs -f --service hello
```


### 4. Access Grafana Dashboard

[Reference](https://github.com/knative/docs/blob/master/docs/serving/accessing-metrics.md)

```
kubectl port-forward --namespace knative-monitoring \
$(kubectl get pods --namespace knative-monitoring \
--selector=app=grafana --output=jsonpath="{.items..metadata.name}") \
3000
```
### 5. Remove the Deployed Function

[Reference](https://github.com/cppforlife/knctl/blob/master/docs/cmd/knctl_service_delete.md)

```
knctl service delete -n default -s hello
```