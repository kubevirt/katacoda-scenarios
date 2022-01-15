GitOps is simply defined as managing operations using a version control workflow.
It consists of three main practices:

- Infrastructure-as-code
- Change control through pull (or merge) requests
- Continuous integration / continuous delivery (CI/CD)

With [KubeVirt](https://kubevirt.io), it is possible to increase the scope of Infrastructure as Code to include *Virtual* Infrastructure as Code.

This lab will set up a two node Kubernetes cluster with the CI/CD tool, [ArgoCD](https://argo-cd.readthedocs.io) installed, then demonstrate the process of adding KubeVirt, Hostpath Provisioner, and Containerized Data Importer (CDI). The demonstration will culminate in creation of a VM using ArgoCD.
