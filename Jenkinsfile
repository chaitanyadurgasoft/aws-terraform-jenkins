pipeline {
    agent {
        label 'Dev'
    }

    parameters {
        choice(name: 'BUILD_AMI', choices: ['yes', 'no'], description: 'Do you want to build an AMI using Packer?')
    }

    environment {
        PACKER_TEMPLATE = 'packer.json'
        AMI_NAME_PREFIX = 'Count-App'
        REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning git repository...'
                checkout scm
            }
        }

        stage('Check Packer Installation') {
            steps {
                script {
                    echo 'Checking if Packer is installed...'
                    def status = sh(script: 'which packer || echo "notfound"', returnStdout: true).trim()
                    if (status == 'notfound') {
                        error "❌ Packer is not installed on the agent."
                    } else {
                        echo "✅ Packer found at: ${status}"
                        sh 'packer --version'
                    }
                }
            }
        }

        stage('AMI Create with Packer') {
            when {
                expression { params.BUILD_AMI == 'yes' }
            }
            steps {
                echo '🏗️ Running Packer to build AMI...'
                sh '''
                    packer validate --var-file packer-vars.json ${PACKER_TEMPLATE}
                    packer build --var-file packer-vars.json ${PACKER_TEMPLATE} | tee packer_output.log

                    # Extract AMI ID from packer log and save to terraform.tfvars
                    echo "✅ AMI ID saved to terraform.tfvars"
                '''
            }
        }

        stage('Fetch Existing AMI') {
            when {
                expression { params.BUILD_AMI == 'no' }
            }
            steps {
                echo 'Fetching latest AMI by name from AWS EC2...'
                sh '''
                    ami_id=$(aws ec2 describe-images \
                        --owners self \
                        --region ${REGION} \
                        --filters "Name=name,Values=${AMI_NAME_PREFIX}*" "Name=state,Values=available" \
                        --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
                        --output text)

                    echo "ami= \\"$ami_id\\"" > ami.tfvars

                    echo "AMI ID from AWS: $ami_id"
                    cat ami.tfvars
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                echo 'Running Terraform...'
                sh '''
                    terraform init
                    terraform apply --auto-approve --var-file ami.tfvars
                '''
            }
        }
    }
}

