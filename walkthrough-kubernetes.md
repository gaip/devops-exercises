# Walkthrough: Kubernetes Journey (Rancher Desktop) ☸️

## Module 1: Planning (The Map) 🗺️ [Current]

We will collect information and agree on the plan before creating anything.

### 🗺️ Step 1: Collect Information
**Goal:** Capture the minimum details needed to build a meaningful frontend/backend demo.

**Proposed meaning (unless you prefer something else):**
- **Frontend**: a simple “Shop UI” page
- **Backend**: a “Catalog API” that returns JSON (e.g., list of items)

**Answers captured:**
1) Theme: **Yes** (Shop UI + Catalog API)
2) Images: **Public demo images** (no custom code)
3) Ports (industry standard): **frontend 80**, **backend 8080**
4) Namespace: **default**
5) Access: **Both**
	- Backend: **ClusterIP** (internal DNS)
	- Frontend: **NodePort** (external access)

---
*Next: Confirm the plan based on your answers.*

### 🗺️ Step 2: Confirm Architecture
**Goal:** Lock the target layout shown in your diagram.

**Proposed plan (based on the diagram):**
- Two Deployments: `frontend` (Shop UI) and `backend` (Catalog API)
- Two Services: `fe` (NodePort) and `be` (ClusterIP)
- `frontend` calls `backend` using DNS: `be.default.svc.cluster.local`
- Default namespace

**Confirm this is correct (yes/no).** If anything differs (names/namespace), tell me.

---
*Next: Verify Kubernetes context in Rancher Desktop.*
