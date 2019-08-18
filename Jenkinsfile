node{
    stage('checkout'){
        
    }
    stage('awarm setup'){
        ansiblePlaybook credentialsId: 'admin_credential', inventory: 'swarm-playground/hosts.yml', playbook: 'swarm-playground/basic_setup.yml'
    }
}