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

-   **Conference Web site**: the SPA application that will use configuration settings to handle custom styles for the tenant

-   **Admin Web site**: the SPA application that conference owners use to manage conference configuration details, manage attendee registrations, manage campaigns and communicate with attendees

-   **Registration service**: the API that handles all registration activities creating new conference registrations with the appropriate package selections and associated cost

-   **Email service**: the API that handles email notifications to conference attendees during registration, or when the conference owners choose to engage the attendees through their admin site

-   **Config service**: the API that handles conference configuration settings such as dates, locations, pricing tables, early bird specials, countdowns and related

-   **Content service**: the API that handles content for the conference such as speakers, sessions, workshops and sponsors

## Requirements

1.  Microsoft Azure subscription must be pay-as-you-go or MSDN.

    a.  Trial subscriptions will *not* work.

    b.  You must have rights to create a service principal as discussed in Task 9: Create a Service Principal --- and this typically requires a subscription owner to log in. You may have to ask another subscription owner to login to the portal and execute that step ahead of time if you do not have the rights.

    c.  You must have enough cores available in your subscription to create the build agent and Azure Kubernetes Service cluster in Task 5: Create a build agent VM and Task 10: Create an Azure Kubernetes Service cluster. You'll need eight cores if following the exact instructions in the lab, more if you choose additional agents or larger VM sizes. If you execute the steps required before the lab, you will be able to see if you need to request more cores in your sub.

2.  Local machine or a virtual machine configured with:

    -   A browser, preferably Chrome for consistency with the lab implementation tests

    -   Command prompt

        -   On Windows, you will be using Bash on Ubuntu on Windows, hereon referred to as WSL.

        -   On Mac, all instructions should be executed using bash in Terminal.

3.  You will be asked to install other tools throughout the exercises.

**VERY IMPORTANT: You should be typing all of the commands as they appear in the guide, except where explicitly stated in this document. Do not try to copy and paste from Word to your command windows or other documents where you are instructed to enter information shown in this document. There can be issues with Copy and Paste from Word that result in errors, execution of instructions, or creation of file content.**


## Exercise 1: Create and run a Docker application

**Duration**: 40 minutes

In this exercise, you will take the starter files and run the node.js application as a Docker application. You will create a Dockerfile, build Docker images, and run containers to execute the application.

**NOTE: Complete these tasks from the WSL window with the build agent session.**

### Task 1: Test the application

The purpose of this task is to make sure you can run the application successfully before applying changes to run it as a Docker application.

1. From the WSL window, connect to your build agent if you are not already connected.

1. Type the following command to create a Docker network named "fabmedical".

    ```bash
    docker network create fabmedical
    ```

1. Run an instance of mongodb to use for local testing.

    ```bash
    docker run --name mongo --net fabmedical -p 27017:27017 -d mongo
    ```

1. Confirm that the mongo container is running and ready.

    ```bash
    docker container list
    docker logs mongo
    ```

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task1.4.png)

1. Connect to the mongo instance using the mongo shell and test some basic commands.

    ```bash
    mongo
    ```

    ```text
    show dbs
    quit()
    ```

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task1.5.png)

1. To initialize the local database with test content, first navigate to the content-init directory and run npm install.

    ```bash
    cd content-init
    npm install
    ```

1. Initialize the database.

    ```bash
    nodejs server.js
    ```

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task1.7.png)

1. Confirm that the database now contains test data.

    ```bash
    mongo
    ```

    ```text
    show dbs
    use contentdb
    show collections
    db.speakers.find()
    db.sessions.find()
    quit()
    ```

    This should produce output similar to the following:

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task1.8.png)

1. Now, navigate to the content-api directory and run npm install.

    ```bash
    cd ../content-api
    npm install
    ```

1. Start the API as a background process.

    ```bash
    nodejs ./server.js &
    ```

    ![In this screenshot, nodejs ./server.js & has been typed and run at the command prompt, which starts the API as a background process.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image47.png)

1. Press ENTER again to get to a command prompt for the next step.

1. Test the API using curl. You will request the speakers content, and this will return a JSON result.

    ```bash
    curl http://localhost:3001/speakers
    ```

1. Navigate to the web application directory, run npm install and bower install, and then run the application as a background process as well. Ignore any warnings you see in the output; this will not affect running the application.

    ```bash
    cd ../content-web
    npm install
    bower install
    nodejs ./server.js &
    ```

    ![In this screenshot, after navigating to the web application directory, nodejs ./server.js & has been typed and run at the command prompt, which runs the application as a background process as well.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image48.png)

1. Press ENTER again to get a command prompt for the next step.

1. Test the web application using curl. You will see HTML output returned, without errors.

    ```bash
    curl http://localhost:3000
    ```

1. Leave the application running for the next task.

1. If you received a JSON response to the /speakers content request and an HTML response from the web application, your environment is working as expected.

### Task 2: Enable browsing to the web application

In this task, you will open a port range on the agent VM so that you can browse to the web application for testing.

1. From the Azure portal select the resource group you created named fabmedical-SUFFIX.

1. Select the Network Security Group associated with the build agent from your list of available resources.

    ![In this screenshot of your list of available resources, the sixth item is selected: fabmedical-(suffix obscured)-nsg (Network security group).](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image49.png)

1. From the Network interface essentials blade, select **Inbound security rules**.

    ![In the Network interface essentials blade, Inbound security rules is highlighted under Settings.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image50.png)

1. Select **Add** to add a new rule.

    ![In this screenshot of the Inbound security rules windows, a red arrow points at Add.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image51.png)

1. From the Add inbound security rule blade, enter the values as shown in the screenshot below:

    - **Source**: Any

    - **Source port ranges**:

    - **Destination**: Any

    - **Destination Port Ranges**: 3000-3010

    - **Protocol**: Any

    - **Action**: Allow

    - **Priority**: Leave at the default priority setting

    - **Name**: Enter "allow-app-endpoints"

        ![In the Add inbound security rule blade, the values listed above appear in the corresponding boxes.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image52.png)

1. Select **OK** to save the new rule.

    ![In this screenshot, a table has the following columns: Priority, Name, Port, Protocol, Source, Destination, and Action. The first row is highlighted with the following values: 100, allow-app-endpoints, 3000-3010, Any, Any, Any, and Allow (which has a green check mark next to it).](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image53.png)

1. From the resource list shown in step 2, select the build agent VM named fabmedical-SUFFIX.

    ![In this screenshot of your list of available resources, the first item is selected, which has the following values for Name, Type, and Location: fabmedical-soll (a red arrows points to this name), Virtual machine, and East US 2.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image54.png)

1. From the Virtual Machine blade overview, find the IP address of the VM.

    ![In the Virtual Machine blade, Overview is selected on the left and Public IP address 52.174.141.11 is highlighted on the right.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image26.png)

1. Test the web application from a browser. Navigate to the web application using your build agent IP address at port 3000.

    ```text
    http://[BUILDAGENTIP]:3000

    EXAMPLE: http://13.68.113.176:3000
    ```

1. Select the Speakers and Sessions links in the header. You will see the pages display the HTML version of the JSON content you curled previously.

1. Once you have verified the application is accessible through a browser, go to your WSL window and stop the running node processes.

    ```bash
    killall nodejs
    ```

### Task 3: Create a Dockerfile

In this task, you will create a new Dockerfile that will be used to run the API application as a containerized application.

**NOTE: You will be working in a Linux VM without friendly editor tools. You must follow the steps very carefully to work with Vim for a few editing exercises if you are not already familiar with Vim.**

1. From WSL, navigate to the content-api folder. List the files in the folder with this command. The output should look like the screenshot below.

    ```bash
    cd ../content-api
    ll
    ```

    ![In this screenshot of the WSL window, ll has been typed and run at the command prompt. The files in the folder are listed in the window. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image55.png)

