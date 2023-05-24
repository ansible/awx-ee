# AWX-EE

The default Execution Environment for AWX.

## Build the AWX-EE image locally

First, [install ansible-builder](https://ansible-builder.readthedocs.io/en/stable/installation/).

Then run the following command from the root of this repo:

```
pip install --pre ansible-builder
```

Run the following command from the directory of the cloned code to build the AWX-EE image:

```
ansible-builder build -v3 -t your-build-tag # --container-runtime=docker # Is podman by default
```
