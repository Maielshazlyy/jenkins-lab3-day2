FROM jenkins/jenkins:lts-jdk21

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-venv openssh-client \
    && python3 -m venv /opt/ansible \
    && /opt/ansible/bin/pip install --no-cache-dir 'ansible-core>=2.18,<3' \
    && /opt/ansible/bin/ansible-galaxy collection install -p /opt/ansible/collections ansible.windows chocolatey.chocolatey \
    && jenkins-plugin-cli --plugins ssh-agent \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/ansible/bin:${PATH}"
ENV ANSIBLE_COLLECTIONS_PATHS="/opt/ansible/collections"

USER jenkins