1. Create a new file named "Dockerfile" and note the casing in the name. Use the following Vim command to create a new file. The WSL window should look as shown in the following screenshot.

    ```bash
    vi Dockerfile
    ```

    ![This is a screenshot of a new file named Dockerfile in the WSL window.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image56.png)

1. Select "i" on your keyboard. You'll see the bottom of the window showing INSERT mode.

    ![\-- INSERT -- appears at the bottom of the Dockerfile window.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image57.png)

1. Type the following into the file. These statements produce a Dockerfile that describes the following:

    - The base stage includes environment setup which we expect to change very rarely, if at all.

        - Creates a new Docker image from the base image node:alpine. This base image has node.js on it and is optimized fro small size.

        - Add `curl` to the base image to support Docker health checks.

        - Creates a directory on the image where the application files can be copied.

        - Exposes application port 3001 to the container environment so that the application can be reached at port 3001.

    - The build stage contains all the tools and intermediate files needed to create the application.

        - Creates a new Docker image from node:argon

        - Creates a directory on the image where the application files can be copied.

        - Copies package.json to the working directory.

        - Runs npm install to initialize the node application environment.

        - Copies the source files for the application over to the image.

    - The final stage combines the base image with the build output from the build stage

        - Sets the working directory to the application file location.

        - Copies the app files from the build stage

        - Indicates the command to start the node application when the container is run.

    **NOTE: Type the following into the editor, as you may have errors with copying and pasting.**

    ```Dockerfile
    FROM node:alpine AS base
    RUN apk -U add curl
    WORKDIR /usr/src/app
    EXPOSE 3001

    FROM node:argon AS build
    WORKDIR /usr/src/app

    # Install app dependencies
    COPY package.json /usr/src/app/
    RUN npm install

    # Bundle app source
    COPY . /usr/src/app

    FROM base AS final
    WORKDIR /usr/src/app
    COPY --from=build /usr/src/app .
    CMD [ "npm", "start" ]
    ```

1. When you are finished typing, hit the Esc key and type ":wq" and hit the Enter key to save the changes and close the file.

    ```bash
    <Esc>
    :wq
    <Enter>
    ```

1. List the contents of the folder again, to verify the new Dockerfile has been created.

    ```bash
    ll
    ```

    ![In this screenshot of the WSL window, ll has been typed and run at the command prompt. The Dockerfile file is highlighted at the top of list.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image58.png)

1. Verify the file contents, to ensure it was saved as expected. Type the following command to see the output of the Dockerfile in the command window.

    ```bash
    cat Dockerfile
    ```

### Task 4: Create Docker images

In this task, you will create Docker images for the application --- one for the API application and another for the web application. Each image will be created via Docker commands that rely on a Dockerfile.

1. From WSL, type the following command to view any Docker images on the VM. The list will only contain the mongodb image downloaded earlier.

    ```bash
    docker images
    ```

1. From the content-api folder containing the API application files and the new Dockerfile you created, type the following command to create a Docker image for the API application. This command does the following:

    - Executes the Docker build command to produce the image.

    - Tags the resulting image with the name content-api (-t).

    - The final dot (".") indicates to use the Dockerfile in this current directory context. By default, this file is expected to have the name "Dockerfile" (case sensitive).

    ```bash
    docker build -t content-api .
    ```

1. Once the image is successfully built, run the Docker images command again. You will see several new images: the node images and your container image.

    ```bash
    docker images
    ```

    Notice the untagged image.  This is the build stage which contains all the intermediate files not need in your final image.

    ![The node image (node) and your container image (content-api) are visible in this screenshot of the WSL window.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image59.png)

1. Navigate to the content-web folder again and list the files. Note that this folder already has a Dockerfile.

    ```bash
    cd ../content-web
    ll
    ```

1. View the Dockerfile contents -- which are similar to the file you created previously in the API folder. Type the following command:

    ```bash
    cat Dockerfile
    ```

    Notice that the content-web Dockerfile build stage includes additional tools to install bower packages in addition to the npm packages.

1. Type the following command to create a Docker image for the web application.

    ```bash
    docker build -t content-web .
    ```

1. When complete, you will see seven images now exist when you run the Docker images command.

    ```bash
    docker images
    ```

    ![Three images are now visible in this screenshot of the WSL window: content-web, content-api, and node.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image60.png)

### Task 5: Run a containerized application

The web application container will be calling endpoints exposed by the API application container and the API application container will be communicating with mongodb. In this exercise, you will launch the images you created as containers on same bridge network you created when starting mongodb.

1. Create and start the API application container with the following command. The command does the following:

    - Names the container "api" for later reference with Docker commands.

    - Instructs the Docker engine to use the "fabmedical" network.

    - Instructs the Docker engine to use port 3001 and map that to the internal container port 3001.

    - Creates a container from the specified image, by its tag, such as content-api.

    ```bash
    docker run --name api --net fabmedical -p 3001:3001 content-api
    ```

1. The docker run command has failed because it is configured to connect to mongodb using a localhost url.  However, now that content-api is isolated in a separate container, it cannot access mongodb via localhost, even when running on the same docker host.  Instead, the API must use the bridge network to connect to mongodb.

    ```text
    > content-api@0.0.0 start /usr/src/app
    > node ./server.js

    Listening on port 3001
    Could not connect to MongoDB!
    MongoNetworkError: failed to connect to server [localhost:27017] on first connect [MongoNetworkError: connect ECONNREFUSED 127.0.0.1:27017]
    npm ERR! code ELIFECYCLE
    npm ERR! errno 255
    npm ERR! content-api@0.0.0 start: `node ./server.js`
    npm ERR! Exit status 255
    npm ERR!
    npm ERR! Failed at the content-api@0.0.0 start script.
    npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

    npm ERR! A complete log of this run can be found in:
    npm ERR!     /root/.npm/_logs/2018-06-08T13_36_52_985Z-debug.log
    ```

1. The content-api application allows an environment variable to configure the mongodb connection string.  Remove the existing container, then instruct the docker engine to set the environment variable by adding the `-e` switch to the docker run command.  Also, use the `-d` switch to run the api as a daemon.

    ```bash
    docker rm api
    docker run --name api --net fabmedical -p 3001:3001 -e MONGODB_CONNECTION=mongodb://mongo:27017/contentdb -d content-api
    ```

1. Enter the command to show running containers. You'll observe that the "api" container is in the list.  Use the docker logs command to see that the API application has connected to mongodb.

    ```bash
    docker container ls
    docker logs api
    ```

    ![In this screenshot of the WSL window, docker container ls has been typed and run at the command prompt, and the "api" container is in the list with the following values for Container ID, Image, Command, Created, Status, Ports, and Names: 548d25a1449f, content-api, "npm start", 8 seconds ago, Up 6 seconds, 0.0.0.0:3001-\>3001/tcp, and api.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image61.png)

1. Test the API by curling the URL. You will see JSON output as you did when testing previously.

    ```bash
    curl http://localhost:3001/speakers
    ```

1. Create and start the web application container with a similar Docker run command -- instruct the docker engine to use any port with the `-P` command:

    ```bash
    docker run --name web --net fabmedical -P -d content-web
    ```

1. Enter the command to show running containers again and you'll observe that both the API and web containers are in the list. The web container shows a dynamically assigned port mapping to its internal container port 3000.

    ```bash
    docker container ls
    ```

    ![In this screenshot of the WSL window, docker container ls has again been typed and run at the command prompt. 0.0.0.0:32768->3000/tcp is highlighted under Ports, and a red arrow is pointing at it.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image62.png)

1. Test the web application by curling the URL. For the port, use the dynamically assigned port, which you can find in the output from the previous command. You will see HTML output, as you did when testing previously.

    ```bash
    curl http://localhost:[PORT]/speakers.html
    ```

### Task 6: Setup environment variables

