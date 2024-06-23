# Chap 6. Deploy, Operate, and Monitor

By the time an application reaches the production environment:

- The code should have been reviewed, tested many times
- The deployment to an environment (qa, uat, ...) should have been done many times
- There should be little room for suprises.
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
> - can operate without agent (agentless)
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
- execute automation tasks to config these environment
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
- static code analysics
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

n a digital signature system,

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

| When? | What?                            | How                   | Where?                                                                                                                                                                                                                                    | Note |
| ----- | -------------------------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| 1.    | An SSH **key-pair** is generated | e.g. Use `ssh-keygen` | Anywhere                                                                                                                                                                                                                                  |
| 2.    | The key-pair is distributed      |                       |                                                                                                                                                                                                                                           |
| 2.a.  | - to the server: **public key**  |                       | In file `~/.ssh/authorized_keys` on the s                                                                                                                                                                                                 |
| 2.b.  | - to the client: **private key** |                       | In directory `~/.ssh/` on the client                                                                                                                                                                                                      |
| 3.    | Login to the server              | Use `ssh`             | On the client - The first time you connect to a server, you need to confirm the server by the **fingerprint** of the public key.<br>- After you confirmed, the server's **public key** is saved to the client's `known_hosts` <br>- <br>- |
|       |                                  |                       |                                                                                                                                                                                                                                           |
|       |                                  |                       |                                                                                                                                                                                                                                           |

> [!NOTE]
> Public/Private key-pair vs Fingerprint?
>
> - Private key:
> - Public key: one of the two key of the public/private key-pair
> - Fingerprint (Public key fingerprint): a short hash of the public key, so human can compare 2 public keys

###### SSH Key format and key type

The following SSH key formats are supported by OpenSSH:

- `PEM` (PEM public key): OpenSSL's format - still used by GitHub
- `PKCS8` (PKCS8 public or private key)
- [`RFC4716`](https://www.ietf.org/rfc/rfc4716.txt): aka `SSH2` - Default when exporting
- OpenSSH's own format: Default for creating

The fowlloing SSH key type are supported by OpenSSH:

- `dsa` (Depracated)
- `rsa`: Greatest portability
- `ecdsa`: Balance, More compatible
- `ed25519` (Default): Best security

> [!TIP]
> There are also `ecdsa-sk`, `ed25519-sk`: created with FIDO/U2F hardware token, e.g. YubiKey
> `-sk` stands for _security key_

##### Transfer files between servers

###### Clone source code to Jenkins server

- `git`

###### To the production server

- `rsync`
- `scp`

## Monitoring

## Summary
