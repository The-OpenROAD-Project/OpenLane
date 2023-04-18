// This file is used for internal testing by the OpenROAD team.
def NEW_SHA = "NONE"
def OLD_SHA = "NONE"
pipeline {
    agent any;
    options {
        timeout(time: 8, unit: 'HOURS');
    }
    environment {
        ROUTING_CORES = 32;
    }
    stages {

        // not used, checkout just to keep track of changes
        stage("Update OpenROAD to HEAD of master branch") {
            steps {
                checkout([$class: "GitSCM",
                        branches: [[name: "*/master"]],
                        userRemoteConfigs: [[url: "https://github.com/The-OpenROAD-Project/OpenROAD"]],
                        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'openroad']]
                ]);
            }
        }

        stage('Build OpenROAD Docker image with master branch') {
            steps {
                sh 'PDK_ROOT=$(pwd)/pdks OPENLANE_IMAGE_NAME=efabless/openlane python3 .github/scripts/update_tools.py openroad_app';
                sh 'make -C docker build-openroad_app';
                script { NEW_SHA  = sh (returnStdout: true, script: "python3 dependencies/tool.py -f commit openroad_app").trim(); }
            }
        }

        stage('Build Docker OpenLane image with openroad_app master') {
            steps {
                sh 'make -C docker openlane OPENLANE_IMAGE_NAME=current:latest';
                sh 'docker save current:latest-amd64 | gzip > openlane-current.tar.gz';
                stash name: 'data', includes: 'openlane-current.tar.gz';
            }
        }

        stage('Run Tests') {
            matrix {
                axes {
                    axis {
                        name 'DESIGN';
                        values "aes",
                               "aes_core",
                               "APU",
                               "blabla",
                               "BM64",
                               "gcd",
                               "inverter",
                               "manual_macro_placement_test",
                               "picorv32a",
                               "PPU",
                               "s44",
                               "salsa20",
                               "spm",
                               "usb",
                               "usb_cdc_core",
                               "wbqspiflash",
                               "xtea",
                               "y_huff",
                               "zipdiv";
                    }
                }
                stages {
                    stage('Test') {
                        agent any;
                        steps {
                            script {
                                stage("${DESIGN} - Install PDK") {
                                    sh 'python3 -m pip install --user --upgrade --no-cache-dir pip';
                                    sh 'python3 -m pip install --user --upgrade --no-cache-dir volare';
                                    sh 'make pdk';
                                }
                                stage("${DESIGN} - Import Docker image") {
                                    unstash "data";
                                    sh 'docker load --input openlane-current.tar.gz';
                                }
                                stage("${DESIGN} - Update OpenROAD commit") {
                                    script { OLD_SHA  = sh (returnStdout: true, script: "python3 dependencies/tool.py -f commit openroad_app").trim(); }
                                    sh "sed -i s/${OLD_SHA}/${NEW_SHA}/ ./dependencies/tool_metadata.yml"
                                }
                                stage("${DESIGN} - Run test") {
                                    sh "make OPENLANE_IMAGE_NAME=current:latest TEST_DESIGN=${DESIGN} test";
                                }
                            }
                        }
                        post {
                            failure {
                                archiveArtifacts artifacts: "designs/**/*.log, designs/**/openroad_issue_reproducible/**/*";
                            }
                        }
                    }
                }
            }
        }

    }

    post {
        failure {
            emailext(
                    to: '$DEFAULT_RECIPIENTS',
                    subject: '$DEFAULT_SUBJECT',
                    body: '$DEFAULT_CONTENT',
                    );
        }
    }

}