In this task, you will configure the "web" container to communicate with the API container using an environment variable, similar to the way the mongodb connection string is provided to the api. You will modify the web application to read the URL from the environment variable, rebuild the Docker image, and then run the container again to test connectivity.

1. From WSL, stop and remove the web container using the following commands.

    ```bash
    docker stop web
    docker rm web
    ```

1. Validate that the web container is no longer running or present by using the -a flag as shown in this command. You will see that the "web" container is no longer listed.

    ```bash
    docker container ls -a
    ```

1. Navigate to the `content-web/data-access` directory. From there, open the index.js file for editing using Vim and press the "i" key to go into edit mode.

    ```bash
    cd data-access
    vi index.js
    <i>
    ```

1. Locate the following TODO item and modify the code to comment the first line and uncomment the second. The result is that the contentApiUrl variable will be set to an environment variable.

    ```javascript
    //TODO: Exercise 2 - Task 6 - Step 4

    //const contentApiUrl = "http://localhost:3001";
    const contentApiUrl = process.env.CONTENT_API_URL;
    ```

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

1. Navigate to the content-web directory. From there open the Dockerfile for editing using Vim and press the "i" key to go into edit mode.

    ```bash
    cd ..
    vi Dockerfile
    <i>
    ```

1. Locate the EXPOSE line shown below and add a line above it that sets the default value for the environment variable as shown in the screenshot.

    ```Dockerfile
    ENV CONTENT_API_URL http://localhost:3001
    ```

    ![In this screenshot of Dockerfile, ENV CONTENT\_API\_URL http://localhost:3001 appears above Expose 3000.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image63.png)

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

1. Rebuild the web application Docker image using the same command as you did previously.

    ```bash
    docker build -t content-web .
    ```

1. Create and start the image passing the correct URI to the API container as an environment variable. This variable will address the API application using its container name over the Docker network you created. After running the container, check to see the container is running and note the dynamic port assignment for the next step.

    ```bash
    docker run --name web --net fabmedical -P -d -e CONTENT_API_URL=http://api:3001 content-web
    docker container ls
    ```

1. Curl the speakers path again, using the port assigned to the web container. Again you will see HTML returned, but because curl does not process javascript, you cannot determine if the web application is communicating with the api application.  You must verify this connection in a browser.

    ```bash
    curl http://localhost:[PORT]/speakers.html
    ```

1. You will not be able to browse to the web application on the ephemeral port because the VM only exposes a limited port range. Now you will stop the web container and restart it using port 3000 to test in the browser. Type the following commands to stop the container, remove it, and run it again using explicit settings for the port.

    ```bash
    docker stop web
    docker rm web
    docker run --name web --net fabmedical -p 3000:3000 -d -e CONTENT_API_URL=http://api:3001 content-web
    ```

1. Curl the speaker path again, using port 3000. You will see the same HTML returned.

    ```bash
    curl http://localhost:3000/speakers.html
    ```

1. You can now use a web browser to navigate to the website and successfully view the application at port 3000. Replace [BUILDAGENTIP] with the IP address you used previously.

    ```bash
    http://[BUILDAGENTIP]:3000

    EXAMPLE: http://13.68.113.176:3000
    ```

1. Managing several containers with all their command line options can become difficult as the solution grows.  `docker-compose` allows us to declare options for several containers and run them together.  First, cleanup the existing containers.

    ```bash
    docker stop web && docker rm web
    docker stop api && docker rm api
    docker stop mongo && docker rm mongo
    ```

1. Navigate to your home directory (where you checked out the content repositories) and create a docker compose file.

    ```bash
    cd ~
    vi docker-compose.yml
    ```

    Type the following as the contents of `docker-compose.yml`

    ```yaml
    version: '3.4'

    services:
      mongo:
        image: mongo
        restart: always

      api:
        build: ./content-api
        image: content-api
        depends_on:
          - mongo
        environment:
          MONGODB_CONNECTION: mongodb://mongo:27017/contentdb

      web:
        build: ./content-web
        image: content-web
        depends_on:
          - api
        environment:
          CONTENT_API_URL: http://api:3001
        ports:
          - "3000:3000"
    ```

1. Start the applications with the `up` command

    ```bash
    docker-compose -f docker-compose.yml -p fabmedical up -d
    ```

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task6.17.png)

1. Visit the website in the browser, notice that we no longer have any data on the speakers or sessions pages.

    ![Browser view](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task6.18.png)

1. We stopped and removed our previous mongodb container, all the data contained in it has been removed.  Docker compose has created a new, empty mongodb instance that must be reinitialized.  If we care to persist our data between container instances, docker has several mechanisms to do so.  First we will update our compose file to persist mongodb data to a directory on the build agent.

    ```bash
    mkdir data
    vi docker-compose.yml
    ```

    Update the mongo service to mount the local data directory onto to the `/data/db` volume in the docker container.

    ```yaml
    mongo:
      image: mongo
      restart: always
      volumes:
        - ./data:/data/db
    ```

    The result should look similar to the following screenshot.

    ![Dockerfile](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task6.19.png)

1. Next we will add a second file to our composition so tha we can initialize the mongodb data when needed.

    ```bash
    vi docker-compose.init.yml
    ```

    Add the following as the content.

    ```yaml
    version: '3.4'

    services:
        init:
          build: ./content-init
          image: content-init
          depends_on:
            - mongo
          environment:
            MONGODB_CONNECTION: mongodb://mongo:27017/contentdb
    ```

1. To reconfigure the mongodb volume, we need to bring down the mongodb service first.

    ```bash
    docker-compose -f docker-compose.yml -p fabmedical down
    ```

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task6.21.png)

