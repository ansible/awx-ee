# AWX-EE

The default Execution Environment for AWX.

## Build the AWX-EE image locally

Building AWX-EE requires [ansible-builder](https://ansible-builder.readthedocs.io/en/stable/installation/)
_*AWX-EE currently requires a pre-release version (v3 rc2) of ansible-builder which can be installed with the `--pre` flag:_
```
pip install --pre ansible-builder
```

Run the following command from the directory of the cloned code to build the AWX-EE image:

```
ansible-builder build -v3 -t your-build-tag # --container-runtime=docker # Is podman by default
```
