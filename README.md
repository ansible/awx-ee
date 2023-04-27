# AWX custom Execution Environment - default

An Ansible execution environment for a private AWX - default set.
This repo got forked from the ansible/awx-ee repo.

## Build the image locally

First, [install ansible-builder](https://ansible-builder.readthedocs.io/en/stable/installation/).

Then run the following command from the root of this repo:

```bash
$ ansible-builder build -v3 -t quay.io/ansible/awx-ee # --container-runtime=docker # Is podman by default
```