1. Now run `up` again with both files to update the mongodb configuration and run the initialization script.

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.init.yml -p fabmedical up -d
    ```

1. Check the data folder to see that mongodb is now writing data files to the host.

    ```bash
    ls ./data/
    ```

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task6.23.png)

1. Check the results in the browser, the speaker and session data is now available.

    ![Console Output](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task6.24.png)

### Task 7: Push images to Azure Container Registry

To run containers in a remote environment, you will typically push images to a Docker registry, where you can store and distribute images. Each service will have a repository that can be pushed to and pulled from with Docker commands. Azure Container Registry (ACR) is a managed private Docker registry service based on Docker Registry v2.

In this task, you will push images to your ACR account, version images with tagging, and setup continuous integration (CI) to build future versions of your containers and push them to ACR automatically.

1. In the [Azure Portal](https://portal.azure.com/), navigate to the ACR you created in Before the hands-on lab.

1. Select Access keys under Settings on the left-hand menu.

    ![In this screenshot of the left-hand menu, Access keys is highlighted below Settings.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image64.png)

1. The Access keys blade displays the Login server, username, and password that will be required for the next step. Keep this handy as you perform actions on the build VM.

    **NOTE: If the username and password do not appear, select Enable on the Admin user option.**

1. From the WSL session connected to your build VM, login to your ACR account by typing the following command. Follow the instructions to complete the login.

    ```bash
    docker login [LOGINSERVER] -u [USERNAME] -p [PASSWORD]
    ```

    For example:

    ```bash
    docker login fabmedicalsoll.azurecr.io -u fabmedicalsoll -p +W/j=l+Fcze=n07SchxvGSlvsLRh/7ga
    ```

    ![In this screenshot of the WSL window, the following has been typed and run at the command prompt: docker login fabmedicalsoll.azurecr.io --u fabmedicalsoll --p +W/j=l+Fcze=n07SchxvGSlvsLRh/7ga](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image65.png)

    **Tip: Make sure to specify the fully qualified registry login server (all lowercase).**

1. Run the following commands to properly tag your images to match your ACR account name.

    ```bash
    docker tag content-web [LOGINSERVER]/content-web
    docker tag content-api [LOGINSERVER]/content-api
    ```

1. List your docker images and look at the repository and tag. Note that the repository is prefixed with your ACR login server name, such as the sample shown in the screenshot below.

    ```bash
    docker images
    ```

    ![This is a screenshot of a docker images list example. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image66.png)

1. Push the images to your ACR account with the following command.

    ```bash
    docker push [LOGINSERVER]/fabmedical/content-web
    docker push [LOGINSERVER]/fabmedical/content-api
    ```

    ![In this screenshot of the WSL window, an example of images being pushed to an ACR account results from typing and running the following at the command prompt: docker push \[LOGINSERVER\]/fabmedical/content-web. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image67.png)

1. In the Azure Portal, navigate to your ACR account, and select Repositories under Services on the left-hand menu. You will now see two, one for each image.

    ![In this screenshot, fabmedical/content-api and fabmedical/content-web each appear on their own lines below Repositories.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image68.png)

1. Select content-api. You'll see the latest tag is assigned.

    ![In this screenshot, fabmedical/content-api is selected under Repositories, and the Tags blade appears on the right.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image69.png)

1. From WSL, assign the v1 tag to each image with the following commands. Then, list the Docker images to note that there are now two entries for each image, showing the latest tag and the v1 tag. Also note that the image ID is the same for the two entries, as there is only one copy of the image.

    ```bash
    docker tag [LOGINSERVER]/content-web:latest [LOGINSERVER]/content-web:v1
    docker tag [LOGINSERVER]/content-api:latest [LOGINSERVER]/content-api:v1
    docker images
    ```

    ![In this screenshot of the WSL window is an example of tags being added and displayed. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image70.png)

1. Repeat Step 7 to push the images to ACR again, so that the newly tagged v1 images are pushed. Then, refresh one of the repositories to see the two versions of the image now appear.

    ![In this screenshot, fabmedical/content-api is selected under Repositories, and the Tags blade appears on the right. In the Tags blade, latest and v1 appear under Tags.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image71.png)

1. Run the following commands to pull an image from the repository. Note that the default behavior is to pull images tagged with "latest." You can pull a specific version using the version tag. Also, note that since the images already exist on the build agent, nothing is downloaded.

    ```bash
    docker pull [LOGINSERVER]/content-web
    docker pull [LOGINSERVER]/content-web:v1
    ```

    - **Azure subscription**: Choose "azurecloud-sol"

    - **Azure Container Registry**: Choose your ACR instance by name

    - **Include Latest Tag**: Checked

1. Next we will use VSTS to automate the process for creating images and pushing to ACR.  First, you need to add an Azure Service Principal to your VSTS account.  Login to your VisualStudio.com account and click the gear icon to access your settings. Then click Services.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.13.png)

1. Choose "+ New Service Endpoint".  Then pick "Azure Resource Manager" from the menu.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.14.png)


1. Click the link indicated in the screenshot below to access the advanced settings.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.15.png)


1. Enter the required information using the service principal information you created before the lab.

    > Note if you don't have your Subscription information handy you can view it using `az account show` on your **local** machine (not the build agent)

    - **Connection name**: azurecloud-sol

    - **Environment**: AzureCloud

    - **Subscription ID**: `id` from `az account show` output

    - **Subscription Name**: `name` from `az account show` output

    - **Service Principal Client ID**: `appId` from service principal output.

    - **Service Principal Key**: `password` from service principal output.

    - **Tenant ID**: `tenant` from service principal output.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.16.png)

1. Click "Verify connection" then click "OK".

    > If the connection does not verify, then recheck and reenter the required data.

1. Now create your first build.  Click "Build and Release", then click "+ New definition"

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.18.png)

1. Choose the content-web repository and accept the other defaults.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.19.png)

1. Next, search for "Docker" templates and choose "Container" then click "Apply'

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.20.png)

1. Change the build name to "content-web-Container-CI"

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.21.png)

1. Click "Build an image"

    - **Azure subscription**: Choose "azurecloud-sol"

    - **Azure Container Registry**: Choose your ACR instance by name

    - **Include Latest Tag**: Checked

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.22.png)

1. Click "Push an image"

    - **Azure subscription**: Choose "azurecloud-sol"

    - **Azure Container Registry**: Choose your ACR instance by name

    - **Include Latest Tag**: Checked

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.23.png)

1. Click "Triggers"

    - **Enable continuous integration**: Checked

    - **Batch changes while a build is in progress**: Checked

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.24.png)


1. Click "Save & queue", then click "Save & queue" two more times to kick off the first build.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.26.png)

1. While that build runs, create the content-api build.  Click "Builds", click "+ New".  Configure content-api by following the same steps used to configure content-web.

1. While the content-api build runs, setup one last build for content-init by following the same steps as the previous two builds.

1. Visit your ACR instance in the Azure portal, you should see new containers tagged with the VSTS build number.

    ![Image](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex1-Task7.28.png)

## Exercise 2: Deploy the solution to Azure Kubernetes Service

**Duration**: 30 minutes

In this exercise, you will connect to the Azure Kubernetes Service cluster you created before the hands-on lab and deploy the Docker application to the cluster using Kubernetes.

### Task 1: Tunnel into the Azure Kubernetes Service cluster

In this task, you will gather the information you need about your Azure Kubernetes Service cluster to connect to the cluster and execute commands to connect to the Kubernetes management dashboard from your local machine.

1. Open your WSL console (close the connection to the build agent if you are connected). From this WSL console, ensure that you installed the Azure CLI correctly by running the following command:

    ```bash
    az --version
    ```

    - This should produce output similar to this:

        ![In this screenshot of the WSL console, example output from running az --version appears. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image73.png)

    - If the output is not correct, review your steps from the instructions in Task 11: Install Azure CLI from the instructions before the lab exercises.

1. Also, check the installation of the Kubernetes CLI (kubectl) by running the following command:

    ```bash
    kubectl version
    ```

    - This should produce output similar to this:

        ![In this screenshot of the WSL console, kubectl version has been typed and run at the command prompt, which displays Kubernetes CLI client information.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image74.png)

    - If the output is not correct, review the steps from the instructions in Task 12: Install Kubernetes CLI from the instructions before the lab exercises.

1. Once you have installed and verified Azure CLI and Kubernetes CLI, login with the following command, following the instructions to complete your login as presented:

    ```bash
    az login
    ```

1. Verify that you are connected to the correct subscription with the following command to show your default subscription:

    ```bash
    az account show
    ```

    If you are not connected to the correct subscription, list your subscriptions and then set the subscription by its id with the following commands (similar to what you did in cloud shell before the lab):

    ```bash
    az account list
    az account set --subscription {id}
    ```

1. Configure kubectl to connect to the Kubernetes cluster.

    ```bash
    az aks get-credentials --name fabmedical-SUFFIX --resource-group fabmedical-SUFFIX
    ```

1. Test that the configuration is correct by running a simple kubectl command to produce a list of nodes:

    ```bash
    kubectl get nodes
    ```

    ![In this screenshot of the WSL console, kubectl get nodes has been typed and run at the command prompt, which produces a list of nodes.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image75.png)

1. Create an SSH tunnel linking a local port (8001) on your machine to port 80 on the management node of the cluster. Execute the command below replacing the values as follows:

    ***NOTE:* After you run this command, it may work at first and later lose its connection, so you may have to run this again to reestablish the connection. If the Kubernetes dashboard becomes unresponsive in the browser this is an indication to return here and check your tunnel or rerun the command.**

    ```bash
    az aks browse --name fabmedical-SUFFIX --resource-group fabmedical-SUFFIX
    ```

    ![In this screenshot of the WSL console, the output of the above command produces output similar to the following: Password for private key: Proxy running on 127.0.0.1:8001/ui Press CTRL+C to close the tunnel \... Starting to server on 127.0.0.1:8001](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image76.png)

1. Open a browser window and access the Kubernetes management dashboard at the Services view. To reach the dashboard, you must access the following address:

    ```bash
    http://localhost:8001
    ```

1. If the tunnel is successful, you will see the Kubernetes management dashboard. ![This is a screenshot of the Kubernetes management dashboard. Overview is highlighted on the left, and at right, kubernetes has a green check mark next to it. Below that, default-token-b9kf6 is listed under Secrets.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image77.png)

### Task 2: Deploy a service using the Kubernetes management dashboard

In this task, you will deploy the API application to the Azure Kubernetes Service cluster using the Kubernetes dashboard.

1. From the Kubernetes dashboard, select Create in the top right corner.

1. From the Resource creation view, select Create an App

    ![This is a screenshot of the Deploy a Containerized App dialog box. Specify app details below is selected, and the fields have been filled in with the information that follows. At the bottom of the dialog box is a SHOW ADVANCED OPTIONS link.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image78.png)

    - Enter "api" for the App name.

    - Enter [LOGINSERVER]/content-api for the Container Image, replacing [LOGINSERVER] with your ACR login server, such as fabmedicalsol.azurecr.io

    - Set Number of pods to 1.

    - Set Service to "Internal".

    - Use 3001 for Port and 3001 for Target port.

1. Select SHOW ADVANCED OPTIONS.

    - Enter 0.125 for the CPU requirement.

    - Enter 128 for the Memory requirement.

    ![In the Advanced options dialog box, the above information has been entered. At the bottom of the dialog box is a Deploy button.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image79.png)

1. Select Deploy to initiate the service deployment based on the image. This can take a few minutes. In the meantime, you will be redirected to the Overview dashboard. Select the API deployment from the Overview dashboard to see the deployment in progress.

    ![This is a screenshot of the Kubernetes management dashboard. Overview is highlighted on the left, and at right, a red arrow points to the api deployment.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image80.png)

1. Kubernetes indicates a problem with the api Replica Set.  Click the log icon to investigate.

    ![Dashboard](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.5.png)

1. The log indicates that the content-api application is once again failing because it cannot find a mongodb instance to communicate with.  You will resolve this issue by migrating your data workload to CosmosDb.

    ![Dashboard](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.6.png)

1. Open the Azure portal in your browser and click "+ Create a resource".  Search for "Database as a service for MongoDB", select the result and click "Create"

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.7.png)

1. Configure Azure CosmosDb as follows and click "Create":

    - **ID**: fabmedical-SUFFIX

    - **Subscription**: Use the same subscription you have used for all your other work.

    - **Resource Group**: fabmedical-SUFFIX

    - **Geo-redundancy**: default (checked)

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.8.png)

1. Navigate to your resource group and find your new CosmosDb resource.  Click on the CosmosDb resource to view details.

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.9.png)
1. Under "Quick Start" select the "Node.js" tab and copy the Node 3.0 connection string.

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.10.png)

1. Update the provided connection string with a database "contentdb" and a replica set "globaldb"

    > Note: User name and password redacted for brevity.

    ```text
    mongodb://<USERNAME>:<PASSWORD>@fabmedical-sol2.documents.azure.com:10255/contentdb?ssl=true&replicaSet=globaldb
    ```

1. You will setup a Kubernetes secret to store the connection string, and configure the content-api application to access the secret.  First, you must base64 encode the secret value.  Open your WSL window and use the following command to encode the connection string and copy to your clipboard all in one step.

    > If 'clip.exe' does not work, make sure your WSL window is not logged into the build agent over SSH.

    ```bash
    echo -n "<connection string value>" | base64 -w 0 - | clip.exe
    ```

1. Return to the Kubernetes UI in your browser and click "+ Create".  Update the following YAML with the encoded connection string from your clipboard, paste the YAML data into the create dialog and click "Upload".

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: mongodb
    type: Opaque
    data:
        db: <base64 encoded value>
    ```

    ![Kubernetes](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.13.png)

