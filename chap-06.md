# Chap 6. Deploy, Operate, and Monitor

By the time an application reaches the production environment:

- The code should have been reviewed, tested many times
- The deployment to an environment (qa, uat, ...) should have been done many times
- There should be little room for surprises.
  -> This is also known as _shift-left_

## Continuous Integration and Continuous Deployment (CI/CD)

> [!NOTE]
> This chapter demonstrate the use of
>
> - Ansible (for maintaining environments)
> - Jenkins (for deployment)
>
> Many organizations may outgrow this deployment mode, e.g.
>
> - Use other tools:
>   - Terraform
>   - Kubernetes, ArgoCD
> - Deploy on multiple clouds with other cloud-native tools

### Building and Maintaining Environments with Ansible

> [!NOTE]
> Ansible - just like Chef, Puppet - is configuration management tools:
>
> - can operate without agent (agent-less)
> - use declarative approach (configuration is managed as code in YAML/INI format)

#### Ansible concepts

inventory
: defines the hosts being managed
: : ~ _which servers_

e.g. A group of servers (that mean to be DNS servers)

playbook
: defines the automation tasks to get the desired state of the hosts
: ~ _what to do_ (to which servers)

e.g. What to do to make these server up-and-running as a DNS server

- Install DNS-related software, e.g. BIND

```yaml
- name: ensure installed- bind9
  apt: name=bind9 state=present
```

- Sync the configuration to the device under managed

```yaml
- name: sync named.conf
  copy: src={{ config_dir }}/dns/named.conf dest=/etc/bind/named.conf group=bind backup=yes
  notify:
    - restart named
  tags:
    - bindconfigs
```

#### How Ansible works?

With Ansible, you can

- create a desired state for environments
- execute automation tasks to configure these environment
  with a single command `ansible-playbook` by using a configuration as code approach.

### Using Jenkins for CI/CD

Jenkins
: an automation server - support automating virtually anything, so that _humans can spend their time doing things machines cannot_.
: powerful & extensive
: ~ CI/CD server

#### Why Jenkins?

Automate your development workflow:

- building projects
- running tests
- static code analysis
- deployment
- ...
  so you can focus on work that matters most.

#### Setup a Jenkins server

#### Creating a simple Pipeline with Jenkins

A simple pipeline that deploy a application to a server looks like this:

- Pull code
- Build code
- (Test code)
- (Release code)
- Deploy code

##### Connect to a server

- `ssh`

