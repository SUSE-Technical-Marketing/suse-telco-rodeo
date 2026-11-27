---
slug: the-control-room-stack-and-hosts
id: 3031f4d919j7
type: challenge
title: "\U0001F39B️ Chapter 2: The Control Room"
teaser: The management stack is already installed and four site servers wait in the inventory. Identify every controller, read the versions, and check the servers Metal3 will build on.
tabs:
- id: 58olqxfw022t
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: 5wwzz5tc8qqv
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
difficulty: basic
timelimit: 2700
enhanced_loading: null
---

🎛️ Chapter 2: The Control Room
==============================

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

<div id="201" class="story">
<span id="ch2.story1" lang="en" hist="northline">
Ingrid walks you into the control room. One screen shows the management cluster. Another shows a list of four servers, all marked ready.

*"Nobody installed anything here today,"* she says. *"The stack came up before you arrived, and the servers enrolled themselves through their BMCs."*

*"Your job this morning is to know every piece by name and version. When a site misbehaves at three in the morning, you will not have time to guess."*
</span>
</div>

This chapter is about identification. `rodeo up` already installed the management stack and enrolled the site servers, so there is nothing to install.

<div class="missionbox">

## 🎯 Your Quest Objectives

1. Find the controllers that build a site
2. Read their versions against the SUSE Telco Cloud 3.7 pins
3. Inspect the four enrolled servers

</div>

🔐 Credentials
==============

The **SUSE Rancher Prime** UI uses the `admin` user. The password is below, and also in the **Credentials** panel in the header.

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

Your terminal logs in to `mgmt` with your SSH key, no password.

⌨️ Your shell on mgmt
=====================

The commands in this chapter run on `mgmt`, in the workshop directory. If your [button label="Terminal" variant="success"](tab-0) prompt does not show `mgmt`, open the shell again:

```bash,wrap,run
ssh root@192.168.122.10
```

```bash,wrap,run
cd ~/suse-telco-workshop
```

🔎 Task 1: Find the controllers
===============================

A downstream cluster is built by a chain of controllers on the management cluster. Find them:

```bash,wrap,run
kubectl get pods -A
```

Look for these, by namespace:

| Namespace | What it does |
|:----------|:-------------|
| `cattle-system` | Rancher Prime |
| `cattle-turtles-system` | Rancher Turtles: imports Cluster API clusters into Rancher |
| `cattle-capi-system` | Cluster API core controller |
| `capm3-system` | CAPM3: the Cluster API provider for Metal3 |
| `rke2-bootstrap-system`, `rke2-control-plane-system` | The RKE2 bootstrap and control-plane providers |
| `metal3-system` | Metal3: baremetal-operator and Ironic |
| `cert-manager` | cert-manager, for the controllers' certificates |

Now list the object types they add to the Kubernetes API:

```bash,wrap,run
kubectl api-resources | grep -Ei 'cluster|metal3|baremetal|turtles|rke2'
```

You should see `clusters` and `machines` from Cluster API, `baremetalhosts` and `metal3machinetemplates` from Metal3, and `rke2controlplanes` from the RKE2 provider. IPAM types can show up too. This lab does not use upstream Metal3 IPAM objects.

> [!NOTE]
> NeuVector is left out of this lab on purpose. If you do not see it, that matches the pin.

🏷️ Task 2: Read the versions
============================

A telco stack is a set of pinned versions that SUSE tests together. Read what this region runs. First, the Helm releases:

```bash,wrap,run
helm list -A
```

Then the controller images, namespace by namespace:

```bash,wrap,run
for ns in cattle-turtles-system cattle-capi-system capm3-system rke2-bootstrap-system rke2-control-plane-system metal3-system; do
  echo "== $ns"
  kubectl -n $ns get deploy -o jsonpath='{range .items[*]}{.metadata.name}{"  "}{.spec.template.spec.containers[*].image}{"\n"}{end}'
done
```

Compare what you see with the SUSE Telco Cloud 3.7.0 pins:

| Component | Pin |
|:----------|:----|
| Rancher Prime | 2.15.1 |
| Rancher Turtles | `v0.27.1`, built into Rancher |
| Turtles providers chart | `307.0.8+up0.27.0` |
| Cluster API controller | `v1.13.3` |
| RKE2 bootstrap and control-plane providers | `v0.25.0` |
| CAPM3 | `v1.13.2` |
| Metal3 chart | `307.0.31+up0.16.0`, with baremetal-operator 0.13.3 |
| Ironic | 38.0.0 |
| cert-manager | 1.20.1 |

The management node is RKE2 `v1.36.3+rke2r1` on SUSE Linux Micro 6.2, with Cilium as the CNI. Ironic keeps its working data on an `emptyDir` volume, the Metal3 chart default for a single management node. SUSE Storage stays off `mgmt`: it runs on the sites.

🗄️ Task 3: Inspect the enrolled servers
=======================================

`rodeo up` registered four `BareMetalHost` objects and waited until Ironic had inspected each one. You do not enroll them by hand. You read them and see what a real server would change.

```bash,wrap,run
kubectl get baremetalhosts -A
```

Then the fields that matter, side by side:

```bash,wrap,run
kubectl get baremetalhosts -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATE:.status.provisioning.state,BMC:.spec.bmc.address
```

Check three things on each host:

1. The state is `available`.
2. The BMC address is a `redfish-virtualmedia://192.168.122.1:8000/...` URL: the sushy-tools BMC you found in chapter 1. That is the only BMC method this stack supports.
3. The labels say which site a host belongs to.

Read the labels:

```bash,wrap,run
kubectl get baremetalhosts -A --show-labels
```

`site-co`, `site-co-2` and `site-co-3` live in namespace `default` and carry `cluster-role: control-plane` and `site: site-co`. `site-ran` lives in namespace `northline` and carries `cluster-role: control-plane`, `deploy-region: northline` and `cluster-type: site-ran`. Cluster API picks hosts by these labels in the next chapters.

For the full record of one host, including what Ironic found during inspection:

```bash,wrap,run
kubectl get baremetalhost -n default site-co -o yaml
```

A real server uses this same API. Only the BMC address changes, from sushy-tools to that server's own Redfish virtual-media address.

🐮 Bonus: the same view in Rancher Prime (optional)
===================================================

Open the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab and open the `local` cluster. Use the resource search at the top of the cluster view and look for `BareMetalHost`.

You see the same four hosts. Rancher reads the same Kubernetes objects you just read with `kubectl`.

💼 Why does this matter?
========================

- **Versions you can name.** The whole stack is a tested set of pins. When you open a support case, you can say exactly what runs.
- **Servers as inventory.** Each server is a `BareMetalHost` with a state, a BMC address and labels. A cluster asks for hosts by label, never by name.
- **The same API on real hardware.** Swap the BMC address and the rest of the YAML stays the same.

Click **Check** to confirm the stack is healthy and all four servers are ready to build on.

📚 More information
===================

- [Workshop guide: Management stack](https://avaleror.github.io/suse-telco-workshop/exercises/02-management-stack/)
- [Workshop guide: Enroll site servers](https://avaleror.github.io/suse-telco-workshop/exercises/03-enroll-hosts/)
- [Workshop guide: Product language](https://avaleror.github.io/suse-telco-workshop/reference/product-language/)
