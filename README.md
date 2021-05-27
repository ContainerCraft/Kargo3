# Kargo | CCIO KubeVirt Hypervisor
## Quick Starts:
  - [Fedora Quick Start Guide] (recommended)
  - [Ubuntu Quick Start Guide] (experimental)

## About
Kargo is a Kubernetes native KubeVirt based hypervisor solution built as an easy
path to gitops friendly single node and multi node HomeLab VM scheduling and
lifecycle management.

### Problem:
Present day dev and homelab ecosystems commonly rely on bespoke snowflake digital
witchcraft and extensive tribal knowledge to achieve each success. Kargo represents
a bleeding edge solution to accelerating common standards adoption across 
the dev/student/homelab user base. 

### Purpose:
Virtual machines and the surrounding infrastructure to support them with scheduling,
storage, networking, and availability has become a commonplace, commodity featureset
across public clouds.

Kargo attempts to bring basic commodity cloud feature sets onto commodity user
provided hardware in the age of gitops and declarative infrastructure as code
with an emphasis on budget commodity hardware and high performance scalable
production like infrastructure modeling & orchestration.

### Motivation:
While FLOSS has lowered the cost barrier to enterprise software for the
resource limited professional, student, and hobbyist, the vast number of choices
and accumulation of legacy knowledge on the internet presents an extremely high
learning curve required to achieve rudimentary success with leading edge advancements.
Industry talent shortages indicate a fundamental gap in accessibility which the CCIO
codebases including Kargo intend to bridge.

### Prereq: (v1.0 planned objective)
  - Intel VT-d
  - Modern Linux OS on bare metal host
  - Direct or SSH Access
  - Sudo Priviledges
  - Docker or Podman

### Goals:
  - Single Node Support
  - Forkless consumption
  - Minimal barrier to entry
  - Wider gitops workflow adoption
  - Homelab Infrastructure-as-a-Service
  - Zero pre-existing infrastructure dependencies
  - Reference platform for student & new hire curriculum
  - Fully realized DevSecOps dogfood built implementation
  - Convenient support for fully disconnected / airgap use
  - Enable commonly consumable homelab applications as code
  - Support single ethernet port hardware (think Intel NUC / Laptop)
  - Declarative Virtual Machine & Virtual Network Overlay Orchestration

### Non-Goals: (for now)
  - End to end production ready best practices

[Ubuntu Quick Start Guide]:./docs/Ubuntu.md
[Fedora Quick Start Guide]:./docs/Fedora.md
