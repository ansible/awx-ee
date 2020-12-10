# AWX EE

This is a work in progress.

## Regenerating the build context:

```
$ ansible-builder build --tag=quay.io/awx/ee -v3 -c .
```

By default, podman will be used. To use Docker:

```
$ ansible-builder build --container-runtime=docker --tag=quay.io/awx/ee -v3 -c .
```

