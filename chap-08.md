# Chap 8. DevSecOps Patterns & Beyond

- What exactly is DevSecOps?

  It means _different_ things to different people _depends_ on context, experiences, organization need.

- DevSecOps is not a mature enough to have a recipe for success.

- DevSecOps is not an ~~end goal~~, but rather an **iterative _improvement_ process** to make software delivery faster & more reliable.

## DevSecOps Patterns

### Shifting Left toward CI/CD

CI/CD is the ultimate gold of Dev(Sec)Ops.

- A developer should be able to

  - write code
  - see the code moving to production
    - passe tests... (CI)
    - deploy to production (CD)

- ArgoCD is designed with DevSecOps in mind:
  - There is a web interface to increase visibility: developers can see what see deployment status of the system.
  - Takes advantages of tools: K8s, Helm...

### Multi-cloud Deployments

With

- containerization technology: Docker, Kubernetes
- the support of cloud providers to provide a platform for containers that integrates well Kubernetes

any organization can run containerized workflow seamlessly on any cloud provides based on:

- organization need
- geographic demand
- redundancy

### Integrated and Automatic Security

The whole SDLC should be secure by default, in an unobtrusive way:

- Role-based access control should be everywhere.

- In addition to post-production, security needs to be shifted left and automatic (developers don't need to be an expert in cybersecurity):

  - When code is committed/pushed, the CI system's security scanning tool should flag the security issues so developers can remediation these security issues early.

    e.g. Credentials, secrets within code/configuration needs to be remove ASAP.

  - The tooling should minimize the any security risks for the developers.

### Linux Everywhere

Promoting tools that:

- are Linux-based
- work seamlessly with Linux

Linux-related skills - utilizing CLI, understand Linux's architecture ... - should be promoted in an organization.

### Refactor and Redeploy

For a bare-metal/VM server,

- the cost of deploying another instance is quite high (the hardware purchasing, the setup...)
- the cost of getting the most from the existing instances is cheaper, optimization & troubleshooting skills is more emphasized.

Today, the time spending to get the most out of an instance is more costly than a redeploy:

- Computing resources - processor, memory - are cheap enough that a deployment of another instance is cheaper than determine the root-cause of an instance.
- You can treat redeploying as "turning it off and back on again"

## Summary

- DevSecOps patterns:

  - Shift-left (deployment, security)
  - Multi-cloud deployment
  - Linux (& its skills)
  - Redeploy

- DevSecOps is more than a practice, it's the culture

  - Change the culture first, then introduce the DevSecOps practices, tools.
  - Don't make DevSecOps a technical debt to sole other technical debts.