1. Scroll down in the Kubernetes dashboard until you can see "Secrets" in the left hand menu.  Click it.

    ![Kubernetes](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.14.png)

1. View the details for the "mongodb" secret.  Click the eyeball icon to show the secret.

    ![Kubernetes](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.15.png)

1. Next, download the api deployment configuration using the following command in your WSL window:

    ```bash
    kubectl get -o=yaml --export=true deployment api > api.deployment.yml
    ```

1. Edit the downloaded file:

    ```bash
    vi api.deployment.yml
    ```

    Add the following environment configuration to the container spec, below the "image" property:

    ```yaml
    - image: fabmedicalsol2.azurecr.io/fabmedical/content-api
      env:
        - name: MONGODB_CONNECTION
          valueFrom:
            secretKeyRef:
              name: mongodb
              key: db
    ```

    ![Kubernetes](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.17.png)

1. Update the api deployment by using `kubectl` to apply the new configuration.

    ```bash
    kubectl apply -f ./api.deployment.yml
    ```

1. Click "Deployments" then "api" to view the api deployment, it now has a healthy instance and the logs indicate it has connected to mongodb.

    ![Kubernetes](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task1.19.png)

### Task 3: Deploy a service using kubectl

In this task, deploy the web service using `kubectl`.

1. Open a **new** WSL console.

1. Create a text file called web.deployment.yml using Vim and press the "i" key to go into edit mode.

    ```bash
    vi web.deployment.yml
    <i>
    ```

1. Copy and paste the following text into the editor.

    **NOTE: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters.**

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

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

1. Create a text file called web.service.yml using Vim and press the "i" key to go into edit mode.

    ```bash
    vi web.service.yml
    ```

1. Copy and paste the following text into the editor.

    **NOTE: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters.**

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

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

1. Type the following command to deploy the application described by the YAML files. You will receive a message indicating the items kubectl has created a web deployment and a web service.

    ```bash
    kubectl create --save-config=true -f web.deployment.yml -f web.service.yml
    ```

    ![In this screenshot of the WSL console, kubectl apply -f kubernetes-web.yaml has been typed and run at the command prompt. Messages about web deployment and web service creation appear below.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image93.png)

1. Return to the browser where you have the Kubernetes management dashboard open. From the navigation menu, select Services view under Discovery and Load Balancing. From the Services view, select the web service and, from this view, you will see the web service deploying. This deployment can take a few minutes. When it completes you should be able to access the website via an external endpoint.

    ![In the Kubernetes management dashboard, Services is selected below Discovery and Load Balancing in the navigation menu. At right are three boxes that display various information about the web service deployment: Details, Pods, and Events. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image94.png)

1. Click the speakers and sessions links, and note that no data is displayed, although we have connected to our CosmosDb instance, there is no data loaded.  You will resolve this by running the content-init application as a Kubernetes Job.

    ![Browser](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task3.11.png)

### Task 4: Initialize database with a Kubernetes Job

In this task, you will use a Kubernetes Job to run a container that is meant to execute a task and terminate, rather than run all the time.

1. In your WSL window create a text file called web.service.yml using Vim and press the "i" key to go into edit mode.

    ```bash
    vi init.job.yml
    ```

1. Copy and paste the following text into the editor.

    **NOTE: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters.**

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

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

1. Type the following command to deploy the job described by the YAML. You will receive a message indicating the kubectl has created an init "job.batch".

    ```bash
    kubectl create --save-config=true -f init.job.yml
    ```

1. View the Job by clicking "Jobs" under "Workloads" in the Kubernetes UI

    ![Dashboard](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task4.6.png)

1. Click the log icon to view the logs.

    ![Dashboard](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task4.7.png)

1. Next view your CosmosDb instance in the Azure portal and see that it now contains two collections.

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex2-Task4.8.png)

### Task 5: Test the application in a browser

In this task, you will verify that you can browse to the web service you have deployed and view the speaker and content information exposed by the API service.

