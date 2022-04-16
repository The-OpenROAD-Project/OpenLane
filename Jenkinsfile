// This file is used for internal testing by the OpenROAD team.
pipeline {
    agent any;
    options {
        timeout(time: 8, unit: 'HOURS');
    }
    environment {
        ROUTING_CORES = 32;
    }
    stages {

        stage('Checkout PDKs') {
            steps {
                sh 'git switch -C main';
                sh 'python3 -m pip install --user --upgrade --no-cache-dir pip';
                sh 'python3 -m pip install --user --upgrade --no-cache-dir volare';
                sh 'PDK_ROOT=$(pwd)/pdks ~/.local/bin/volare enable_or_build -t NULL -j$(nproc) $(python3 ./dependencies/tool.py open_pdks -f commit)';
            }
        }

        stage('Build Docker update OpenROAD commit') {
            steps {
                sh 'PDK_ROOT=$(pwd)/pdks OPENLANE_IMAGE_NAME=efabless/openlane python3 .github/scripts/update_tools.py openroad_app';
            }
        }

        stage('Build OpenROAD Docker image with master branch') {
            steps {
                sh 'make -C docker build-openroad_app';
            }
        }

        stage('Build Docker OpenLane image with openroad_app master') {
            steps {
                sh 'make -C docker openlane';
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
                        steps {
                            script {
                                stage("${DESIGN}") {
                                    sh "make OPENLANE_DOCKER_TAG=current TEST_DESIGN=${DESIGN} test";
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    post {
        always {
            archiveArtifacts artifacts: "designs/**/*.log, designs/**/openroad_issue_reproducible/**/*";
        }
        failure {
            emailext(
                    to: '$DEFAULT_RECIPIENTS',
                    subject: '$DEFAULT_SUBJECT',
                    body: '$DEFAULT_CONTENT',
                    );
        }
    }

}
