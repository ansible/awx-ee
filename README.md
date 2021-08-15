# AWX custom Execution Environment - default

An Ansible execution environment for a private AWX - default set.
This repo got forked from the ansible/awx-ee repo.

## Regenerating the build context with podman

```bash
$ tox -epodman
```

## Regenerating the build context with docker

```bash
$ tox -edocker
```
