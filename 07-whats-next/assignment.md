---
slug: whats-next
id: xm4y6fhob18l
type: challenge
title: "\U0001F305 Chapter 7: What's Next"
teaser: Northline's region now runs from one management cluster. Review what you built, look around the lab while it lasts, and see where the same pattern goes on real hardware.
tabs:
- id: 2prxuw1hrl2b
  title: Terminal
  type: terminal
  hostname: kvm-host
- id: h8bermx02y0b
  title: SUSE Rancher Prime
  type: service
  hostname: kvm-host
  path: /
  port: 30002
  protocol: https
- id: hymh36ccyrg8
  title: Gitea
  type: service
  hostname: kvm-host
  path: /gitea/telco-site-console
  port: 3000
  protocol: http
- id: n7064r9yg8tb
  title: Site console (site-co-01)
  type: service
  hostname: kvm-host
  path: /
  port: 30080
  protocol: http
- id: 3ajny57c163w
  title: Site console (site-ran-01)
  type: service
  hostname: kvm-host
  path: /
  port: 30081
  protocol: http
difficulty: basic
timelimit: 1200
enhanced_loading: null
---

🌅 Chapter 7: What's Next
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

<div id="701" class="story">
<span id="ch7.story1" lang="en" hist="northline">
The wall map in the operations room has two green dots now. Ingrid looks at them for a while.

*"Two sites, and neither one was built by hand,"* she says. *"The next one is a copy of a file and a few labels."*

*"Write down what you did. The next region starts on Monday."*
</span>
</div>

## <b class="hovereffect">🏆 What you built</b>

| Chapter | Northline's problem | What you did |
|:--------|:--------------------|:-------------|
| 📡 The Region | Sites built by hand, each one different | Walked the KVM host, the BMC, the image cache and the management cluster |
| 🎛️ The Control Room | Nobody could name every piece | Identified the controllers, read the pinned versions, inspected four enrolled servers |
| 🏢 The Central Office | A cluster that must survive a host failure | Built three-node `site-co-01` with Cluster API and Metal3, imported by Rancher Turtles |
| 🗼 The Far Edge | Many small sites, too many files | Stamped out `site-ran-01` from a ClusterClass |
| 📟 The Site Console | The same app, copied by hand to each site | Labelled both sites and let Fleet deliver the console from Gitea |
| 💾 The Holdout | A function that ships only as a VM | Ran `site-co-guest` with Edge Virtualization next to the console, on SUSE Storage |

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

🧭 Victory lap: the lab is still yours
======================================

The lab stays up until your timer runs out. Use it. Some ideas:

- **Walk the region in the UI.** In the [button label="SUSE Rancher Prime" variant="success"](tab-1) tab, open **Cluster Management**, then **Continuous Delivery**. Both sites, and what Fleet sent to them, are there.
- **Look at the source.** The [button label="Gitea" variant="success"](tab-2) tab shows the repository every site runs the console from.
- **Visit both sites.** Open the [button label="Site console (site-co-01)" variant="success"](tab-3) and the [button label="Site console (site-ran-01)" variant="success"](tab-4) tabs side by side.
- **Count it all from the command line.** In the [button label="Terminal" variant="success"](tab-0), on `mgmt`, against the management cluster:

```bash,wrap,run
unset KUBECONFIG
kubectl get clusters.cluster.x-k8s.io -A
kubectl get baremetalhosts -A
kubectl get gitrepo,bundle -n fleet-default
```

And on `site-co-01`:

```bash,wrap,run
kubectl --kubeconfig ~/site-co-01.kubeconfig get nodes,vm,vmi -A
```

🚀 What's next
==============

- 🔌 **Real servers.** Only the BMC address changes, from sushy-tools to a server's own Redfish virtual-media address. [telco-examples on `release-3.7`](https://github.com/suse-edge/telco-cloud-examples/tree/release-3.7/telco-examples) shows a real Redfish URL.
- 🧰 **The rest of the telco toolkit.** The same examples cover the `dhcp-less` nmstate tree, SR-IOV, CPU Manager and the air-gap management ISO. This lab left them out on purpose.
- 🛤️ **Other onboarding paths.** SUSE Telco Cloud 3.7 also supports an Edge Image Builder standalone cluster, then an import into Rancher. This lab taught Cluster API plus Metal3, then the Turtles auto-import label.
- 📖 **The workshop guide.** Every chapter here follows the [SUSE Telco Cloud workshop guide](https://avaleror.github.io/suse-telco-workshop/), with the full architecture and hardware notes.
- 💬 **Your own region.** Talk to your SUSE representative about what this would look like with your sites, your servers and your network functions.

<div id="702" class="story">
<span id="ch7.story2" lang="en" hist="northline">
Thank you for building Northline's region with us.

**Happy provisioning!** 🎉
</span>
</div>

📚 More information
===================

- [SUSE Telco Cloud 3.7: Downstream cluster provisioning (multi-node)](https://documentation.suse.com/suse-telco/3.7/html/telco/multi-node.html)
- [SUSE Telco Cloud 3.7: Edge Virtualization](https://documentation.suse.com/suse-telco/3.7/html/telco/components-kubevirt.html)
- [Workshop guide: Bonus, not numbered](https://avaleror.github.io/suse-telco-workshop/reference/bonus/)
- [Fleet documentation](https://fleet.rancher.io/)
