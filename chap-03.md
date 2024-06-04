# Chap 3. Integrating Security

In DevSecOps,

- security is an integral element contained within each step of the software development lifecycle.

- the processes & tools for security are available to all members of a DevSecOps team (rather than only of the security team)

## Integrating Security Practices

- Some processes & tools that should exists regardless of DevSecOps

  - Patch, update process
  - Thread modeling; identification of attack vector, model
  - Security training
  - Compliance for legal/regulation requirements
  - Disaster recovery (DR) policies, responses, recovery

- Some processes & tools for DevSecOps

  - Least privilege
  - Role-based authentication
  - Key-based, certificate-based authentication
  - Code traceability

### Implementing Least Privilege

Everyone should have only enough - no more, no less - permissions to handle their tasks.

e.g.

- Granting the minimum rights needed for database users
  - Read records
  - Create new record
- Some software requires elevated permissions to be installed, but day-to-day work doesn't need these permissions

> [!WARNING]
> Least privilege can be frustrating at times, because of the context switching required when a developer finds that they can’t access certain data.

### File permissions in Linux

File permissions in Linux is the answer to

- 1️⃣ **who**?
- 2️⃣ can **do what**?

In Linux:

- Every file has 6 _permission modes_ (aka _file mode_) (👈 2️⃣ do what?)

  - 3 normal modes: `read`, `write`, and `executable`

    | Permission | File                                                           | Directory                                                                                              |
    | ---------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
    | Read       | Read the **content** of the file.                              | Read the **names** of files in the directory.                                                          |
    | Write      | _Modify & delete_ the file.                                    | _Create, rename & delete_ files in the directory.                                                      |
    | Execute    | Execute the file (if the user also has read permissions on it) | Access file information in the directory:<br />- change into it (`cd`)<br />- list its content (`ls`). |

  - 3 special modes: the `sticky bit`, `setuid`, and `setgid`.

- Every file has 3 types of _class_ (ownership category): `user`, `group`, and `other`. (👈 1️⃣ who?)

  The _class_ of a file specifies the ownership category of users who may have different permissions to perform any of the above operations on a file.

  | File class | The ownership category of users                      | Notes       |
  | ---------- | ---------------------------------------------------- | ----------- |
  | User       | The user that own the file                           | aka `owner` |
  | Group      | The group that own the file, has one or more members |             |
  | Other      | The category for everyone else                       | aka `world` |

When files are created, they are usually given:

- the `owner`: the current user
- the `group`: group of the directory the file is in

  But this varies with the operating system, the file system the file is created on, and the way the file is created.

You can change the

- owner and group of a file by using the `chown` and `chgrp` commands.
- permissions of a file by using the `chmod` comman.

> [!NOTE]
> When using `chmod`, the permissions can be specified in symbolic notation or octal notation
>
> | Permission (👈 2️⃣ do what?) | Symbolic notation | Octal notation |
> | --------------------------- | ----------------- | -------------- |
> | Read                        | `r`               | `4`            |
> | Write                       | `w`               | `2`            |
> | Execute                     | `x`               | `1`            |

#### File permissions in action

- e.g.

  ```bash
  $ ls -la /etc/hosts
  -rw-r--r--. 1 root root 538 Mar  2 15:13 /etc/hosts
  ```

- A `file permission bits` - e.g. `-rw-r--r--.` - specify
  - the scope of permissions (👈 2️⃣ who?)
  - the type of access (👈 1️⃣ do what?)

|         | Prefix              | `File permission bits` (aka `file mode bits`)   | Suffix                          |
| ------- | ------------------- | ----------------------------------------------- | ------------------------------- |
| Example | `-`                 | `rw-r--r--`                                     | `.`                             |
|         |                     | `rw-` `r--` `r--`                               |                                 |
| Purpose | File type           | Each `permission bit` is represent:             | Additional permission features  |
|         | - `-`: regular file | - In _symbolic_ notation by **3 characters**.   | - `.`: SELinux context          |
|         | - `d`: directory    | - or in _octal_ notation by **a octal number**. | - `+`: ACL                      |
|         | - ...               |                                                 | - `@`: extended file attributes |

##### Symbolic notation

| The                                             | 1st triad | 2nd triad | 3rd triad |
| ----------------------------------------------- | --------- | --------- | --------- |
| ... is the permission bit for file class of ... | `user`    | `group`   | `other`   |
| Example                                         | `rw-`     | `r--`     | `r--`     |

In symbolic natation, each `permission bit` is present by 3 characters:

- First character represent `read` permission: `r` if reading is permitted, `-` if it is not.
- Second character represent `write` permission: `w` if writing is permitted, `-` if it is not.
- Third character represent `execute` permission : `x` if execution is permitted, `-` if it is not.

##### Numeric notation (aka octal notation)

In numeric notation, the `file mode bits` is represent by 4 octal digits (`0-7`), derived by adding up the bits with values `4`, `2`, and `1`

| Example                | File mode bits      | First digit                                      | Second digit | Third digit     | Fourth digit    |
| ---------------------- | ------------------- | ------------------------------------------------ | ------------ | --------------- | --------------- |
|                        | Bit values          | `4`: set-_user_-ID bit                           | `4`: read    | The same values | The same values |
|                        |                     | `2`: set-_group_-ID bit                          | `2`: write   |                 |                 |
|                        |                     | `1`: restricted deletion or _sticky_ attributes. | `1`: execute |                 |                 |
|                        |                     |                                                  |              |                 |                 |
| Anyone can do anything | Numeric: `777`      |                                                  | `7`          | `7`             | `7`             |
|                        | Symbol: `rwxrwxrwx` |                                                  | `rwx`        | `rwx`           | `rwx`           |
|                        |                     |                                                  |              |                 |                 |
|                        | Numeric: `755`      |                                                  | `7`          | `5`             | `5`             |
|                        | Symbol: `rwxr-xr-x` |                                                  | `rwx`        | `r-x`           | `r-x`           |
|                        |                     |                                                  |              |                 |                 |
|                        | Numeric: `644`      |                                                  | `6`          | `4`             | `4`             |
|                        | Symbol: `rw-r--r--` |                                                  | `rwx`        | `r--`           | `r--`           |

### Role-based access control (RBAC)

### Maintaining Confidentiality

### Data in Flight

### Data at Rest

## Verifying Integrity

### Checksums

### Verifying Email

## Providing Availability

### Service-Level Agreements and Service-Level Objectives

### Identifying Stakeholders

### Identifying Availability Needs

### Defining Availability and Estimating Costs

## What About Accountability?

### Site Reliability Engineering

### Code Traceability and Static Analysis

## Becoming Security Aware

### Finding Formal Training

### Obtaining Free Knowledge

### Enlightenment Through Log Analysis

## Practical Implementation: OWASP ZAP

### Creating a Target

### Installing ZAP

### Getting Started with ZAP: Manual Scan

## Summary