1. From the Kubernetes management dashboard, in the navigation menu, select the Services view under Discovery and Load Balancing.

1. In the list of services, locate the external endpoint for the web service and select this hyperlink to launch the application.

    ![In the Services box, a red arrow points at the hyperlinked external endpoint for the web service.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image112.png)

1. You will see the web application in your browser and be able to select the Speakers and Sessions links to view those pages without errors. The lack of errors means that the web application is correctly calling the API service to show the details on each of those pages.

    ![In this screenshot of the Contoso Neuro 2017 web application, Speakers has been selected, and sample speaker information appears at the bottom.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image114.png)

    ![In this screenshot of the Contoso Neuro 2017 web application, Sessions has been selected, and sample session information appears at the bottom.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image115.png)

## Exercise 3: Scale the application and test HA

**Duration**: 20 minutes

At this point you have deployed a single instance of the web and API service containers. In this exercise, you will increase the number of container instances for the web service and scale the front end on the existing cluster.

### Task 1: Increase service instances from the Kubernetes dashboard

In this task, you will increase the number of instances for the API deployment in the Kubernetes management dashboard. While it is deploying, you will observe the changing status.

1. From the navigation menu, select Workloads\>Deployments and select the API deployment.

1. Select SCALE.

    ![In the Workloads \> Deployments \> api bar, the Scale icon is highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image89.png)

1. Change the number of pods to 2, and then select **OK**.

    ![In the Scale a Deployment dialog box, 2 is entered in the Desired number of pods box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image116.png)

**NOTE: If the deployment completes quickly, you may not see the deployment Waiting states in the dashboard as described in the following steps**.

1. From the Replica Set view for the API, you'll see it is now deploying and that there is one healthy instance and one pending instance.

    ![Replica Sets is selected under Workloads in the navigation menu on the left, and at right, Pods status: 1 pending, 1 running is highlighted. Below that, a red arrow points at the API deployment in the Pods box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image117.png)

1. From the navigation menu, select Deployments and from the list and note that the api service has a pending status indicated by the grey timer icon, and it shows a pod count 1 of 2 instances (shown as "1/2").

    ![In the Deployments box, the api service is highlighted with a grey timer icon at left and a pod count of 1/2 listed at right.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image118.png)

1. From the Navigation menu, select Workloads. From this view note that the health overview in the right panel of this view. You'll see the following:

    - One deployment and one replica set are each healthy for the api service.

    - One replica set is healthy for the web service.

    - Three pods are healthy.

1. Navigate to the web application from the browser again. The application should still work without errors as you navigate to Speakers and Sessions pages.

    - Navigate to the /stats.html page. You'll see information about the environment including:

        i.  webTaskId: the task identifier for the web service instance

        ii. taskId: the task identifier for the API service instance

        iii. hostName: the hostname identifier for the API service instance

        iv. pid: the process id for the API service instance

        v.  mem: some memory indicators returned from the API service instance

        vi. counters: counters for the service itself, as returned by the API service instance

        vii. uptime: the up time for the API service

    - Refresh the page in the browser, and you can see the hostName change between the two API service instances. The letters after "api-{number}-" in the hostname will change.

### Task 2: Increase service instances beyond available resources

In this task, you will try to increase the number of instances for the API service container beyond available resources in the cluster. You will observe how Kubernetes handles this condition and correct the problem.

1. From the navigation menu, select Deployments. From this view, select the API deployment.

1. Configure the deployment to use a fixed host port for initial testing. Select Edit.

    ![In the Workloads \> Deployments \> api bar, the Edit icon is highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image81.png)

1. In the Edit a Deployment dialog you will see a list of settings shown in JSON format. Use the copy button to copy the text to your clipboard.

    ![Screenshot of the Edit a Deployment dialog box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image82.png)

1. Paste the contents into the text editor of your choice (notepad is shown here, MacOS users can use TextEdit).

    ![Screenshot of the Edit a Deployment contents pasted into Notepad text editor.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image83.png)

1. Scroll down about half way to find the node "$.spec.template.spec.containers[0]" as shown in the screenshot below.

    ![Screenshot of the deployment JSON code, with the \$.spec.template.spec.containers\[0\] section highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image84.png)

1. The containers spec has a single entry for the API container at the moment, you'll see the name of the container is "api" - this is how you know you are looking at the correct container spec.

    Add the following JSON snippet below the "name" property in the container spec.

    ```json
    "ports": [
        {
        "containerPort": 3001,
        "hostPort": 3001
        }
    ],
    ```

    Your container spec should now look like this:

    ![Screenshot of the deployment JSON code, with the \$.spec.template.spec.containers\[0\] section highlighted, showing the updated values for containerPort and hostPost, both set to port 3001.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image85.png)

1. Copy the updated JSON document from notepad into the clipboard. Return to the Kubernetes dashboard, which should still be viewing the "api" deployment.

    Click Edit.

    ![In the Workloads \> Deployments \> api bar, the Edit icon is highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image87.png)

    Paste the updated JSON document.

    Click Update.

    ![UPDATE is highlighted in the Edit a Deployment dialog box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image88.png)

1. From the API deployment view, select **Scale**.

    ![In the Workloads \> Deployments \> api bar, the Scale icon is highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image89.png)

1. Change the number of pods to 4 and select **OK**.

    ![In the Scale a Deployment dialog box, 4 is entered in the Desired number of pods box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image119.png)

1. From the navigation menu, select Services view under Discovery and Load Balancing. Select the api service from the Services list. From the api service view, you'll see it has two healthy instances and two unhealthy (or possibly pending depending on timing) instances.

    ![In the api service view, various information is displayed in the Details box and in the Pods box. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image120.png)

1. After a few minutes, select Workloads from the navigation menu. From this view, you should see an alert reported for the api deployment.

    ![Workloads is selected in the navigation menu. At right, an exclamation point (!) appears next to the api deployment listing in the Deployments box. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image121.png)

    **NOTE: This message indicates that there weren't enough available resources to match the requirements for a new pod instance. In this case, this is because the instance requires port 3001, and since there are only 2 nodes available in the cluster, only two api instances can be scheduled. The third and fourth pod instances will wait for a new node to be available that can run another instance using that port.**

1. Reduce the number of requested pods to 2 using the Scale button.

1. Almost immediately, the warning message from the Workloads dashboard should disappear, and the API deployment will show 2/2 pods are running.

    ![Workloads is selected in the navigation menu. A green check mark now appears next to the api deployment listing in the Deployments box at right. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image122.png)

### Task 3: Restart containers and test HA

In this task, you will restart containers and validate that the restart does not impact the running service.

1. From the navigation menu on the left, select Services view under Discovery and Load Balancing. From the Services list, select the external endpoint hyperlink for the web service and visit the stats page by adding /stats.html to the URL. Keep this open and handy to be refreshed as you complete the steps that follow.

    ![In the Services box, a red arrow points at the hyperlinked external endpoint for the web service. ](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image112.png)

    ![The Stats page is visible in this screenshot of the Contoso Neuro 2017 web application. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image123.png)

1. From the navigation menu, select Workloads>Deployments. From Deployments list, select the API deployment.

    ![A red arrows points at Deployments, which is selected below Workloads in the navigation menu. At right, the API deployment is highlighted in the Deployments box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image124.png)

1. From the API deployment view, select **Scale** and from the dialog presented, enter 4 for the desired number of pods. Select **OK**.

1. From the navigation menu, select Workloads>Replica Sets. Select the api replica set and, from the Replica Set view, you will see that two pods cannot deploy.

    ![Replica Sets is selected under Workloads in the navigation menu on the left. On the right are the Details and Pods boxes. In the Pods box, two pods have exclamation point (!) alerts and messages indicating that they cannot deploy.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image125.png)

