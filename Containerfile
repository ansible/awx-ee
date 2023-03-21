ARG EE_BASE_IMAGE=quay.io/centos/centos:stream9
ARG EE_BUILDER_IMAGE=quay.io/centos/centos:stream9

FROM $EE_BASE_IMAGE as galaxy
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS=
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS=
USER root

# BEGIN (remove this when we move back to using ansible-builder)
RUN dnf install -y python3.9-pip git && pip3 install -U pip && pip3 install ansible-core
# END (remove this when we move back to using ansible-builder)

ADD _build /build
WORKDIR /build

RUN ansible-galaxy role install $ANSIBLE_GALAXY_CLI_ROLE_OPTS -r requirements.yml --roles-path "/usr/share/ansible/roles"
RUN ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path "/usr/share/ansible/collections"

FROM $EE_BUILDER_IMAGE as builder

COPY --from=galaxy /usr/share/ansible /usr/share/ansible

# BEGIN (remove this when we move back to using ansible-builder)
RUN dnf install -y python3.9-pip && pip3 install -U pip && pip3 install ansible-builder wheel
# END (remove this when we move back to using ansible-builder)

ADD _build/requirements.txt requirements.txt
ADD _build/bindep.txt bindep.txt
RUN ansible-builder introspect --sanitize --user-pip=requirements.txt --user-bindep=bindep.txt --write-bindep=/tmp/src/bindep.txt --write-pip=/tmp/src/requirements.txt
# BEGIN (remove this when we move back to using ansible-builder)
ADD https://raw.githubusercontent.com/ansible/python-builder-image/main/scripts/assemble /usr/local/bin
RUN chmod +x /usr/local/bin/assemble
ADD https://raw.githubusercontent.com/ansible/python-builder-image/main/scripts/get-extras-packages /usr/local/bin
RUN chmod +x /usr/local/bin/get-extras-packages
# END (remove this when we move back to using ansible-builder)
RUN assemble

FROM $EE_BASE_IMAGE
USER root

COPY --from=galaxy /usr/share/ansible /usr/share/ansible

COPY --from=builder /output/ /output/


# BEGIN (remove this when we move back to using ansible-builder)
ADD https://raw.githubusercontent.com/ansible/python-builder-image/main/scripts/install-from-bindep /usr/local/bin
RUN chmod +x /usr/local/bin/install-from-bindep

ADD https://raw.githubusercontent.com/ansible/ansible-runner/devel/utils/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod 755 /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]

# NB: this appears to be necessary for container builds based on this container, since we can't rely on the entrypoint
# script to run during a build to fix up /etc/passwd. This envvar value, and the fact that all user homedirs are
# set to /home/runner is an implementation detail that may change with future versions of runner and should not be
# assumed by other code or tools.
ENV HOME=/home/runner

RUN dnf install -y python3.9-pip && pip3 install -U pip

RUN install-from-bindep && rm -rf /output/wheels

ADD https://raw.githubusercontent.com/ansible/ansible/ff3ee9c4bdac68909bcb769091a198a7c45e6350/lib/ansible/cli/inventory.py \
      /usr/local/lib/python3.9/site-packages/ansible/cli/inventory.py
RUN chmod 0644 /usr/local/lib/python3.9/site-packages/ansible/cli/inventory.py

# In OpenShift, container will run as a random uid number and gid 0. Make sure things
# are writeable by the root group.
RUN for dir in \
      /home/runner \
      /home/runner/.ansible \
      /home/runner/.ansible/tmp \
      /runner \
      /home/runner \
      /runner/env \
      /runner/inventory \
      /runner/project \
      /runner/artifacts ; \
    do mkdir -m 0775 -p $dir ; chmod -R g+rwx $dir ; chgrp -R root $dir ; done && \
    for file in \
      /home/runner/.ansible/galaxy_token \
      /etc/passwd \
      /etc/group ; \
    do touch $file ; chmod g+rw $file ; chgrp root $file ; done

WORKDIR /runner
# END (remove this when we move back to using ansible-builder)

COPY --from=quay.io/ansible/receptor:devel /usr/bin/receptor /usr/bin/receptor
RUN mkdir -p /var/run/receptor
ADD run.sh /run.sh
CMD /run.sh
USER 1000
RUN git lfs install
LABEL ansible-execution-environment=true
