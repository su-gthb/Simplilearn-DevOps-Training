  pipeline {
    agent {
      node {
        label "master"
      } 
    }

    stages {
      stage('fetch_latest_code') {
        steps {
          git branch: 'main', changelog: false, url: 'https://github.com/su-gthb/Simplilearn-DevOps-Training.git'
        }
      }

      stage('TF Init&Plan') {
        steps {
          sh 'terraform init'
          sh 'terraform plan'
        }      
      }

      stage('Approval') {
        steps {
          script {
            def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
          }
        }
      }

      stage('TF Apply') {
        steps {
          sh 'terraform apply -input=false'
        }
      }
    } 
  }