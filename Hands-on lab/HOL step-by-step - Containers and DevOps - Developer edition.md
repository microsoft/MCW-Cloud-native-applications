![](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/master/Media/ms-cloud-workshop.png "Microsoft Cloud Workshops")

<div class="MCWHeader1">
Containers and DevOps - Developer edition
</div>

<div class="MCWHeader2">
Hands-on lab step-by-step
</div>

<div class="MCWHeader3">
April 2019
</div>

Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.

© 2019 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at https://www.microsoft.com/en-us/legal/intellectualproperty/Trademarks/Usage/General.aspx are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents**

<!-- TOC -->

- [Containers and DevOps - Developer edition hands-on lab step-by-step](#containers-and-devops-developer-edition-hands-on-lab-step-by-step)
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
  - [Exercise 2: Deploy the solution to Azure Kubernetes Service](#exercise-2-deploy-the-solution-to-azure-kubernetes-service)
    - [Task 1: Tunnel into the Azure Kubernetes Service cluster](#task-1-tunnel-into-the-azure-kubernetes-service-cluster)
    - [Task 2: Deploy a service using the Kubernetes management dashboard](#task-2-deploy-a-service-using-the-kubernetes-management-dashboard)
    - [Task 3: Deploy a service using kubectl](#task-3-deploy-a-service-using-kubectl)
    - [Task 4: Deploy a service using a Helm chart](#task-4-deploy-a-service-using-a-helm-chart)
    - [Task 5: Initialize database with a Kubernetes Job](#task-5-initialize-database-with-a-kubernetes-job)
    - [Task 6: Test the application in a browser](#task-6-test-the-application-in-a-browser)
    - [Task 7: Configure Continuous Delivery to the Kubernetes Cluster](#task-7-configure-continuous-delivery-to-the-kubernetes-cluster)
    - [Task 8: Review Azure Monitor for Containers](#task-8-review-azure-monitor-for-containers)
  - [Exercise 3: Scale the application and test HA](#exercise-3-scale-the-application-and-test-ha)
    - [Task 1: Increase service instances from the Kubernetes dashboard](#task-1-increase-service-instances-from-the-kubernetes-dashboard)
    - [Task 2: Increase service instances beyond available resources](#task-2-increase-service-instances-beyond-available-resources)
    - [Task 3: Restart containers and test HA](#task-3-restart-containers-and-test-ha)
  - [Exercise 4: Setup load balancing and service discovery](#exercise-4-setup-load-balancing-and-service-discovery)
    - [Task 1: Scale a service without port constraints](#task-1-scale-a-service-without-port-constraints)
    - [Task 2: Update an external service to support dynamic discovery with a load balancer](#task-2-update-an-external-service-to-support-dynamic-discovery-with-a-load-balancer)
    - [Task 3: Adjust CPU constraints to improve scale](#task-3-adjust-cpu-constraints-to-improve-scale)
    - [Task 4: Perform a rolling update](#task-4-perform-a-rolling-update)
    - [Task 5: Configure Kubernetes Ingress](#task-5-configure-kubernetes-ingress)
  - [After the hands-on lab](#after-the-hands-on-lab)

<!-- /TOC -->

# Containers and DevOps - Developer edition hands-on lab step-by-step

## Abstract and learning objectives

This hands-on lab is designed to guide you through the process of building and deploying Docker images to the Kubernetes platform hosted on Azure Kubernetes Services (AKS), in addition to learning how to work with dynamic service discovery, service scale-out, and high-availability.

At the end of this lab you will be better able to build and deploy containerized applications to Azure Kubernetes Service and perform common DevOps procedures.

## Overview

Fabrikam Medical Conferences (FabMedical) provides conference website services tailored to the medical community. They are refactoring their application code, based on node.js, so that it can run as a Docker application, and want to implement a POC that will help them get familiar with the development process, lifecycle of deployment, and critical aspects of the hosting environment. They will be deploying their applications to Azure Kubernetes Service and want to learn how to deploy containers in a dynamically load-balanced manner, discover containers, and scale them on demand.

In this hands-on lab, you will assist with completing this POC with a subset of the application code base. You will create a build agent based on Linux, and an Azure Kubernetes Service cluster for running deployed applications. You will be helping them to complete the Docker setup for their application, test locally, push to an image repository, deploy to the cluster, and test load-balancing and scale.

> **IMPORTANT**: Most Azure resources require unique names. Throughout these steps you will see the word "SUFFIX" as part of resource names. You should replace this with your Microsoft email prefix to ensure the resource is uniquely named.

## Solution architecture

Below is a diagram of the solution architecture you will build in this lab. Please study this carefully, so you understand the whole of the solution as you are working on the various components.

The solution will use Azure Kubernetes Service (AKS), which means that the container cluster topology is provisioned according to the number of requested nodes. The proposed containers deployed to the cluster are illustrated below with Cosmos DB as a managed service:

![A diagram showing the solution, using Azure Kubernetes Service with a Cosmos DB back end.](media/image3.png)

Each tenant will have the following containers:

- **Conference Web site**: The SPA application that will use configuration settings to handle custom styles for the tenant.

- **Admin Web site**: The SPA application that conference owners use to manage conference configuration details, manage attendee registrations, manage campaigns and communicate with attendees.

- **Registration service**: The API that handles all registration activities creating new conference registrations with the appropriate package selections and associated cost.

- **Email service**: The API that handles email notifications to conference attendees during registration, or when the conference owners choose to engage the attendees through their admin site.

- **Config service**: The API that handles conference configuration settings such as dates, locations, pricing tables, early bird specials, countdowns, and related.

- **Content service**: The API that handles content for the conference such as speakers, sessions, workshops, and sponsors.

## Requirements

1. Microsoft Azure subscription must be pay-as-you-go or MSDN.

    - Trial subscriptions will *not* work.

    - You must have rights to create a service principal as discussed in Before the Hands on Lab Task 9: Create a Service Principal --- and this typically requires a subscription owner to log in. You may have to ask another subscription owner to login to the portal and execute that step ahead of time if you do not have the rights.

    - You must have enough cores available in your subscription to create the build agent and Azure Kubernetes Service cluster in Before the Hands on Lab Task 5: Create a build agent VM and Task 10: Create an Azure Kubernetes Service cluster. You'll need eight cores if following the exact instructions in the lab, or more if you choose additional agents or larger VM sizes. If you execute the steps required before the lab, you will be able to see if you need to request more cores in your sub.

2. Local machine or a virtual machine configured with:

    - A browser, preferably Chrome for consistency with the lab implementation tests.

    - Command prompts:

        - On Windows, you will be using Bash on Ubuntu on Windows, hereon referred to as WSL.

        - On Mac, all instructions should be executed using bash in Terminal.

3. You will be asked to install other tools throughout the exercises.

> **VERY IMPORTANT**: You should be typing all of the commands as they appear in the guide, except where explicitly stated in this document. Do not try to copy and paste to your command windows or other documents where you are instructed to enter information shown in this document. There can be issues with Copy and Paste that result in errors, execution of instructions, or creation of file content.

## Exercise 1: Create and run a Docker application

**Duration**: 40 minutes

In this exercise, you will take the starter files and run the node.js application as a Docker application. You will create a Dockerfile, build Docker images, and run containers to execute the application.

> **Note**: Complete these tasks from the WSL window with the build agent session.

### Task 1: Test the application

The purpose of this task is to make sure you can run the application successfully before applying changes to run it as a Docker application.

1. From the WSL window, connect to your build agent if you are not already connected.

2. Type the following command to create a Docker network named "fabmedical":

    ```bash
    docker network create fabmedical
    ```

3. Run an instance of mongodb to use for local testing.

    ```bash
    docker run --name mongo --net fabmedical -p 27017:27017 -d mongo
    ```

4. Confirm that the mongo container is running and ready.

    ```bash
    docker container list
    docker logs mongo
    ```

    ![In this screenshot of the WSL window, docker container list has been typed and run at the command prompt, and the “api” container is in the list. Below this the log output is shown.](media/Ex1-Task1.4.png)

5. Connect to the mongo instance using the mongo shell and test some basic commands:

    ```bash
    mongo
    ```

    ```text
    show dbs
    quit()
    ```

    ![This screenshot of the WSL window shows the output from connecting to mongo.](media/Ex1-Task1.5.png)

6. To initialize the local database with test content, first navigate to the content-init directory and run npm install.

    ```bash
    cd content-init
    npm install
    ```

7. Initialize the database.

    ```bash
    nodejs server.js
    ```

    ![This screenshot of the WSL window shows output from running the database initialization.](media/Ex1-Task1.7.png)

8. Confirm that the database now contains test data.

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

    ![This screenshot of the WSL window shows the data output.](media/Ex1-Task1.8.png)

9. Now navigate to the content-api directory and run npm install.

    ```bash
    cd ../content-api
    npm install
    ```

10. Start the API as a background process.

    ```bash
    nodejs ./server.js &
    ```

    ![In this screenshot, nodejs ./server.js & has been typed and run at the command prompt, which starts the API as a background process.](media/image47.png)

11. Press ENTER again to get to a command prompt for the next step.

12. Test the API using curl. You will request the speaker's content, and this will return a JSON result.

    ```bash
    curl http://localhost:3001/speakers
    ```

13. Navigate to the web application directory, run npm install and bower install, and then run the application as a background process as well. Ignore any warnings you see in the output; this will not affect running the application.

    ```bash
    cd ../content-web
    npm install
    bower install
    nodejs ./server.js &
    ```

    ![In this screenshot, after navigating to the web application directory, nodejs ./server.js & has been typed and run at the command prompt, which runs the application as a background process as well.](media/image48.png)

14. Press ENTER again to get a command prompt for the next step.

15. Test the web application using curl. You will see HTML output returned without errors.

    ```bash
    curl http://localhost:3000
    ```

16. Leave the application running for the next task.

17. If you received a JSON response to the /speakers content request and an HTML response from the web application, your environment is working as expected.

### Task 2: Enable browsing to the web application

In this task, you will open a port range on the agent VM so that you can browse to the web application for testing.

1. From the Azure portal select the resource group you created named fabmedical-SUFFIX.

2. Select the Network Security Group associated with the build agent from your list of available resources.

    ![In this screenshot of your list of available resources, the sixth item is selected: fabmedical-(suffix obscured)-nsg (Network security group).](media/image49.png)

3. From the Network interface essentials blade, select **Inbound security rules**.

    ![In the Network interface essentials blade, Inbound security rules is highlighted under Settings.](media/image50.png)

4. Select **Add** to add a new rule.

    ![In this screenshot of the Inbound security rules windows, a red arrow points at Add.](media/image51.png)

5. From the Add inbound security rule blade, enter the values as shown in the screenshot below:

    - **Source**: Any

    - **Source port ranges**: *

    - **Destination**: Any

    - **Destination port ranges**: 3000-3010

    - **Protocol**: Any

    - **Action**: Allow

    - **Priority**: Leave at the default priority setting.

    - **Name**: Enter "allow-app-endpoints".

        ![In the Add inbound security rule blade, the values listed above appear in the corresponding boxes.](media/image52.png)

6. Select **OK** to save the new rule.

    ![In this screenshot, a table has the following columns: Priority, Name, Port, Protocol, Source, Destination, and Action. The first row is highlighted with the following values: 100, allow-app-endpoints, 3000-3010, Any, Any, Any, and Allow (which has a green check mark next to it).](media/image53.png)

7. From the resource list shown in step 2, select the build agent VM named fabmedical-SUFFIX.

    ![In this screenshot of your list of available resources, the first item is selected, which has the following values for Name, Type, and Location: fabmedical-soll (a red arrows points to this name), Virtual machine, and East US 2.](media/image54.png)

8. From the Virtual Machine blade overview, find the IP address of the VM.

    ![In the Virtual Machine blade, Overview is selected on the left and Public IP address 52.174.141.11 is highlighted on the right.](media/image26.png)

9. Test the web application from a browser. Navigate to the web application using your build agent IP address at port 3000.

    ```text
    http://[BUILDAGENTIP]:3000

    EXAMPLE: http://13.68.113.176:3000
    ```

10. Select the Speakers and Sessions links in the header. You will see the pages display the HTML version of the JSON content you curled previously.

11. Once you have verified the application is accessible through a browser, go to your WSL window and stop the running node processes.

    ```bash
    killall nodejs
    ```

### Task 3: Create a Dockerfile

In this task, you will create a new Dockerfile that will be used to run the API application as a containerized application.

> **Note**: You will be working in a Linux VM without friendly editor tools. You must follow the steps very carefully to work with Vim for a few editing exercises if you are not already familiar with Vim.

1. From WSL, navigate to the content-api folder. List the files in the folder with this command. The output should look like the screenshot below.

    ```bash
    cd ../content-api
    ll
    ```

    ![In this screenshot of the WSL window, ll has been typed and run at the command prompt. The files in the folder are listed in the window. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](media/image55.png)

2. Create a new file named "Dockerfile" and note the casing in the name. Use the following Vim command to create a new file. The WSL window should look as shown in the following screenshot.

    ```bash
    vi Dockerfile
    ```

    ![This is a screenshot of a new file named Dockerfile in the WSL window.](media/image56.png)

3. Select "i" on your keyboard. You'll see the bottom of the window showing INSERT mode.

    ![\-- INSERT -- appears at the bottom of the Dockerfile window.](media/image57.png)

4. Type the following into the file. These statements produce a Dockerfile that describes the following:

    - The base stage includes environment setup which we expect to change very rarely, if at all.

      - Creates a new Docker image from the base image node:alpine. This base image has node.js on it and is optimized for small size.

      - Add `curl` to the base image to support Docker health checks.

      - Creates a directory on the image where the application files can be copied.

      - Exposes application port 3001 to the container environment so that the application can be reached at port 3001.

    - The build stage contains all the tools and intermediate files needed to create the application.

      - Creates a new Docker image from node:argon.

      - Creates a directory on the image where the application files can be copied.

      - Copies package.json to the working directory.

      - Runs npm install to initialize the node application environment.

      - Copies the source files for the application over to the image.

    - The final stage combines the base image with the build output from the build stage.

      - Sets the working directory to the application file location.

      - Copies the app files from the build stage.

      - Indicates the command to start the node application when the container is run.

    > **Note**: Type the following into the editor, as you may have errors with copying and pasting:

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

5. When you are finished typing, hit the Esc key and type ":wq" and hit the Enter key to save the changes and close the file.

    ```bash
    <Esc>
    :wq
    <Enter>
    ```

6. List the contents of the folder again to verify that the new Dockerfile has been created.

    ```bash
    ll
    ```

    ![In this screenshot of the WSL window, ll has been typed and run at the command prompt. The Dockerfile file is highlighted at the top of list.](media/image58.png)

7. Verify the file contents to ensure it was saved as expected. Type the following command to see the output of the Dockerfile in the command window.

    ```bash
    cat Dockerfile
    ```
    

### Task 4: Create Docker images

In this task, you will create Docker images for the application --- one for the API application and another for the web application. Each image will be created via Docker commands that rely on a Dockerfile.

1. From WSL, type the following command to view any Docker images on the VM. The list will only contain the mongodb image downloaded earlier.

    ```bash
    docker images
    ```

2. From the content-api folder containing the API application files and the new Dockerfile you created, type the following command to create a Docker image for the API application. This command does the following:

    - Executes the Docker build command to produce the image

    - Tags the resulting image with the name content-api (-t)

    - The final dot (".") indicates to use the Dockerfile in this current directory context. By default, this file is expected to have the name "Dockerfile" (case sensitive).

    ```bash
    docker build -t content-api .
    ```

3. Once the image is successfully built, run the Docker images command again. You will see several new images: the node images and your container image.

    ```bash
    docker images
    ```

    Notice the untagged image.  This is the build stage which contains all the intermediate files not needed in your final image.

    ![The node image (node) and your container image (content-api) are visible in this screenshot of the WSL window.](media/image59.png)

4. Commit and push the new Dockerfile before continuing.

    ```bash
    git add .
    git commit -m "Added Dockerfile"
    git push
    ```

    Enter credentials if prompted.

5. Navigate to the content-web folder again and list the files. Note that this folder already has a Dockerfile.

    ```bash
    cd ../content-web
    ll
    ```

6. View the Dockerfile contents -- which are similar to the file you created previously in the API folder. Type the following command:

    ```bash
    cat Dockerfile
    ```

    Notice that the content-web Dockerfile build stage includes additional tools to install bower packages in addition to the npm packages.

7. Type the following command to create a Docker image for the web application.

    ```bash
    docker build -t content-web .
    ```

8. When complete, you will see seven images now exist when you run the Docker images command.

    ```bash
    docker images
    ```
    ![Three images are now visible in this screenshot of the WSL window: content-web, content-api, and node.](media/image60.png)  
9. Navigate to the content-init folder and list the files. Note that this folder also has the same Dockerfile.

    ```bash
    cd ../content-init
    ll
    ```
    
10. Type the following command to create a Docker image for the web application.

    ```bash
    docker build -t content-init .
    ```
 
11. List the docker images to see the new content-init image: 

    ```bash
    docker images
    ```


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

2. The docker run command has failed because it is configured to connect to mongodb using a localhost url.  However, now that content-api is isolated in a separate container, it cannot access mongodb via localhost even when running on the same docker host.  Instead, the API must use the bridge network to connect to mongodb.

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

3. The content-api application allows an environment variable to configure the mongodb connection string.  Remove the existing container, and then instruct the docker engine to set the environment variable by adding the `-e` switch to the docker run command.  Also, use the `-d` switch to run the api as a daemon.

    ```bash
    docker rm api
    docker run --name api --net fabmedical -p 3001:3001 -e MONGODB_CONNECTION=mongodb://mongo:27017/contentdb -d content-api
    ```

4. Enter the command to show running containers. You'll observe that the "api" container is in the list.  Use the docker logs command to see that the API application has connected to mongodb.

    ```bash
    docker container ls
    docker logs api
    ```

    ![In this screenshot of the WSL window, docker container ls has been typed and run at the command prompt, and the "api" container is in the list with the following values for Container ID, Image, Command, Created, Status, Ports, and Names: 548d25a1449f, content-api, "npm start", 8 seconds ago, Up 6 seconds, 0.0.0.0:3001-\>3001/tcp, and api.](media/image61.png)

5. Test the API by curling the URL. You will see JSON output as you did when testing previously.

    ```bash
    curl http://localhost:3001/speakers
    ```

6. Create and start the web application container with a similar Docker run command -- instruct the docker engine to use any port with the `-P` command.

    ```bash
    docker run --name web --net fabmedical -P -d content-web
    ```

7. Enter the command to show running containers again and you'll observe that both the API and web containers are in the list. The web container shows a dynamically assigned port mapping to its internal container port 3000.

    ```bash
    docker container ls
    ```

    ![In this screenshot of the WSL window, docker container ls has again been typed and run at the command prompt. 0.0.0.0:32768->3000/tcp is highlighted under Ports, and a red arrow is pointing at it.](media/image62.png)

8. Test the web application by curling the URL. For the port, use the dynamically assigned port, which you can find in the output from the previous command. You will see HTML output, as you did when testing previously.

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

2. Validate that the web container is no longer running or present by using the -a flag as shown in this command. You will see that the "web" container is no longer listed.

    ```bash
    docker container ls -a
    ```

3. Navigate to the `content-web/data-access` directory. From there, open the index.js file for editing using Vim, and press the "i" key to go into edit mode.

    ```bash
    cd data-access
    vi index.js
    <i>
    ```

4. Locate the following TODO item and modify the code to comment the first line and uncomment the second. The result is that the contentApiUrl variable will be set to an environment variable.

    ```javascript
    //TODO: Exercise 2 - Task 6 - Step 4

    //const contentApiUrl = "http://localhost:3001";
    const contentApiUrl = process.env.CONTENT_API_URL;
    ```

5. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

6. Navigate to the content-web directory. From there open the Dockerfile for editing using Vim and press the "i" key to go into edit mode.

    ```bash
    cd ..
    vi Dockerfile
    <i>
    ```

7. Locate the EXPOSE line shown below, and add a line above it that sets the default value for the environment variable as shown in the screenshot.

    ```Dockerfile
    ENV CONTENT_API_URL http://localhost:3001
    ```

    ![In this screenshot of Dockerfile, ENV CONTENT\_API\_URL http://localhost:3001 appears above Expose 3000.](media/image63.png)

8. Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

9. Rebuild the web application Docker image using the same command as you did previously.

    ```bash
    docker build -t content-web .
    ```

10. Create and start the image passing the correct URI to the API container as an environment variable. This variable will address the API application using its container name over the Docker network you created. After running the container, check to see the container is running and note the dynamic port assignment for the next step.

    ```bash
    docker run --name web --net fabmedical -P -d -e CONTENT_API_URL=http://api:3001 content-web
    docker container ls
    ```

11. Curl the speakers path again, using the port assigned to the web container. Again, you will see HTML returned, but because curl does not process javascript, you cannot determine if the web application is communicating with the api application.  You must verify this connection in a browser.

    ```bash
    curl http://localhost:[PORT]/speakers.html
    ```

12. You will not be able to browse to the web application on the ephemeral port because the VM only exposes a limited port range. Now you will stop the web container and restart it using port 3000 to test in the browser. Type the following commands to stop the container, remove it, and run it again using explicit settings for the port.

    ```bash
    docker stop web
    docker rm web
    docker run --name web --net fabmedical -p 3000:3000 -d -e CONTENT_API_URL=http://api:3001 content-web
    ```

13. Curl the speaker path again, using port 3000. You will see the same HTML returned.

    ```bash
    curl http://localhost:3000/speakers.html
    ```

14. You can now use a web browser to navigate to the website and successfully view the application at port 3000. Replace [BUILDAGENTIP] with the IP address you used previously.

    ```bash
    http://[BUILDAGENTIP]:3000

    EXAMPLE: http://13.68.113.176:3000
    ```

15. Managing several containers with all their command line options can become difficult as the solution grows.  `docker-compose` allows us to declare options for several containers and run them together.  First, cleanup the existing containers.

    ```bash
    docker stop web && docker rm web
    docker stop api && docker rm api
    docker stop mongo && docker rm mongo
    ```

16. Commit your changes and push to the repository.

    ```bash
    git add .
    git commit -m "Setup Environment Variables"
    git push
    ```

17. Navigate to your home directory (where you checked out the content repositories) and create a docker compose file.

    ```bash
    cd ~
    vi docker-compose.yml
    <i>
    ```

    Type the following as the contents of `docker-compose.yml`:

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

    Press the Escape key and type ":wq" and then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

18. Start the applications with the `up` command.

    ```bash
    docker-compose -f docker-compose.yml -p fabmedical up -d
    ```

    ![This screenshot of the WSL window shows the creation of the network and three containers: mongo, api and web.](media/Ex1-Task6.17.png)

19. Visit the website in the browser; notice that we no longer have any data on the speakers or sessions pages.

    ![Browser view of the web site.](media/Ex1-Task6.18.png)

20. We stopped and removed our previous mongodb container; all the data contained in it has been removed.  Docker compose has created a new, empty mongodb instance that must be reinitialized.  If we care to persist our data between container instances, the docker has several mechanisms to do so. First we will update our compose file to persist mongodb data to a directory on the build agent.

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

    The result should look similar to the following screenshot:

    ![This screenshot of the VIM edit window shows the resulting compose file.](media/Ex1-Task6.19.png)

21. Next we will add a second file to our composition so that we can initialize the mongodb data when needed.

    ```bash
    vi docker-compose.init.yml
    ```

    Add the following as the content:

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

22. To reconfigure the mongodb volume, we need to bring down the mongodb service first.

    ```bash
    docker-compose -f docker-compose.yml -p fabmedical down
    ```

    ![This screenshot of the WSL window shows the running containers stopping.](media/Ex1-Task6.21.png)

23. Now run `up` again with both files to update the mongodb configuration, and run the initialization script.

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.init.yml -p fabmedical up -d
    ```

24. Check the data folder to see that mongodb is now writing data files to the host.

    ```bash
    ls ./data/
    ```

    ![This screenshot of the WSL window shows the output of the data folder.](media/Ex1-Task6.23.png)

25. Check the results in the browser. The speaker and session data are now available.

    ![A screenshot of the sessions page.](media/Ex1-Task6.24.png)

### Task 7: Push images to Azure Container Registry

To run containers in a remote environment, you will typically push images to a Docker registry, where you can store and distribute images. Each service will have a repository that can be pushed to and pulled from with Docker commands. Azure Container Registry (ACR) is a managed private Docker registry service based on Docker Registry v2.

In this task, you will push images to your ACR account, version images with tagging, and setup continuous integration (CI) to build future versions of your containers and push them to ACR automatically.

1. In the [Azure Portal](https://portal.azure.com/), navigate to the ACR you created in Before the hands-on lab.

2. Select Access keys under Settings on the left-hand menu.

    ![In this screenshot of the left-hand menu, Access keys is highlighted below Settings.](media/image64.png)

3. The Access keys blade displays the Login server, username, and password that will be required for the next step. Keep this handy as you perform actions on the build VM.

    > **Note**: If the username and password do not appear, select Enable on the Admin user option.

4. From the WSL session connected to your build VM, login to your ACR account by typing the following command. Follow the instructions to complete the login.

    ```bash
    docker login [LOGINSERVER] -u [USERNAME] -p [PASSWORD]
    ```

    For example:

    ```bash
    docker login fabmedicalsoll.azurecr.io -u fabmedicalsoll -p +W/j=l+Fcze=n07SchxvGSlvsLRh/7ga
    ```

    ![In this screenshot of the WSL window, the following has been typed and run at the command prompt: docker login fabmedicalsoll.azurecr.io --u fabmedicalsoll --p +W/j=l+Fcze=n07SchxvGSlvsLRh/7ga](media/image65.png)

    **Tip: Make sure to specify the fully qualified registry login server (all lowercase).**

5. Run the following commands to properly tag your images to match your ACR account name.

    ```bash
    docker tag content-web [LOGINSERVER]/content-web
    docker tag content-api [LOGINSERVER]/content-api
    ```

6. List your docker images and look at the repository and tag. Note that the repository is prefixed with your ACR login server name, such as the sample shown in the screenshot below.

    ```bash
    docker images
    ```

    ![This is a screenshot of a docker images list example.](media/image66.png)

7. Push the images to your ACR account with the following command:

    ```bash
    docker push [LOGINSERVER]/content-web
    docker push [LOGINSERVER]/content-api
    ```

    ![In this screenshot of the WSL window, an example of images being pushed to an ACR account results from typing and running the following at the command prompt: docker push \[LOGINSERVER\]/fabmedical/content-web.](media/image67.png)

8. In the Azure Portal, navigate to your ACR account, and select Repositories under Services on the left-hand menu. You will now see two; one for each image.

    ![In this screenshot, fabmedical/content-api and fabmedical/content-web each appear on their own lines below Repositories.](media/image68.png)

9. Select content-api. You'll see the latest tag is assigned.

    ![In this screenshot, fabmedical/content-api is selected under Repositories, and the Tags blade appears on the right.](media/image69.png)

10. From WSL, assign the v1 tag to each image with the following commands. Then list the Docker images to note that there are now two entries for each image; showing the latest tag and the v1 tag. Also note that the image ID is the same for the two entries, as there is only one copy of the image.

    ```bash
    docker tag [LOGINSERVER]/content-web:latest [LOGINSERVER]/content-web:v1
    docker tag [LOGINSERVER]/content-api:latest [LOGINSERVER]/content-api:v1
    docker images
    ```

    ![In this screenshot of the WSL window is an example of tags being added and displayed.](media/image70.png)

11. Repeat Step 7 to push the images to ACR again so that the newly tagged v1 images are pushed. Then refresh one of the repositories to see the two versions of the image now appear.

    ![In this screenshot, fabmedical/content-api is selected under Repositories, and the Tags blade appears on the right. In the Tags blade, latest and v1 appear under Tags.](media/image71.png)

12. Run the following commands to pull an image from the repository. Note that the default behavior is to pull images tagged with "latest." You can pull a specific version using the version tag. Also, note that since the images already exist on the build agent, nothing is downloaded.

    ```bash
    docker pull [LOGINSERVER]/content-web
    docker pull [LOGINSERVER]/content-web:v1
    ```

13. Next we will use Azure DevOps to automate the process for creating images and pushing to ACR. First, you need to add an Azure Service Principal to your Azure DevOps account. Login to your Azure DevOps account and click the Project settings gear icon to access your settings. Then select Service connections.

14. Choose "+ New service connection". Then pick "Azure Resource Manager" from the menu.

    ![A screenshot of the New service connection selection in Azure DevOps with Azure Resource Manager highlighted.](media/vso-service-connection-settings.png)

15. Select the link indicated in the screenshot below to access the advanced settings.

    ![A screenshot of the Add Azure Resource Manager dialog where you can enter your subscription information.](media/vso-service-connection-settings2.png)

16. Enter the required information using the service principal information you created before the lab.

    > **Note:** I you don't have your Subscription information handy you can view it using `az account show` on your **local** machine (not the build agent). If you are using pre-provisioned environment, Service Principal is already pre-created and you can use the already shared Service Principal details.

    - **Connection name**: azurecloud-sol

    - **Environment**: AzureCloud

    - **Subscription ID**: `id` from `az account show` output

    - **Subscription Name**: `name` from `az account show` output

    - **Service Principal Client ID**: `appId` from service principal output.

    - **Service Principal Key**: `password` from service principal output.

    - **Tenant ID**: `tenant` from service principal output.

    ![A screenshot of the Add Resource Manager Add Service Endpoint dialog.](media/Ex1-Task7.16.png)

17. Select "Verify connection" then select "OK".

    >**Note**: If the connection does not verify, then recheck and reenter the required data.

18. Now create your first build. Select "Pipelines", then select "New pipeline"

    ![A screenshot of Azure DevOps build definitions.](media/Ex1-Task7.18.png)

19. Choose the content-web repository and accept the other defaults.

    ![A screenshot of the source selection showing Azure DevOps highlighted.](media/Ex1-Task7.19.png)

20. Next, search for "Docker" templates and choose "Docker Container" then select "Apply".

    ![A screenshot of template selection showing Docker Container selected.](media/Ex1-Task7.20.png)

21. Change the build name to "content-web-Container-CI".

    ![A screenshot of the dialog where you can enter the name for the build.](media/Ex1-Task7.21.png)

22. Select "Build an image":

    - **Azure subscription**: Choose "azurecloud-sol".

    - **Azure Container Registry**: Choose your ACR instance by name.

    - **Include Latest Tag**: Checked

    ![A screenshot of the dialog where you can describe the image build.](media/Ex1-Task7.22.png)

23. Select "Push an image".

    - **Azure subscription**: Choose "azurecloud-sol".

    - **Azure Container Registry**: Choose your ACR instance by name.

    - **Include Latest Tag**: Checked

    ![A screenshot of the dialog where you can describe the image push.](media/Ex1-Task7.23.png)

24. Select "Triggers".

    - **Enable continuous integration**: Checked

    - **Batch changes while a build is in progress**: Checked

    ![A screenshot of the dialog where you can setup triggers.](media/Ex1-Task7.24.png)

25. Select "Save & queue"; then select "Save & queue" two more times to kick off the first build.

    ![A screenshot showing the queued build.](media/Ex1-Task7.26.png)

26. While that build runs, create the content-api build. Select "Builds", then select "+ New", and then select "New build pipeline". Configure content-api by following the same steps used to configure content-web.

27. While the content-api build runs, setup one last build for content-init by following the same steps as the previous two builds.

28. Visit your ACR instance in the Azure portal, you should see new containers tagged with the Azure DevOps build number.

    ![A screenhot of the container images in ACR.](media/Ex1-Task7.28.png)

## Exercise 2: Deploy the solution to Azure Kubernetes Service

**Duration**: 30 minutes

In this exercise, you will connect to the Azure Kubernetes Service cluster you created before the hands-on lab and deploy the Docker application to the cluster using Kubernetes.

### Task 1: Tunnel into the Azure Kubernetes Service cluster

In this task, you will gather the information you need about your Azure Kubernetes Service cluster to connect to the cluster and execute commands to connect to the Kubernetes management dashboard from your local machine.

1. Open your WSL console (close the connection to the build agent if you are connected). From this WSL console, ensure that you installed the Azure CLI correctly by running the following command:

    ```bash
    az --version
    ```

    -  This should produce output similar to this:

    ![In this screenshot of the WSL console, example output from running az --version appears. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](media/image73.png)

    - If the output is not correct, review your steps from the instructions in Task 11: Install Azure CLI from the instructions before the lab exercises.

2. Also, check the installation of the Kubernetes CLI (kubectl) by running the following command:

    ```bash
    kubectl version
    ```

    - This should produce output similar to this:

    ![In this screenshot of the WSL console, kubectl version has been typed and run at the command prompt, which displays Kubernetes CLI client information.](media/image74.png)

    - If the output is not correct, review the steps from the instructions in Task 12: Install Kubernetes CLI from the instructions before the lab exercises.

3. Once you have installed and verified Azure CLI and Kubernetes CLI, login with the following command, and follow the instructions to complete your login as presented:

    ```bash
    az login
    ```

4. Verify that you are connected to the correct subscription with the following command to show your default subscription:

    ```bash
    az account show
    ```

    a. If you are not connected to the correct subscription, list your subscriptions and then set the subscription by its id with the following commands (similar to what you did in cloud shell before the lab):

    ```bash
    az account list
    az account set --subscription {id}
    ```

5. Configure kubectl to connect to the Kubernetes cluster:

    ```bash
    az aks get-credentials --name fabmedical-SUFFIX --resource-group fabmedical-SUFFIX
    ```

6. Test that the configuration is correct by running a simple kubectl command to produce a list of nodes:

    ```bash
    kubectl get nodes
    ```

    ![In this screenshot of the WSL console, kubectl get nodes has been typed and run at the command prompt, which produces a list of nodes.](media/image75.png)

7. Since the AKS cluster uses RBAC, a ClusterRoleBinding must be created before you can correctly access the dashboard. To create the required binding, execute the command bellow:

    ```bash
    kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
    ```

8. Create an SSH tunnel linking a local port (8001) on your machine to port 80 on the management node of the cluster. Execute the command below replacing the values as follows:

   > **Note**: After you run this command, it may work at first and later lose its connection, so you may have to run this again to reestablish the connection. If the Kubernetes dashboard becomes unresponsive in the browser this is an indication to return here and check your tunnel or rerun the command.

    ```bash
    az aks browse --name fabmedical-SUFFIX --resource-group fabmedical-SUFFIX
    ```

    ![In this screenshot of the WSL console, the output of the above command produces output similar to the following: Password for private key: Proxy running on 127.0.0.1:8001/ui Press CTRL+C to close the tunnel \... Starting to server on 127.0.0.1:8001](media/image76.png)

9. Open a browser window and access the Kubernetes management dashboard at the Services view. To reach the dashboard, you must access the following address:

    ```bash
    http://localhost:8001
    ```

10. If the tunnel is successful, you will see the Kubernetes management dashboard.

    ![This is a screenshot of the Kubernetes management dashboard. Overview is highlighted on the left, and at right, kubernetes has a green check mark next to it. Below that, default-token-s6kmc is listed under Secrets.](media/image77.png)

### Task 2: Deploy a service using the Kubernetes management dashboard

In this task, you will deploy the API application to the Azure Kubernetes Service cluster using the Kubernetes dashboard.

1. From the Kubernetes dashboard, select Create in the top right corner.

2. From the Resource creation view, select Create an App.

    ![This is a screenshot of the Deploy a Containerized App dialog box. Specify app details below is selected, and the fields have been filled in with the information that follows. At the bottom of the dialog box is a SHOW ADVANCED OPTIONS link.](media/image78.png)

    - Enter "api" for the App name.

    - Enter [LOGINSERVER]/content-api for the Container Image, replacing [LOGINSERVER] with your ACR login server, such as fabmedicalsol.azurecr.io.

    - Set Number of pods to 1.

    - Set Service to "Internal".

    - Use 3001 for Port and 3001 for Target port.

3. Select SHOW ADVANCED OPTIONS-----

    - Enter 0.125 for the CPU requirement.

    - Enter 128 for the Memory requirement.

    ![In the Advanced options dialog box, the above information has been entered. At the bottom of the dialog box is a Deploy button.](media/image79.png)

4. Select Deploy to initiate the service deployment based on the image. This can take a few minutes. In the meantime, you will be redirected to the Overview dashboard. Select the API deployment from the Overview dashboard to see the deployment in progress.

    ![This is a screenshot of the Kubernetes management dashboard. Overview is highlighted on the left, and at right, a red arrow points to the api deployment.](media/image80.png)

5. Kubernetes indicates a problem with the api Replica Set.  Select the log icon to investigate.

    ![This screenshot of the Kubernetes management dashboard shows an error with the replica set.](media/Ex2-Task1.5.png)

6. The log indicates that the content-api application is once again failing because it cannot find a mongodb instance to communicate with.  You will resolve this issue by migrating your data workload to CosmosDb.

    ![This screenshot of the Kubernetes management dashboard shows logs output for the api container.](media/Ex2-Task1.6.png)

7. Open the Azure portal in your browser and click "+ Create a resource".  Search for "Azure Cosmos DB", select the result and click "Create".

    ![A screenshot of the Azure Portal selection to create Azure Cosmos DB.](media/Ex2-Task1.7.1.png)

8. Configure Azure Cosmos DB as follows and click "Review + create" and then click "Create":

    - **Subscription**: Use the same subscription you have used for all your other work.

    - **Resource Group**: fabmedical-SUFFIX

    - **Account Name**: fabmedical-SUFFIX

    - **API**: Azure Cosmos DB for MongoDB API

    - **Location**: Choose the same region that you did before.

    - **Geo-redundancy**: Enabled (checked)

    ![A screenshot of the Azure Portal settings blade for Cosmos DB.](media/Ex2-Task1.8.1.png)

9. Navigate to your resource group and find your new CosmosDb resource.  Click on the CosmosDb resource to view details.

    ![A screenshot of the Azure Portal showing the Cosmos DB among existing resources.](media/Ex2-Task1.9.png)

10. Under "Quick Start" select the "Node.js" tab and copy the Node 3.0 connection string.

    ![A screenshot of the Azure Portal showing the quick start for setting up Cosmos DB with MongoDB API.](media/Ex2-Task1.10.png)

11. Update the provided connection string with a database "contentdb" and a replica set "globaldb".

    >**Note**: User name and password redacted for brevity.

    ```text
    mongodb://<USERNAME>:<PASSWORD>@fabmedical-sol2.documents.azure.com:10255/contentdb?ssl=true&replicaSet=globaldb
    ```

12. You will setup a Kubernetes secret to store the connection string, and configure the content-api application to access the secret.  First, you must base64 encode the secret value.  Open your WSL window and use the following command to encode the connection string and then, copy the output.

    ```bash
    echo -n "<connection string value>" | base64 -w 0
    ```

13. Return to the Kubernetes UI in your browser and click "+ Create".  Update the following YAML with the encoded connection string from your clipboard, paste the YAML data into the create dialog and click "Upload".

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: mongodb
    type: Opaque
    data:
        db: <base64 encoded value>
    ```

    ![A screenshot of the Kubernetes management dashboard showing the YAML file for creating a deployment.](media/Ex2-Task1.13.png)

14. Scroll down in the Kubernetes dashboard until you can see "Secrets" in the left-hand menu.  Click it.

    ![A screenshot of the Kubernetes management dashboard showing secrets.](media/Ex2-Task1.14.png)

15. View the details for the "mongodb" secret.  Click the eyeball icon to show the secret.

    ![A screenshot of the Kubernetes management dashboard showing the value of a secret.](media/Ex2-Task1.15.png)

16. Next, download the api deployment configuration using the following command in your WSL window:

    ```bash
    kubectl get -o=yaml --export=true deployment api > api.deployment.yml
    ```

17. Edit the downloaded file:

    ```bash
    vi api.deployment.yml
    ```

       - Add the following environment configuration to the container spec, below the "image" property:

    ```yaml
    - image: [LOGINSERVER].azurecr.io/fabmedical/content-api
      env:
        - name: MONGODB_CONNECTION
          valueFrom:
            secretKeyRef:
              name: mongodb
              key: db
    ```

    ![A screenshot of the Kubernetes management dashboard showing part of the deployment file.](media/Ex2-Task1.17.png)

18. Update the api deployment by using `kubectl` to apply the new configuration.

    ```bash
    kubectl apply -f api.deployment.yml
    ```

19. Select "Deployments" then "api" to view the api deployment. It now has a healthy instance and the logs indicate it has connected to mongodb.

    ![A screenshot of the Kubernetes management dashboard showing logs output.](media/Ex2-Task1.19.png)

### Task 3: Deploy a service using kubectl

In this task, deploy the web service using `kubectl`.

1. Open a **new** WSL console.

2. Create a text file called web.deployment.yml using Vim and press the "i" key to go into edit mode.

    ```bash
    vi web.deployment.yml
    <i>
    ```

3. Copy and paste the following text into the editor:

    >**Note**: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters. If the code does not paste correctly, you can issue a ":set paste" command before pasting.

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

4. Edit this file and update the [LOGINSERVER] entry to match the name of your ACR login server.

5. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

6. Create a text file called web.service.yml using Vim, and press the "i" key to go into edit mode.

    ```bash
    vi web.service.yml
    ```

7. Copy and paste the following text into the editor:

    >**Note**: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters.

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

8. Press the Escape key and type ":wq"; then press the Enter key to save and close the file.

9. Type the following command to deploy the application described by the YAML files. You will receive a message indicating the items kubectl has created a web deployment and a web service.

    ```bash
    kubectl create --save-config=true -f web.deployment.yml -f web.service.yml
    ```

    ![In this screenshot of the WSL console, kubectl apply -f kubernetes-web.yaml has been typed and run at the command prompt. Messages about web deployment and web service creation appear below.](media/image93.png)

10. Return to the browser where you have the Kubernetes management dashboard open. From the navigation menu, select Services view under Discovery and Load Balancing. From the Services view, select the web service and from this view, you will see the web service deploying. This deployment can take a few minutes. When it completes you should be able to access the website via an external endpoint.

    ![In the Kubernetes management dashboard, Services is selected below Discovery and Load Balancing in the navigation menu. At right are three boxes that display various information about the web service deployment: Details, Pods, and Events. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](media/image94.png)

11. Select the speakers and sessions links. Note that no data is displayed, although we have connected to our CosmosDb instance, there is no data loaded. You will resolve this by running the content-init application as a Kubernetes Job in Task 5.

    ![A screenshot of the web site showing no data displayed.](media/Ex2-Task3.11.png)

### Task 4: Deploy a service using a Helm chart

In this task, deploy the web service using a helm chart.

1. From the Kubernetes dashboard, under "Workloads", select "Deployments".

2. Click the triple vertical dots on the right of the "web" deployment and then select "Delete". When prompted, click "Delete" again.

    ![A screenshot of the Kubernetes management dashboard showing how to delete a deployment.](media/Ex2-Task4.2.png)

3. From the Kubernetes dashboard, under "Discovery and Load Balancing", select "Services".

4. Click the triple vertical dots on the right of the "web" service and then select "Delete". When prompted, click "Delete" again.

    ![A screenshot of the Kubernetes management dashboard showing how to delete a deployment.](media/Ex2-Task4.4.png)

5. Open a **new** WSL console.

6. Create a text file called rbac-config.yaml using Vim and press the "i" key to go into edit mode.

    ```bash
    vi rbac-config.yaml
    <i>
    ```

7. Copy and paste the following text into the editor:

    >**Note**: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters. If the code does not paste correctly, you can issue a ":set paste" command before pasting.

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: tiller
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: tiller
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
      - kind: ServiceAccount
        name: tiller
        namespace: kube-system
    ```

8. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

9. Type the following command to create the service account needed by Tiller (the Helm server part).

    ```bash
    kubectl create -f rbac-config.yaml
    ```

10. Type the following command to initialize Helm using the previously service account setup.

    ```bash
    helm init --service-account tiller
    ```

11. We will use the `helm create` command to scaffold out a chart implementation that we can build on. Use the following commands to create a new chart named `web` in a new directory:

    ```bash
    cd FabMedical/content-web
    mkdir charts
    cd charts
    helm create web
    ```

12. We now need to update the generated scaffold to match our requirements. We will first update the file named `values.yaml`.

    ```bash
    cd web
    vi values.yaml
    <i>
    ```

13. Search for the `image` definition and update the values so that they match the following:

    ```yaml
    image:
      repository: [LOGINSERVER].azurecr.io/content-web
      tag: latest
      pullPolicy: Always
    ```

14. Search for `nameOverride` and `fullnameOverride` entries and update the values so that they match the following:

    ```yaml
    nameOverride: "web"
    fullnameOverride: "web"
    ```

15. Search for the `service` definition and update the values so that they match the following:

    ```yaml
    service:
      type: LoadBalancer
      port: 80
    ```

16. Search for the `resources` definition and update the values so that they match the following:

    ```yaml
    resources:
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
      # limits:
      #  cpu: 100m
      #  memory: 128Mi
      requests:
        cpu: 1000m
        memory: 128Mi
    ```

17. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

18. We will now update the file named `deployment.yaml`.

    ```bash
    cd templates
    vi deployment.yaml
    <i>
    ```

19. Search for the `containers` definition and update the values so that they match the following:

    ```yaml
    containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
          - name: http
            containerPort: 3000
            protocol: TCP
        env:
        - name: CONTENT_API_URL
          value: http://api:3001
        livenessProbe:
          httpGet:
            path: /
            port: 3000
    ```

20. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

21. We will now update the file named `service.yaml`.

    ```bash
    vi service.yaml
    <i>
    ```

22. Search for the `ports` definition and update the values so that they match the following:

    ```yaml
    ports:
      - port: {{ .Values.service.port }}
        targetPort: 3000
        protocol: TCP
        name: http
    ```

23. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

24. The chart is now setup to run our web container. Type the following command to deploy the application described by the YAML files. You will receive a message indicating that helm has created a web deployment and a web service.

    ```bash
    cd ../..
    helm install --name web ./web
    ```

    ![In this screenshot of the WSL console, helm install --name web ./web has been typed and run at the command prompt. Messages about web deployment and web service creation appear below.](media/Ex2-Task4.24.png)

25. Return to the browser where you have the Kubernetes management dashboard open. From the navigation menu, select Services view under Discovery and Load Balancing. From the Services view, select the web service and from this view, you will see the web service deploying. This deployment can take a few minutes. When it completes you should be able to access the website via an external endpoint.

    ![In the Kubernetes management dashboard, Services is selected below Discovery and Load Balancing in the navigation menu. At right are three boxes that display various information about the web service deployment: Details, Pods, and Events. At this time, we are unable to capture all of the information in the window. Future versions of this course should address this.](media/image94.png)

26. Select the speakers and sessions links. Note that no data is displayed, although we have connected to our CosmosDb instance, there is no data loaded. You will resolve this by running the content-init application as a Kubernetes Job.

    ![A screenshot of the web site showing no data displayed.](media/Ex2-Task3.11.png)

27. We will now persist the changes into the repository. Execute the following commands:

    ```bash
    cd ..
    git pull
    git add charts/
    git commit -m "Helm chart added."
    git push
    ```

### Task 5: Initialize database with a Kubernetes Job

In this task, you will use a Kubernetes Job to run a container that is meant to execute a task and terminate, rather than run all the time.

1. In your WSL window create a text file called init.job.yml using Vim, and press the "i" key to go into edit mode.

    ```bash
    vi init.job.yml
    ```

2. Copy and paste the following text into the editor:

   > **Note**: Be sure to copy and paste only the contents of the code block carefully to avoid introducing any special characters.

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

3. Edit this file and update the [LOGINSERVER] entry to match the name of your ACR login server.

4. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

5. Type the following command to deploy the job described by the YAML. You will receive a message indicating the kubectl has created an init "job.batch".

    ```bash
    kubectl create --save-config=true -f init.job.yml
    ```

6. View the Job by selecting "Jobs" under "Workloads" in the Kubernetes UI.

    ![A screenshot of the Kubernetes management dashboard showing jobs.](media/Ex2-Task5.6.png)

7. Select the log icon to view the logs.

    ![A screenshot of the Kubernetes management dashboard showing log output.](media/Ex2-Task5.7.png)

8. Next view your CosmosDb instance in the Azure portal and see that it now contains two collections.

    ![A screenshot of the Azure Portal showing Cosmos DB collections.](media/Ex2-Task5.8.png)

### Task 6: Test the application in a browser

In this task, you will verify that you can browse to the web service you have deployed and view the speaker and content information exposed by the API service.

1. From the Kubernetes management dashboard, in the navigation menu, select the Services view under Discovery and Load Balancing.

2. In the list of services, locate the external endpoint for the web service and select this hyperlink to launch the application.

    ![In the Services box, a red arrow points at the hyperlinked external endpoint for the web service.](media/image112.png)

3. You will see the web application in your browser and be able to select the Speakers and Sessions links to view those pages without errors. The lack of errors means that the web application is correctly calling the API service to show the details on each of those pages.

    ![In this screenshot of the Contoso Neuro 2017 web application, Speakers has been selected, and sample speaker information appears at the bottom.](media/image114.png)

    ![In this screenshot of the Contoso Neuro 2017 web application, Sessions has been selected, and sample session information appears at the bottom.](media/image115.png)

### Task 7: Configure Continuous Delivery to the Kubernetes Cluster

In this task, you will update a Build Pipeline and configure a Release Pipeline in your Azure DevOps account so that when new images are pushed to the ACR, they get deployed to the AKS cluster.

1. We will use Azure DevOps to automate the process for deploying the web image to the AKS cluster. Login to your Azure DevOps account, access the project you created earlier, then select "Pipelines", and then select "Builds".

2. From the builds list, select the `content-web-Container-CI` build and then click `Edit.`

    ![A screenshot with the `content-web-Container-CI` build selected and the `Edit` button highlighted.](media/Ex2-Task7.2.png)

3. In the `Agent job 1` row, click `+`.

    ![A screenshot that shows how to add a task to a build pipeline.](media/Ex2-Task7.3.png)

4. Search for "Helm", select "Helm tool installer" and then click "Add".

    ![A screenhost that shows adding the "Helm tool installer" task.](media/Ex2-Task7.4.png)

5. Still using the same search, select "Package and deploy Helm charts" and then click "Add".

    ![A screenhost that shows adding the "Package and deploy Helm charts" task.](media/Ex2-Task7.5.png)

6. Search for "Publish Artifacts", select "Publish Build Artifacts" and then click "Add".

    ![A screenhost that shows adding the "Publish Build Artifacts" task.](media/Ex2-Task7.6.png)

7. Select "helm ls":

    - **Azure subscription**: Choose "azurecloud-sol".

    - **Resource group**: Choose your resource group by name.

    - **Kubernetes cluster**: Choose your AKS instance by name.

    - **Command**: Select "package".

    - **Chart Path**: Select "charts/web".

    ![A screenshot of the dialog where you can describe the helm package.](media/Ex2-Task7.7.png)

8. Select "Publish Artifact: drop":

    - **Path to publish**: Ensure that the value matches "$(Build.ArtifactStagingDirectory)".

    - **Artifact name**: Update the value to "chart".

    ![A screenshot of the dialog where you can describe the publish artifact.](media/Ex2-Task7.8.png)

9. Select "Save & queue"; then select "Save & queue" two more times to kick off the build.

10. Now create your first release. Select "Pipelines, then select "Releases", and then select "New pipeline".

    ![A screenshot of Azure DevOps release definitions.](media/Ex2-Task7.10.png)

11. Search for "Helm" templates and choose "Deploy an application to a Kubernetes cluster by using its Helm chart." then select "Apply".

    ![A screenshot of template selection showing Deploy an application to a Kubernetes cluster by using its Helm chart selected.](media/Ex2-Task7.11.png)

12. Change the release name to "content-web-AKS-CD".

    ![A screenshot of the dialog where you can enter the name for the release.](media/Ex2-Task7.12.png)

13. Select "+ Add an artifact".

    ![A screenshot of the release artifacts.](media/Ex2-Task7.13.png)

14. Setup the artifact:

    - **Project**: fabmedical

    - **Source (build pipeline)**: content-web-Container-CI

    - **Default version**: select "Latest"

    ![A screenshot of the add an artifact dialog.](media/Ex2-Task7.14.png)

15. Select the "Continuous deployment trigger".

    ![A screenshot of the continuous deployment trigger.](media/Ex2-Task7.15.png)

16. Enable the continuous deployment.

    ![A screenshot of the continuous deployment being enabled.](media/Ex2-Task7.16.png)

17. In "Stage 1", click "1 job, 3 tasks".

    ![A screenshot of the Stage 1 current status.](media/Ex2-Task7.17.png)

18. Setup the stage:

    - **Azure subscription**: Choose "azurecloud-sol".

    - **Resource group**: Choose your resource group by name.

    - **Kubernetes cluster**: Choose your AKS instance by name.

    ![A screenshot of ](media/Ex2-Task7.18.png)

19. Select "helm init":

    - **Command**: select "init"

    - **Arguments**: Update the value to "--service-account tiller"

    ![A screenshot of ](media/Ex2-Task7.19.png)

20. Select "helm upgrade":

    - **Command**: select "upgrade"
    - **Chart Type**: select "File Path"
    - **Chart Path**: select the location of the chart artifact
    - **Release Name**: web
    - **Set values**: image.tag=$(Build.BuildId)

    ![A screenshot of ](media/Ex2-Task7.20.png)

21. Select "Save" and then "OK".

22. Select "+ Release", then "+ Create a release" and then "Create" to kick off the release.

### Task 8: Review Azure Monitor for Containers

In this task, you will access and review the various logs and dashboards made available by Azure Monitor for Containers.

1. From the Azure Portal, select the resource group you created named fabmedical-SUFFIX, and then select your AKS cluster.

    ![In this screenshot, the resource group was previously selected and the AKS cluster is selected.](media/Ex2-Task8.1.png)

2. From the Monitoring blade, select **Insights**.

    ![In the Monitoring blade, Insights is highlighted.](media/Ex2-Task8.2.png)

3. Review the various available dashboards and a deeper look at the various metrics and logs available on the Cluster, Cluster Nodes, Cluster Controllers and deployed Containers.

    ![In this screenshot, the dashboards and blades are shows.](media/Ex2-Task8.3.png)

4. To review the Containers dashboards and see more detailed information about each container click on containers tab.

    ![In this screenshot, the various containers information is shown.](media/monitor_1.png)

5. Now filter by container name and search for the web containers, you will see all the containers created in the Kubernetes cluster with the pod names, you can compare the names with those in the kubernetes dashboard.  

    ![In this screenshot, the containers are filtered by container named web.](media/monitor_3.png)

6. By default, the CPU Usage metric will be selected displaying all cpu information for the selected container, to switch to another metric open the metric dropdown list and select a different metric.

    ![In this screenshot, the various metric options are shown.](media/monitor_2.png)

7. Upon selecting any pod, all the information related to the selected metric will be displayed on the right panel, and that would be the case when selecting any other metric, the details will be displayed on the right panel for the selected pod.

    ![In this screenshot, the pod cpu usage details are shown.](media/monitor_4.png)

8. To display the logs for any container simply select it and view the right panel and you will find "View Container Log" link which will list all logs for this specific container.

    ![Container Log view](media/monitor_5.png)

9. For each log entry you can display more information by expanding the log entry to view the below details.

    ![Log entry details](media/monitor_6.png)
    
## Exercise 3: Scale the application and test HA

**Duration**: 20 minutes

At this point you have deployed a single instance of the web and API service containers. In this exercise, you will increase the number of container instances for the web service and scale the front end on the existing cluster.

### Task 1: Increase service instances from the Kubernetes dashboard

In this task, you will increase the number of instances for the API deployment in the Kubernetes management dashboard. While it is deploying, you will observe the changing status.

1. From the navigation menu, select Workloads\>Deployments, and then select the API deployment.

2. Select SCALE.

    ![In the Workloads \> Deployments \> api bar, the Scale icon is highlighted.](media/image89.png)

3. Change the number of pods to 2, and then select **OK**.

    ![In the Scale a Deployment dialog box, 2 is entered in the Desired number of pods box.](media/image116.png)

    >**Note: If the deployment completes quickly, you may not see the deployment Waiting states in the dashboard as described in the following steps**.

4. From the Replica Set view for the API, you'll see it is now deploying and that there is one healthy instance and one pending instance.

    ![Replica Sets is selected under Workloads in the navigation menu on the left, and at right, Pods status: 1 pending, 1 running is highlighted. Below that, a red arrow points at the API deployment in the Pods box.](media/image117.png)

5. From the navigation menu, select Deployments from the list. Note that the api service has a pending status indicated by the grey timer icon and it shows a pod count 1 of 2 instances (shown as "1/2").

    ![In the Deployments box, the api service is highlighted with a grey timer icon at left and a pod count of 1/2 listed at right.](media/image118.png)

6. From the Navigation menu, select Workloads. From this view, note that the health overview in the right panel of this view. You'll see the following:

    - One deployment and one replica set are each healthy for the api service.

    - One replica set is healthy for the web service.

    - Three pods are healthy.

7. Navigate to the web application from the browser again. The application should still work without errors as you navigate to Speakers and Sessions pages

    - Navigate to the /stats.html page. You'll see information about the environment including:

        - **webTaskId:** The task identifier for the web service instance.

        - **taskId:** The task identifier for the API service instance.

        - **hostName:** The hostname identifier for the API service instance.

        - **pid:** The process id for the API service instance.

        - **mem:** Some memory indicators returned from the API service instance.

        - **counters:** Counters for the service itself, as returned by the API service instance.

        - **uptime:** The up time for the API service.

    - Refresh the page in the browser, and you can see the hostName change between the two API service instances. The letters after "api-{number}-" in the hostname will change.

### Task 2: Increase service instances beyond available resources

In this task, you will try to increase the number of instances for the API service container beyond available resources in the cluster. You will observe how Kubernetes handles this condition and correct the problem.

1. From the navigation menu, select Deployments. From this view, select the API deployment.

2. Configure the deployment to use a fixed host port for initial testing. Select Edit.

    ![In the Workloads \> Deployments \> api bar, the Edit icon is highlighted.](media/image81.png)

3. In the Edit a Deployment dialog, you will see a list of settings shown in JSON format. Use the copy button to copy the text to your clipboard.

    ![Screenshot of the Edit a Deployment dialog box.](media/image82.png)

4. Paste the contents into the text editor of your choice (notepad is shown here, MacOS users can use TextEdit).

    ![Screenshot of the Edit a Deployment contents pasted into Notepad text editor.](media/image83.png)

5. Scroll down about half way to find the node "$.spec.template.spec.containers[0]", as shown in the screenshot below.

    ![Screenshot of the deployment JSON code, with the \$.spec.template.spec.containers\[0\] section highlighted.](media/image84.png)

6. The containers spec has a single entry for the API container at the moment. You'll see that the name of the container is "api" - this is how you know you are looking at the correct container spec.

    - Add the following JSON snippet below the "name" property in the container spec:

    ```json
    "ports": [
        {
        "containerPort": 3001,
        "hostPort": 3001
        }
    ],
    ```

    - Your container spec should now look like this:

    ![Screenshot of the deployment JSON code, with the \$.spec.template.spec.containers\[0\] section highlighted, showing the updated values for containerPort and hostPost, both set to port 3001.](media/image85.png)

7. Copy the updated JSON document from notepad into the clipboard. Return to the Kubernetes dashboard, which should still be viewing the "api" deployment.

    - Select Edit.

    ![In the Workloads \> Deployments \> api bar, the Edit icon is highlighted.](media/image87.png)

    - Paste the updated JSON document.

    - Select Update.

    ![UPDATE is highlighted in the Edit a Deployment dialog box.](media/image88.png)

8. From the API deployment view, select **Scale**.

    ![In the Workloads \> Deployments \> api bar, the Scale icon is highlighted.](media/image89.png)

9. Change the number of pods to 4 and select **OK**.

    ![In the Scale a Deployment dialog box, 4 is entered in the Desired number of pods box.](media/image119.png)

10. From the navigation menu, select Services view under Discovery and Load Balancing. Select the api service from the Services list. From the api service view, you'll see it has two healthy instances and two unhealthy (or possibly pending depending on timing) instances.

    ![In the api service view, various information is displayed in the Details box and in the Pods box.](media/image120.png)

11. After a few minutes, select Workloads from the navigation menu. From this view, you should see an alert reported for the api deployment.

    ![Workloads is selected in the navigation menu. At right, an exclamation point (!) appears next to the api deployment listing in the Deployments box.](media/image121.png)

    >**Note**: This message indicates that there weren't enough available resources to match the requirements for a new pod instance. In this case, this is because the instance requires port 3001, and since there are only 2 nodes available in the cluster, only two api instances can be scheduled. The third and fourth pod instances will wait for a new node to be available that can run another instance using that port.

12. Reduce the number of requested pods to 2 using the Scale button.

13. Almost immediately, the warning message from the Workloads dashboard should disappear, and the API deployment will show 2/2 pods are running.

    ![Workloads is selected in the navigation menu. A green check mark now appears next to the api deployment listing in the Deployments box at right.](media/image122.png)

### Task 3: Restart containers and test HA

In this task, you will restart containers and validate that the restart does not impact the running service.

1. From the navigation menu on the left, select Services view under Discovery and Load Balancing. From the Services list, select the external endpoint hyperlink for the web service, and visit the stats page by adding /stats.html to the URL. Keep this open and handy to be refreshed as you complete the steps that follow.

    ![In the Services box, a red arrow points at the hyperlinked external endpoint for the web service. ](media/image112.png)

    ![The Stats page is visible in this screenshot of the Contoso Neuro 2017 web application.](media/image123.png)

2. From the navigation menu, select Workloads>Deployments. From Deployments list, select the API deployment.

    ![A red arrows points at Deployments, which is selected below Workloads in the navigation menu. At right, the API deployment is highlighted in the Deployments box.](media/image124.png)

3. From the API deployment view, select **Scale** and from the dialog presented, and enter 4 for the desired number of pods. Select **OK**.

4. From the navigation menu, select Workloads>Replica Sets. Select the api replica set and, from the Replica Set view, you will see that two pods cannot deploy.

    ![Replica Sets is selected under Workloads in the navigation menu on the left. On the right are the Details and Pods boxes. In the Pods box, two pods have exclamation point (!) alerts and messages indicating that they cannot deploy.](media/image125.png)

5. Return to the browser tab with the web application stats page loaded. Refresh the page over and over. You will not see any errors, but you will see the api host name change between the two api pod instances periodically. The task id and pid might also change between the two api pod instances.

    ![On the Stats page in the Contoso Neuro 2017 web application, two different api host name values are highlighted.](media/image126.png)

6. After refreshing enough times to see that the hostName value is changing, and the service remains healthy, return to the Replica Sets view for the API. From the navigation menu, select Replica Sets under Workloads and select the API replica set.

7. From this view, take note that the hostName value shown in the web application stats page matches the pod names for the pods that are running.

    ![Two different pod names are highlighted in the Pods box, which match the values from the previous Stats page.](media/image127.png)

8. Note the remaining pods are still pending, since there are not enough port resources available to launch another instance. Make some room by deleting a running instance. Select the context menu and choose Delete for one of the healthy pods.

    ![A red arrow points at the context menu for the previous pod names that were highlighted in the Pod box. Delete is selected and highlighted in the submenu.](media/image128.png)

9. Once the running instance is gone, Kubernetes will be able to launch one of the pending instances. However, because you set the desired size of the deploy to 4, Kubernetes will add a new pending instance. Removing a running instance allowed a pending instance to start, but in the end, the number of pending and running instances is unchanged.

    ![The first row of the Pods box is highlighted, and the pod has a green check mark and is running.](media/image129.png)

10. From the navigation menu, select Deployments under Workloads. From the view's Deployments list select the API deployment.

11. From the API Deployment view, select Scale and enter 1 as the desired number of pods. Select OK.

    ![In the Scale a Deployment dialog box, 1 is entered in the Desired number of pods box.](media/image130.png)

12. Return to the web site's stats.html page in the browser and refresh while this is scaling down. You'll notice that only one API host name shows up, even though you may still see several running pods in the API replica set view. Even though several pods are running, Kubernetes will no longer send traffic to the pods it has selected to scale down. In a few moments, only one pod will show in the API replica set view.

    ![Replica Sets is selected under Workloads in the navigation menu on the left. On the right are the Details and Pods boxes. Only one API host name, which has a green check mark and is listed as running, appears in the Pods box.](media/image131.png)

13. From the navigation menu, select Workloads. From this view, note that there is only one API pod now.

    ![Workloads is selected in the navigation menu on the left. On the right are the Deployment, Pods, and Replica Sets boxes.](media/image132.png)

## Exercise 4: Setup load balancing and service discovery

**Duration**: 45 minutes

In the previous exercise we introduced a restriction to the scale properties of the service. In this exercise, you will configure the api deployments to create pods that use dynamic port mappings to eliminate the port resource constraint during scale activities.

Kubernetes services can discover the ports assigned to each pod, allowing you to run multiple instances of the pod on the same agent node --- something that is not possible when you configure a specific static port (such as 3001 for the API service).

### Task 1: Scale a service without port constraints

In this task, we will reconfigure the API deployment so that it will produce pods that choose a dynamic hostPort for improved scalability.

1. From the navigation menu select Deployments under Workloads. From the view's Deployments list select the API deployment.

2. Select Edit.

3. From the Edit a Deployment dialog, do the following:

    - Scroll to the first spec node that describes replicas as shown in the screenshot. Set the value for replicas to 4.

    - Within the replicas spec, beneath the template node, find the "api" containers spec as shown in the screenshot. Remove the hostPort entry for the API container's port mapping.

        ![This is a screenshot of the Edit a Deployment dialog box with various displayed information about spec, selector, and template. Under the spec node, replicas: 4 is highlighted. Further down, ports are highlighted.](media/image137.png)

4. Select **Update**. New pods will now choose a dynamic port.

5. The API service can now scale to 4 pods since it is no longer constrained to an instance per node -- a previous limitation while using port 3001.

    ![Replica Sets is selected under Workloads in the navigation menu on the left. On the right, four pods are listed in the Pods box, and all have green check marks and are listed as Running.](media/image138.png)

6. Return to the browser and refresh the stats.html page. You should see all 4 pods serve responses as you refresh.

### Task 2: Update an external service to support dynamic discovery with a load balancer

In this task, you will update the web service so that it supports dynamic discovery through the Azure load balancer.

1. From the navigation menu, select Deployments under Workloads. From the view's Deployments list select the web deployment.

2. Select **Edit**.

3. From the Edit a Deployment dialog, scroll to the web containers spec as shown in the screenshot. Remove the hostPort entry for the web container's port mapping.

    ![This is a screenshot of the Edit a Deployment dialog box with various displayed information about spec, containers, ports, and env. The ports node, containerPort: 3001 and protocol: TCP are highlighted.](media/image140.png)

4. Select **Update**.

5. From the web Deployments view, select **Scale**. From the dialog presented enter 4 as the desired number of pods and select **OK**.

6. Check the status of the scale out by refreshing the web deployment's view. From the navigation menu, select Deployments from under Workloads. Select the web deployment. From this view, you should see an error like that shown in the following screenshot.

    ![Deployments is selected under Workloads in the navigation menu on the left. On the right are the Details and New Replica Set boxes. The web deployment is highlighted in the New Replica Set box, indicating an error.](media/image141.png)

Like the API deployment, the web deployment used a fixed *hostPort*, and your ability to scale was limited by the number of available agent nodes. However, after resolving this issue for the web service by removing the *hostPort* setting, the web deployment is still unable to scale past two pods due to CPU constraints. The deployment is requesting more CPU than the web application needs, so you will fix this constraint in the next task.

### Task 3: Adjust CPU constraints to improve scale

In this task, you will modify the CPU requirements for the web service so that it can scale out to more instances.

1. From the navigation menu, select Deployments under Workloads. From the view's Deployments list select the web deployment.

2. Select **Edit**.

3. From the Edit a Deployment dialog, find the *cpu* resource requirements for the web container. Change this value to "125m".

    ![This is a screenshot of the Edit a Deployment dialog box with various displayed information about ports, env, and resources. The resources node, with cpu: 125m selected, is highlighted.](media/image142.png)

4. Select **Update** to save the changes and update the deployment.

5. From the navigation menu, select Replica Sets under Workloads. From the view's Replica Sets list select the web replica set.

6. When the deployment update completes, four web pods should be shown in running state.

    ![Four web pods are listed in the Pods box, and all have green check marks and are listed as Running.](media/image143.png)

7. Return to the browser tab with the web application loaded. Refresh the stats page at /stats.html to watch the display update to reflect the different api pods by observing the host name refresh.

### Task 4: Perform a rolling update

In this task, you will edit the web application source code to add Application Insights and update the Docker image used by the deployment. Then you will perform a rolling update to demonstrate how to deploy a code change.

1. First create an Application Insights key for content-web using the Azure Portal.

2. Select "+ Create a Resource" and search for "Application Insights" and select "Application Insights".

    ![A screenshot of the Azure Portal showing a listing of Application Insights resources from search results.](media/Ex4-Task4.2.png)

3. Configure the resource as follows, then select "Create":

    - **Name**: content-web

    - **Application Type**: Node.js Application

    - **Subscription**: Use the same subscription you have been using throughout the lab.

    - **Resource Group**: Use the existing resource group fabmedical-SUFFIX.

    - **Location**: Use the same location you have been using throughout the lab.

    ![A screenshot of the Azure Portal showing the new Application Insights blade.](media/Ex4-Task4.3.png)

4. While the Application Insights resource for content-web deploys, create a second Application Insights resource for content-api.  Configure the resource as follows, then select "Create":

   - **Name**: content-api

   - **Application Type**: Node.js Application

   - **Subscription**: Use the same subscription you have been using throughout the lab.

   - **Resource Group**: Use the existing resource group fabmedical-SUFFIX.

   - **Location**: Use the same location you have been using throughout the lab.

5. When both resources have deployed, locate them in your resource group.

    ![A screenshot of the Azure Portal showing the new Application Insights resources in the resource group.](media/Ex4-Task4.5.png)

6. Select the content-web resource to view the details.  Make a note of the Instrumentation Key; you will need it when configuring the content-web application.

    ![A screenshot of the Azure Portal showing the Instrumentation Key for an Application Insights resource.](media/Ex4-Task4.6.png)

7. Return to your resource group and view the details of the content-api Application Insights resource.  Make a note of its unique Instrumentation Key as well.

8. Connect to your build agent VM using ssh as you did in Task 6: Connect securely to the build agent before the hands-on lab.

9. From the command line, navigate to the content-web directory.

10. Install support for Application Insights.

    ```bash
    npm install applicationinsights --save
    ```

11. Open the server.js file using VI:

    ```bash
    vi server.js
    ```

12. Enter insert mode by pressing `<i>`.

13. Add the following lines immediately after the config is loaded.

    ```javascript
    const appInsights = require("applicationinsights");
    appInsights.setup(config.appInsightKey);
    appInsights.start();
    ```

    ![A screenshot of the VIM editor showing the modified lines.](media/Ex4-Task4.13.png)

14. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

15. Update your config files to include the Application Insights Key.

    ```bash
    vi config/env/production.js
    <i>
    ```

16. Add the following line to the `module.exports` object, and then update [YOUR APPINSIGHTS KEY] with the your Application Insights Key from the Azure portal.

    ```javascript
    appInsightKey: '[YOUR APPINSIGHTS KEY]'
    ```

    ![A screenshot of the VIM editor showing the modified lines.](media/Ex4-Task4.16.png)

17. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

18. Now update the development config:

    ```bash
    vi config/env/development.js
    <i>
    ```

19. Add the following line to the `module.exports` object, and then update [YOUR APPINSIGHTS KEY] with the your Application Insights Key from the Azure portal.

    ```javascript
    appInsightKey: '[YOUR APPINSIGHTS KEY]'
    ```

20. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

21. Push these changes to your repository so that Azure DevOps CI will build a new image while you work on updating the content-api application.

    ```bash
    git add .
    git commit -m "Added Application Insights"
    git push
    ```

22. Now update the content-api application.

    ```bash
    cd ../content-api
    npm install applicationinsights --save
    ```

23. Open the server.js file using VI:

    ```bash
    vi server.js
    ```

24. Enter insert mode by pressing `<i>`.

25. Add the following lines immediately after the config is loaded:

    ```javascript
    const appInsights = require("applicationinsights");
    appInsights.setup(config.appSettings.appInsightKey);
    appInsights.start();
    ```

    ![A screenshot of the VIM editor showing ](media/Ex4-Task4.25.png)

26. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

    ```text
    <Esc>
    :wq
    <Enter>
    ```

27. Update your config files to include the Application Insights Key.

    ```bash
    vi config/config.js
    <i>
    ```

28. Add the following line to the `exports.appSettings` object, and then update [YOUR APPINSIGHTS KEY] with the your Application Insights Key for **content-api** from the Azure portal.

    ```javascript
    appInsightKey: '[YOUR APPINSIGHTS KEY]'
    ```

    ![A screenshot of the VIM editor showing updating the Application Insights key.](media/Ex4-Task4.28.png)

29. Press the Escape key and type ":wq". Then press the Enter key to save and close the file.

30. Push these changes to your repository so that Azure DevOps CI will build a new image.

    ```bash
    git add .
    git commit -m "Added Application Insights"
    git push
    ```

31. Visit your ACR to see the new images and make a note of the tags assigned by Azure DevOps.

     - Make a note of the latest tag for content-web.

        ![A screenshot of the Azure Container Registry listing showing the tagged versions of the content-web image.](media/Ex4-Task4.31a.png)

     - And the latest tag for content-api.

        ![A screenshot of the Azure Container Registry listing showing the tagged versions of the content-api image.](media/Ex4-Task4.31b.png)

32. Now that you have finished updating the source code, you can exit the build agent.

    ```bash
    exit
    ```

33. Visit your Azure DevOps Release pipeline for the content-web application and see the new image being deployed into your Kubernetes cluster.

34. From WSL, request a rolling update for the content-api application using this kubectl command:

    ```bash
    kubectl set image deployment/api api=[LOGINSERVER]/content-api:[LATEST TAG]
    ```

35. While this updates run, return the Kubernetes management dashboard in the browser.

36. From the navigation menu, select Replica Sets under Workloads. From this view you will see a new replica set for web which may still be in the process of deploying (as shown below) or already fully deployed.

    ![At the top of the list, a new web replica set is listed as a pending deployment in the Replica Set box.](media/image144.png)

37. While the deployment is in progress, you can navigate to the web application and visit the stats page at /stats.html. Refresh the page as the rolling update executes. Observe that the service is running normally, and tasks continue to be load balanced.

    ![On the Stats page, the webTaskId is highlighted. ](media/image145.png)

### Task 5: Configure Kubernetes Ingress

In this task you will setup a Kubernetes Ingress to take advantage of path-based routing and TLS termination.

1. Update your helm package list.

    ```bash
    helm repo update
    ```

2. Install the ingress controller resource to handle ingress requests as they come in.  The ingress controller will receive a public IP of its own on the Azure Load Balancer and be able to handle requests for multiple services over port 80 and 443.

    ```bash
    helm install stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2
    ```

3. Set a DNS prefix on the IP address allocated to the ingress controller.  Visit the `kube-system` namespace in your Kubeneretes dashboard to find the IP.

    http://localhost:8001/#!/service?namespace=kube-system

    ![A screenshot of the Kubernetes management dashboard showing the ingress controller settings.](media/Ex4-Task5.5.png)

4. Create a script to update the public DNS name for the IP.

    ```bash
    vi update-ip.sh
    <i>
    ```

    Paste the following as the contents and update the IP and SUFFIX values:

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

    ![A screenshot of VIM editor showing the updated file.](media/Ex4-Task5.6.png)

5. Use `<esc>:wq` to save your script and exit VIM.

6. Run the update script.

    ```bash
    bash ./update-ip.sh
    ```

7. Verify the IP update by visiting the url in your browser.

    >**Note**: It is normal to receive a 404 message at this time.

    ```text
    http://fabmedical-[SUFFIX]-ingress.[AZURE-REGION].cloudapp.azure.com/
    ```

    ![A screenshot of the browser url.](media/Ex4-Task5.9.png)

8. Use helm to install `cert-manager`; a tool that can provision SSL certificates automatically from letsencrypt.org.

    ```bash
    kubectl label namespace kube-system certmanager.k8s.io/disable-validation=true

    kubectl apply \
        -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml

    helm install stable/cert-manager \
        --namespace kube-system \
        --set ingressShim.defaultIssuerName=letsencrypt-prod \
        --set ingressShim.defaultIssuerKind=ClusterIssuer \
        --version v0.6.6
    ```

9. Cert manager will need a custom ClusterIssuer resource to handle requesting SSL certificates.

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
        server: https://acme-v02.api.letsencrypt.org/directory
        # Email address used for ACME registration
        email: user@fabmedical.com
        # Name of a secret used to store theACMEaccount private key
        privateKeySecretRef:
          name: letsencrypt-prod
        # Enable HTTP01 validations
        http01: {}
    ```

10. Save the file with `<esc>:wq`.

11. Create the issuer using kubectl.

    ```bash
    kubectl create --save-config=true -f clusterissuer.yml
    ```

12. Now you can create a certificate object.

    > **NOTE:**
    >
    > Cert-manager might have already created a certificate object for you using ingress-shim.
    >
    > To verify that the certificate was created successfully, use the `kubectl describe certificate tls-secret` command.
    >
    > If a certificate is already available, skip to step 15.

    ```bash
    vi certificate.yml
    <i>
    ```

    Use the following as the contents and update the [SUFFIX] and [AZURE-REGION] to match your ingress DNS name

    ```yaml
    apiVersion: certmanager.k8s.io/v1alpha1
    kind: Certificate
    metadata:
      name: tls-secret
    spec:
      secretName: tls-secret
      dnsNames:
      - fabmedical-[SUFFIX]-ingress.[AZURE-REGION].cloudapp.azure.com
      acme:
        config:
        - http01:
            ingressClass: nginx
          domains:
          - fabmedical-[SUFFIX]-ingress.[AZURE-REGION].cloudapp.azure.com
      issuerRef:
        name: letsencrypt-prod
        kind: ClusterIssuer
    ```

13. Save the file with `<esc>:wq`.

14. Create the certificate using kubectl.

    ```bash
    kubectl create --save-config=true -f certificate.yml
    ```

    > **Note**: To check the status of the certificate issuance, use the `kubectl describe certificate tls-secret` command and look for an *Events* output similar to the following:
    >
    > ```text
    > Type    Reason         Age   From          Message
    > ----    ------         ----  ----          -------
    > Normal  Generated      27s   cert-manager  Generated new private key
    > Normal  OrderCreated   27s   cert-manager  Created Order resource "tls-secret-1375302092"
    > Normal  OrderComplete  2s    cert-manager  Order "tls-secret-1375302092" completed successfully
    > Normal  CertIssued     2s    cert-manager  Certificate issued successfully
    > ```
    > .

15. Now you can create an ingress resource for the content applications.

    ```bash
    vi content.ingress.yml
    <i>
    ```

    Use the following as the contents and update the [SUFFIX] and [AZURE-REGION] to match your ingress DNS name

    ```yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: content-ingress
      annotations:
        kubernetes.io/ingress.class: nginx
        certmanager.k8s.io/cluster-issuer: letsencrypt-prod
        nginx.ingress.kubernetes.io/rewrite-target: /$1
    spec:
      tls:
      - hosts:
        - fabmedical-[SUFFIX]-ingress.[AZURE-REGION].cloudapp.azure.com
        secretName: tls-secret
      rules:
      - host:   fabmedical-[SUFFIX]-ingress.[AZURE-REGION].cloudapp.azure.com
        http:
          paths:
          - path: /(.*)
            backend:
              serviceName: web
              servicePort: 80
          - path: /content-api/(.*)
            backend:
              serviceName: api
              servicePort: 3001

    ```

16. Save the file with `<esc>:wq`.

17. Create the ingress using kubectl.

    ```bash
    kubectl create --save-config=true -f content.ingress.yml
    ```

18. Refresh the ingress endpoint in your browser.  You should be able to visit the speakers and sessions pages and see all the content.

19. Visit the api directly, by navigating to `/content-api/sessions` at the ingress endpoint.

    ![A screenshot showing the output of the sessions content in the browser.](media/Ex4-Task5.19.png)

20. Test TLS termination by visiting both services again using `https`.

    > It can take a few minutes before the SSL site becomes available.  This is due to the delay involved with provisioning a TLS cert from letsencrypt.

## After the hands-on lab

**Duration**: 10 mins

In this exercise, you will de-provision any Azure resources created in support of this lab.

1. Delete both of the Resource Groups in which you placed all of your Azure resources

    - From the Portal, navigate to the blade of your Resource Group and then select Delete in the command bar at the top.

    - Confirm the deletion by re-typing the resource group name and selecting Delete.

2. Delete the Service Principal created on Task 9: Create a Service Principal before the hands-on lab.

    ```bash
    az ad sp delete --id "Fabmedical-sp"
    ```

You should follow all steps provided *after* attending the Hands-on lab.