1. Return to the browser tab with the web application stats page loaded. Refresh the page over and over. You will not see any errors, but you will see the api host name change between the two api pod instances periodically. The task id and pid might also change between the two api pod instances.

    ![On the Stats page in the Contoso Neuro 2017 web application, two different api host name values are highlighted. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image126.png)

1. After refreshing enough times to see that the hostName value is changing, and the service remains healthy, return to the Replica Sets view for the API. From the navigation menu, select Replica Sets under Workloads and select the API replica set.

1. From this view, take note that the hostName value shown in the web application stats page matches the pod names for the pods that are running.

    ![Two different pod names are highlighted in the Pods box, which match the values from the previous Stats page.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image127.png)

1. Note the remaining pods are still pending, since there are not enough port resources available to launch another instance. Make some room by deleting a running instance. Select the context menu and choose Delete for one of the healthy pods.

    ![A red arrow points at the context menu for the previous pod names that were highlighted in the Pod box. Delete is selected and highlighted in the submenu.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image128.png)

1. Once the running instance is gone, Kubernetes will be able to launch one of the pending instances. However, because you set the desired size of the deploy to 4, Kubernetes will add a new pending instance. Removing a running instance allowed a pending instance to start, but in the end, the number of pending and running instances is unchanged.

    ![The first row of the Pods box is highlighted, and the pod has a green check mark and is running.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image129.png)

1. From the navigation menu, select Deployments under Workloads. From the view's Deployments list select the API deployment.

1. From the API Deployment view, select Scale and enter 1 as the desired number of pods. Select OK.

    ![In the Scale a Deployment dialog box, 1 is entered in the Desired number of pods box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image130.png)

1. Return to the web site's stats.html page in the browser, and refresh while this is scaling down. You'll notice that only one API host name shows up, even though you may still see several running pods in the API replica set view. Even though several pods are running, Kubernetes will no longer send traffic to the pods it has selected to scale down. In a few moments, only one pod will show in the API replica set view.

    ![Replica Sets is selected under Workloads in the navigation menu on the left. On the right are the Details and Pods boxes. Only one API host name, which has a green check mark and is listed as running, appears in the Pods box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image131.png)

1. From the navigation menu, select Workloads. From this view, note that there is only one API pod now.

    ![Workloads is selected in the navigation menu on the left. On the right are the Deployment, Pods, and Replica Sets boxes. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image132.png)

## Exercise 4: Setup load balancing and service discovery

**Duration**: 45 minutes

In the previous exercise we introduced a restriction to the scale properties of the service. In this exercise, you will configure the api deployments to create pods that use dynamic port mappings to eliminate the port resource constraint during scale activities.

Kubernetes services can discover the ports assigned to each pod, allowing you to run multiple instances of the pod on the same agent node --- something that is not possible when you configure a specific static port (such as 3001 for the API service).

### Task 1: Scale a service without port constraints

In this task, we will reconfigure the API deployment so that it will produce pods that choose a dynamic hostPort for improved scalability.

1. From the navigation menu select Deployments under Workloads. From the view's Deployments list select the API deployment.

1. Select Edit.

1. From the Edit a Deployment dialog, do the following:

    - Scroll to the first spec node that describes replicas as shown in the screenshot. Set the value for replicas to 4.

    - Within the replicas spec, beneath the template node, find the "api" containers spec as shown in the screenshot. Remove the hostPort entry for the API container's port mapping.

        ![This is a screenshot of the Edit a Deployment dialog box with various displayed information about spec, selector, and template. Under the spec node, replicas: 4 is highlighted. Further down, ports are highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image137.png)

1. Select **Update**. New pods will now choose a dynamic port.

1. The API service can now scale to 4 pods since it is no longer constrained to an instance per node -- a previous limitation while using port 3001.

    ![Replica Sets is selected under Workloads in the navigation menu on the left. On the right, four pods are listed in the Pods box, and all have green check marks and are listed as Running.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image138.png)

1. Return to the browser and refresh the stats.html page.  You should see all 4 pods serve responses as you refresh.

### Task 2: Update an external service to support dynamic discovery with a load balancer

In this task, you will update the web service so that it supports dynamic discovery through the Azure load balancer.

1. From the navigation menu, select Deployments under Workloads. From the view's Deployments list select the web deployment.

1. Select **Edit**.

1. From the Edit a Deployment dialog, scroll to the web containers spec as shown in the screenshot. Remove the hostPort entry for the web container's port mapping.

    ![This is a screenshot of the Edit a Deployment dialog box with various displayed information about spec, containers, ports, and env. The ports node, containerPort: 3001 and protocol: TCP are highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image140.png)

1. Select **Update**.

1. From the web Deployments view, select **Scale**. From the dialog presented enter 4 as the desired number of pods and select **OK**.

1. Check the status of the scale out by refreshing the web deployment's view. From the navigation menu, select Deployments from under Workloads. Select the web deployment and from this view you should see an error like that shown in the following screenshot.

    ![Deployments is selected under Workloads in the navigation menu on the left. On the right are the Details and New Replica Set boxes. The web deployment is highlighted in the New Replica Set box, indicating an error.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image141.png)

Like the API deployment, the web deployment used a fixed *hostPort*, and your ability to scale was limited by the number of available agent nodes. However, after resolving this issue for the web service by removing the *hostPort* setting, the web deployment is still unable to scale past two pods due to CPU constraints. The deployment is requesting more CPU than the web application needs, so you will fix this constraint in the next task.

### Task 3: Adjust CPU constraints to improve scale

In this task, you will modify the CPU requirements for the web service so that it can scale out to more instances.

1. From the navigation menu, select Deployments under Workloads. From the view's Deployments list select the web deployment.

1. Select **Edit**.

1. From the Edit a Deployment dialog, find the *cpu* resource requirements for the web container. Change this value to "125m".

    ![This is a screenshot of the Edit a Deployment dialog box with various displayed information about ports, env, and resources. The resources node , with cpu: 125m selected, is highlighted.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image142.png)

1. Select **Update** to save the changes and update the deployment.

1. From the navigation menu, select Replica Sets under Workloads. From the view's Replica Sets list select the web replica set.

1. When the deployment update completes, four web pods should be shown in running state.

    ![Four web pods are listed in the Pods box, and all have green check marks and are listed as Running.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image143.png)

1. Return to the browser tab with the web application loaded and refresh the stats page at /stats.html to watch the display update to reflect the different api pods by observing the host name refresh.

### Task 4: Perform a rolling update

In this task, you will edit the web application source code to add Application Insights and update the Docker image used by the deployment. Then you will perform a rolling update to demonstrate how to deploy a code change.

1. First create an Application Insights key for content-web using the Azure Portal

1. Click "+ Create a Resource" and search for "Application Insights" and select "Application Insights"

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.2.png)

1. Configure the resource as follows the click "Create":

    - **Name**: content-web

    - **Application Type**: Node.js Application

    - **Subscription**: Use the same subscription you have been using throughout the lab.

    - **Resource Group**: Use the existing resource group fabmedical-SUFFIX

    - **Location**: Use the same location you have been using throughout the lab.

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.3.png)

1. While the Application Insights resource for content-web deploys, create a second Application Insights resource for content-api.  Configure the resource as follows the click "Create":

    - **Name**: content-api

    - **Application Type**: Node.js Application

    - **Subscription**: Use the same subscription you have been using throughout the lab.

    - **Resource Group**: Use the existing resource group fabmedical-SUFFIX

    - **Location**: Use the same location you have been using throughout the lab.

1. When both resources have deployed, locate them in your resource group.

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.5.png)

1. Click on the content-web resource to view the details.  Make a note of the Instrumentation Key, you will need it when configuring the content-web application.

    ![Azure Portal](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.6.png)

1. Return to your resource group and view the details of the content-api Application Insights resource.  Make a note of it's unique Instrumentation Key as well.

1. Connect to your build agent VM using ssh as you did in Task 6: Connect securely to the build agent before the hands-on lab.

