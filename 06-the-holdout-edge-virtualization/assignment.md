---
slug: the-holdout-edge-virtualization
id: rpem18qynuly
type: challenge
title: "\U0001F4BE Chapter 6: The Holdout"
teaser: One network function still ships only as a VM. Add Edge Virtualization to site-co-01 and run that guest next to the site console, on the same cluster, with its disk on SUSE Storage.
tabs:
- id: 2bk8qwlnb1wb
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: rk5k9hjcuvfg
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
- id: i2fpnudjcqau
  title: Site console (site-co-01)
  type: service
  hostname: kvm-host
  path: /
  port: 30080
  protocol: http
difficulty: advanced
timelimit: 3000
enhanced_loading: null
---

💾 Chapter 6: The Holdout
=========================

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

<div id="601" class="story">
<span id="ch6.story1" lang="en" hist="northline">
Everything at the central office runs in containers now. Everything except one function, from a vendor that still ships it only as a virtual machine.

*"Today that VM has its own server and its own hypervisor,"* Ingrid says. *"Another box to power, patch and license, at every central office."*

*"Put it on the cluster we already run. Same servers, same storage, same Rancher."*
</span>
</div>

Do this on `site-co-01` only. `site-ran-01` stays without a guest.

The feature is **Edge Virtualization**. The project behind it is **KubeVirt**, at 1.8.3 in this lab, with **CDI** 1.65.0 to import disks.

Operator language: the VM is a VNF. In this lab it is one guest, VirtualMachine `site-co-guest`.

<div class="missionbox">

## 🎯 Your Quest Objectives

1. Point `kubectl` at `site-co-01`
2. Check the storage the guest will use
3. Install KubeVirt and CDI
4. Start the guest and see it next to the console

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

🎯 Task 1: Point kubectl at site-co-01
======================================

Every command in this chapter goes to `site-co-01`, not to the management cluster. Cluster API keeps the cluster's kubeconfig in a Secret on `mgmt`. Write it to a file and point `kubectl` and `helm` at it:

```bash,wrap,run
kubectl get secret -n default site-co-01-kubeconfig -o jsonpath='{.data.value}' | base64 -d > ~/site-co-01.kubeconfig
export KUBECONFIG=~/site-co-01.kubeconfig
kubectl get nodes
```

Three nodes, all `Ready`. The API address in that file is `https://192.168.122.20:6443`, the MetalLB address from chapter 3.

> [!NOTE]
> `KUBECONFIG` lives only in this shell. If you open a new shell on `mgmt`, run the `export` line again. To go back to the management cluster, run `unset KUBECONFIG`.

🗄️ Task 2: Check the storage
============================

The guest disk is a PersistentVolumeClaim, so `site-co-01` needs a storage class before CDI can import anything. **SUSE Storage** 1.12.1 (Longhorn) came with the cluster: the `files` block in `manifests/site-co.yaml` installed it on first boot.

```bash,wrap,run
kubectl get storageclass
kubectl -n longhorn-system get nodes.longhorn.io
```

`longhorn` is the default class, and all three nodes show in SUSE Storage. The class keeps three replicas of every volume, one per node, so a volume survives the loss of one host.

SUSE Storage needs `open-iscsi` and a running `iscsid` on every node. The site image rodeo builds already has both.

⚙️ Task 3: Install KubeVirt and CDI
===================================

Install both from the SUSE registry, at the SUSE Telco Cloud 3.7 pins:

| Component | Version | Chart |
|:----------|:--------|:------|
| KubeVirt | 1.8.3 | `307.0.3+up0.8.0` |
| CDI | 1.65.0 | `307.0.3+up0.8.0` |

```bash,wrap,run
helm install kubevirt oci://registry.suse.com/edge/charts/kubevirt \
  --version 307.0.3+up0.8.0 -n kubevirt-system --create-namespace
helm install cdi oci://registry.suse.com/edge/charts/cdi \
  --version 307.0.3+up0.8.0 -n cdi-system --create-namespace
```

Wait for both to report `Available`. KubeVirt can take several minutes:

```bash,wrap,run
kubectl -n kubevirt-system wait kubevirt --all --for=condition=Available --timeout=600s
kubectl -n cdi-system wait cdi --all --for=condition=Available --timeout=300s
```

🖥️ Task 4: Start the guest
==========================

The guest runs one level deeper: inside a `site-co` host, which is itself a VM on the KVM host. That only works because the `site-co` hosts have nested virtualization.

Read the manifest first:

```bash,wrap,run
cat manifests/kubevirt-vm.yaml
```

The file is the guest only. It does not install KubeVirt.

CDI imports the disk from the registry source in the manifest onto the default storage class, through a DataVolume. Longhorn V2 backing images are not supported for this import.

Start it:

```bash,wrap,run
kubectl apply -f manifests/kubevirt-vm.yaml
```

Follow the import, then the VM:

```bash,wrap,run
kubectl get dv,pvc
kubectl get vm,vmi -o wide
```

The DataVolume reaches `Succeeded` first, then the VMI goes `Running`. Run the commands again until it does. The `NODENAME` column shows which of the three hosts runs the guest.

👀 Task 5: Two workloads, one site
==================================

Look at both workloads on `site-co-01`:

```bash,wrap,run
kubectl get pods -A | grep -E 'virt-launcher|telco-site-console'
```

The console pod from chapter 5 and the `virt-launcher` pod that holds `site-co-guest` run on the same cluster. Open the [button label="Site console (site-co-01)" variant="success"](tab-2) tab: the console still answers.

In the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab, open `site-co-01` and search for `VirtualMachine` in the resource search. The guest is one more Kubernetes object, under the same access control as the rest of the site.

🧩 Bonus: the dashboard extension (optional)
============================================

SUSE Telco Cloud 3.7 ships a KubeVirt dashboard extension for Rancher Prime, chart `307.0.5+up1.4.2` (extension 1.4.2). It adds VM views to the Rancher UI.

The install steps are in the [Edge Virtualization](https://documentation.suse.com/suse-telco/3.7/html/telco/components-kubevirt.html) chapter of the SUSE Telco Cloud 3.7 guide. The check does not need it.

💼 Why does this matter?
========================

- **One platform for both.** The VM-only function runs on the servers, storage and management the site already has. No separate hypervisor stack per site.
- **The disk is protected.** SUSE Storage keeps three replicas of the guest disk, one per host, so the VM's data survives the loss of a server.
- **A path off the VM.** When the vendor ships a container version, it moves to the same cluster. Nothing else about the site changes.

Click **Check** when `site-co-guest` is `Running`.

📚 More information
===================

- [Workshop guide: Edge Virtualization](https://avaleror.github.io/suse-telco-workshop/exercises/07-edge-virtualization/)
- [SUSE Telco Cloud 3.7: Edge Virtualization](https://documentation.suse.com/suse-telco/3.7/html/telco/components-kubevirt.html)
- [KubeVirt user guide](https://kubevirt.io/user-guide/)
