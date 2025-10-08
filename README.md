# Inception-of-Things (IoT)

**Summary:** This document is a System Administration related exercise.  
**Version:** 2.1

---

## Contents

- I. [Preamble](#chapter-i-preamble)
- II. [Introduction](#chapter-ii-introduction)
- III. [General guidelines](#chapter-iii-general-guidelines)
- IV. [Mandatory part](#chapter-iv-mandatory-part)
  - IV.1 [Part 1: K3s and Vagrant](#iv1-part-1-k3s-and-vagrant)
  - IV.2 [Part 2: K3s and three simple applications](#iv2-part-2-k3s-and-three-simple-applications)
  - IV.3 [Part 3: K3d and Argo CD](#iv3-part-3-k3d-and-argo-cd)
- V. [Bonus part](#chapter-v-bonus-part)
- VI. [Submission and peer-evaluation](#chapter-vi-submission-and-peer-evaluation)

---

## Chapter I — Preamble

[Funny Image]

---

## Chapter II — Introduction

This project aims to deepen your knowledge by making you use **K3d** and **K3s** with **Vagrant**.

You will learn how to:
- Set up a personal virtual machine with Vagrant and the distribution of your choice.
- Use K3s and its Ingress.
- Discover K3d to simplify Kubernetes operations.

These steps will get you started with **Kubernetes**.

> This project is a minimal introduction to Kubernetes.  
> Indeed, this tool is too complex to be mastered in a single subject.

---

## Chapter III — General guidelines

- The whole project has to be done in a **virtual machine**.
- Put all configuration files of your project in folders located at the root of your repository.
  - The folders of the mandatory part must be named: `p1`, `p2`, and `p3`.
  - The bonus folder should be named `bonus`.
- This topic may require concepts you haven't seen yet — don’t hesitate to read documentation on **K8s**, **K3s**, and **K3d**.

> You can use any tools you want to set up your host virtual machine as well as the provider used in Vagrant.

---

## Chapter IV — Mandatory part

This project will consist of setting up several environments under specific rules.  
It is divided into three parts you must do **in order**:

1. **Part 1:** K3s and Vagrant  
2. **Part 2:** K3s and three simple applications  
3. **Part 3:** K3d and Argo CD

---

### IV.1 Part 1: K3s and Vagrant

Set up **2 machines** using Vagrant.

Write your first `Vagrantfile` using the latest stable version of your chosen distribution.  
Use minimal resources:
- **CPU:** 1
- **RAM:** 512–1024 MB

#### Expected specifications:

- Machine names must use your team logins.
  - Hostname of the first machine: `<login>S` (e.g., `wilS`)
  - Hostname of the second machine: `<login>SW` (e.g., `wilSW`)
- Dedicated IPs on `eth1`:
  - Server: `192.168.56.110`
  - ServerWorker: `192.168.56.111`
- SSH access **without password** on both machines.

#### Installation:

- Install **K3s** on both machines:
  - On **Server**, install in **controller mode**.
  - On **ServerWorker**, install in **agent mode**.
- Install and use **kubectl**.

#### Example `Vagrantfile` (partial):

```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "REDACTED"
  config.vm.box_url = "REDACTED"

  config.vm.define "wilS" do |control|
    control.vm.hostname = "wilS"
    control.vm.network "private_network", ip: "192.168.56.110"
    control.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--name", "wilS"]
    end
    control.vm.provision "shell", path: "REDACTED"
  end

  config.vm.define "wilSW" do |control|
    control.vm.hostname = "wilSW"
    control.vm.network "private_network", ip: "192.168.56.111"
    control.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--name", "wilSW"]
    end
    control.vm.provision "shell", path: "REDACTED"
  end
end
```

> On macOS use `ifconfig eth1`,  
> on Linux use `ip a show eth1` to check IP configuration.

---

### IV.2 Part 2: K3s and three simple applications

Now that you understand K3s basics, time to go further!

Use **one virtual machine** with:
- Latest stable distribution
- K3s in **server mode**

#### Goal:

Deploy **3 web applications** accessible through Ingress routing:
- Accessed via `192.168.56.110`
- The host header decides which app to show:
  - `app1.com` → App 1
  - `app2.com` → App 2 (3 replicas)
  - Otherwise → App 3 (default)

Example behavior:
```bash
curl -H "Host: app1.com" http://192.168.56.110
# Returns App 1 content
```

> The Ingress is not displayed in examples — show it during defense.

---

### IV.3 Part 3: K3d and Argo CD

Now, without Vagrant, use **K3d** (requires Docker).

Write a **setup script** that installs all required tools automatically.

#### Requirements:

- Create two namespaces:
  1. `argocd`
  2. `dev` (contains your app)

The app in the `dev` namespace must be **deployed automatically** via **Argo CD** using a **public GitHub repository**.

Your GitHub repository:
- Must be public
- Must include the login of a team member in its name

#### Application setup:

Two options:
1. Use [Wil’s Playground app on DockerHub](https://hub.docker.com/r/wil42/playground)
   - Port: `8888`
   - Tags: `v1`, `v2`
2. Or create your own Dockerized app and push both versions (`v1`, `v2`).

Update the app by changing the tag in your GitHub repo — Argo CD should detect and sync the change.

Example:
```bash
$ cat deployment.yaml | grep v1
- image: wil42/playground:v1

$ curl http://localhost:8888/
{"status":"ok", "message": "v1"}

# Update to v2
$ sed -i 's/v1/v2/g' deploy.yaml
$ git add . && git commit -m "v2" && git push
```

Argo CD should automatically detect the update and redeploy:
```bash
$ curl http://localhost:8888/
{"status":"ok", "message": "v2"}
```

> During evaluation, demonstrate this deployment workflow live.

---

## Chapter V — Bonus part

Add **GitLab** to the lab from Part 3.

#### Requirements:

- Use the **latest GitLab version** (official site).
- Deploy GitLab **locally** and integrate it with your cluster.
- Use a **namespace** named `gitlab`.
- Ensure everything from Part 3 still works using this local GitLab.

> Use any tool you like (e.g., **Helm**) to complete this bonus.  
> Only evaluated if the **mandatory part is perfect**.

---

## Chapter VI — Submission and peer-evaluation

Submit your assignment in your Git repository.

#### Guidelines:
- Mandatory parts: folders `p1`, `p2`, `p3`
- Optional bonus: folder `bonus`

Example directory structure:
```
.
├── p1/
│   ├── Vagrantfile
│   ├── scripts/
│   └── confs/
├── p2/
│   ├── Vagrantfile
│   ├── scripts/
│   └── confs/
├── p3/
│   ├── scripts/
│   └── confs/
└── bonus/
    ├── Vagrantfile
    ├── scripts/
    └── confs/
```

- Place **scripts** in a `scripts/` folder.
- Place **config files** in a `confs/` folder.
- Evaluation happens on the **evaluated group’s computer**.