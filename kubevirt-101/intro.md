# Environment Notes

In this interactive scenario, this pane will serve as a guide, providing explanations of tasks to accomplish, clickable commands to run in the accompanying terminal, and example output.
The terminal on the right is connected to a virtual instance running a single node Kubernetes ([k3s](https://k3s.io/)) cluster.
As this scenario starts up, a script will run to set up your environment.
Sometimes, when the system is under heavy load, commands in the script may time out, printing errors to the screen.
These may be safely ignored.
Once the script has finished, you will be presented with a prompt and may enter commands either by clicking through this guide, or by clicking in the terminal and typing them in manually.

# About this Scenario

KubeVirt provides a unified development platform where developers can build, modify, and deploy applications residing in both Containers and Virtual Machines in a common environment.

This scenario guides the user through all the steps required to install KubeVirt on a Kubernetes cluster and run a Virtual Machine.

# Objectives

On completing this scenario, the user will learn the following skills:

  * Installation of the latest KubeVirt using operators and the KubeVirt Custom Resource
  * Installation of virtctl, the command-line client for managing Virtual Machines
  * Use of kubectl and virtctl commands to create, start, stop, and report status of Virtual Machines
