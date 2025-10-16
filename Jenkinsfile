pipeline {
    agent any  // Run this pipeline on any available Jenkins agent

    environment {
        // Define the Jenkins credentials ID that stores your AWS Access Key + Secret Key
        AWS_CREDS = credentials('aws-credentials')
    }

    stages {

        // ───────────────────────────────────────────────
        stage('Terraform Init') {
            steps {
                echo "=== Initializing Terraform ==="
                dir('terraform') { // Change to the 'terraform' folder where main.tf is stored
                    withEnv([
                        // Export AWS credentials for Terraform to use
                        "AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}"
                    ]) {
                        // Initialize Terraform (downloads providers and prepares environment)
                        sh 'terraform init'
                    }
                }
            }
        }

        // ───────────────────────────────────────────────
        stage('Terraform Apply') {
            steps {
                echo "=== Creating EC2 Instance with Terraform ==="
                dir('terraform') { // Run inside terraform directory
                    withEnv([
                        // Pass AWS credentials to Terraform
                        "AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}"
                    ]) {
                        // Apply Terraform configuration and create the EC2 instance
                        // '-auto-approve' means no manual confirmation is needed
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        // ───────────────────────────────────────────────
        stage('Get EC2 IP') {
            steps {
                script {
                    echo "=== Fetching EC2 Public IP ==="
                    // Run Terraform output command to get the public IP of the created EC2
                    // '-raw' means the output is clean (no quotes or formatting)
                    env.EC2_IP = sh(
                        script: "cd terraform && terraform output -raw instance_ip",
                        returnStdout: true // Return output as text instead of printing to console
                    ).trim() // Remove any trailing spaces/newlines
                    echo "EC2 Public IP: ${EC2_IP}" // Print EC2 IP for logging
                }
            }
        }

        // ───────────────────────────────────────────────
        stage('Create Ansible Inventory') {
            steps {
                echo "=== Creating Ansible Inventory File ==="
                // Create or overwrite the inventory file dynamically with the EC2 IP
                sh """
                echo "[ec2]" > ansible/inventory
                echo "${EC2_IP} ansible_user=ec2-user ansible_ssh_private_key_file=/root/.ssh/rsa.pem" >> ansible/inventory
                cat ansible/inventory  // Show inventory file in Jenkins logs
                """
            }
        }

        // ───────────────────────────────────────────────
        stage('Run Ansible Playbook') {
            steps {
                echo "=== Running Ansible Playbook on EC2 ==="
                dir('ansible') { // Move into ansible directory
                    // Run the Ansible playbook using the generated inventory file
                    sh 'ansible-playbook -i inventory playbook.yml'
                }
            }
        }

        // ───────────────────────────────────────────────
        stage('Terraform Destroy') {
            steps {
                echo "=== Destroying EC2 Instance ==="
                dir('terraform') { // Move into terraform directory
                    withEnv([
                        // Export AWS credentials again for Terraform destroy command
                        "AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}",
                        "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}"
                    ]) {
                        // Destroy the created EC2 instance to avoid unnecessary AWS costs
                        // '|| true' means even if destroy fails, pipeline continues gracefully
                        sh 'terraform destroy -auto-approve || true'
                    }
                }
            }
        }
    }
}
