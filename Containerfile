FROM quay.io/ansible/ansible-runner:devel as galaxy

ADD sources/requirements.yml /build/sources/requirements.yml

RUN ansible-galaxy role install -r /build/sources/requirements.yml --roles-path /usr/share/ansible/roles
RUN ansible-galaxy collection install -r /build/sources/requirements.yml --collections-path /usr/share/ansible/collections

RUN mkdir -p /usr/share/ansible/roles /usr/share/ansible/collections

FROM quay.io/ansible/python-builder:latest as builder

ADD sources/requirements_combined.txt /tmp/src/requirements.txt
ADD sources/bindep_combined.txt /tmp/src/bindep.txt
RUN assemble

FROM quay.io/ansible/ansible-runner:devel


COPY --from=galaxy /usr/share/ansible/roles /usr/share/ansible/roles
COPY --from=galaxy /usr/share/ansible/collections /usr/share/ansible/collections

COPY --from=builder /output/ /output/
RUN /output/install-from-bindep && rm -rf /output/wheels
