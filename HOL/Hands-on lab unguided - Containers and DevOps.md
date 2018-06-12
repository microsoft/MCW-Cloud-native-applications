!["Microsoft Cloud Workshops"](images/HeaderPic.png)

**Containers and DevOps**

**Hands-on lab step-by-step**

**June 2018**

Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.
© 2018 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at https://www.microsoft.com/en-us/legal/intellectualproperty/Trademarks/Usage/General.aspx are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents**

<!-- TOC -->

- [Containers and DevOps hands-on lab step-by-step](#containers-and-devops-hands-on-lab-step-by-step)
    - [Abstract and learning objectives](#abstract-and-learning-objectives)
    - [Overview](#overview)
    - [Solution architecture](#solution-architecture)
    - [Requirements](#requirements)
    - [Exercise 1: Create and run a Docker application](#exercise-1-create-and-run-a-docker-application)
        - [Task 1: Test the application](#task-1-test-the-application)
        - [Task 2: Enable browsing to the web application](#task-2-enable-browsing-to-the-web-application)
        - [Task 3: Create a Dockerfile](#task-3-create-a-dockerfile)
        - [Task 4: Create Docker images](#task-4-create-docker-images)
        - [Task 5: Run a containerized application](#task-5-run-a-containerized-application)
        - [Task 6: Setup environment variables](#task-6-setup-environment-variables)
        - [Task 7: Push images to Azure Container Registry](#task-7-push-images-to-azure-container-registry)
    - [Exercise 2: Deploy the solution to Azure Kubernetes Service](#exercise-2-deploy-the-solution-to-azure-container-service)
        - [Task 1: Tunnel into the Azure Kubernetes Service cluster](#task-1-tunnel-into-the-azure-container-service-cluster)
        - [Task 2: Deploy a service using the Kubernetes management dashboard](#task-2-deploy-a-service-using-the-kubernetes-management-dashboard)
        - [Task 3: Deploy a service using kubectl](#task-3-deploy-a-service-using-kubernetes-rest-api)
        - [Task 4: Initialize database with a Kubernetes Job](#task-4-explore-service-instance-logs-and-resolve-an-issue)
        - [Task 5: Test the application in a browser](#task-5-test-the-application-in-a-browser)
    - [Exercise 3: Scale the application and test HA](#exercise-3-scale-the-application-and-test-ha)
        - [Task 1: Increase service instances from the Kubernetes dashboard](#task-1-increase-service-instances-from-the-kubernetes-dashboard)
        - [Task 2: Increase service instances beyond available resources](#task-2-increase-service-instances-beyond-available-resources)
        - [Task 3: Restart containers and test HA](#task-3-restart-containers-and-test-ha)
    - [Exercise 4: Setup load balancing and service discovery](#exercise-4-setup-load-balancing-and-service-discovery)
        - [Task 1: Scale a service without port constraints](#task-1-scale-a-service-without-port-constraints)
        - [Task 2: Update an external service to support dynamic discovery with a load balancer](#task-2-update-an-external-service-to-support-dynamic-discovery-with-a-load-balancer)
        - [Task 3: Adjust CPU constraints to improve scale](#task-3-adjust-cpu-constraints-to-improve-scale)
        - [Task 4: Perform a rolling update](#task-4-perform-a-rolling-update)
    - [After the hands-on lab](#after-the-hands-on-lab)

<!-- /TOC -->

# Containers and DevOps hands-on lab step-by-step

## Abstract and learning objectives

Build a PoC to deliver a multi-tenant web app hosting solution leveraging Azure Container Service (AKS), Docker containers, and Linux nodes.

Attendees will be better able to deploy Docker-based applications and scale them with Azure Kubernetes Service and Kubernetes orchestration. In addition,

- Create and run a Docker Application

- Deploy to the Azure Kubernetes Service

- Implement load balancing and service discovery

- Scale the application and test availability

- Use Kubernetes ingress for path based routing and TLS termination.

## Overview

Fabrikam Medical Conferences (FabMedical) provides conference website services tailored to the medical community. They are refactoring their application code, based on node.js, so that it can run as a Docker application, and want to implement a POC that will help them get familiar with the development process, lifecycle of deployment, and critical aspects of the hosting environment. They will be deploying their applications to Azure Kubernetes Service and want to learn how to deploy containers in a dynamically load-balanced manner, discover containers, and scale them on demand.

In this hands-on lab, you will assist with completing this POC with a subset of the application code base. You will create a build agent based on Linux, and an Azure Kubernetes Service cluster for running deployed applications. You will be helping them to complete the Docker setup for their application, test locally, push to an image repository, deploy to the cluster, and test load-balancing and scale.

**IMPORTANT: Most Azure resources require unique names. Throughout these steps you will see the word "SUFFIX" as part of resource names. You should replace this with your Microsoft email prefix to ensure the resource is uniquely named.**

## Solution architecture

Below is a diagram of the solution architecture you will build in this lab. Please study this carefully, so you understand the whole of the solution as you are working on the various components.

The solution will use Azure Kubernetes Service (AKS) which means that the container cluster topology is provisioned according to the number of requested nodes. The proposed containers deployed to the cluster are illustrated below, with MongoDB remaining as a managed service:

![The solution will use Azure Kubernetes Service (AKS). The proposed containers deployed to the cluster are illustrated in this diagram, with MongoDB remaining as a managed service.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image3.png)

Each tenant will have the following containers:

- **Conference Web site**: the SPA application that will use configuration settings to handle custom styles for the tenant

- **Admin Web site**: the SPA application that conference owners use to manage conference configuration details, manage attendee registrations, manage campaigns and communicate with attendees

- **Registration service**: the API that handles all registration activities creating new conference registrations with the appropriate package selections and associated cost

- **Email service**: the API that handles email notifications to conference attendees during registration, or when the conference owners choose to engage the attendees through their admin site

- **Config service**: the API that handles conference configuration settings such as dates, locations, pricing tables, early bird specials, countdowns and related

- **Content service**: the API that handles content for the conference such as speakers, sessions, workshops and sponsors

## Requirements

1. Microsoft Azure subscription must be pay-as-you-go or MSDN.

    a.  Trial subscriptions will *not* work.

    b.  You must have rights to create a service principal as discussed in Task 9: Create a Service Principal --- and this typically requires a subscription owner to log in. You may have to ask another subscription owner to login to the portal and execute that step ahead of time if you do not have the rights.

    c.  You must have enough cores available in your subscription to create the build agent and Azure Kubernetes Service cluster in Task 5: Create a build agent VM and Task 10: Create an Azure Kubernetes Service cluster. You'll need eight cores if following the exact instructions in the lab, more if you choose additional agents or larger VM sizes. If you execute the steps required before the lab, you will be able to see if you need to request more cores in your sub.

1. Local machine or a virtual machine configured with:

    - A browser, preferably Chrome for consistency with the lab implementation tests

    - Command prompt

        - On Windows, you will be using Bash on Ubuntu on Windows, hereon referred to as WSL.

        - On Mac, all instructions should be executed using bash in Terminal.

1. You will be asked to install other tools throughout the exercises.

**VERY IMPORTANT: You should be typing all of the commands as they appear in the guide, except where explicitly stated in this document. Do not try to copy and paste from Word to your command windows or other documents where you are instructed to enter information shown in this document. There can be issues with Copy and Paste from Word that result in errors, execution of instructions, or creation of file content.**


## Exercise 1: Create and run a Docker application

**Duration**: 40 minutes

In this exercise, you will take the starter files and run the node.js application as a Docker application. You will create a Dockerfile, build Docker images, and run containers to execute the application.

**NOTE: Complete these tasks from the WSL window with the build agent session.**

### Task 1: Test the application

The purpose of this task is to make sure you can run the application successfully before applying changes to run it as a Docker application.

1. On the build agent VM create a new Docker network named "fabmedical".

1. Run mongodb as a container, and be sure it accessible from services running on the same host.

1. Run the content init application by navigating to the conent-init directory and running these commands:

    ```bash
    npm install
    nodejs server.js
    ```
1. Run the API and web applications in that order, by navigating to their respective folders and running these commands:


    ```bash
    npm install
    nodejs server.js &
    ```

1. Test the results by curling these URLs and observing the JSON responses:

    API Application:

    ```bash
    curl http://localhost:3001/speakers
    ```

    Web Application:

    ```bash
    curl http://localhost:3000
    ```

### Task 2: Enable browsing to the web site

In this task, you will open a port range on the agent VM so that you can browse to the application for testing.

1. From the Azure portal, select the Network Security Group associated with the build agent VM. Create an inbound security rule to allow TCP calls over port range 3000-3010.

1. Find the IP address for the VM and browse to that IP address with port 3000.

1. You can browse to the website and see the speakers and session pages, you can reach the web application from a browser and have correctly opened the port on the agent VM.

1. Once you have seen the website running, you can stop the running node processes with this command:

    ```bash
    killall nodejs
    ```

### Task 3: Create a Dockerfile

In this task, you will create a new Dockerfile that will be used to run the API as a containerized application.

**NOTE: You will be working in a Linux VM without friendly editor tools. You must follow the steps very carefully to work with Vim for a few editing exercises if you are not already familiar with Vim.**

1. From the content-api folder, using Vim create a new file named Dockerfile.

1. Create a multi-stage Dockerfile based on the node:argon image for build stage(s) and node:alpine for the deployable artifact.

1. Include instructions to copy the source files for the application to the image and to run npm install.

1. Expose port 3001 and put the startup command npm

1. Verify the file contents, to ensure it saved as expected.

### Task 4: Create Docker images

In this task, you will create Docker images for the application -- one for the API and another for the web application. Each image will be created via Docker commands that rely on a Dockerfile.

1. From the content-api directory, build a Docker image using the Dockerfile you created.

1. From the content-web directory, build a Docker image with the existing Dockerfile in the folder.

1. Once both images are successfully built, you will see three images now exist when you run the Docker images command. One for API, one for web, and another for node.

### Task 5: Run a containerized application

The web application container will be calling endpoints exposed by the API application container. In this exercise, you will create a bridge network so that containers can communicate with one another, and then launch the images you created as containers in that network.

1. Start the API container with this command.

    ```bash
     docker run --name api --net fabmedical -p 3001:3001 content-api
    ```

1. Diagnose the failure with the api container and resolve by setting the MONGODB_CONNECTION environment variable within the container.

1. Start the API and web containers with these commands:

    ```bash
    docker run --name web --net fabmedical -P -d content-web
    ```

1. Test the API application by curling the speakers URL once again.

1. Test the web application by curling the site but using the dynamic port assigned to the container from the run command.

### Task 6: Setup environment variables

In this task, you will configure the web container to communicate with the API container using an environment variable. You will modify the web application to read the URL from the environment variable, rebuild the Docker image, and then run the container again to test connectivity.

1. From WSL, stop and remove the web container.

1. Edit content-web\\data-access\\index.js and locate the TODO item and modify the code so that the contentApiUrl variable will be set to an environment variable.

1. Edit the Dockerfile in content-web to add an environment variable CONTENT_API_URL matching http://localhost:3001.

1. Rebuild the web Docker image.

1. Create and start the image passing the correct URI to the API container as an environment variable, then check the port that the container is running on.

    ```bash
    docker run --d --P --name web --net fabmedical --e CONTENT_API_URL=http://api:3001 content-web
    ```
1. Curl the speakers path again, using the port assigned to the web container.

1. Stop and restart the container so that it uses port 3000 and then browse to the URL at the build agent IP address with that port to view the web application.

1. Stop and remove all the running docker containers, including the mongo container.

1. Create a docker-compose yaml file that will run all containers together.  Make sure all dependencies are considered so that the containers start in the correct order.

1. Update the docker-compose solution to initialize and persist mongodb data.

1. Check the results in the browser, the speaker and session data is now available.

### Task 7: Push images to Azure Container Registry

To run containers in a remote environment, you will typically push images to a Docker registry, where you can store and distribute images. Each service will have a repository that can be pushed to and pulled from with Docker commands. Azure Container Registry (ACR) is a managed private Docker registry service based on Docker Registry v2.

In this task, you will push images to your ACR account, version images with tagging, and run containers from an image in your ACR.

1. Gather credentials for your ACR in the Azure Portal.

1. Login to your ACR from the build agent VM.

Tip: Make sure to specify the fully qualified registry login server (all lowercase).

1. Tag your images to match your ACR account name.

    ```bash
    docker tag content-web [LOGINSERVER]/content-web

    docker tag content-api [LOGINSERVER]/content-api
    ```
1. Push the API and web images to the ACR.

. Assign a new tag "v1" to both images and push the newly tagged version of the images to the ACR.

1. Verify the tagged images are created in the ACR.

1. From your build agent VM, perform a pull on each image to validate pulls are working from the VM.

1. Next setup VSTS to automate the process for creating images and pushing to ACR.  Add an Azure Service Principal to your VSTS account. Create docker container builds for all repositories which push images to your ACR instance.  Enable Continuous Integration for all repositories.

## Exercise 2: Deploy the solution to Azure Container Service

**Duration**: 30 minutes

In this exercise, you will connect to the Azure Container Service cluster you created before the hands-on lab, and deploy the Docker application to the cluster using Kubernetes.

### Task 1: Tunnel into the Azure Container Service cluster

In this task, you will gather the information you need about your Azure Container Service cluster to connect to the cluster and execute commands to connect to the Kubernetes management dashboard from your local machine.

1. Verify that Azure CLI is working correctly and that you are logged in and connected to the correct default subscription.

1. Verify that Kubernetes CLI is working correctly.

1. Configure kubectl to connect to the Kubernetes cluster.

    ```bash
    az aks get-credentials --name fabmedical-SUFFIX --resource-group fabmedical-SUFFIX-2
    ```

1. List the cluster nodes to verify the connection is working.

1. Create an SSH tunnel linking a local port (8001) on your machine to port 80 on the management node of the cluster. Execute the command below replacing the values accordingly:

    **NOTE: After you run this command, it may work at first and later lose its connection, so you may have to run this again to reestablish the connection. If the Kubernetes dashboard becomes unresponsive in the browser this is an indication to return here and check your tunnel or rerun the command.**

    ```bash
    az aks browse --name fabmedical-SUFFIX --resource-group fabmedical-SUFFIX-2
    ```

1. Open a browser and navigate to the Kubernetes management dashboard.

### Task 2: Deploy a service using the Kubernetes management dashboard

In this task, you will deploy the API application to the Azure Container Service cluster using the Kubernetes dashboard.

1. From the Kubernetes dashboard create a new deployment for the API application, based on the API image you pushed to your ACR. Use the following settings:

    - Set Number of pods to 1

    - Set Service to "Internal"

    - Use 3001 for Port and 3001 for Target port

    - Use 0.125 for the CPU requirement

    - Use 128 for the Memory requirement

1. When Kubernetes indicates a problem with the deployment, investigate using the pod logs.

1. Deploy a CosmosDb instance to provide a mongodb data store for the api.  Configure the API deployment to access the CosmosDb connection string using a Kubernetes secret.

1. iew the api deployment, it now has a healthy instance and the logs indicate it has connected to mongodb.

### Task 3: Deploy a service using kubectl

In this task, deploy the web service using `kubectl`.

1. Create a text file called web.deployment.yml using Vim and copy and paste the following text into the editor.

    ```yaml
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      labels:
          app: web
      name: web
    spec:
      replicas: 1
      selector:
          matchLabels:
            app: web
      strategy:
          rollingUpdate:
            maxSurge: 1
            maxUnavailable: 1
          type: RollingUpdate
      template:
          metadata:
            labels:
                app: web
            name: web
          spec:
            containers:
            - image: [LOGINSERVER].azurecr.io/content-web
              env:
                - name: CONTENT_API_URL
                  value: http://api:3001
              livenessProbe:
                httpGet:
                    path: /
                    port: 3000
                initialDelaySeconds: 30
                periodSeconds: 20
                timeoutSeconds: 10
                failureThreshold: 3
              imagePullPolicy: Always
              name: web
              ports:
                - containerPort: 3000
                  hostPort: 80
                  protocol: TCP
              resources:
                requests:
                    cpu: 1000m
                    memory: 128Mi
              securityContext:
                privileged: false
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
            dnsPolicy: ClusterFirst
            restartPolicy: Always
            schedulerName: default-scheduler
            securityContext: {}
            terminationGracePeriodSeconds: 30
    ```

1. Edit this file and update the [LOGINSERVER] entry to match the name of your ACR login server.

1. Create a text file called web.service.yml using Vim and copy and paste the following text into the editor.

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      labels:
          app: web
      name: web
    spec:
      ports:
        - name: web-traffic
          port: 80
          protocol: TCP
          targetPort: 3000
      selector:
          app: web
      sessionAffinity: None
      type: LoadBalancer
    ```

1. Type the following command to deploy the application described by the YAML files.

    ```bash
    kubectl create --save-config=true -f web.deployment.yml -f web.service.yml
    ```

1. Test the website in the browser and see that no data is available on the speakers and sessions pages.

### Task 4: Initialize database with a Kubernetes Job

In this task, you will use a Kubernetes Job to run a container that is meant to execute a task and terminate, rather than run all the time.

1. Create a text file called web.service.yml using Vim and copy and paste the following text into the editor.

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: init
    spec:
      template:
        spec:
          containers:
          - name: init
            image: [LOGINSERVER]/content-init
            env:
              - name: MONGODB_CONNECTION
                valueFrom:
                  secretKeyRef:
                    name: mongodb
                    key: db
          restartPolicy: Never
      backoffLimit: 4
    ```

1. Edit this file and update the [LOGINSERVER] entry to match the name of your ACR login server.

1. Type the following command to deploy the job described by the YAML.

    ```bash
    kubectl create --save-config=true -f init.job.yml
    ```

### Task 5: Test the application in a browser

In this task, you will verify that you can browse to the "web" service you have deployed, and view the speaker and content information exposed by the API service.

1. From the Kubernetes management dashboard, navigate to services, find the endpoint for the web service and launch the application in the browser.

1. You will see the web application in your browser and be able to select the Speakers and Sessions links to view those pages without errors. The lack of errors means that the web service is correctly calling the API service to show the details on each of those pages.

## Exercise 3: Scale the application and test HA

**Duration**: 20 minutes

At this point, you have deployed a single instance of the web and API service containers. In this exercise, you will increase the number of container instances for the API service and scale the front end on the existing cluster.

### Task 1: Increase service instances from the Kubernetes dashboard

In this task, you will increase the number of instances for the API deployment in the Kubernetes management dashboard. While it is deploying, you will observe the changing status.

1. From the Kubernetes dashboard, scale the number of pods for the API deployment to 2.

1. Go to the Replica Sets view of the API and note that there is a pending instance deploying.

1. Go to the Services view and note that the API is pending.

1. Go to the Workloads view and by this time note that the API and web services are healthy.

1. Navigate to the web application in the browser to view the content at /stats.html and take note of the following details as you refresh the page:

    - webTaskId: the task identifier for the web service instance

    - taskId: the task identifier for the API service instance

    - hostName: the host name identifier for the API service instance

    - pid: the process id for the API service instance

    - mem: some memory indicators returned from the API service instance

    - counters: counters for the service itself, as returned by the API service instance

    - uptime: the up time for the API service

1. The taskId and hostName for the API service will change as you refresh since there are two pods.

### Task 2: Increase service instances beyond available resources

In this task, you will try to increase the number of instances for the API service container beyond available resources in the cluster. You will observe how Kubernetes handles this condition and correct the problem.

1. From the navigation menu, select Deployments. From this view, select the API deployment. Configure the deployment to use a fixed host port (3001) for initial testing. Add the following JSON snippet below the "name" property in the container spec.

    ```json
    "ports": [
        {
        "containerPort": 3001,
        "hostPort": 3001
        }
    ],
    ```

1. API deployment and scale the API deployment to four pods.

1. From the API deployments view note that four pods are running and one pending.

1. Navigate to the Workloads view and note that there are errors in the API deployment. These errors are due to the fixed port requirement. Only two instances of the API pod can be deployed as there are only two nodes with port 3001 available.

1. Scale the API deployment back down to 2 pods and note that the errors are almost immediately resolved.

### Task 3: Restart containers and test HA

In this task, you will restart containers and validate that the restart does not impact the running service. First, you will restart the API service, followed by the web service. You will also note that there are issues with HA restarts when there is only a single instance.

1. Navigate to the Services view and select the external endpoint for the web service. Add /stats.html to the URL to browse to the stats page of the web application.

1. Navigate to the API deployment and scale it to 4 pods.

1. Navigate to the API Replica Set view and note that two pods cannot deploy.

1. Return to the browser tab with the web application stats page loaded. Refresh the page over and over. You will not see any errors, but you will see the API hostName change between the two API pod instances periodically.

1. Return to the API Replica Set view and note that as you refresh the page, the hostName from the stats page switches between the pod names for the API pods that are running.

1. Note the remaining pods are still pending, since there are not enough port resources available to launch another instance. Make some room by deleting a running pod instance.

1. Note that a new pod instance is deployed and, since the desired state is four pods, another pending instance is created.

1. Scale the API deployment down to 1 pod. As it scales down, return to the web application stats page and refresh, noting that only one API hostName and taskId displays. Kubernetes has already stopped sending requests to the pods that are scaling down.

1. Navigate to the Workloads view and note that eventually there is only one API pod deployed.

## Exercise 4: Setup load balancing and service discovery

**Duration**: 45 minutes

In the previous exercise we introduced a restriction to the scale properties of the service. In this exercise, you will configure the api deployments to create pods that use dynamic port mappings to eliminate the port resource constraint during scale activities.

Kubernetes services can discover the ports assigned to each pod, allowing you to run multiple instances of the pod on the same agent node --- something that is not possible when you configure a specific static port (such as 3001 for the API service).

### Task 1: Scale a service without port constraints

In this task, we will reconfigure the deployment's container template so that it will produce pods that choose a dynamic host port.

1. Edit the API deployment. Set replicas to 4 and remove the hostPort entry.

1. This time the deployment will be able to run 4 pods since the hostPort restriction has been removed.

1. Refresh the stats endpoint for the API service deployment in the browser and note that the hostPort entry will start to change as you refresh, to match the names of the 4 pods.

### Task 2: Update an external service to support dynamic discovery with a load balancer

In this task, you will update the web service so that it supports dynamic discovery through the Azure load balancer.

1. Edit the web deployment. Remove the *hostPort* setting to allow a dynamic port assignment as pods are created.

1. Scale the web deployment to 4 pods.

1. Refresh the web Deployments view and note the error indicating that the deployment cannot scale beyond 2 pod instances. This is due to a CPU constraint since the web service is asking for more CPU than is available. The port constraint has already been resolved by allowing dynamic discovery.

### Task 3: Adjust CPU constraints to improve scale

In this task you will modify the CPU requirements for the web service so that it can scale out to more instances.

1. Edit the web deployment. Set the *cpu* resource requirement to 125m.

1. Navigate to the web replica set and note that the four pods will show as deployed and running health.

1. Return to the browser tab with the web application loaded and refresh the stats page at /stats.html to watch the display update to reflect the different API pod names for the hostName.

### Task 4: Perform a rolling update

In this task, you will edit the web application source code to add Application Insights and update the Docker image used by the deployment. Then you will perform a rolling update to demonstrate how to deploy a code change.

1. Create an Application Insights key for content-web and content-api using the Azure Portal.

1. On your build agent VM, navigate to the content-web directory.

1. Install support for Application Insights

    ```bash
    npm install applicationinsights --save
    ```

1. Open the server.js file using Vim and add support for application insights with code similar to this:

    ```javascript
    const appInsights = require("applicationinsights");
    appInsights.setup(config.appInsightKey);
    appInsights.start();
    ```

1. Repeat the process to add support to content-api.

1. Push the changes to your repository so that VSTS CI will build a new image

1. Visit your ACR to see the new images and make a note of the tags assigned by VSTS.

1. From WSL on your local machine, request a rolling update using this kubectl command:

    ```bash
    kubectl set image deployment/web web=[LOGINSERVER]/content-web:[LATEST TAG]
    ```

1. Next update the content-api application

    ```bash
    kubectl set image deployment/api api=[LOGINSERVER]/content-api:[LATEST TAG]
    ```

1. While the deployment is in progress, you can navigate to the web application and visit the stats page at /stats.html. Refresh the page as the rolling update executes. Observe that the service is running normally and tasks continue to be load balanced..

### Task 5 Configure Kubernetes Ingress

In this task you will setup a Kubernetes Ingress to take advantage of path based routing and TLS termination.

1. Install helm, a package manager for Kubernetes.  Initialize your local configuration and install Tiller on your cluster.  Update your chart repository list.

1. Install the nginx-ingress controller resource, to handle ingress requests when they come in.

1. Set a DNS prefix on the IP address allocated to the ingress controller.

1. Use helm to install `cert-manager` a tool that can provision SSL certificates automatically from letsencrypt.org.

1. Cert manager will need a custom ClusterIssuer resource to handle requesting SSL certificates.

    ```yaml
    apiVersion: certmanager.k8s.io/v1alpha1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
    spec:
      acme:
        # The ACME server URL
        server: https://acme-v02.api.letsencryptorg/diretory
        # Email address used for ACME registration
        email: user@example.com
        # Name of a secret used to store theACMEaccount private key
        privateKeySecretRef:
          name: letsencrypt-prod
        # Enable HTTP01 validations
        http01: {}
    ```

1. Update the cert-manager to use the ClusterIssuer by default.

    ```bash
    helm upgrade cert-manager stable/cert-manager --namespace kube-system --set rbac.create=false --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer
    ```

1. Now you can create an ingress resource for the content applications.

    ```yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: content-ingress
      annotations:
        kubernetes.io/tls-acme: "true"
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      tls:
      - hosts:
        - fabmedical-[SUFFIX]-ingress.eastus.cloudapp.azure.com
        secretName: tls-secret
      rules:
      - host:   fabmedical-[SUFFIX]-ingress.eastus.cloudapp.azure.com
        http:
          paths:
          - path: /
            backend:
              serviceName: web
              servicePort: 80
          - path: /content-api
            backend:
              serviceName: api
              servicePort: 3001

    ```

1. Visit the ingress endpoint in your browser.  You should be able to visit the speakers and sessions pages and see all the content.

1. Visit the api directly, by navigating to `/content-api/sessions` at the ingress endpoint.

1. Test TLS termination by visiting both services again using `https`

    > It can take a few minutes before the SSL site becomes avaiable.  This is due to the delay involved with provisioning a TLS cert from letsencypt.

## After the hands-on lab

**Duration**: 10 mins

In this exercise, you will de-provision any Azure resources created in support of this lab.

1. Delete both of the Resource Groups in which you placed all of your Azure resources.

    - From the Portal, navigate to the blade of your Resource Group and select Delete in the command bar at the top.

    - Confirm the deletion by re-typing the resource group name and selecting Delete.

1. Delete the Service Principal created on Task 9: Create a Service Principal before the hands-on lab.

    ```bash
    az ad sp delete --id "Fabmedical-sp"
    ```