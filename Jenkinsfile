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
      docker.withRegistry('https://703569030910.dkr.ecr.ap-south-1.amazonaws.com', 'ecr:ap-south-1:ecr-cred') {
            //build image
	      def customImage = docker.build("703569030910.dkr.ecr.ap-south-1.amazonaws.com/helloworld:${BUILD_NUMBER}")
	    //push image
            customImage.push()
            }
    }
  }

  stage('Deploy on Dev') {
    node('master'){
	sh ''' sed -i 's/VERSION/'"${BUILD_NUMBER}"'/g' deployment.yaml '''
  	sh "kubectl apply -f deployment.yaml"
	DEPLOYMENT = sh (
	      script: 'grep metadata -A3 deployment.yaml|grep name|awk "{print $2}"| head -1 | tr -s " " |cut -d " " -f 3',
	      returnStdout: true
	).trim()
	echo "Creating the deployment..."
       	OUTPUT = sh (
		script: "kubectl rollout status deployment/helloworld --watch=true | grep -i success | awk '{print \$3}' | cut -b 1-7",
         	returnStdout: true
       	).trim()
       	if (OUTPUT =='success') {
         	echo " Deployment is successfull"
		currentBuild.result = "SUCCESS"
         	return
       	} else {
		echo "Starting rollback"
		sh "kubectl rollout undo deployment/helloworld | awk '{print \$1}' | grep -v NAME"
         	error("Deployment Unsuccessful.")
		currentBuild.result = "FAILURE"
         	return
        }
    	}
    }
}
catch (err){
    currentBuild.result = "FAILURE"
    throw err
}
