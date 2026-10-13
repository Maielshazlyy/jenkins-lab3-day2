pipeline {
    agent any

    stages {
        stage('Validate Ansible files') {
            steps {
                sh 'ansible --version'
                sh 'ansible-inventory -i inventory.ini --graph'
                sh 'ansible-playbook --syntax-check -i inventory.ini playbook.yml'
            }
        }

        stage('Validate Windows host connection') {
            steps {
                // Jenkins credential: SSH Username with private key, ID windows-host-ssh-key.
                sshagent(credentials: ['windows-host-ssh-key']) {
                    sh 'ansible windows_host -i inventory.ini -m ansible.windows.win_ping'
                }
            }
        }

        stage('Install and start Nginx on Windows host') {
            steps {
                sshagent(credentials: ['windows-host-ssh-key']) {
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }

    post {
        success {
            echo 'Ansible validation and Nginx setup completed successfully.'
        }
        failure {
            echo 'Ansible validation or Nginx setup failed.'
            mail(
                to: "${env.JENKINS_ADMIN_EMAIL}",
                subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    Ansible pipeline failed.
                    Job: ${env.JOB_NAME}
                    Build: ${env.BUILD_NUMBER}
                    URL: ${env.BUILD_URL}
                """
            )
        }
        always {
            echo 'Pipeline finished.'
        }
    }
}
