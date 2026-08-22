# Inception-of-Things (IoT)

**Summary:** This document is a System Administration related exercise.  
**Version:** 4.0

---

## Contents

- I. [Preamble](#chapter-i--preamble)
- II. [Introduction](#chapter-ii--introduction)
- III. [General guidelines](#chapter-iii--general-guidelines)
- IV. [Mandatory part](#chapter-iv--mandatory-part)
  - IV.1 [Part 1: K3s and Vagrant](#iv1-part-1-k3s-and-vagrant)
  - IV.2 [Part 2: K3s and three simple applications](#iv2-part-2-k3s-and-three-simple-applications)
  - IV.3 [Part 3: K3d and Argo CD](#iv3-part-3-k3d-and-argo-cd)
- V. [Bonus part](#chapter-v--bonus-part)
- VI. [Submission and peer-evaluation](#chapter-vi--submission-and-peer-evaluation)

---

## Chapter I — Preamble

![Learning curves](https://user-images.githubusercontent.com/learning-curves-preamble.png)

---

## Chapter II — Introduction

This project aims to deepen your knowledge by making you use **K3d** and **K3s** with **Vagrant**.

You will learn how to set up a personal virtual machine with Vagrant and the distribution of your choice. Then, you will learn how to use K3s and its Ingress. Last but not least, you will discover K3d that will simplify your life.

These steps will get you started with **Kubernetes**.

> ℹ️ **Note:** This project is a minimal introduction to Kubernetes. Indeed, this tool is too complex to be mastered in a single subject.

---

## Chapter III — General guidelines

- The whole project has to be done in a **virtual machine**.
- You have to put all the configuration files of your project in folders located at the root of your repository (go to [Submission and peer-evaluation](#chapter-vi--submission-and-peer-evaluation) for more information). The folders of the mandatory part will be named: `p1`, `p2`, and `p3`, and the bonus one: `bonus`.
- This topic requires you to apply concepts that, depending on your background, you may not have covered yet. We therefore advise you not to be afraid to read a lot of documentation to learn how to use K8s with K3s, as well as K3d.

> ℹ️ **Note:** You can use any tools you want to set up your host virtual machine as well as the provider used in Vagrant.

---

## Chapter IV — Mandatory part

This project will consist of setting up several environments under specific rules.  
It is divided into three parts you have to do in the following order:

- **Part 1:** K3s and Vagrant
- **Part 2:** K3s and three simple applications
- **Part 3:** K3d and Argo CD

---

### IV.1 Part 1: K3s and Vagrant

To begin, you have to set up **2 machines**.

Write your first `Vagrantfile` using the **latest stable version** of the distribution of your choice as your operating system. It is **STRONGLY advised** to allow only the bare minimum in terms of resources: **1 CPU** and **512 MB of RAM** (or 1024). The machines must be run using Vagrant.

#### Expected specifications:

- The machine names must be the login of someone from your team. The hostname of the first machine must be followed by the capital letter **S** (like *Server*). The hostname of the second machine must be followed by **SW** (like *ServerWorker*).
- Have a dedicated IP on the primary network interface. The IP of the first machine (*Server*) will be `192.168.56.110`, and the IP of the second machine (*ServerWorker*) will be `192.168.56.111`.
- Be able to connect with SSH on both machines with no password.

> ⚠️ **Warning:** You will set up your Vagrantfile according to modern practices.

#### K3s Installation:

You must install K3s on both machines:
- In the first one (*Server*), it will be installed in **controller mode**.
- In the second one (*ServerWorker*), in **agent mode**.

> 💡 **Tip:** You will have to use `kubectl` (and therefore install it as well).

#### Example `Vagrantfile` (basic structure):

```ruby
Vagrant.configure(2) do |config|
  [...]
  config.vm.box = REDACTED
  config.vm.box_url = REDACTED

  config.vm.define "wilS" do |control|
    control.vm.hostname = "wilS"
    control.vm.network REDACTED, ip: "192.168.56.110"
    control.vm.provider REDACTED do |v|
      v.customize ["modifyvm", :id, "--name", "wilS"]
      [...]
    end
    config.vm.provision :shell, :inline => SHELL
    [...]
    SHELL
    control.vm.provision "shell", path: REDACTED
  end

  config.vm.define "wilSW" do |control|
    control.vm.hostname = "wilSW"
    control.vm.network REDACTED, ip: "192.168.56.111"
    control.vm.provider REDACTED do |v|
      v.customize ["modifyvm", :id, "--name", "wilSW"]
      [...]
    end
    config.vm.provision "shell", inline: <<-SHELL
    [...]
    SHELL
    control.vm.provision "shell", path: REDACTED
  end
end
```

> ℹ️ **Note on Network Interfaces:** Modern Linux distributions use predictable network interface names (e.g., `enp0s8`, `enp0s9`) instead of `eth0`/`eth1`. To check your network configuration, use `ip a` to list all interfaces, or `ip a show <interface_name>` for a specific interface. On macOS, use `ifconfig`. Adapt the commands according to your system's actual interface names.

---

### IV.2 Part 2: K3s and three simple applications

You now understand the basics of K3s. Time to go further! To complete this part, you will need **only one virtual machine** with the distribution of your choice (latest stable version) and K3s in server mode installed.

You will set up **3 web applications** of your choice that will run in your K3s instance. You will have to be able to access them depending on the `HOST` used when making a request to the IP address `192.168.56.110`. The name of this machine will be your login followed by **S** (e.g., `wilS` if your login is `wil`).

#### Routing specifications:

When a client inputs the IP address `192.168.56.110` in their web browser:
- With the `HOST app1.com` → the server must display **app1**.
- With the `HOST app2.com` → the server must display **app2** (**3 replicas**).
- Otherwise → **app3** will be selected by default.

> ℹ️ **Note:** Application number 2 has 3 replicas. Adapt your configuration to create the replicas.

> ⚠️ **Warning:** The Ingress is not displayed here on purpose. You will have to show it to your evaluators during your defense.

---

### IV.3 Part 3: K3d and Argo CD

You now master a minimalist version of K3s! Time to set up everything you have just learnt (and much more!) but **without Vagrant this time**. To begin, install **K3d** on your virtual machine.

> 💡 **Tip:** You will need Docker for K3d to work, and probably some other software as well. Therefore, you must write a script to install all the necessary packages and tools during your defense.

First of all, you must understand the difference between K3s and K3d.

Once your configuration works as expected, you can start to create your first continuous integration!

#### Namespaces:

You have to create two namespaces:
- The first one will be dedicated to **Argo CD**.
- The second one will be named **`dev`** and will contain an application. This application will be automatically deployed by Argo CD using your online GitHub repository.

> ℹ️ **Note:** You will have to create a **public repository on GitHub** where you will push your configuration files. You are free to organize it the way you like. The only mandatory requirement is to put the **login of a member of the group** in the name of your repository.

#### Application Setup:

The application to be deployed must have **two different versions** (v1 and v2).

You have two options:
1. **Use the pre-made application created by Wil:**  
   Available on Docker Hub: [hub.docker.com/r/wil42/playground](https://hub.docker.com/r/wil42/playground)  
   The application uses port `8888`. Find the two versions in the TAG section.
2. **Or code and use your own application:**  
   Create a public Docker Hub repository to push a Docker image of your application tagged `v1` and `v2` (the two versions must have a few differences).

#### CD Workflow:

You must be able to change the version from your public GitHub repository, then check that the application has been correctly updated by Argo CD.

```bash
# Verify v1
$ cat deployment.yaml | grep v1
- image: wil42/playground:v1
$ curl http://localhost:8888/
{"status":"ok", "message": "v1"}

# Update to v2
$ sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' deployment.yaml
$ git add deployment.yaml && git commit -m "v2" && git push

# Verify v2 is automatically synchronized & deployed
$ curl http://localhost:8888/
{"status":"ok", "message": "v2"}
```

> ℹ️ **Note:** During the evaluation process, you will have to do this operation with the app you chose (Wil's or yours).

---

## Chapter V — Bonus part

The following bonus task is intended to be useful: **add GitLab** to the lab you completed in Part 3.

> ⚠️ **Warning:** Beware this bonus is complex. The latest version available of GitLab from the official website is expected.

You are allowed to use whatever you need to achieve this extra (for example, Helm could be useful here).

#### Requirements:
- Your GitLab instance must run **locally**.
- Configure GitLab to make it work with your cluster.
- Create a dedicated namespace named **`gitlab`**.
- Everything you did in Part 3 must work with your local GitLab.

Turn this extra work in a new folder named `bonus` located at the root of your repository. You can add everything needed so your entire cluster works.

> ⚠️ **Warning:** The bonus part will only be assessed if the mandatory part is flawless. Flawless means the mandatory part has been fully completed and functions without issues. If you have not passed ALL the mandatory requirements, your bonus part will not be evaluated at all.

---

## Chapter VI — Submission and peer-evaluation

Turn in your assignment in your Git repository as usual. Only the work inside your repository will be evaluated during the defense. Don't hesitate to double-check the names of your folders and files to ensure they are correct.

#### Reminder:
- Turn the mandatory part in three folders located at the root of your repository: `p1`, `p2`, and `p3`.
- *Optional:* Turn the bonus part in a folder located at the root of your repository: `bonus`.

#### Expected directory structure:

```text
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

> 💡 **Tip:** Any scripts you need will be added in a `scripts` folder. The configuration files will be in a `confs` folder.

> ℹ️ **Note:** The evaluation process will happen on the computer of the evaluated group.