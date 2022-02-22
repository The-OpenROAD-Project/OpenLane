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

        stage("Setup") {
            steps {
                sh 'docker system prune -a -f';
            }
        }

        stage("Checkout") {
            steps {
                checkout([$class: "GitSCM",
                        branches: [[name: "*/master"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'CleanBeforeCheckout']],
                        submoduleCfg: [],
                        userRemoteConfigs: [[credentialsId: "openroad-ci", url: "https://github.com/The-OpenROAD-Project/OpenLane"]]
                ]);
            }
        }

        stage('Checkout PDKs') {
            steps {
                sh 'git switch -c main';
                sh 'make -j 1 NPROC=1 pdk';
            }
        }

        stage('Build Docker update OpenROAD commit') {
            steps {
                sh 'PDK_ROOT=$(pwd)/pdks OPENLANE_IMAGE_NAME=efabless/openlane python3 .github/scripts/update_tools.py openroad_app';
            }
        }

        stage('Build Docker image with openroad/master') {
            steps {
                sh 'make -C docker build-openroad_app';
            }
        }

        stage('Merge Docker images') {
            steps {
                sh 'make -C docker merge';
            }
        }

        stage('Run Tests') {
            matrix {
                axes {
                    axis {
                        name 'DESIGN';
                        // designs disabled "aes128", "chacha", "ldpcenc", "sha512", "des";
                        values "aes", "aes_cipher", "aes_core", "APU", "blabla", "BM64", "digital_pll_sky130_fd_sc_hd", "genericfir", "inverter", "manual_macro_placement_test", "picorv32a", "PPU", "s44", "salsa20", "spm", "usb", "usb_cdc_core", "wbqspiflash", "xtea", "y_huff", "zipdiv";
                    }
                }
                stages {
                    stage('Test') {
                        steps {
                            script {
                                stage("${DESIGN}") {
                                    sh "make OPENLANE_TAG=current TEST_DESIGN=${DESIGN} test";
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
            emailext (
                    to: '$DEFAULT_RECIPIENTS',
                    subject: '$DEFAULT_SUBJECT',
                    body: '$DEFAULT_CONTENT',
                    );
        }
    }

}