|                     | Server                                                                    | Client                                                                  |
| ------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| SSH key-pair        | Public key                                                                | Private key                                                             |
|                     |                                                                           | ssh/                                                                    |
| Authentication data | `~/.ssh/authorized_keys`<br>The users that are allowed to log in remotely | `~/.ssh/known_hosts`<br>Public keys of the hosts accessed by a user<br> |
|                     | (Is this the user that I should let log in?)                              | (Is this the same server I've connected last time?)                     |

###### Public-key cryptography

Public-key cryptography (asymmetric cryptography)
: The field of cryptographic systems that use pairs of related keys.
: Each **key-pair** consists of a public key and a corresponding private key
: Security of public-key cryptography depends on _keeping the **private key** secret_; the public key can be openly distributed without compromising security

In a public-key encryption system,

- anyone with a _**public key** can encrypt_ a message, yielding a ciphertext,
- but only those who know the corresponding private key can decrypt the ciphertext to obtain the original message.

In a digital signature system,

- a sender can use a private key together with a message to create a signature.
- anyone with the corresponding _**public key** can verify_ whether the signature matches the message, but a forger who does not know the private key cannot find any message/signature pair that will pass verification with the public key

###### ssh

|      | SSH                                                                                                                                                                                                        | ELI5                                                                   |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Why  | Remote login, command-line execution...                                                                                                                                                                    | A server is crashed, you need to **_login_ to your server** and fix it |
| What | Network protocol for provide secure _**encrypted** communications_ between two **un~~trusted~~ hosts** over an **un~~secure~~ network**                                                                    | You can send your backend code to your server over the **public wifi** |
| How  | SSH uses [public-key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) and [challenge-response authentication](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication) | You can only login to your server if you have your **private key**     |
|      |                                                                                                                                                                                                            |                                                                        |

`ssh`
: `SSH` - the protocol
: `ssh` - the program

`ssh` (the program)
: OpenSSH remote login client
: a program for
: - _logging_ into a remote machine
: - _executing commands_ on a **remote machine**

###### OpenSSH

|                | OpenSSH tool  | Docs - What is it?                                              | tldr - What it does?                                             |
| -------------- | ------------- | --------------------------------------------------------------- | ---------------------------------------------------------------- |
| Server         | `ssh-agent`   | OpenSSH authentication **agent**                                | Holds SSH keys decrypted in memory                               |
|                | `sshd`        | OpenSSH daemon                                                  | Allows remote machines to securely log in to the current machine |
| Key management | `ssh-add`     | Adds private key identities to the OpenSSH authentication agent | Manage loaded SSH keys in the ssh-agent                          |
|                | `ssh-keygen`: | OpenSSH authentication **key utility**                          | Generate SSH keys used for authentication<br>                    |
|                | `ssh-keyscan` | Gather SSH public keys from servers                             | Get the public SSH keys of remote hosts                          |
| Client         | `ssh`         | OpenSSH remote login **client**                                 | Logging or executing commands on a remote server                 |

> [!NOTE]
> The `ssh-copy-id` is used when:
>
> - you have logged in to a remote server (by using a login password),
> - you need to copy SSH public keys to that remote server's `authorized_keys`.

###### A normal flow when working with OpenSSH

> [!WARNING]
> Any one have your private key can do malicious things in your name.

| When? | What?                            | How                   | Where?                                    | Note                                                                                                                                                                                                            |
| ----- | -------------------------------- | --------------------- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.    | An SSH **key-pair** is generated | e.g. Use `ssh-keygen` | Anywhere                                  |                                                                                                                                                                                                                 |
| 2.    | The key-pair is distributed      |                       |                                           |                                                                                                                                                                                                                 |
| 2.a.  | - to the server: **public key**  |                       | In file `~/.ssh/authorized_keys` on the s |                                                                                                                                                                                                                 |
| 2.b.  | - to the client: **private key** |                       | In directory `~/.ssh/` on the client      |                                                                                                                                                                                                                 |
| 3.    | Login to the server              | Use `ssh`             | On the client                             | - The first time you connect to a server, you need to confirm the server by the **fingerprint** of the public key.<br>- After you confirmed, the server's **public key** is saved to the client's `known_hosts` |
|       |                                  |                       |                                           |                                                                                                                                                                                                                 |
|       |                                  |                       |                                           |                                                                                                                                                                                                                 |

###### Key-pair, public/private key, passphrase, fingerprint, randomart image

- Private key: is known only to you and it should be safely guarded

  ```bash
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
  QyNTUxOQAAACCLdbmJdwnuwFEb4syAWfwkFrkVEbTOM28u9TDlA5D5qgAAAJDy28+G8tvP
  hgAAAAtzc2gtZWQyNTUxOQAAACCLdbmJdwnuwFEb4syAWfwkFrkVEbTOM28u9TDlA5D5qg
  AAAEC78OkniXvREV3umKoZY3r+jYPXXAyocmGV0gFf+xmKZYt1uYl3Ce7AURvizIBZ/CQW
  uRURtM4zby71MOUDkPmqAAAAC2xxdEBsZy1ncmFtAQI=
  -----END OPENSSH PRIVATE KEY-----
  ```

- Public key: can be shared freely with any SSH server to which you wish to connect.

  ```bash
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIt1uYl3Ce7AURvizIBZ/CQWuRURtM4zby71MOUDkPmq username@hostname
  ```

- Passphrase: an extra protection layer for the private key, used to encrypt/decrypt the private key on the client

- Fingerprint (Public key fingerprint): a short hash of the public key, provides an easy way to visually identifying the key

  e.g.

  - SHA256

    ```bash
    SHA256:qkb5wD2QW8+ASMWiGnSEEE/heGuugC9gH20yFpq/jn0 username@hostname
    ```

  - MD5

    ```bash
    MD5:73:ee:67:ef:53:2b:84:d7:4e:bc:5c:14:78:90:a5:53 username@hostname
    ```

- Randomart image: an even easier way for humans to identify the key (fingerprint)

  e.g.

  ```bash
  +--[ED25519 256]--+
  |+.==.            |
  | Bo..            |
  |oo=o o           |
  |o..o+ o          |
  |..=.o* +S        |
  |+* =*oo.o        |
  |= =.=o..         |
  |oooo.E.          |
  |.oo=+            |
  +----[SHA256]-----+
  ```

###### SSH Key format and key type

The following SSH key formats are supported by OpenSSH:

| SSH key format   | Note                   | aka              |
| ---------------- | ---------------------- | ---------------- |
| `PEM`            | Used by GitHub         | OpenSSL's format |
| `PKCS8`          |                        |                  |
| `RFC4716`[^1]    | Default when exporting | SSH2             |
| OpenSSH's format | Default when creating  |                  |

The following SSH key type are supported by OpenSSH:

| SSH key type | Note               | Pros / Cons                  | Example                               |
| ------------ | ------------------ | ---------------------------- | ------------------------------------- |
| `rsa`        |                    | Greatest portability         | `ssh-keygen -b 4096`                  |
| `dsa`        | (Deprecated)       |                              |                                       |
| `ecdsa`      | (Prefer `ed25519`) | Political/technical concerns |                                       |
| `ed25519`    | (Default)          | Best security                | `ssh-keygen -t ed25519`, `ssh-keygen` |

> [!TIP]
> There are also `ecdsa-sk`, `ed25519-sk`:
>
> - These key type are created with FIDO/U2F hardware token, e.g. YubiKey
> - `-sk` stands for _security key_

##### Transfer files between servers

###### Clone source code to Jenkins server

- `git`

###### To the production server

- `rsync`
- `scp`

## Monitoring

The complexity to deploy a modern application has increased significantly:

- Many organizations even requires no downtime between deployments.

To keep the complexity under control, you need to _monitor it_ to know

- **what happening** with the application
- **how it's running**

### Best practices for monitoring

- Visibility means fix-ability:

  e.g. Knowing about an outrage before someone call you can give you some time.

- Triage is important

  e.g. Which problem should you spend your time?

- Shift downtime left with instrumentation enabled

  e.g. Downtime in non-production environments is also needed to be fixed early

- Focus on important metrics

  e.g.

  - I/O latency for a database is important metric
  - Requests/second, request latency is important metrics for a web server

- Don’t forget dependencies

  e.g. Network latency is uncontrolled.

- Alerts need to be actionable

  e.g. No one care if a job they don't care about success.

  If a job is not actionable, it should be a log not an alert.

## Summary

- Ansible: provision infrastructure
- Jenkins: create CI/CD pipelines
- Monitoring & best practices

[^1]: (https://www.ietf.org/rfc/rfc4716.txt)
