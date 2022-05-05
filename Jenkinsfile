pipeline {
  agent {
    docker {
      image 'python:3.7-buster'
      args '-u root:root'
      label 'ds-datascience'
    }
  }

  parameters {
    string(name: 'S3_PEX_DIR', description: 'S3 location for PEX archives', trim: true, defaultValue: 's3://tld-deployment/dev/repository/com.trainline/pex/')
  }

  environment {
    REPO = env.GIT_URL.replaceFirst(/^.*\/([^\/]+?).git$/, '$1')
  }

  stages {
    stage('PEX') {
      steps {
        sh "pip install pex==2.1.47"
        sh "./build-pex.sh ${REPO} ${env.GIT_COMMIT}"
        withCredentials([usernamePassword(usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: 'aws-data-creds')]) {
          sh "pip install awscli"
          sh '''#!/bin/bash
            local_pex=$(find ./dist -name "*.pex")
            pex_filename="$(basename -- ${local_pex})"
            s3_path="${S3_PEX_DIR%/}/${REPO}"
            echo "Copy ${local_pex} into ${s3_path}/${pex_filename}"
            aws s3 cp ${local_pex} ${s3_path}/${pex_filename}
            '''
        }
      }
    }
  }

  post {
    cleanup {
      sh 'find . -user root -name \'*\' | xargs chmod -f ugo+rw || true'
      deleteDir()
    }
  }

}