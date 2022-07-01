# Cloud-native applications

## This workshop is archived and no longer being maintained.  Content is read-only.

Fabrikam Medical Conferences provides conference web site services, tailored to the medical community. Their business has grown and the management of many instances of the code base and change cycle per tenant has gotten out of control.

The goal of this workshop is to help them build a proof of concept (POC) that will migrate their code to a more manageable process that involves containerization of tenant code, a better DevOps workflow, and a simple lift-and-shift story for their database backend.

November 2021

## Target Audience

- Application developer
- Infrastructure architect

## Abstracts

### Workshop

In this workshop, you will build a proof of concept (POC) that will transform an existing on-premises application to a container-based application. This POC will deliver a multi-tenant web app hosting solution leveraging Azure Kubernetes Service (AKS), Docker containers on Linux nodes, and a migration from MongoDB to CosmosDB.

At the end of this workshop, you will be better able to improve the reliability of and increase the release cadence of your container-based applications through time-tested DevOps practices.

### Whiteboard Design Session

In this whiteboard design session, you will learn about the choices related to building and deploying containerized applications in Azure, critical decisions around this, and other aspects of the solution, including ways to lift-and-shift parts of the application to reduce applications changes.

By the end of this design session, you will be better able to design solutions that target Azure Kubernetes Service (AKS) and define a DevOps workflow for containerized applications.

### Hands-on Lab

This hands-on lab will guide the student through deploying a web application and API microservice to a Kubernetes platform hosted on Azure Kubernetes Services (AKS). In addition, the lab will instruct the student on configuring the behavior of these services through dynamic service discovery, service scale-out, and high availability in the context of AKS-hosted services. By demonstrating crucial Kubernetes concepts, the student will gain experience with the Kubernetes deployment and service resource types. The student will create them manually through the Azure Portal and manipulate their configurations to scale the associated microservice instances up and down and manage their CPU and memory resource allocations with the Kubernetes cluster.

At the end of this lab, you have a solid understanding of how to build and deploy containerized applications to Azure Kubernetes Service and perform common DevOps tasks and procedures.

## Azure services and related products

- Azure Kubernetes Service (AKS)
- Azure Container Registry
- GitHub
- Docker
- Cosmos DB (including MongoDB API)

## Related references

- [MCW](https://github.com/Microsoft/MCW)

## Help & Support

We welcome feedback and comments from Microsoft SMEs & learning partners who deliver MCWs.  

***Having trouble?***

- First, verify you have followed all written lab instructions (including the Before the Hands-on lab document).
- Next, submit an issue with a detailed description of the problem.
- Do not submit pull requests. Our content authors will make all changes and submit pull requests for approval.

If you are planning to present a workshop, *review and test the materials early*! We recommend at least two weeks prior.

### Please allow 5 - 10 business days for review and resolution of issues.
