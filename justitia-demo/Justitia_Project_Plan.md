# Training Module 1: GitOps Implementation Plan

## Goal
Set up a compliance-ready GitOps workflow using ArgoCD to demonstrate audit capabilities for Justitia 4.0.

## User Review Required
> [!IMPORTANT]
> **ArgoCD Availability**: The current cluster environment may not have ArgoCD installed (only Argo Workflows detected so far). If `Application` CRDs are missing, we will simulate the deployment step by validating the manifests locally (`oc apply --dry-run=client` or `argocd app create --dry-run`).
> **Git Repository**: You will need to push the created files to a real Git repository (GitHub/GitLab) for the final ArgoCD integration.

## Proposed Changes

### [File Structure] `justitia-demo`
- Create directory structure for overlays pattern (base/overlays).
- **[NEW]** `justitia-demo/base/deployment.yaml`: The core application manifest (auditable).
- **[NEW]** `justitia-demo/base/kustomization.yaml`: Application assembly instructions.
- **[NEW]** `justitia-demo/overlays/dev/kustomization.yaml`: Environment-specific overrides.

### [ArgoCD Configuration]
- **[NEW]** `argocd-application.yaml`: The declaration of the GitOps state. 
    - *Note*: `repoURL` will be a placeholder initially.

## Verification Plan

### Automated Verification
- **Syntax Check**: Run `oc apply --dry-run=client -f justitia-demo/base/deployment.yaml` to verify Kubernetes syntax.
- **ArgoCD Check**: Run `oc get crd applications.argoproj.io` to confirm if we can proceed with actual deployment.

### Manual Verification
- **Audit Trail Simulation**: We will manually commit a change to the local git repo (if initialized) to demonstrate the "Commit Hash" concept.
