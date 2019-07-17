## Knative Assignments

For completing the assignments Knative offers:

- Kubernetes Custom Ressource Definitions (CRDs) which can be accessed via the Kubernetes CLI ```kubectl```
- a community Command Line Interface ```knctl```

### References

[Knative Docs](https://knative.dev/docs/)
[Knative Community CLI (knctl)](https://github.com/cppforlife/knctl)
[Grafana](https://github.com/knative/docs/blob/master/docs/serving/accessing-metrics.md)
[Kibana](https://knative.dev/docs/serving/accessing-logs/)
[Request Traces](https://knative.dev/docs/serving/accessing-traces/)

### 1. Deployment

Deploy a function in a language of your choice to your local cluster. Make sure that scaling to zero is enabled on that function. The AutoScaling for the function should range from minimum 0 to maximum 10 Replicas. 

You can either use an existing Docker Image from the Google Container Registry or create your own.


### 2. Invocation

Invoke the previously created function. 
**Note:** Invocation is currently not working with the community CLI

### 3. Logs

Access the logs for the previously created function. 

### 4. Metrics

Knative offers multiple platforms in order to oversee the gained metrics:
- Prometheus with Grafana
- Elasticsearch with Kibana
- Stackdriver (not installed with the script)

You can also use End to End Request Tracing:
- Zipkin
- Jaeger (not installed with the script)

Feel free to install Stackdriver and Jaeger to your local Cluster with Knative! [More Information](https://knative.dev/docs/serving/installing-logging-metrics-traces/)


Access one of these platforms to oversee the metrics.

### 5. Remove

Remove the previously created function.