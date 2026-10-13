# Jenkins + Ansible: Install Nginx on the Windows Docker Host

Beginner lab guide · Steps only · No solution code

## Goal

Run Ansible from a Jenkins container on Windows Docker Desktop to install Nginx on the Windows host, then start the Nginx Windows service and configure it to start automatically. Ansible's Windows SSH support requires Ansible Core 2.18 or newer. This is a Windows-target adaptation of the original Ubuntu lab.

## Expected result

- Ansible runs inside the custom Jenkins container.
- Jenkins connects to the Windows Docker host over SSH.
- Nginx is installed on Windows as a service, running, and configured to start automatically.
- The Nginx page is reachable at HTTP on port 80 if that port is available and Windows Firewall permits access.

## 1. Prerequisites

- Windows 10/11 host using Docker Desktop with Linux containers.
- Jenkins running in a container on Docker Desktop.
- A custom Jenkins image containing Ansible Core 2.18 or newer, the required Ansible collections, an SSH client, and the Jenkins SSH Agent plugin.
- Windows OpenSSH Server installed and configured on the host, with PowerShell as its default shell and an SSH key for a Windows administrator account.
- A Jenkins SSH private-key credential for that Windows account. Never place the private key or account password in the inventory or repository.
- A verified Windows SSH host key available to Jenkins. Keep SSH host-key verification enabled.
- A Jenkins job running on the Jenkins container/agent built from the custom image.
- Port 80 available if you want to open the Nginx page.

## 2. Prepare the project files

### Step 1 — Build the custom Jenkins image

Use the supplied Dockerfile to build a custom image with Ansible installed. Recreate the Jenkins container using this image and preserve the existing Jenkins home volume so jobs and configuration remain available.

### Step 2 — Configure Windows OpenSSH

Install and start the Windows OpenSSH Server, set PowerShell as the SSH default shell, configure the firewall for the required connection, and install the administrator's public key in the correct authorized-keys location. Verify the host key independently and make it available to Jenkins. Do not disable host-key checking.

### Step 3 — Add the Jenkins SSH credential

In Jenkins, add the Windows account and private key as an SSH Username with private key credential. Use the credential ID expected by the Jenkinsfile. Keep the private key out of the project files.

### Step 4 — Configure the inventory

The inventory targets the Docker Desktop host name reachable from containers, uses SSH with PowerShell, and specifies the Windows account. Replace its username placeholder. Do not use `localhost`: inside Jenkins that refers to the Jenkins container. Do not commit passwords or private keys.

### Step 5 — Understand the playbook

The Windows-targeted playbook uses Chocolatey to install Nginx and the Windows service module to ensure the Nginx service is running and starts automatically.

### Step 6 — Configure the failure email

In Jenkins global system properties, set the `JENKINS_ADMIN_EMAIL` environment variable to the inbox that should receive failure notifications. The Jenkinsfile reads that variable so your email address does not need to be committed in the public repository. SMTP must also be configured in Jenkins.

## 3. Configure the Jenkins job

### Step 7 — Add the project files to the repository root

Commit the Dockerfile, inventory, playbook, Jenkinsfile, and this guide together at the root of the Git repository.

### Step 8 — Create a Pipeline job

From the Jenkins dashboard, choose **New Item**, enter a job name, select **Pipeline**, and create the job.

### Step 9 — Point Jenkins to the Jenkinsfile

In the job's **Pipeline** section, choose **Pipeline script from SCM**, select **Git**, enter the repository URL and branch, and set the script path to `Jenkinsfile`.

### Step 10 — Check the execution environment

Confirm the job runs on the Jenkins container/agent built from the custom image and can access the checked-out project. Confirm the credential ID and the `JENKINS_ADMIN_EMAIL` variable are configured.

## 4. Run and verify

### Step 11 — Save and run

Save the job, choose **Build Now**, and inspect **Console Output**. The pipeline first checks the Ansible version, inventory parsing, and playbook syntax. It then tests SSH/PowerShell connectivity before installing Nginx. Confirm the service is running and set for automatic startup.

If port 80 is available, open the Docker host's HTTP address in a browser.
