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

#### File permissions in Linux

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

##### File permissions in action

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

##### Using `chmod` to change file permission modes

The `chmod` command supports both type of permission notation:

- For symbolic notation, `chmod` can add/remove/set permissions of each individual file class (or all file classes).
- For numeric notation, `chmod` can set permissions of:
  - all file classes
  - some trailing classes (by ignoring leading digits)

#### Role-based access control (RBAC)

RBAC
: granting permissions based on the **role** (or job duties).
: ~ group-based permissions (no more granting permissions to individuals)
: no more revoking all permissions of someone leaving

e.g.

- A hiring manager can access to data about candidates, salaries... of someone hired into a developer role.
- A developer
  - doesn't need to (& can't) access to these data.
  - need to access to the development server...

### Security for authentication process

- Don't you a permanent credential, e.g. password

  - use a short-term or/and revokable credential, e.g. token

- If you must use a password:

  - Don't use the same password for many accounts.
  - Don't remember the password by heart, use a password manager - e.g. `1Password`, `Bitwarden` - try your best to secure it.
  - Instead of using only password:
    - Use multi-factor authentication:
      - OTP from an app, a physical key.
    - Use Passkey

- When using SSH protocol to connect to a remote server:
  - Instead of using SSH key-pair
    You can
    - Prevent someone from using your SSH key-pair (A public-private key-pair can be protected with a username/password)
    - Prevent a host - that has the SSH key-pair - e.g. your computer - from connecting to a remote host, e.g. instead of your server, it's the attacker server
  - Use short-live certificate that's signed by a Certificate Authority (CA).

## Maintaining Confidentiality

### Data in Flight

#### HTTPS, DoH

- Instead of using HTTP (HTTP over TCP/IP) - and sending unencrypted data (as plaintext).

  - Using HTTPS (HTTP over **TLS** over TCP/IP) that has an extra TLS connection to _encrypt_ the data (using _asymmetric cryptography_).

> [!NOTE]
> No mailing post-card, only mailing letter.

> [!NOTE]
> HTTPS is like using Enigma machine to encipher your messages. Even if someone opens it, they still cannot read the real messages.

- Using DNS over HTTPS (DoH) (from a centralized DNS resolvers, e.g. Google, CloudFlare, instead of from ISPs) to protect privacy.

> [!NOTE]
> No one should know you're surfing `Reddit`, `Facebook`, some `NSFW` pages, whether it's your boss, the IT guys, or the Big Brother.

#### Eavesdropping on email

For email,

- To transfer email (between servers), there is SMTP - Simple Mail Transfer Protocol
- To receive email (on end-user devices), there are

  - POP3 - Post Office Protocol v3
  - IMAP - Internet Message Access Protocol

- These protocols are all un-encrypted - just like HTTP - but can integrated with TLS to add encryption.

#### Transfer files

- Secure Shell (SSH) is encrypted by default.
- File Transfer Protocol (FTP) needs to add the encryption layer.

#### Wired versus WiFi versus offline

Data traverses a wired network is less likely to eavesdropping than a wireless network (Wifi, Cellular/LTE).

An attacker can capture the traffic over wireless network (Physical layer), but they still need to break the layer on top (TLS) to decrypt the HTTP traffic.

### Data at Rest

After transferred through the network, data will be at rest - in a storage, e.g. disks, USB drives, backup tapes...

Data at rest needs to be

- encrypted at:

  - Hardware level
  - OS level
  - Database level
  - File level

- using standard ciphers, e.g. Advanced Encryption Standard (AES)

> [!CAUTION]
> Remember, these standard ciphers still can be brute-force attack with enough computing resource and time.
>
> - Time-sensitive data is not a big problem if attackers success.
> - But long-lived data - Social Security, medical record,... - may cause problematic.

### Data in Use

Data in use needs to be protect by best-effort of patching CVEs and preventing supply-chain attacks.

## Verifying Integrity

An attack on integrity may take a long time before found.

- To verify integrity, in additional to the data, there need to be a verifiable source of original truth.
- If an attacker can approach the source of original truth, they can change the data integrity without being notice.

### Checksums

hash function
: a function that can be used to map data of arbitrary size to fixed-size values (hashed string)
: ~ _checksum function_, e.g `MD5`, `SHA-1`,`SHA-256`, `SHA-384`, `SHA-512`

checksum ~ one-way hashed
: take a _data_, e.g. a file/string; execute a _checksum function_ on it will return a _checksum_

> [!IMPORTANT]
> A checksum:
>
> - is unchanged for a specific dagta
> - has a fixed length no matter the size (this length is depended on the algorithm of the hash function)

> [!TIP]
> Fingerprint -> A Person
> Hashes string -> File/String

> [!WARNING]
> A matched checksum doesn't guarantee 100% that the file/string hasn't been corrupt/altered.
>
> - There may be collisions.

### Verifying Email

[SDP] - **Sender** Policy Framework ~ (IP check)
: Ensures the **sending mail server** is authorized to originate mail from the email sender's domain
: ~ Is the mail's sender matched with the sender server?
: e.g.
: - A mail that claims it's from `example.com`, needs to be sent from `1.2.3.4` IP address

> [!TIP]
> A mail that claims it's from `you`, needs to be sent from `your home's address`.
>
> The collect postman check if the mail's sender address matched the house address?

[DKIM] - **DomainKeys** Identified Mail ~ (Domain check)
: Allows the **receiver** to _check_ that an email that claimed to have come from a specific domain was indeed authorized by the owner of that domain
: ~ Is the mail sealed & has the sender signature?
: e.g.
: - A mail that claims it's from `example.com` needs to have a public key for `example.com`

> [!TIP]
> A mail that claims it's from `you` needs to be _sealed_ and has `your signature`
>
> The deliver postman check if the mail's has its sender signature?

[DMARC] [^DMARC] - Domain-based Message Authentication, **Reporting**, and Conformance
: Give email **domain owners** the ability to protect their domain from unauthorized use (email spoofing)

> [!TIP]
> Someone is sending fake mails in your name, what do want to do with those mails?

> [!CAUTION]
> All 3 protocols: SPF, DKIM, and DMARC rely on DNS to function.
>
> If your DNS infrastructure is exploit, attackers can:
>
> - Add IP to SPF
> - Change the signature to their
> - Change the policy of DMARC

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

[SDP]: https://en.wikipedia.org/wiki/Sender_Policy_Framework
[DKIM]: https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail
[DMARC]: https://en.wikipedia.org/wiki/DMARC

[^DMARC]: https://www.twilio.com/docs/sendgrid/ui/sending-email/dmarc
