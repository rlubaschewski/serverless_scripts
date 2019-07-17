## OpenFaaS Assignments

Complete the survey [here](https://docs.google.com/forms/d/e/1FAIpQLSdYn0lkUgtiH7VqgNXOnachXUJaqtCJtYcibiPCeUL6yYMHDw/viewform?usp=sf_link)

For completing the assignments OpenFaaS offers:

- a Graphical User Interface (access via your ```$OPENFAAS_URL```, login with ```admin``` and your ```$PASSWORD```)
- a Command Line Interface (access via ```faas-cli```)
- a REST API ([Swagger Docs](https://github.com/openfaas/faas/tree/master/api-docs), access the api with your ```$OPENFAAS_URL``` and your desired endpoint)

### References

[OpenFaaS Docs](https://docs.openfaas.com/)

[faas-idler (scale to zero)](https://github.com/openfaas-incubator/faas-idler)

[faas-cli](https://github.com/openfaas/faas-cli)

[grafana](https://github.com/stefanprodan/faas-grafana)


### 1. Deployment

Deploy a function in a language of your choice to your local cluster. Make sure that scaling to zero is enabled on that function. The AutoScaling for the function should range from minimum 1 to maximum 10 Replicas. 

You can either use an existing Docker Image from the ```faas-cli store``` or create your own.


### 2. Invocation

Invoke the previously created function. 

### 3. Logs

Access the logs for the previously created function. 

### 4. Metrics

OpenFaaS offers Prometheus and it is possible to expose a Grafana dashboard to oversee the metrics. Open the Grafana Dashboard to oversee the metrics.

### 5. Remove

Remove the previously created function.