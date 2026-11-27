# SUSE Telco Cloud Rodeo

A story-driven lab track for the rodeo player. Participants join the platform team at
**Northline**, a regional mobile network, and build its region on **SUSE Telco Cloud 3.7**:
one management cluster with **Rancher Prime**, **Cluster API**, **Metal3** and
**Rancher Turtles**, a three-node central office, a far-edge site from a ClusterClass,
an operations console delivered by **Fleet**, and a VM next to containers with
**Edge Virtualization**.

The lab runs on a KVM host built by rodeo-cli with the `suse-telco` profile. The
management stack is installed and the four site servers are enrolled before the
student arrives, so the session goes to the tasks, not to installs.

**Versions:** SUSE Telco Cloud 3.7.0 · Rancher Prime 2.15.1 · RKE2 v1.36.3+rke2r1 · SUSE Linux Micro 6.2 · KubeVirt 1.8.3
**Duration:** about 3 hours 15 minutes, the same writing target as the workshop guide
**Audience:** platform and network operations teams at telecom operators
**Track version:** draft, not released

> **This repo is the lab content only.** The infrastructure it runs on is built and
> owned by **rodeo-cli**. The exercises follow the
> [SUSE Telco Cloud workshop guide](https://github.com/avaleror/suse-telco-workshop)
> (branch `docs/lab-player`, the student-path version), and the YAML the student
> applies comes from that repo's `manifests/`.

## The story

Northline's sites grew one at a time, each built by hand. Ingrid, head of network
operations, wants one management cluster for the region and every site built from the
same plan. Each chapter is one step of that change: learn the region, name every piece
of the stack, build the central office, stamp out the far edge, ship the same console
to every site, and bring the last VM-only network function onto the cluster.

## The chapters

Seven story chapters, run in order. Each is a directory with an `assignment.md` and,
where there is something to grade, a `check-kvm-host` and a `solve-kvm-host`.

| # | Chapter | Guide lab | What the student does |
|---|---------|-----------|-----------------------|
| 1 | 📡 The Region | 01 | Walk the KVM host and its BMC, open a shell on `mgmt`, fetch the workshop files, find the image cache, log in to Rancher Prime. |
| 2 | 🎛️ The Control Room | 02 + 03 | Identify the controllers, read their versions against the 3.7 pins, inspect the four enrolled BareMetalHosts. |
| 3 | 🏢 The Central Office | 04 | Apply `site-co.yaml` and watch `site-co-01` come up on three hosts and get imported into Rancher. |
| 4 | 🗼 The Far Edge | 05 | Apply ClusterClass `example-clusterclass` and `site-ran-01` from it. |
| 5 | 📟 The Site Console | 06 | Label both sites and let Fleet deliver the console from Gitea on `mgmt`. |
| 6 | 💾 The Holdout | 07 | Install KubeVirt and CDI on `site-co-01` and run VirtualMachine `site-co-guest`. |
| 7 | 🌅 What's Next | | Recap, a victory lap in the lab, and where the pattern goes on real hardware. |

Guide labs 02 and 03 are one chapter here. Both are read-only and short, and together
they make one chapter about the size of the others.

## Where the lab runs

The track assumes one KVM host, `kvm-host`, deployed with
**[rodeo-cli](https://github.com/avaleror/rodeo-cli)** and the `suse-telco` profile:

```bash
rodeo up --profile suse-telco
```

That builds five libvirt guests on network `default` (`virbr0`, `192.168.122.0/24`) and
stops when the four site hosts are `available` BareMetalHosts:

| VM | IP | Notes |
|----|----|-------|
| mgmt | 192.168.122.10 | RKE2, Rancher Prime (NodePort 30002), Metal3, Turtles, image cache (:8080), Gitea (:3000) |
| site-co, site-co-2, site-co-3 | .21, .23, .24 | Hosts of `site-co-01` (API on the MetalLB address .20) |
| site-ran | .32 | Host of `site-ran-01` (API on the MetalLB address .22) |

The BMC for the site hosts is sushy-tools on the KVM host, `https://192.168.122.1:8000`.

## How the player runs it

The player shows the assignment on the left and the chapter's tabs on the right. Each
chapter declares its tabs in its front matter. Service tabs name a port on `kvm-host`,
and the player's `suse-telco` profile (`player.yaml` in rodeo-cli) maps that port to a
UI on the lab network:

| Tab | `port` / `protocol` | Upstream | Chapters |
|-----|---------------------|----------|----------|
| Terminal | `type: terminal` | the `student` shell on `kvm-host` | all |
| SUSE Rancher Prime | 30002 / https | 192.168.122.10:30002 | all |
| Gitea | 3000 / http | 192.168.122.10:3000 | 5, 7 |
| Site console (site-co-01) | 30080 / http | 192.168.122.21:30080 | 5, 6, 7 |
| Site console (site-ran-01) | 30081 / http | 192.168.122.32:30080 | 5, 7 |

The site consoles answer only after chapter 5.

The student is the unprivileged user `student` on `kvm-host`: in the `libvirt` group
for `virsh`, with an SSH key that root on `mgmt` accepts. Every `kubectl` and `helm`
command runs on `mgmt` as root. Logins come from the player's **Credentials** panel.

Chapter scripts run as root on `kvm-host`, in their chapter directory, with a wiped
environment. They share `lib/telco.sh`, which reaches `mgmt` over SSH with root's key
and runs `kubectl` there.

| Script | When it runs | Limit |
|--------|--------------|-------|
| `setup-kvm-host` | entering a chapter | 30 min |
| `check-kvm-host` | the **Check** button, and its output is the student's feedback | 120 s |
| `solve-kvm-host` | skipping past a chapter, to make its end state real | 30 min |

A chapter without a check (chapter 7) offers **Next** instead.

## Repository layout

```
.
├── 01-the-region-tour/                       # Chapter 1
├── 02-the-control-room-stack-and-hosts/
├── 03-the-central-office-first-cluster/
├── 04-the-far-edge-clusterclass/
├── 05-the-site-console-fleet/
├── 06-the-holdout-edge-virtualization/
├── 07-whats-next/                            # Chapter 7
└── lib/
    └── telco.sh                              # helpers the chapter scripts source
```

Each chapter directory holds:

- `assignment.md`: the story, instructions and tab buttons the student reads
- `check-kvm-host`: validates the chapter objective
- `solve-kvm-host`: the automated solution the player runs on a skip
- `setup-kvm-host`: only in chapters 1 and 5, a short non-fatal wait for `mgmt` and Gitea

## Working on the lab

Check that the player parses every chapter, with the player code from a rodeo-cli checkout:

```bash
PYTHONPATH=/path/to/rodeo-cli python3 -c "
from rodeo.player.runner import load_track
for c in load_track('.'): print(c.dirname, c.title, [t.title for t in c.tabs])"
```

Before a commit, run `bash -n` on every script and the writing linter on every
`assignment.md`. Teasers stay under 255 bytes.

### Credentials

Rancher Prime: user `admin`, password from the player's **Credentials** panel. The
Gitea repository is public, so browsing it needs no login. The track never prints a
password and never sends the student to `~/.rodeo/secrets.yaml`.

## Contributing

Keep this repo lab-only. Anything about building the host, the guests, the BMC or the
site image belongs in **[rodeo-cli](https://github.com/avaleror/rodeo-cli)**. Changes to
the YAML the student applies belong in the workshop guide repo.
