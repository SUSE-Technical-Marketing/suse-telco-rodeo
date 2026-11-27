---
slug: the-far-edge-clusterclass
id: 161fycvnhhi3
type: challenge
title: "\U0001F5FC Chapter 4: The Far Edge"
teaser: Far-edge sites are small and there are many of them. Turn the site plan into a ClusterClass template, stamp out site-ran-01 from it, and see both sites in one Rancher Prime.
tabs:
- id: 5751oplu8a6h
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: mrev2japvh3r
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
difficulty: intermediate
timelimit: 2400
enhanced_loading: null
---

🗼 Chapter 4: The Far Edge
==========================

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

<div id="401" class="story">
<span id="ch4.story1" lang="en" hist="northline">
The central office is up. Ingrid is already looking past it, at the radio sites on the map.

*"The far edge is a different job,"* Ingrid says. *"One server per site, in a cabinet at the foot of a mast, and a lot of sites."*

*"A file the size of the central office plan, for every one of them, is more than my team can review. Give me a template, so a new site is a name and a few values."*
</span>
</div>

`site-co-01` was written out object by object. A far-edge site is smaller and there are many of them, so an operator stamps them out from a template instead. In Cluster API that template is a **ClusterClass**.

This chapter adds ClusterClass `example-clusterclass` in namespace `northline`, then `site-ran-01` from it: one host, `site-ran`.

<div class="missionbox">

## 🎯 Your Quest Objectives

1. Read the template and the site that uses it
2. Apply both
3. See two sites in one Rancher Prime

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
cd ~/suse-telco-workshop-main
```

📐 Task 1: Read the template and the site
=========================================

The template lives in `manifests/clusterclass.yaml`. It creates namespace `northline` and the class, with three variables a site fills in:

```bash,wrap,run
grep -n -E '^  - name: (clusterType|controlPlaneEndpointHost|tlsSan)' manifests/clusterclass.yaml
```

The class owns the control-plane machine template. Cluster API clones it for each cluster and fills in the site type, so the host selector follows the variable `clusterType`. Like `site-co-01`, the class ships MetalLB and endpoint-copier-operator with every cluster, so each site gets a stable API address.

Now the site itself. Compare its size with `site-co.yaml`:

```bash,wrap,run
cat manifests/site-ran.yaml
wc -l manifests/site-ran.yaml manifests/site-co.yaml
```

`site-ran-01` names its class, one control-plane replica, RKE2 `v1.36.3+rke2r1`, the auto-import label and the endpoint `192.168.122.22`. That endpoint is a MetalLB address on the new cluster. The `site-ran` host itself keeps `192.168.122.32`.

With `clusterType: site-ran`, the cluster selects hosts labelled `cluster-role: control-plane`, `deploy-region: northline` and `cluster-type: site-ran`. You saw those labels on `site-ran` in chapter 2.

🚀 Task 2: Apply the template and the site
==========================================

Apply the class first, then the site:

```bash,wrap,run
kubectl apply -f manifests/clusterclass.yaml
kubectl apply -f manifests/site-ran.yaml
```

Check both clusters:

```bash,wrap,run
kubectl get clusters -A
kubectl get machines -n northline
kubectl get baremetalhosts -n northline
```

Metal3 builds `site-ran` the same way it built the central office: BMC, virtual media, image from the cache, then RKE2. This time there is one machine to wait for. Run the last two commands again until the machine is `Running`.

> [!NOTE]
> **Real-time kernel.** In production, RAN sites run the SUSE Linux Micro real-time image on tuned bare metal. This lab uses the standard image for every site: the sites are nested VMs, so a real-time kernel would show nothing here.

🐮 Task 3: Two sites, one Rancher
=================================

Open the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab and go to **Cluster Management**.

`site-ran-01` joins `site-co-01` and `local`. Turtles imported it through the same auto-import label. Wait until it shows **Active**.

`site-ran-01` is the far-edge site. It does not get Edge Virtualization in this lab.

Scale, as this lab teaches it, is a replica count plus one `BareMetalHost` per machine. The lab stops at two sites. The published ceiling to quote is the large row of the Rancher Manager 2.15 sizing table: 500 clusters and 5,000 nodes, at 16 vCPU and 64 GB per management node, under the assumptions on that page.

The SUSE Telco Cloud guide does not publish a downstream count of its own. More than one management cluster is how an operator covers several regions and limits the blast radius of an upgrade. Northline uses one.

💼 Why does this matter?
========================

- **A new site is a short file.** The class holds everything common. Each site states only what makes it different, such as its endpoint and its ClusterClass variables.
- **One change, every site.** Fix the class and every cluster made from it follows. Nobody edits a pile of hand-written files.
- **One view for the region.** The central office and the far edge sit side by side in the same Rancher Prime, with the same access control.

Click **Check** when the `site-ran-01` machine is `Running`.

📚 More information
===================

- [Workshop guide: exercise 5, the far-edge site](https://avaleror.github.io/suse-telco-workshop/exercises/05-clusters-at-scale/)
- [telco-examples, release-3.7](https://github.com/suse-edge/telco-cloud-examples/tree/release-3.7/telco-examples)
