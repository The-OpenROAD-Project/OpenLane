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

        stage('Build Docker OpenLane image with openroad_app master') {
            steps {
                script {
                    retry(3) {
                        try {
                            sh 'PDK_ROOT=$(pwd)/pdks OPENLANE_IMAGE_NAME=efabless/openlane python3 .github/scripts/update_tools.py openroad_app';
                            sh 'make -C docker build-openroad_app';
                            script { NEW_SHA  = sh (returnStdout: true, script: "python3 dependencies/tool.py -f commit openroad_app").trim(); }
                            sh 'make -C docker openlane OPENLANE_IMAGE_NAME=current:latest';
                            sh 'docker save current:latest-amd64 | gzip > openlane-current.tar.gz';
                            stash name: 'data', includes: 'openlane-current.tar.gz';
                        }
                        catch (e) {
                            sleep(60);
                            sh 'exit 1';
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            matrix {
                axes {
                    axis {
                        name 'DESIGN';
                        values "ci/aes",
                               "ci/aes_core",
                               "ci/APU",
                               "ci/blabla",
                               "'ci/BM64 -override_env QUIT_ON_LINTER_ERRORS=0'",
                               "ci/gcd",
                               "ci/inverter",
                               "ci/manual_macro_placement_test",
                               "ci/picorv32a",
                               "ci/PPU",
                               "ci/s44",
                               "ci/salsa20",
                               "ci/usb",
                               "ci/usb_cdc_core",
                               "ci/wbqspiflash",
                               "ci/xtea",
                               "'ci/y_huff -override_env QUIT_ON_SYNTH_CHECKS=0'",
                               "ci/zipdiv",
                               "ci/aes_user_project_wrapper",
                               "ci/caravel_upw",
                               "ci/mem_1r1w",
                               "spm";
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
