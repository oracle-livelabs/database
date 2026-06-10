# OLVM Live Instructor Companion - 1-Page Version with Exact Quiz Stops

## Introduction
Use this as a **thin instructor overlay** while teaching the Luna lab live on a shared screen. Students already have the explanations in the Luna left pane, and both students and instructor also have access to the quiz page. Your job is to control **pace, checkpoints, quiz moments, recovery, and verbal emphasis**.

Quiz source: attached OLVM quiz bank.

Instructor prerequisite setup: open `workshops/instructor/index.html` and choose one setup path. Use the Ansible setup lab for the working E5 bootstrap build, or use `e5-oci-prereq-setup.md` for manual OCI setup.

Estimated Time: 8 hours

### Objectives

In this instructor companion, you will:

- Plan the one-day delivery sequence
- Manage checkpoints, breaks, and quiz stops
- Keep the class synchronized during long-running lab tasks
- Reinforce key OLVM concepts at the end of the workshop

---

## Delivery Model
- Instructor runs the lab live in Luna on a projected screen.
- Students follow in their own Luna sessions.
- Students read the Luna explanations as needed.
- Students and instructor open the quiz page only at planned quiz stops.
- Instructor screen is the reference for commands, clicks, output, timing, and quiz transitions.
- Goal: **keep the room synchronized**.

---

## Day Fit
- Student hands-on runtime: **3–4 hours**
- Breaks: **4 × 15 min = 60 min**
- Lunch: **45 min**
- Total break time: **1 hr 45 min**
- In an 8-hour day, usable instructional time is about **6 hr 15 min**

**Verdict:** This fits a one-day instructor-led class if explanations stay tight, quiz stops stay short, and checkpoints are managed aggressively.

---

## Instructor Rules
**Do**
- show the step first
- let students follow immediately
- explain only what helps the next action
- stop at checkpoints
- use wait time for short, useful discussion
- use short quiz bursts after each major section
- preserve time for all required lab parts, including Part 4

**Do not**
- turn every Luna explanation into a lecture
- let fast students drag the room forward
- spend too long troubleshooting one person live
- let quiz time turn into a second lecture
- duplicate the student guide in your own notes

---

## Quiz Use Rule
Use the quiz page as a **section close**, not as a separate lesson.

**Best pattern**
1. finish the section
2. verify the checkpoint
3. tell students exactly which quiz block to do
4. give them **3–5 minutes**
5. review only the missed or tricky items
6. move on

**Target quiz time**
- **3–5 minutes max** after each major section
- **10 minutes max** for final quiz recap

---

## One-Day Plan with Exact Quiz Stops

| Time | Segment | Mode | Quiz stop |
|---|---|---|---|
| 09:00–09:20 | Welcome, access check, expectations | Instructor-led | Explain quiz rhythm |
| 09:20–10:15 | Part 1 – Infrastructure Setup | Hands-on | |
| 10:15–10:20 | **Quiz Stop 1** | Quiz | **Quiz Bank Section 1** + **Quiz Bank Section 2** |
| 10:20–10:35 | Break | Buffer | |
| 10:35–11:25 | Part 2 – KVM Hosts | Hands-on | |
| 11:25–11:30 | **Quiz Stop 2** | Quiz | **Quiz Bank Section 3** |
| 11:30–12:05 | Part 3A – Networking | Hands-on | |
| 12:05–12:10 | **Quiz Stop 3** | Quiz | **Quiz Bank Section 4 Q1–Q4** |
| 12:10–12:15 | Buffer / checkpoint | Mixed | |
| 12:15–13:00 | Lunch | Buffer | |
| 13:00–14:00 | Part 3B – Storage, Template, Test VM | Hands-on | |
| 14:00–14:05 | **Quiz Stop 4** | Quiz | **Quiz Bank Section 4 Q5–Q12** |
| 14:05–14:20 | Break | Buffer | |
| 14:20–15:00 | Part 4 – Application Tier | **Required hands-on** | |
| 15:00–15:05 | **Quiz Stop 5** | Quiz | **Optional review only** — reuse Section 4 VM questions if desired |
| 15:05–15:20 | Break | Buffer | |
| 15:20–16:00 | Part 5 – Live Migration | Hands-on | |
| 16:00–16:05 | **Quiz Stop 6** | Quiz | **Quiz Bank Section 5** |
| 16:05–16:20 | Break | Buffer | |
| 16:20–17:00 | Review, exam mapping, Q&A, final recap | Instructor-led | Revisit misses |

---

## Section Cues

### Part 1 – Infrastructure Setup
**Target:** 55 min  
**Say while they work:** engine = management plane, hosts = where VMs run, record credentials carefully  
**Checkpoint:** terminal open, repo cloned, config created, VNC works, portal login works  
**Quiz block:**  
- **Section 1: Architecture & Big Picture**
- **Section 2: Engine Installation & Configuration**  
These cover standalone vs self-hosted engine, HA agent, oVirt engine role, VDSM, QEMU, KVM, engine prerequisites, engine-setup, portals, logs, and databases.  
**Watch for:** bad copy/paste, wrong file content, VNC/cert confusion, forgotten password

