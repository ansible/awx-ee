FROM quay.io/ansible/ansible-runner:devel

RUN pip3 install --upgrade pip setuptools
ADD requirements.yml /build/

RUN ansible-galaxy role install -r /build/requirements.yml --roles-path /usr/share/ansible/roles
RUN ansible-galaxy collection install -r /build/requirements.yml --collections-path /usr/share/ansible/collections
ADD bindep_output.txt /build/
RUN dnf -y install $(cat /build/bindep_output.txt)
ADD requirements_combined.txt /build/
RUN pip3 install --upgrade -r /build/requirements_combined.txt
COPY --from=quay.io/project-receptor/receptor /usr/bin/receptor /usr/bin/receptor
RUN mkdir -m 0770 /var/run/receptor
