properties([
	parameters([
        string(defaultValue: "master", description: 'Which Git Branch to clone?', name: 'GIT_BRANCH'),
        string(defaultValue: "helloworld", description: 'Docker Repository where built docker images will be pushed.', name: 'DOCKER_REPO_NAME')
	])
])

try {

  stage('Checkout'){
    node('master'){
        checkout([$class: 'GitSCM', branches: [[name: '*/$GIT_BRANCH']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/krupakar5/sample-helloworld.git']]])
    }
  }
  stage('Build Maven'){
      node('master'){
       sh "mvn clean verify package"
    }
  }

  stage('Build And Push Docker Image') {
    node('master'){
      sh "docker login "
      sh "docker build -t helloworld:${BUILD_NUMBER} ."
      sh "docker push helloworld:${BUILD_NUMBER}"
    }
  }

  stage('Container Security Scan') {
  	node('master'){
  	    sh 'echo "helloworld:${BUILD_NUMBER} `pwd`/Dockerfile" > anchore_images'
  	    anchore autoSubscribeTagUpdates: false, bailOnFail: false, bailOnPluginFail: false, name: 'anchore_images'
      	}
    }
    
  stage('Cleanup') {
      node('master') {
          sh ''' for i in `cat anchore_images | awk '{print $1}'`;do docker rmi $i; done '''
      }   
    }

  stage('Deploy on Dev') {
  	node('master'){
        sh ''' sed -i 's/VERSION/'"${BUILD_NUMBER}"'/g' deployment.yaml '''
  	    sh "kubectl apply -f deployment.yaml"
      	}
    }
}
catch (err){
    currentBuild.result = "FAILURE"
    throw err
}