### Part 2 – KVM Hosts
**Target:** 50 min  
**Say while they work:** engine talks to VDSM, use private/VDSM hostname, “Up” is the success state  
**Checkpoint:** first host Up, second host Up  
**Quiz block:**  
- **Section 3: KVM Host & Cluster Management**  
This matches host prerequisites, adding hosts, authentication, VDSM, hierarchy, and host state.  
**Watch for:** wrong hostname, SSH key copy failure, moving on before host is Up

### Part 3A – Networking
**Target:** 35–40 min  
**Say while they work:** logical network = OLVM-managed, both hosts need the same VM network  
**Checkpoint:** `l2-vm-network` created, attached to both hosts, `olkvm01` has `10.0.10.254/24`, and `olkvm02` has `10.0.10.253/24`  
**Quiz block:**  
- **Section 4 Q1–Q4**  
This covers logical networks, `ovirtmgmt`, storage domain types, and storage-domain sharing rules.  
**Watch for:** drag/drop mistake, forgetting to save, only one host configured

### Part 3B – Storage, Template, Test VM
**Target:** 60 min  
**Say while they work:** shared storage enables migration, template = reusable source image, test VM proves the stack works  
**Checkpoint:** storage Active, template imported, test VM Up, IP correct, VM reachable through the KVM host  
**Quiz block:**  
- **Section 4 Q5–Q12**  
This covers SPM, shared storage for migration, local storage limits, OVA, thin provisioning, cloud-init, and storage-domain requirement before initialization.  
**Watch for:** wrong LUN/host, continuing before storage is active, mistyped guest network values

### Part 4 – Application Tier
**Target:** 40 min  
**Mode:** **Required hands-on**  
**Say while they work:** this is a required validation layer of the class, not an optional extra  
**Checkpoint:** both app VMs Up, DB query works, app loads  
**Quiz block:**  
- No dedicated application-tier quiz exists in the bank.
- If you want a short check, reuse **Section 4 Q9–Q11** for OVA, provisioning, and cloud-init reinforcement.  
**Watch for:** slow downloads/imports, wrong network assignment, missing `l2-vm-network` host address on the KVM host shown in the VM Host column  
**Instructor note:** protect enough time earlier in the day so Part 4 is always completed hands-on

### Part 5 – Live Migration
**Target:** 40 min  
**Say while they work:** migration is the payoff for all prior setup; shared storage + same cluster + same network make it possible  
**Checkpoint:** migration starts, VM Up on destination host, validation succeeds  
**Quiz block:**  
- **Section 5: VM Lifecycle, Migration & Operations**  
This directly covers migration prerequisites, migration phases, downtime expectations, same-cluster limits, maintenance mode, SPM failover, and run options.  
**Watch for:** skipped prerequisites, stale cache/state, students assuming failure too early

---

## Wait-Time Topics
Use waiting periods for short, useful explanations only:
- engine vs host roles
- VDSM -> libvirt -> KVM/QEMU
- data center -> cluster -> host
- shared storage and why it matters
- template vs VM
- migration prerequisites
- OVA import value in real environments

Avoid deep theory detours.

---

## Global Checkpoints
1. Luna open and terminal ready
2. Administration Portal accessible
3. Both hosts Up
4. Logical network on both hosts
5. Storage domain Active
6. Template imported
7. Test VM reachable through its KVM host
8. App VMs working through KVM-host access
9. Migration complete
10. Section quiz completed

If the room fragments, stop and re-sync at the next checkpoint.

---

## Decision Rules
**If ahead:** keep explanations concise and allow a little more quiz discussion  
**If on time:** stick to plan, keep explanations tight, quiz only the essentials  
**If behind:** compress discussion, reduce quiz review to answer-check only, but still complete **all parts including Part 4**  
**If several students are stuck:** restate page + step, re-show command/click path, verify expected output on your screen

---

## End-of-Day Close

<details>
<summary>**What is the role of the engine?**</summary>  
The OLVM engine is the **central management plane**. It manages hosts, clusters, storage, networks, users, and virtual machines through the Administration Portal, REST API, and related services. It does **not** run the VMs themselves; it controls and coordinates the environment.
</details>

<details>
<summary>**What does VDSM do?**</summary>  
VDSM is the **host agent** running on each KVM host. It receives commands from the engine and uses lower-level virtualization services such as libvirt to manage VM lifecycle, networking, storage operations, and host reporting.
</details>

<details>
<summary>**Why were two hosts needed?**</summary>  
Two hosts were needed to create a real **clustered virtualization environment** that supports workload distribution, high availability concepts, and especially **live migration**. With only one host, there is nowhere to migrate a running VM.
</details>

<details>
<summary>**Why did both hosts need the same logical network?**</summary>  
Both hosts needed the same logical network so VMs could attach to a consistent network no matter which host they ran on. That is essential for VM placement and migration, because the VM’s required network must exist on both the source and destination hosts.
</details>

<details>
<summary>**Why was shared storage required?**</summary>  
Shared storage was required because both hosts must be able to access the **same VM disks and templates**. That shared access is what allows a VM to move between hosts without copying its entire disk locally during migration.
</details>

<details>
<summary>**What does live migration prove?**</summary>  
Live migration proves that the OLVM environment was configured correctly across the key layers: **cluster membership, host compatibility, shared storage, and network availability**. It also proves that a running workload can move between hosts with little or no service interruption.
</details>

## Acknowledgements

- **Author** - Shawn Kelley, Perside Foster
- **Contributor** - Marvin Kim
- **Last Updated By/Date** - Perside Foster, May 20, 2026
