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
        always {
            echo 'Pipeline finished.'
        }
    }
}
