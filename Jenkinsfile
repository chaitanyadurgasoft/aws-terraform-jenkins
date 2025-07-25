pipeline {
    agent {
        label 'Dev'
    }
       parameters {
        choice(name: 'BUILD_AMI', choices: ['yes', 'no'], description: 'Do you want to build an AMI using Packer?')
    }
    environment {
        PACKER_TEMPLATE = 'packer.json'  // Adjust if your packer file name is different
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
                        error "Packer is not installed on the agent. Please install it before proceeding."
                    } else {
                        echo "Packer found at: ${status}"
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
                echo 'Running Packer to create AMI and extract AMI ID...'
                sh '''
                    packer validate --var-file packer-vars.json ${PACKER_TEMPLATE}
                    
                    # Run Packer build and capture output
                    packer build --var-file packer-vars.json ${PACKER_TEMPLATE} | tee packer_output.log

                    # Extract AMI ID and save to a file
                    grep -oE 'ami-[a-zA-Z0-9]+' packer_output.log | tail -1 > ${AMI_ID_FILE}
                    echo "AMI ID extracted: $(cat ${AMI_ID_FILE})"
                '''
            }
        }

        stage('Skip AMI Build') {
            when {
                expression { params.BUILD_AMI == 'no' }
            }
            steps {
                echo 'BUILD_AMI is set to no. Skipping AMI build.'
            }
        }
    }
}
