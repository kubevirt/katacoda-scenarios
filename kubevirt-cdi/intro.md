# Environment Notes

In this interactive scenario, this pane will serve as a guide, providing explanations of tasks to accomplish, clickable commands to run in the accompanying terminal, and example output.
The terminal on the right is connected to a virtual instance running a single node Kubernetes ([k3s](https://k3s.io/)) cluster.
As this scenario starts up, a script will run to set up your environment.
Sometimes, when the system is under heavy load, commands in the script may time out, printing errors to the screen.
These may be safely ignored.
Once the script has finished, you will be presented with a prompt and may enter commands either by clicking through this guide, or by clicking in the terminal and typing them in manually.

# About this Scenario

Containerized Data Importer (CDI) is an utility designed to import Virtual Machine images for use with Kubevirt.

In this lab you'll play with CDI to import an existing VM to be started under KubeVirt.