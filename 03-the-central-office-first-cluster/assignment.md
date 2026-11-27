---
slug: the-central-office-first-cluster
id: jrwkyw4j6m6g
type: challenge
title: "\U0001F3E2 Chapter 3: The Central Office"
teaser: The central office needs a cluster that survives a host failure. Apply one file and watch Cluster API, Metal3 and Rancher Turtles build site-co-01 on three servers and import it into Rancher Prime.
tabs:
- id: qvobtudr38oj
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: 6y4ehpqe78ob
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
difficulty: intermediate
timelimit: 3000
enhanced_loading: null
---

🏢 Chapter 3: The Central Office
================================

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

<div id="301" class="story">
<span id="ch3.story1" lang="en" hist="northline">
The central office is where Northline's traffic for the whole area comes together. Its old cluster was built by hand, and nobody wants to do that again.

*"Three servers are racked and enrolled,"* Ingrid says. *"I want a cluster on them that keeps running when one of them dies. And I want it written down as a file, so the next one is a copy."*

You open the file Ingrid sent. It is the whole site, from the servers up to the storage.
</span>
</div>

This chapter creates `site-co-01`, the central office. It is a downstream cluster with three control-plane nodes, one on each of `site-co`, `site-co-2` and `site-co-3`, and no workers. Three nodes is what a central office runs: the cluster keeps working if one host fails.

<div class="missionbox">

## 🎯 Your Quest Objectives

1. Read the plan for `site-co-01`
2. Apply it
3. Watch Metal3 build the three servers
4. Find `site-co-01` in Rancher Prime

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

📜 Task 1: Read the plan
========================

`manifests/site-co.yaml` is the SUSE Telco Cloud 3.7 Metal3 quickstart set from telco-examples `release-3.7`, with the SR-IOV charts removed. List the objects in it:

```bash,wrap,run
grep -n '^kind:' manifests/site-co.yaml
```

Each object has one job:

| Object | Job |
|:-------|:----|
| `Cluster` | The cluster itself, with the label `cluster-api.cattle.io/rancher-auto-import: "true"` |
| `Metal3Cluster` | The API endpoint, `192.168.122.20`, and `cloudProviderEnabled: false` |
| `RKE2ControlPlane` | Three replicas of RKE2 `v1.36.3+rke2r1`, Cilium as the CNI |
| `Metal3MachineTemplate` | Which hosts to use, and the image to write to their disks |
| `Metal3DataTemplate` | Per-machine metadata, `metaData` only |

See how the plan picks its servers and its image:

```bash,wrap,run
grep -n -A3 -E 'hostSelector|image:' manifests/site-co.yaml
```

The template asks for hosts labelled `cluster-role: control-plane` and `site: site-co`, never for a host by name. Three hosts match. The image comes from the cache on `mgmt` you found in chapter 1.

A three-node cluster cannot use one host's address for its API. The endpoint `192.168.122.20` is a MetalLB address. The `files` block in the same file writes Helm charts into `/var/lib/rancher/rke2/server/manifests/` on every node, and RKE2 applies them on first boot:

- **MetalLB** and **endpoint-copier-operator** announce `192.168.122.20` and keep the `kubernetes-vip` Service pointed at the API servers
- **SUSE Storage 1.12.1**, three replicas, so the cluster comes up with a default storage class

```bash,wrap,run
grep -n -E 'name: (metallb|endpoint-copier-operator|longhorn)$' manifests/site-co.yaml
```

This is the layout of the SUSE Telco Cloud 3.7 multi-node chapter, with MetalLB as the load balancer. `RKE2ControlPlane` sets `registrationAddress` to the VIP and carries the `load-balancer-exclusion` annotation, so MetalLB stops sending API traffic to a node while Cluster API drains it.

🚀 Task 2: Apply it
===================

One command creates the site:

```bash,wrap,run
kubectl apply -f manifests/site-co.yaml
```

Look at what Cluster API made of it:

```bash,wrap,run
kubectl get clusters -A
kubectl get machines -n default
```

`site-co-01` shows up with machines in `Provisioning`. Cluster API adds the nodes one at a time.

🔧 Task 3: Watch the servers being built
========================================

Metal3 now picks a host for each machine. Ironic powers it on through the BMC, boots its agent from virtual media, and writes the image from the cache to the disk. Then RKE2 starts.

Follow it from the host side:

```bash,wrap,run
kubectl get baremetalhosts -n default
```

The three `site-co` hosts move from `available` to `provisioning`, then `provisioned`. Follow it from the cluster side:

```bash,wrap,run
kubectl get machines -n default
```

Run both commands again every minute or two. The cluster turns `Available` after the first node, and the other two follow. On the tested lab host, all three nodes took about 10 minutes.

Wait until all three machines are `Running` before you click **Check**.

> [!NOTE]
> While you wait, open the [button label="Terminal" variant="success"](tab-0), type `exit` to go back to the KVM host and run `virsh list --all`. The `site-co` hosts are running: Metal3 drives their power through the BMC, not you. Then `ssh root@192.168.122.10` and `cd ~/suse-telco-workshop` to come back.

🐮 Task 4: Find site-co-01 in Rancher Prime
===========================================

Open the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab and go to **Cluster Management**.

`site-co-01` is in the list next to `local`. Nobody imported it by hand: the `rancher-auto-import` label told Rancher Turtles to do it. This workshop teaches that path only: provisioned by Cluster API plus Metal3, then imported by Rancher Turtles.

Wait until `site-co-01` shows **Active**, then open it and look at its three nodes.

> [!WARNING]
> **Starting over.** Delete the Cluster object only: `kubectl delete cluster -n default site-co-01`. Cluster API removes the machines and releases the hosts.
>
> `kubectl delete -f manifests/site-co.yaml` also deletes the Metal3MachineTemplate while the cluster is still going away, and the RKE2 control plane deletion hangs.

💼 Why does this matter?
========================

- **A site is a file.** The servers, the Kubernetes version, the API address and the storage all live in one YAML file you can review and copy.
- **Hosts by label.** The plan asks for any three hosts with the right labels. Replace a dead server with a new one that has the same labels, and the plan still works.
- **In Rancher without a manual step.** The auto-import label puts every new cluster under the same management and access control as the rest of the region.

Click **Check** when all three machines are `Running`.

📚 More information
===================

- [Workshop guide: First downstream cluster](https://avaleror.github.io/suse-telco-workshop/exercises/04-first-downstream/)
- [SUSE Telco Cloud 3.7: Downstream cluster provisioning with Directed network provisioning (multi-node)](https://documentation.suse.com/suse-telco/3.7/html/telco/multi-node.html)
