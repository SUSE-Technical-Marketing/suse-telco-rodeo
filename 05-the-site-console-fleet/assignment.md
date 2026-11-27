---
slug: the-site-console-fleet
id: zjj4urcewpz2
type: challenge
title: "\U0001F4DF Chapter 5: The Site Console"
teaser: Every site needs the same operations console, and nobody should copy it there by hand. Label both sites and let Fleet deliver the console from Git to site-co-01 and site-ran-01 at once.
tabs:
- id: xxcxjnrhtpsy
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: 4negpdm8fw0g
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
- id: ikx7j7chuoxj
  title: Gitea
  type: service
  hostname: kvm-host
  path: /gitea/telco-site-console
  port: 3000
  protocol: http
- id: qg0wvc7xgjbx
  title: Site console (site-co-01)
  type: service
  hostname: kvm-host
  path: /
  port: 30080
  protocol: http
- id: 0vl0i2lhtsih
  title: Site console (site-ran-01)
  type: service
  hostname: kvm-host
  path: /
  port: 30081
  protocol: http
difficulty: intermediate
timelimit: 1800
enhanced_loading: null
---

📟 Chapter 5: The Site Console
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

<div id="501" class="story">
<span id="ch5.story1" lang="en" hist="northline">
Two sites are live. The field team wants the same thing on both: an operations console that tells them which site they are standing in and how it is doing.

*"Last time we did this, someone copied the files to each site by hand,"* Ingrid says. *"Half of them ended up on an old version."*

*"This time the console lives in one Git repository. Any site with the right labels gets it, and gets every change after it."*
</span>
</div>

The container on the site is an operations console. Operator language: this is the CNF-side workload. The pod is still an operations console: it has no user plane, no SR-IOV and no Multus.

**Fleet**, the GitOps engine in Rancher Prime, delivers it. The GitRepo targets clusters labelled `demo=true` and `site-type=downstream`.

<div class="missionbox">

## 🎯 Your Quest Objectives

1. Find the console's source in Gitea
2. Label both sites
3. Deliver the console with Fleet
4. Open the console on each site

</div>

🔐 Credentials
==============

Rancher Prime: user `admin`, password in the player's **Credentials** panel, under **SUSE Rancher Prime**. The Gitea repository is public, so you can browse it without a login. Your terminal logs in to `mgmt` with your SSH key, no password.

⌨️ Your shell on mgmt
=====================

The commands in this chapter run on `mgmt`, in the workshop directory. If your [button label="Terminal" variant="success"](tab-0) prompt does not show `mgmt`, open the shell again:

```bash,wrap,run
ssh root@192.168.122.10
```

```bash,wrap,run
cd ~/suse-telco-workshop-main
```

📦 Task 1: Find the source in Gitea
===================================

Fleet needs a Git repository to read from. A far-edge site should not depend on the internet for that, so the source lives on `mgmt`.

Open the [button label="Gitea" variant="success"](tab-2) tab: Gitea on `mgmt`, at `http://192.168.122.10:3000`. If it opens on the start page, click **Explore** in the top bar and open the repository `gitea/telco-site-console`.

rodeo copied `https://github.com/avaleror/telco-site-console.git` into this Gitea when it built the lab. Fleet never goes to GitHub during the lab. Open `fleet.yaml` in the repository: it is how Fleet knows what to deploy from it.

Now read the GitRepo you will apply:

```bash,wrap,run
cat manifests/site-console-gitrepo.yaml
```

It points at `http://192.168.122.10:3000/gitea/telco-site-console.git`, branch `main`, and targets clusters with both labels. Selectors inside the console's `fleet.yaml` do not apply when the GitRepo sets its own targets.

🏷️ Task 2: Label both sites
===========================

The imported clusters carry no labels yet. Fleet reads them from the Rancher cluster objects, and those have generated IDs (`c-xxxxx`), so look each one up by its display name:

```bash,wrap,run
for c in site-co-01 site-ran-01; do
  id=$(kubectl get clusters.management.cattle.io \
    -o jsonpath="{.items[?(@.spec.displayName==\"$c\")].metadata.name}")
  kubectl label clusters.management.cattle.io "$id" demo=true site-type=downstream --overwrite
done
```

Rancher copies the labels to the Fleet clusters within a few seconds. Check:

```bash,wrap,run
kubectl get clusters.fleet.cattle.io -n fleet-default -L demo,site-type
```

Both sites show `true` and `downstream`.

> [!NOTE]
> You can also add the labels in the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab, under **Cluster Management**, **Edit Config** on each cluster.

🚚 Task 3: Deliver the console
==============================

Apply the GitRepo:

```bash,wrap,run
kubectl apply -f manifests/site-console-gitrepo.yaml
```

Fleet clones the repository from Gitea, builds a Bundle and rolls it out to every matching cluster:

```bash,wrap,run
kubectl get gitrepo -n fleet-default
kubectl get bundle -n fleet-default
```

Run them again until the Bundle reports ready on both clusters. In Rancher, **Continuous Delivery** shows the same GitRepo and where it landed.

🖥️ Task 4: Open the console on each site
========================================

The console listens on node port `30080` of a host in each site: `192.168.122.21` (or `.23`, `.24`) for `site-co-01`, and `192.168.122.32` for `site-ran-01`.

Open the [button label="Site console (site-co-01)" variant="success"](tab-3) tab, then the [button label="Site console (site-ran-01)" variant="success"](tab-4) tab.

Each console shows its own site name in the header. Rancher labels each Fleet cluster with its display name, and the repository's `fleet.yaml` passes that label to the chart. `CLUSTER_NAME` in the console must match the cluster you are on.

Check the Bundle status, not only the page. A console can answer on `30080` while the Bundle is `NotReady`, for example when one image in the repository fails to pull.

Live panels are cluster facts. Simulated rows stay labelled simulated.

💼 Why does this matter?
========================

- **Labels decide, not people.** A new site with `demo=true` and `site-type=downstream` gets the console the moment it is imported. Nobody logs in to it.
- **Git is the record.** Every site runs what is in the repository. To change the console everywhere, change the repository.
- **No internet needed at the site.** Fleet reads from Gitea on the management cluster, which suits sites on thin or closed links.

Click **Check** when the Bundle is ready on both sites.

📚 More information
===================

- [Workshop guide: Site console](https://avaleror.github.io/suse-telco-workshop/exercises/06-site-console/)
- [Fleet documentation](https://fleet.rancher.io/)
