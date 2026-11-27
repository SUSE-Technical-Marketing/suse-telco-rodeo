# Shared helpers for the chapter scripts. Source it from a chapter script:
#
#   . "$(dirname "$0")/../lib/telco.sh"
#
# The rodeo player runs every chapter script as root on the KVM host, in the
# chapter directory, with a wiped environment (PATH, HOME, KUBECONFIG only).
# Everything Kubernetes happens on mgmt, so these helpers reach it over SSH
# with root's own key and run kubectl there against the RKE2 kubeconfig.
#
# Check output is shown to the student. Never print a password from here.

MGMT_IP="192.168.122.10"
MGMT_KEY="/root/.ssh/id_ed25519"
# Where chapter 1 tells the student to unpack the workshop files on mgmt.
WORKSHOP_DIR="/root/suse-telco-workshop-main"
WORKSHOP_TARBALL="https://github.com/avaleror/suse-telco-workshop/archive/refs/heads/main.tar.gz"

# Remote preamble: kubectl and helm live in /usr/local/bin on mgmt.
_MGMT_ENV='export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin; export KUBECONFIG=/etc/rancher/rke2/rke2.yaml;'

_mgmt_ssh() {
  ssh -i "${MGMT_KEY}" -o StrictHostKeyChecking=accept-new -o BatchMode=yes \
      -o ConnectTimeout=10 -o ServerAliveInterval=15 "root@${MGMT_IP}" "$@"
}

# mgmt 'kubectl get nodes': one command string, run on mgmt.
mgmt() {
  _mgmt_ssh "${_MGMT_ENV} $*"
}

# mgmt_script <<'EOF' ... EOF: a multi-line bash script, run on mgmt.
mgmt_script() {
  _mgmt_ssh "${_MGMT_ENV} bash -s"
}

# kc ARGS...: kubectl on the management cluster, with a short request timeout.
kc() {
  mgmt "kubectl --request-timeout=20s $*"
}

mgmt_reachable() {
  mgmt true >/dev/null 2>&1
}

# Unpack the workshop files on mgmt where chapter 1 puts them (idempotent).
ensure_workshop_files() {
  mgmt_script <<EOF
set -e
cd "\$(dirname ${WORKSHOP_DIR})"
if [ ! -f ${WORKSHOP_DIR}/manifests/site-co.yaml ]; then
  curl -fsSL ${WORKSHOP_TARBALL} | tar xz
fi
test -f ${WORKSHOP_DIR}/manifests/site-co.yaml
EOF
}

# Rancher's generated ID (c-xxxxx) for an imported cluster's display name.
rancher_cluster_id() {
  kc "get clusters.management.cattle.io -o jsonpath='{.items[?(@.spec.displayName==\"$1\")].metadata.name}'" 2>/dev/null
}

# "True" when Rancher reports the imported cluster Ready.
rancher_cluster_ready() {
  local id
  id="$(rancher_cluster_id "$1")"
  [ -n "${id}" ] || return 1
  [ "$(kc "get clusters.management.cattle.io ${id} -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'" 2>/dev/null)" = "True" ]
}

# Phases of a CAPI cluster's machines, one per line.
machine_phases() {
  local ns="$1" cluster="$2"
  kc "get machines.cluster.x-k8s.io -n ${ns} -l cluster.x-k8s.io/cluster-name=${cluster} -o jsonpath='{range .items[*]}{.status.phase}{\"\\n\"}{end}'" 2>/dev/null
}

# running_machines NS CLUSTER: how many machines are Running.
running_machines() {
  machine_phases "$1" "$2" | grep -c '^Running$' || true
}

# CAPI cluster phase (Provisioned, Provisioning, ...), empty if it does not exist.
cluster_phase() {
  kc "get clusters.cluster.x-k8s.io -n $1 $2 -o jsonpath='{.status.phase}'" 2>/dev/null
}

cluster_exists() {
  kc "get clusters.cluster.x-k8s.io -n $1 $2 -o name" >/dev/null 2>&1
}

# wait_for SECONDS DESCRIPTION COMMAND...: poll every 20 s until COMMAND succeeds.
wait_for() {
  local limit="$1" what="$2" start
  shift 2
  start=$(date +%s)
  while true; do
    if "$@"; then
      echo ">>> ${what}: done"
      return 0
    fi
    if [ $(( $(date +%s) - start )) -ge "${limit}" ]; then
      echo ">>> ${what}: still not done after $(( limit / 60 )) min"
      return 1
    fi
    echo ">>> waiting: ${what} ($(( ($(date +%s) - start) / 60 )) min so far)"
    sleep 20
  done
}
