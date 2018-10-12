# Running Devito with Dask and Kubernetes

This contains the repo Dockerfiles, Kubernetes configuration YAML and instruction needed to solve a full-waveform inversion problem with Devito using Tensorflow on a dask-kubernetes cluster hosted on Google's Kubernetes Engine or Minikube.

## Instructions for running on Minikube
1. Open the `docker-compose.yaml' file and change the `image` value from `rajatr/devito-dask-kube` to `YOUR-DOCKER-IMAGE-REPOSITRY/devito-dask-kube`
2. Do the same in `config/worker.yaml` and `kube/minikube/deployment.yaml` 
3. Log-in to docker with `docker login`. Run `docker-compose build scheduler && docker-compose push scheduler`. In the case of http timeout, just try again. Then run `docker-compose build worker && docker-compose push worker`.
4. [Install minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
5. `minikube stop && minikube delete` (just in case there is already a minikube node running)
6. `minikube start --vm-driver hyperkit --cpus 4 --memory 8000` 
7. `eval $(minikube docker-env)`
8. Run all the configuration yaml files in `kube/minikube` with `kubectl apply -f kube/minikube`.
9. By running `kubectl get svc` you should see that the `svc-notebooks` service has an EXTERNAL-IP which is <pending>. This is because minikube does not support the load balancer serive. You can get the kubernetes URL for the `svc-notebooks` service from your local cluster with `minikube service svc-notebooks`.

For additional help with setting up minikube, refer to [Hello Minikube](https://kubernetes.io/docs/tutorials/hello-minikube/).

You may also need to alter the resource requests and limits for the workers (config/worker.yaml) or the scheduler (kube/minikube/deployment.yaml).

## Instructions for running on Google Kubernetes Engine
1. Set up a Google Cloud Platform project. Enable the Kubernetes Engine API within that project, then [configure default settings for gcloud](https://cloud.google.com/kubernetes-engine/docs/quickstart#defaults) and [create a GKE cluster](https://cloud.google.com/kubernetes-engine/docs/quickstart#create_cluster). The tutorial code in the notebooks has been tested primarily on a cluster with 2 nodes each of type n1-highmem-4 (4 vCPUs, 26 GB memory).
2. `gcloud container clusters update YOUR_CLUSTER_NAME --enable-legacy-authorization` to ensure there is no need for RBAC authentication required by the latest versions of kubernetes.
3. Create a data storage bucket called `fwi-data`. If you want to use another name, then the `c.GoogleStorageContentManager.default_path` field in `config/jupyter-config.py` must be changed to the name of your bucket.
4. `gsutil cp notebooks/* gs://fwi-data` to copy all the notebooks into the storage bucket.
5. Pushing docker images to container registries, which will eventually be deployed inside pods in the K8s cluster, is also handled by `docker-compose.yaml`. In this case, the images are being pushed to [GCP's container registry](https://cloud.google.com/container-registry/docs/quickstart). Change the `image` option under `scheduler_gcloud` and `worker_gcloud` your own google cloud container registry. Then run `docker-compose build gcloud_scheduler && docker-compose push gcloud_scheduler`. 
6. Run all the configuration yaml files in `kube/gcloud` with `kubectl apply -f kube/gcloud`. 
7. Open the IP address returned by `kubectl get svc | grep svc-notebook | awk '{print $4 ":80"}` to view and run the notebooks.

