# Running Devito with Dask and Kubernetes

This contains the Dockerfiles and .yaml files needed to run Devito code with dask_kubernetes.

## Instructions for running on minikube
1. Open the `docker-compose.yaml' file and change the `image` value from `rajatr/devito-dask-kube` to `YOUR-DOCKER-IMAGE-REPOSITRY/devito-dask-kube`
2. Do the same in `config/worker.yaml` and `kube/deployment.yaml` 
3. Log-in to docker with `docker login`. Run `docker-compose build && docker-compose push`. In the case of http timeout, just try again.
4. [Install minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
5. `minikube stop && minikube delete` (just in case there is already a minikube node running)
6. `minikube start --vm-driver hyperkit --cpus 8 --memory 8000` 
7. `eval $(minikube docker-env)`
8. `docker-compose pull YOUR-DOCKER-IMAGE-REPOSITRY/devito-dask-kube` although this is not necesary
9. Run all the configuration yaml files in `kube/` with `kubectl apply -f kube/`.
10. By running `kubectl get svc` you should see that the `svc-notebooks` service has an EXTERNAL-IP which is <pending>. This is because minikube does not support the load balancer serive. You can get the kubernetes URL for the `svc-notebooks` service from your local cluster with `minikube service svc-notebooks`.
