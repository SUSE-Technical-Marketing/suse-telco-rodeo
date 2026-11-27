---
slug: the-region-tour
id: 8qkzdlo98ml6
type: challenge
title: "\U0001F4E1 Chapter 1: The Region"
teaser: Northline runs a regional mobile network from one management cluster. Walk the KVM host, open your shell on mgmt and find every piece of the region before you build on it.
notes:
- type: text
  contents: |
    # Welcome to the SUSE Telco Cloud Rodeo!

    Please wait while we prepare your lab environment.

    Ingrid, head of network operations at Northline, is waiting for you in the operations room.
tabs:
- id: 8l1vlfs440ww
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: rrb6iep8z12m
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
difficulty: basic
timelimit: 1800
enhanced_loading: null
---

📡 Chapter 1: The Region
========================

<style type="text/css">
  * {
    font-family: suse;
    src: url('https://fonts.google.com/specimen/SUSE');
  }
  .suse { color: #30ba78; }
  .telco { color: #30ba78; }
  .northline { color: #2453ff; }
  .hovereffect {
    border-radius: 25px 25px 25px 25px;
    background: linear-gradient(#30ba78 0 0) var(--hundredpercent, 0) / var(--hundredpercent, 0) no-repeat;
    transition: 0.5s, background-position 0s;
    padding: 5px;
  }
  .hovereffect:hover {
    --hundredpercent: 100%;
    color: white;
    border-radius: 10px 25px 10px 25px;
  }
  .story {
    border-left: 5px solid #2453ff;
    border-radius: 0 15px 15px 0;
    background: linear-gradient(135deg, rgba(48,186,120,.10), rgba(36,83,255,.10));
    padding: 15px 20px;
    margin: 15px 0;
  }
  .story em { color: #2453ff; }
  .missionbox {
    border: 2px dashed #30ba78;
    border-radius: 15px;
    padding: 12px 18px;
    margin: 15px 0;
  }
  .highlightcopy { color: white; font-weight: bold; padding: 0 10px; }
  img.logos { border-radius: 10px; }
  /* compact copy boxes (scoped: only code blocks inside <div class="cred">) */
  .cred > div { margin: 0; }
  .cred .my-3 {
    display: flex;
    flex-direction: row-reverse;   /* put the copy bar on the right */
    align-items: stretch;
    width: fit-content;
    min-width: 14em;
    margin: 4px 0;
    overflow: hidden;
  }
  .cred .my-3 > div:first-child {  /* the bar holding the copy button */
    height: auto;
    padding: 2px 8px;
    border-bottom: none;
    border-left: 1px solid white;
    border-radius: 0;
    display: flex;
    align-items: center;
    background-color: #30ba78;
  }
  .cred .my-3 > div:first-child,
  .cred .my-3 > div:first-child * {
    color: #fff !important;
  }
  .cred .my-3 > div:first-child:hover,
  .cred .my-3 > div:first-child:hover * {
    font-weight: bold;
  }
  .cred .my-3 > pre {
    flex: 1 1 auto;
    margin: 0 !important;
    padding: 2px !important;
    border-radius: 0 !important;
    display: flex;
    align-items: center;
  }
</style>

<div id="101" class="story">
<span id="ch1.story1" lang="en" hist="northline">
<b class="northline">Northline</b> runs a regional mobile network. Its sites grew one at a time, each one built by hand. No two are quite the same.

Northline's head of network operations, Ingrid, points at the wall map. *"Every site we build by hand, we patch by hand,"* she says. *"From today, one management cluster covers the region, and every site comes from the same plan."*

She hands you a Northline badge. *"Before you build on it, learn what is already there."*
</span>
</div>

## <b class="hovereffect">What is SUSE Telco Cloud?</b>

A mobile operator runs many sites, far apart, with few people on the ground. Each site needs servers installed, a Kubernetes cluster on top, and the same workloads as its neighbours. Doing that by hand does not scale past a handful of sites.

**SUSE Telco Cloud 3.7** gives the operator one management cluster that builds and runs the sites. In this lab it is made of these parts:

| What Northline needs | What the lab uses |
|:---------------------|:------------------|
| Install a site's servers without a visit | **Metal3** and **Ironic**, over Redfish virtual media |
| Describe a site cluster as code | **Cluster API** with the RKE2 providers |
| See every site in one place | **Rancher Prime**, with **Rancher Turtles** importing each cluster |
| Ship the same app to many sites | **Fleet**, from a Git repository |
| Run a VM next to containers | **Edge Virtualization** (KubeVirt) |

The site clusters are called downstream clusters, or the runtime stack. They run RKE2 on **SUSE Linux Micro 6.2**.

<div class="missionbox">

## 🎯 Your Quest Objectives

1. Walk the KVM host: the five machines and their BMC
2. Open your shell on `mgmt` and fetch the workshop files
3. Find the image cache the sites boot from
4. Log in to Rancher Prime

</div>

> [!NOTE]
> This lab is for learning. Every "server" here is a virtual machine on one KVM host, with an emulated BMC in front of it. A real site swaps the BMC address and keeps the same YAML.

🔐 Credentials
==============

The player keeps your logins in its **Credentials** panel. This chapter needs one: **SUSE Rancher Prime**.

Username:

<div class="cred">

```txt
admin
```

</div>

Password:

<div class="cred">

```txt
[[ Instruqt-Var key="RANCHER_PASSWORD" hostname="kvm-host" ]]
```

</div>

Your terminal needs no password. Your own SSH key logs you in to `mgmt` as root. The **mgmt VM (console)** entry is for a VM console, and this track does not use one.

🖥️ Task 1: Walk the KVM host
============================

Your [button label="Terminal" variant="success"](tab-0) opens on the KVM host. Every machine in the region is a libvirt guest on this host, on network `default`, bridge `virbr0`, subnet `192.168.122.0/24`.

List them:

```bash,wrap,run
virsh list --all
```

You should see five guests:

| VM | Address | Role |
|:---|:--------|:-----|
| `mgmt` | 192.168.122.10 | Management cluster, image cache, Ironic, Gitea |
| `site-co` | 192.168.122.21 | Host for the central office `site-co-01` |
| `site-co-2` | 192.168.122.23 | Host for `site-co-01` |
| `site-co-3` | 192.168.122.24 | Host for `site-co-01` |
| `site-ran` | 192.168.122.32 | Host for the far-edge site `site-ran-01` |

`mgmt` is running. Metal3 owns the power of the four site hosts through their BMC, so do not start or stop them yourself.

Read the addresses libvirt handed out:

```bash,wrap,run
for vm in mgmt site-co site-co-2 site-co-3 site-ran; do echo "== $vm"; virsh domifaddr $vm; done
```

A host that is shut off prints no address. Its reserved address is the one in the table.

Now find the BMC. Metal3 talks to each site host through Redfish, the same API a real server's BMC speaks. Here, sushy-tools emulates that BMC on the KVM host, on port `8000`:

```bash,wrap,run
systemctl status rodeo-sushy --no-pager | head -n 5
```

Ask it for its systems without a login:

```bash,wrap,run
curl -sk -o /dev/null -w '%{http_code}\n' https://192.168.122.1:8000/redfish/v1/Systems
```

`401` is the answer you want. The BMC is there, and it refuses anyone without credentials.

⌨️ Task 2: Open your shell on mgmt
==================================

Every `kubectl` and `helm` command in this track runs on `mgmt`, as root. rodeo installed both there and gave root a kubeconfig for the management cluster, so there is nothing to configure.

Your SSH key already works on `mgmt`:

```bash,wrap,run
ssh root@192.168.122.10
```

The prompt changes to `mgmt`. Fetch the workshop files and stay in that directory for the rest of the track:

```bash,wrap,run
curl -fsSL https://github.com/avaleror/suse-telco-workshop/archive/refs/heads/main.tar.gz | tar xz
cd suse-telco-workshop-main
ls manifests
```

`manifests/` holds the YAML you apply in later chapters. rodeo does not apply it for you.

Look at the management cluster itself:

```bash,wrap,run
kubectl get nodes -o wide
kubectl version
```

One node, `mgmt`, `Ready`. The server version reads `v1.36.3+rke2r1`: the management cluster is RKE2 on SUSE Linux Micro 6.2.

> [!NOTE]
> `virsh` runs on the KVM host, not on `mgmt`. To go back to the host, type `exit`. To come back to `mgmt`, run the `ssh` command again and `cd ~/suse-telco-workshop-main`.

💽 Task 3: Find the image cache
===============================

A site host boots from an operating system image. Northline does not want each site pulling that image from the internet, so `mgmt` keeps a local copy.

The image cache is nginx in namespace `imagecache`, serving `/opt/media` at `http://imagecache.local:8080`:

```bash,wrap,run
kubectl -n imagecache get pods
ls -lh /opt/media
```

It already holds `eibimage-downstream-cluster.raw` and its `.sha256`. rodeo built that image before class with Edge Image Builder 1.3.4, so you are not waiting on a build.

🐮 Task 4: Log in to Rancher Prime
==================================

Open the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab and log in as `admin`, with the password above.

> [!NOTE]
> Rancher uses its own self-signed certificate. Accept the browser warning if one appears.

Open the menu at the top left and go to **Cluster Management**. You see one cluster, `local`: the management cluster you just looked at with `kubectl`.

The region has no sites in Rancher yet. You create them in chapters 3 and 4.

💼 Why does this matter?
========================

- **One place to start from.** The management cluster, the image cache and the BMC endpoint are the same for every site. A new site does not need a new toolchain.
- **Servers as an API.** Metal3 sees a Redfish BMC, whether it is sushy-tools in this lab or a real server's controller. The YAML you write stays the same.
- **No image download per site.** Sites boot from the cache on `mgmt`, which matters when a far-edge site sits on a thin link.

Click **Check** to confirm your shell and the workshop files are in place.

📚 More information
===================

- [Workshop guide: Tour the region](https://avaleror.github.io/suse-telco-workshop/exercises/01-environment-tour/)
- [Workshop guide: Architecture and hardware](https://avaleror.github.io/suse-telco-workshop/reference/architecture/)
- [Workshop guide: Lab overview](https://avaleror.github.io/suse-telco-workshop/reference/lab-overview/)
