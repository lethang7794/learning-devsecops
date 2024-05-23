# Chap 1. The Need for DevSecOps

## Developing Software

A software development lifecycle (SDLC) has 4 phases:

1. Gather **Requirements**
1. **Design** Solution
1. **Develope** Code (Implementation)
1. Test Code (Verification)

In **waterfall** development:

- Each stage needs to be completed before moving to the next phase:

  - Gather requirements
    - Design solution
      - Develope code
        - Test code

- At the end of the requirements-gathering phase:

  - The project has a scoped defined, includes all of the features of the software:
    - functional requirements
    - non-functional requirements
  - If a new requirements is discovered during later states, it's added by a following project or skipped.

- The lag between the idea and the implementation can be months, or even years.
  - Any competitive advantage can be evaporated.

### Developing Agility

In order to rapidly delivery values to the skateholder, organizations have turned toward iterative processes like Agile, Scrum.

In **iterative** development:

- Instead of define all requirements of all possible aspects of the projects, only the highest-value features are focused.

  - These high features will come through a short SDLC of 2 to 4 weeks - an **iteration** (aka a **sprint**).
  - If a requirements is missed, it can be added in the next iteration.

- Market conditions can be rapidly response.

  - You can focus on the missing features from the competitors.

- There are a lot of ceremonies:

  1. **Sprint planning**
  1. **Daily stand-up**
  1. **Sprint review**: the team shows up what it has accomplished (during that sprint).
  1. **Sprint retrospective**: the team examines what might have been done differently (during that sprint).

     <details>
     <summary>
     The team might answers 3 questions:
     </summary>

     - What should we _start_ doing? (What the team might **change**?)
     - What should we _stop_ doing? (What doesn't ~~work~~?)
     - What should we _continue_ doing? (What **work**?)

     </details>

  1. **Backlog grooming**: the skakeholders (e.g. product owner) refine, re-priority the product backlog.

     <details>
     <summary>Type of backlogs</summary>

     - An **overall backlog**: list of all possible features to be tracked & prioritized
     - A **sprint backlog**:

       - the commitment from the development team of which features to be implemented in the current iteration.
       - created based on
         - availability of team members
         - their estimations of effort - level of effort (LOE) - for each individual item on the backlog.

     </details>

## The problem with software development, operating, security

### Developing Broken Software

Why development teams develope broken software (software that doesn't meets the requirements)?

- **Flawed requirements**

  - Even if the original requirements was successfully obtained from the project sponsor.

  - **Developing software in silo**:

    - The developers only interact within a silo - other developers.
    - There is no communication between silos - developer teams, operation teams, security teams

    The developers can only examine & interpret the requirements to the best of their ability.

  - Deadlines (timeline of the project) can force everyone to guess the requirements and sacrifice the quality.

    <details>
    <summary>
    The software development triangle
    </summary>

    - Features
    - Timeline
    - Cost

    A project can only choose 2 of 3 elements of the software development

    </details>

### Operating in a Darkroom

The operation teams

- a.k.a networking administrators, system administrators, site reliability engineer (SRE), production engineer...
- are responsible of deploying, operating, supporting the software in its production environment.

  A software may

  - run well on the local environment
  - passed all the tests on the QA environment

  But these environments are not the production environment - in which the operation teams need to deploy, operate, support the software.

### Security as an Afterthought

In some organizations with the "ship at any cost" mentality, "minimum viable product" (MVP) altitude, the security is usually the first requirement to be sacrificed.

Security is hard, it must work every time, while an attacker only needs to be right once.

In DevSecOps, security is integrated early with the development cycle.

## Culture First

The culture of the organization is the primary factor that determines whether DevSecOps will be successful.

- A **control**-oriented, **top-down** organization will struggle to implement DevSecOps.

  - These organization may use technology technology feels like DevSecOps, but without cross-team transparent, it's very hard to success.
  - In these organization, the ~~best solution~~ is less important than subordination & maintaining separation to keep control at the top.

- DevSecOps facilitates a problem-solving approach, even if the solution comes from someone in a different department.

- In DevSecOps, people work together across job functions, using the skills where needed.

  The teams are transparent about their work, focusing on the end goal of accomplish useful work.

  ~~Job titles~~ are less important than **work accomplishing**.

## Processes and People over Tools

Without the right culture, process & people, DevSecOps tools can slow down the development.

### Promoting the Right Skills

- Identify employees who have cross-functional experiences.

  e.g.

  - A developer who can deploy their own clusters, know the difference between DNS/DHCP.

- Allow these employees to cross functional boundaries.

  e.g.

  - Developers will need access to, or at least visibility into, server and network areas that may have been solely under the purview of Operations.
  - Operations and Security teams will need to have substantive early input within the project lifecycle so that they can provide feedback to improve downstream processes.

### DevSecOps as Process

#### Hammers and screwdrivers

Tools are essential to complete some jobs _efficiently_.

- The tool should help complete the job, but the tool does not define the job.

DevSecOps tooling can provide huge efficiency gains when used by the right people.

> [!IMPORTANT]
> Use the right tool
>
> - for the right job
>   - in the right way.

#### Repeatability

DevSecOps focuses on

- building repeatable process

- facilitates automation

  e.g.

  - the creation of environments
  - the deployment of codes
  - the testing

by using the "as Code" paradigm:

- Infrastructure as Code
- Configuration as Code
- Policy as Code
- ...

> [!NOTE]
> Everything as Code
>
> - Manage as much as possible using source code management tools & practice
>   e.g. git, git workflow

> [!IMPORTANT]
> What is the benefit of "as Code"?
>
> - Everything is committed to the history.
> - Each commit is a version of the "Code"

> [!TIP]
> How can a repeatable deployment is possible
>
> By using:
>
> - same version of the configuration (GitOps)
> - same version of software (CI/CD)

#### Visibility

DevSecOps enables visibility through out the development process:

- Via agile ceremony: Daily Standup
- Via tools:

  Member of a DevSecOps team can

  - see exactly

    - which deployment (configuration & software)
    - in which environment.

  - make a new deployment in an environment as needed.

#### Reliability, speed, and scale

Repeatability & visibility leads to reliability.

- Code & environment can be deployed consistently (repeatability).
- If there is an error, it is found (& fixed) immediately (visibility).

And there come:

- speed - the ability to quickly react to changing needs.
- scale - because of repeatable deployment.

#### Microservices and architectural features

With microservices:

- Small functional area of code are separated and can be on their own, called a microservice.
- Each microservice
  - provides a consistent API - e.g as a HTTP web service - to other microservices in the whole system.
  - can be developed & deployed separately, which also increasing speed & momentum.

## The DevSecOps SDLC

| **Dev**                                                | **DevOps**   |                                     | **DevSecOps** |
| ------------------------------------------------------ | ------------ | ----------------------------------- | ------------- |
| 3. Develope Code - Implementation (Dev)                | 1. **Code**  | (Dev)                               | + Security    |
|                                                        | 2. _Build_   | Continuous Integration              | + Security    |
| 4. Test Code - Verification (QA)                       | 3. **Test**  | Continuous Integration              | + Security    |
|                                                        | 4. _Release_ | Continuous Delivery: Approval Gates | + Security    |
|                                                        | 5. Deploy    | Continuous Deployment               | + Security    |
|                                                        | 6. Operate   | (Ops)                               | + Security    |
|                                                        | 7. Monitor   | (Ops)                               | + Security    |
| 1. Gather **Requirements**<br />2. **Design** Solution | 8. Plan      |                                     | + Security    |

- DevOps SDLC closely reflects what actually happens for software development.
- DevSecOps SDLC: security is a part of every phase.

## Summary

DevSecOps comes as a natural progression of software development.

- DevSecOps try to break down development silos (barriers between teams).

Cultural changes, from the top of an organization, is the primary key to achieve the most benefit from DevSecOps.

With the right culture, process, people, an organization can use DevSecOps tools to facilitate:

- repeatability
- visibility
- reliability
- speed & scale
