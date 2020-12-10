# AWX EE

An Ansible Execution Environment for AWX project.

## Regenerating the build context:

```
$ ansible-builder build --tag=quay.io/awx/ee -v3
```

By default, podman will be used. To use Docker:

```
$ ansible-builder build --container-runtime=docker --tag=quay.io/awx/ee -v3
```

