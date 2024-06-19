# Chap 5. Moving Toward Deployment

## Managing Configuration as Code and Software Bill of Materials (SBOM)
### Managing Configuration as Code
configuration
: files that configure the behavior of services in a modern infrastructure
: e.g. Conguration for web server (nginx, Apache)

as code
: managed by a VCS like Git (just like code)
: Changes can be tracked, rolled back if needed
### How to structure configuration?
It's depend on the OS and infrastructure:
- Per-application
- Per-environment

#### Structure the configuration per application (with environments)
Use branching & tagging for changes to the files.
#### Structure the configuration per environment (with applications)
This can lead to a drift between environments, remember to keep the environments as close as possible to the production:
- Any permanent changes to dev, qa... need to be propagated to the production.
- Any temporary changes to dev, qa... needs to be removed before it propagated to production.

> [!NOTE]
> Structure the configuration per environment leads to _variable-based_ configuration management:
>    - the configuration files are stored in the source code repository
>    - instead of hard-coding values, any environment-specific information is gathered at deploy time. (requires additional levels of automation)
> 

# Configuration files and SBOM - Software bill of materials
SBOM
: information about each components of a software
: e.g. name of supplier/component, version, dependencies
: used to verify & validate each pieces of a large application

The configuration files is a part of the SBOM:
- They're the packages need to be installed to make an application work
## Using Docker
Docker provides containerization for applications.
Containerization
: one of the primary tool that enable DevSecOps.
: requires a paradigm shift away from monolithic (one giant application) to microservices (micro application that do only one thing)
### Container and Image Concepts
container
: isolated **process** - abstraction of hardware resources - provides a computing _environment_ (~ runtime for your application)
: lighter than a VM
: not a lightweight VM (~ a container is a OS-level virtualization, a VM is a hardware-level virtualization)

container image
: a **standardized package** that includes all of the files, binaries, libraries, and configurations to run a container

> [!NOTE] 
> Form a security perspective, a container image is more secure than a VM image:
> - For VM: No one can know exact what's inside, what's changed with a VM image.
> - For container:
>   - A container image are composed of layers. And each of these layers, once created, are immutable.
>   - Each layer in an image contains a set of filesystem changes - additions, deletions, or modifications.
>   - if one of the base layers for Docker images was tampered with, the community would be made aware immediately.
 
 
> [!NOTE] 
> From a operational perspective, a container can use the **_minimum_ resource** to:
> - provide the runtime **environment** (software)
> - make that runtime environment _isolated_ (hardware & software)

With container, you can quickly spin up an instance of your application:
- have a vertical scaling (& also gain performance with the same hardware)
- automate the process of horizontal scaling (with minimal overhead)
- have the container run and exit immediately (serverless) 

See:
- https://docs.docker.com/guides/docker-concepts/the-basics/what-is-a-container/
- https://docs.docker.com/guides/docker-concepts/the-basics/what-is-an-image/
### Obtaining Images
To run a container, first you need the container image, which:
- you build yourself from the Dockerfile
- someone's built it, and you only need to _pull_ that pre-built image from a registry, e.g. Docker Hub.
#### Docker Hub
Docker Hub
: the official registry for container images

The Docker Hub can be accessed via:
- its Web UI: https://hub.docker.com/
- Docker Desktop
- via the CLI (its the default registry of the docker CLI)
#### Using the Docker command
- `docker search IMAGE`
- `docker pull IMAGE`
- `docker run --name CONTAINER IMAGE`
- `docker ps`
- `docker exec -it CONTAINER COMMAND`
- `docker stop CONTAINER`
- `docker start CONTAINER`
- ...
#### Using a local network registry
If your organization needs full control of the registry, you can 
- maintain your own registry
	The community maintains an implementation of a container registry:
	- The project (`distribution`) is at https://github.com/distribution/distribution
	- The releases are available as container image (`registry`) at https://hub.docker.com/_/registry
- use SSL (self-signed or CA-signed) to encrypt data on transit
- use `htpasswd` to add authentication
From the perspective of a developer, he/she will need:
- Trust the certificate
- Login to the local registry: 
	`docker login registry.example.com`
- Sync image from Docker Hub to your local registry
	- Pull the image: `docker pull alpine`
	- Retag it: `docker tag alpine registry.example.com/alpine`
	- Push to local registry: `docker push registry.example.com/alpine`
- Pull from local registry
	- (Remove cache images) `docker rmi alpine registry.example.com/alpine`
	- Pull:  ``docker pull registry.example.com/alpine`
## Deploying Safely with Blue-Green Deployment
blue-green deployment
: deployment strategy that deploys in safe manner by using 2 sets of environment 
: - blue - the current-production environment
: -  green - the to-be-production environment
: traffic is switched to green after it has been tested 
## Summary
- Treat configuration as code and manage it using a VCS like Git.
- Containerizing applications to facilitate CI/CD deployment pipeline.
- Blue-green deployment