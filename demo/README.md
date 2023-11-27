# HackSoft Django Containers Meet kubernetes scaling

[HackSoft Django Containers Meet kubernetes scaling](https://www.linkedin.com/events/djangobulgariameetup-novembered7131192374080229377/about/)

## 0. Pre-requisites

### 0.1 Create Virtual Machine

For this lecture we will use Linux Ubuntu 22.04 Virtual Machines. Keep in mind
this is not the focus of the lecture and we will not go into details.

I will use `vagrat` to bring it up:

```bash
~$ vagrant up
Bringing machine 'default' up with 'vmware_desktop' provider...
==> default: Cloning VMware VM: 'hajowieland/ubuntu-jammy-arm'. This can take some time...
==> default: Checking if box 'hajowieland/ubuntu-jammy-arm' version '1.0.0' is up to date...
==> default: Verifying vmnet devices are healthy...
==> default: Preparing network adapters...
==> default: Starting the VMware VM...
==> default: Waiting for the VM to receive an address...
==> default: Forwarding ports...
    default: -- 22 => 2222
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 192.168.59.142:22
    default: SSH username: vagrant
SNIP ....
SNIP ....
==> default: Enabling and configuring shared folders...
    default: -- /Users/vhristev/Documents/gitlab_home/vagrant/rxm-labvm: /vagrant

```

Lets get into the VM:

```bash
~$ vagrant ssh
Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.15.0-56-generic aarch64)

  System load:  0.080078125        Processes:               283
  Usage of /:   13.3% of 35.27GB   Users logged in:         0
  Memory usage: 3%                 IPv4 address for ens160: 192.168.59.142
  Swap usage:   0%


To check for new updates run: sudo apt update

vagrant@ubuntu:~$
```

### 0.2 Resize VM

In any case we can resize the VM if we need more space. Lets do that:

```bash
vagrant@ubuntu:~$ sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
vagrant@ubuntu:~$ sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

### 1. Install Docker

Lets start by installing Docker.

We will use Docker to run our containers. Here is a script to install it:

`cat install-docker.sh`

```bash
vagrant@ubuntu:~$ bash install-docker.sh
```

## 2.0 Overview Django app

Lets overview our Django app which is in `myproject` folder

We have simple Django app with `clock`, `random generated number` and a
JavaScript which will call a `service_status` page every second.


Lets first install pip

```bash
vagrant@ubuntu:~$ sudo apt install python3-pip
```

Now lets install the requirements for our Django app overview the app

```bash
vagrant@ubuntu:~$ pip3 install -r requirements.txt
vagrant@ubuntu:~$ cd myproject/
vagrant@ubuntu:~/myproject$ ls
-rw-r--r-- 1 vagrant vagrant 131072 Nov 27 01:36 db.sqlite3
-rwxr-xr-x 1 vagrant vagrant    665 Nov 27 01:36 manage.py
drwxr-xr-x 3 vagrant vagrant   4096 Nov 27 01:36 myproject
drwxr-xr-x 5 vagrant vagrant   4096 Nov 27 01:36 service
```

After the overview lets start the app to see if its working from our computer


```bash
vagrant@ubuntu:~/myproject$ python3 manage.py runserver
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
November 27, 2023 - 01:45:07
Django version 4.2.7, using settings 'myproject.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.

```

Now lets open Virtual Machine GUI and open the browser to
`http://127.0.0.1:8000`


### 3.0 Build Docker image

Now lets build our Docker image. In our repo we have a `Dockerfile` which will
build our image. Lets overview it first:

```bash
vagrant@ubuntu:~/myproject$ vim Dockerfile
```

Build the image:

```bash
vagrant@ubuntu:~/myproject$ docker build -t django-service:1.0.0 .
```

Lets overview the image:

```bash
vagrant@ubuntu:~/myproject$ docker images
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
django-service   1.0.0     4ea0350aabc4   5 seconds ago   176MB
```


### 3.1 Start Docker container

Now lets start our Docker container:

```bash
vagrant@ubuntu:~/myproject$ docker run --name django -d -p 8000:8000 django-service:1.0.0
72317c20e7762b73d057017f317a95b291f9447c3a72308fd5209de451cedcb6
```

Lets overview the container:

```bash
vagrant@ubuntu:~/myproject$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS                                       NAMES
ee991b86b863   django-service:1.0.0   "/bin/sh -c 'python …"   4 seconds ago   Up 3 seconds   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp   django
```

Now lets again open Virtual Machine GUI and open the browser to
`http://127.0.0.1:8000` and see if our application is working from the
container.


### 3.2 Push Docker image to Docker Hub

Now lets push our image to Docker Hub so we can use it later.

First we need to login to Docker Hub ( pre req is to have an account):

```bash
vagrant@ubuntu:~/myproject$ docker login
Authenticating with existing credentials...
Login Succeeded
```

Lets tag our image with our Docker Hub username. In my case its `rxmdemo`:

```bash
vagrant@ubuntu:~/myproject$ docker tag django-service:1.0.0 rxmdemo/django-service:1.0.0

```

Check the image:

```bash
vagrant@vagrant:~/demo$ docker images
REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
django-service           1.0.0     4ea0350aabc4   14 minutes ago   176MB
rxmdemo/django-service   1.0.0     4ea0350aabc4   14 minutes ago   176MB
```

As you can see now we have the same image but with different tags. One is the
one we build and the other is the one we tagged with our Docker Hub username.

Now lets push the image:

```bash
vagrant@ubuntu:~/myproject$ docker push rxmdemo/django-service:1.0.0
```

Now lets overview our Docker Hub account and see if the image is there.

Open [Docker Hub](https://hub.docker.com/) and find our image


## Scale with Kubernetes

### 4.0 Install Kubernetes with KinD

`KinD` is a tool for running local Kubernetes clusters using Docker container

```bash
vagrant@ubuntu:~$ bash install-kind.sh
```

Now we have kind lets create the Kubernetes cluster. From [KinD
documentation](https://kind.sigs.k8s.io/docs/user/configuration/) you can get a
sample configuration file. We already have one in this repo which will create 1
control plane node and 3 worker nodes.

```bash
kind create cluster --config kind-config.yaml --name=hacksoft
```


### 4.1 Install kubectl

`kubectl` is a command line tool for interacting with Kubernetes clusters.

```bash
vagrant@ubuntu:~$ bash install-kubectl.sh
```

Enable auto completion:

```bash
vagrant@ubuntu:~$ bash k8s-autocompletion.sh
```

Lets overview the cluster:

```bash
vagrant@ubuntu:~$ kubectl get nodes
NAME                     STATUS   ROLES           AGE     VERSION
hacksoft-control-plane   Ready    control-plane   4m11s   v1.27.3
hacksoft-worker          Ready    <none>          3m5s    v1.27.3
hacksoft-worker2         Ready    <none>          3m4s    v1.27.3
hacksoft-worker3         Ready    <none>          3m52s   v1.27.3
```

### 5.0 Deploy Django service

Lets create a deployment for our Django service:

```bash
vagrant@ubuntu:~$ kubectl create deployment django-app --image=rxmdemo/django-service:1.0.0 --port=8000 --replicas=1
deployment.apps/django-app created
```

Lets overview the deployment:

```bash
vagrant@vagrant:$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
django-app   1/1     1            1           85s
```

Lets overview the pods:

```bash
vagrant@ubuntu:~$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
django-app-55d6f6f587-wjs5m   1/1     Running   0          100s
```

All good but the problem is we cannot access the service from outside the cluster.
For that we need to expose it as a service.

Lets expose our deployment as a service:

```bash
vagrant@ubuntu:~$ kubectl expose deployment django-app --type=LoadBalancer --port=8000 --target-port=8000
service/django-app exposed
```

This will create a service with type `LoadBalancer` which will expose it to port
8000 and will forward the traffic to port 8000 of the container.

Lets check the kubernetes services:


```bash
vagrant@vagrant:~$ kubectl get svc
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
django-service   LoadBalancer   10.96.200.235   <pending>     80:32226/TCP   15s
kubernetes       ClusterIP      10.96.0.1       <none>        443/TCP        12m
```

As you can see the LoadBalancer is still pending. This is because we don't have
a LoadBalancer in our cluster. Lets do that.


### 5.1 Install and configure LoadBalancer

We will install `metallb` to provide us with a LoadBalancer for our cluster.

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

...
configmap/metallb-excludel2 created
secret/webhook-server-cert created
service/webhook-service created
deployment.apps/controller created
daemonset.apps/speaker created
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created
```

Find Docker subnet

```bash
docker network inspect -f '{{.IPAM.Config}}' kind
```

Lets overview the metallb config file where we configure IP address pool and our
L2Advertisement. We need that to make our LoadBalancer work.

```bash
vagrant@ubuntu:~$ vim metallb-config.yaml
```

```bash
vagrant@ubuntu:~$ kubectl apply -f metallb-config.yaml
ipaddresspool.metallb.io/example created
l2advertisement.metallb.io/empty created
```

Lets check the services again and see what is going on:

```bash
vagrant@ubuntu:~$ kubectl get svc
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
django-app   LoadBalancer   10.96.51.251   172.18.255.200   8000:32275/TCP   110s
kubernetes   ClusterIP      10.96.0.1      <none>           443/TCP          17m

```

## Validate service is running

```bash
vagrant@ubuntu:~$ curl http://172.18.255.200:8000
<!DOCTYPE html>
<html>
<head>
    <title>Service Status Dashboard</title>
    <link href="https://fonts.googleapis.com/css?family=Roboto&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
...
```

Look at that it seems our service is working. Let check it from the GUI.

Now lets overview our 3 main steps:
- First we start our application from our computer
- After that we create a docker image and run a container and open the application
from the container
- Now we will check our application which is running inside Kubernetes cluster

Lets open our VM GUI browser and navigate to Kubernetes service LoadBalancer IP
http://172.18.255.200:8000 and see if our application is working.


## 2.0 Django service inside Kubernetes


## Chaos Engineering

Want to see something cool?

Lets convince our beloved half that we are actually working not just playing
games.

[KubeDoom](https://github.com/storax/kubedoom)
