pipeline {
    agent {
        label 'docker'
    }
    environment {
        ANSIBLE_INVENTORY_PATH = "/var/lib/jenkins/inventory.ini"
    }
    stages {
        stage('Checkout') {
            when {
                expression {
                    return action == 'apply' || action == 'destroy'
                }
            }
            steps {
                git branch: 'main', url: 'https://github.com/summu97/ASSESMENT.git'
            }
        }
        stage('Desktop-tfm-init') {
            when {
                expression {
                    return action == 'apply' || action == 'destroy'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/pipeline-1/terraform-desktop
                terraform init
                '''
            }
        }
        stage('Desktop-tfm-plan') {
            when {
                expression {
                    return action == 'apply' || action == 'destroy'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/pipeline-1/terraform-desktop
                terraform plan
                '''
            }
        }
        stage('Desktop-tfm-action') {
            when {
                expression {
                    return action == 'apply' || action == 'destroy'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/pipeline-1/terraform-desktop
                terraform $action --auto-approve
                '''
            }
        }
        stage('Create-Inventory-File') {
            when {
                expression {
                    return action == 'ansible'
                }
            }
            steps {
                script {
                    sh '''
                    sudo touch ${ANSIBLE_INVENTORY_PATH}
                    private_ip=$(gcloud compute instances describe default-desktop-server --zone us-west1-b --format='value(networkInterfaces[0].networkIP)')
                    echo "[desktop]" | sudo tee -a ${ANSIBLE_INVENTORY_PATH}
                    echo "${private_ip}" | sudo tee -a ${ANSIBLE_INVENTORY_PATH}
                    '''
                }
            }
        }
        stage('Configure Ansible') {
            when {
                expression {
                    return action == 'ansible'
                }
            }
            steps {
                script {
                    sh '''
                    if ! grep -q "^[defaults]" /etc/ansible/ansible.cfg; then
                        echo "[defaults]" | sudo tee -a /etc/ansible/ansible.cfg
                    fi

                    echo 'host_key_checking = False' | sudo tee -a /etc/ansible/ansible.cfg
                    '''
                }
            }
        }
        stage('instance wait time for 60 seconds') {
            when {
                expression {
                    return action == 'ansible'
                }
            }
            steps{
                script{
                    sleep(time: 60, unit: 'SECONDS')
                }
            }
        }
        stage('Conf-Desktop-server') {
            when {
                expression {
                    return action == 'ansible'
                }
            }
            steps {
                sh 'ansible-playbook -i /var/lib/jenkins/inventory.ini playbook.yml -u root'
            }
        }
    }
}