1. From the command line, navigate to the content-web directory.

1. Install support for Application Insights

    ```bash
    npm install applicationinsights --save
    ```

1. Open the server.js file using VI:

    ```bash
    vi server.js
    ```

1. Enter insert mode by pressing `<i>`.

1. Add the following lines immediately after the config is loaded

    ```javascript
    const appInsights = require("applicationinsights");
    appInsights.setup(config.appInsightKey);
    appInsights.start();
    ```
    ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.13.png)

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

1. Update your config files to include the Application Insights Key

    ```bash
    vi config/env/production.js
    <i>
    ```
1. Add the following line to the `module.exports` object, and then update [YOUR APPINSIGHTS KEY] with the your Application Insights Key from the Azure portal.

    ```javascript
    appInsightKey: '[YOUR APPINSIGHTS KEY]'
    ```

    ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.16.png)

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

1. Now update the development config.
    ```bash
    vi config/env/development.js
    <i>
    ```
1. Add the following line to the `module.exports` object, and then update [YOUR APPINSIGHTS KEY] with the your Application Insights Key from the Azure portal.

    ```javascript
    appInsightKey: '[YOUR APPINSIGHTS KEY]'
    ```
1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

1. Push these changes to your repository so that VSTS CI will build a new image while you work on updating the content-api application.

    ```bash
    git add .
    git commit -m "Added Application Insights"
    git push
    ```

1. Now update the content-api application

    ```bash
    cd ../content-api
    npm install applicationinsights --save
    ```

1. Open the server.js file using VI:

    ```bash
    vi server.js
    ```

1. Enter insert mode by pressing `<i>`.

1. Add the following lines immediately after the config is loaded

    ```javascript
    const appInsights = require("applicationinsights");
    appInsights.setup(config.appInsightKey);
    appInsights.start();
    ```

    ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.25.png)

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

1. Update your config files to include the Application Insights Key

    ```bash
    vi config/config.js
    <i>
    ```

1. Add the following line to the `exports.appSettings` object, and then update [YOUR APPINSIGHTS KEY] with the your Application Insights Key for **content-api** from the Azure portal.

    ```javascript
    appInsightKey: '[YOUR APPINSIGHTS KEY]'
    ```

    ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.28.png)

1. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

1. Push these changes to your repository so that VSTS CI will build a new image.

    ```bash
    git add .
    git commit -m "Added Application Insights"
    git push
    ```

1. Visit your ACR to see the new images and make a note of the tags assigned by VSTS.

    - Make a note of the latest tag for content-web

        ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.31a.png)

    - And the latest tag for content-api

        ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task4.31b.png)

1. Now that you have finished updating the source code, you can exit the build agent.

    ```bash
    exit
    ```

1. From WSL, request a rolling update using this kubectl command:

    ```bash
    kubectl set image deployment/web web=[LOGINSERVER]/content-web:[LATEST TAG]
    ```

1. Next update the content-api application

    ```bash
    kubectl set image deployment/api api=[LOGINSERVER]/content-api:[LATEST TAG]
    ```

1. While this update runs, return the Kubernetes management dashboard in the browser.

1. From the navigation menu select Replica Sets under Workloads. From this view you will see a new replica set for web which may still be in the process of deploying (as shown below) or already fully deployed.

    ![At the top of the list, a new web replica set is listed as a pending deployment in the Replica Set box.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image144.png)

1. While the deployment is in progress, you can navigate to the web application and visit the stats page at /stats.html. Refresh the page as the rolling update executes. Observe that the service is running normally and tasks continue to be load balanced..

    ![On the Stats page, the webTaskId is highlighted. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/image145.png)

### Task 5 Configure Kubernetes Ingress

In this task you will setup a Kubernetes Ingress to take advantage of path based routing and TLS termination.

1. Install helm, a package manager for Kubernetes.  Run the following commands in your WSL window.

    ```bash
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh
    ```

1. Setup your local config and deploy the server side helm component `tiller`.

    ```bash
    helm init --upgrade --service-account default
    ```

1. Update your helm package list.

    ```bash
    helm repo update
    ```

1. Install the ingress controller resource, to handle ingress requests when they come in.  The ingress controller will receive a public IP of its own on the Azure Load Balancer, and be able to handle requests for multiple servicers over port 80 and 443.

    ```bash
    helm install stable/nginx-ingress --namespace kube-system --set rbac.create=false --set rbac.createRole=false --set rbac.createClusterRole=false
    ```

1. Set a DNS prefix on the IP address allocated to the ingress controller.  Visit the `kube-system` namespace in your kubeneretes dashboard to find the IP

    http://localhost:8001/#!/service?namespace=kube-system

    ![Kubernetes Dashboard](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task5.5.png)

1. Create a script to update the public DNS name for the IP.

    ```bash
    vi update-ip.sh
    <i>
    ```

    Paste the following as the contents and update the IP and SUFFIX values

    ```bash
    #!/bin/bash

    # Public IP address
    IP="[INGRESS PUBLIC IP]"

    # Name to associate with public IP address
    DNSNAME="fabmedical-[SUFFIX]-ingress"

    # Get the resource-id of the public ip
    PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

    # Update public ip address with dns name
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME
    ```

    ![VIM](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task5.6.png)

1. Use `<esc>:wq` to save your script and exit VIM.

1. Run the update script

    ```bash
    bash ./update-ip.sh
    ```

1. Verify the IP update by visiting the url in your browser.

    > Note, it is normal to receive a 404 message at this time.

    ```text
    http://fabmedical-[SUFFIX]-ingress.eastus.cloudapp.azure.com/
    ```

    ![Browser](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task5.9.png)

1. Use helm to install `cert-manager` a tool that can provision SSL certificates automatically from letsencrypt.org.

    ```bash
    helm install --name cert-manager --namespace kube-system --set rbac.create=false stable/cert-manager
    ```

1. Cert manager will need a custom ClusterIssuer resource to handle requesting SSL certificates.

    ```bash
    vi clusterissuer.yml
    <i>
    ```

    The following resource configuration should work as is:

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

1. Save the file with `<esc>:wq`.

1. Create the issuer using kubectl

    ```bash
    kubectl create --save-config=true -f clusterissuer.yml
    ```

1. Update the cert-manager to use the ClusterIssuer by default.

    ```bash
    helm upgrade cert-manager stable/cert-manager --namespace kube-system --set rbac.create=false --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer
    ```
1. Now you can create an ingress resource for the content applications.

    ```bash
    vi content.ingress.yml
    <i>
    ```

    Use the following as the contents, and update the [SUFFIX] to match your ingress DNS name.

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

1. Save the file with `<esc>:wq`.

1. Create the ingress using kubectl

    ```bash
    kubectl create --save-config=true -f content.ingress.yml
    ```
1. Refresh the ingress endpoint in your browser.  You should be able to visit the speakers and sessions pages and see all the content.

1. Visit the api directly, by navigating to `/content-api/sessions` at the ingress endpoint.

    ![Browser](images/Hands-onlabstep-by-step-ContainersandDevOpsimages/media/Ex4-Task5.19.png)

1. Test TLS termination by visiting both services again using `https`

    > It can take a few minutes before the SSL site becomes avaiable.  This is due to the delay involved with provisioning a TLS cert from letsencypt.

## After the hands-on lab

**Duration**: 10 mins

In this exercise, you will de-provision any Azure resources created in support of this lab.

1.  Delete both of the Resource Groups in which you placed all of your Azure resources.

    -   From the Portal, navigate to the blade of your Resource Group and select Delete in the command bar at the top.

    -   Confirm the deletion by re-typing the resource group name and selecting Delete.

2.  Delete the Service Principal created on Task 9: Create a Service Principal before the hands-on lab.
    ```
    az ad sp delete --id "Fabmedical-sp"
    ```