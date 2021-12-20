// This file is used for internal testing by the OpenROAD team.
pipeline {
    agent any;
    options {
        timeout(time: 8, unit: 'HOURS');
    }
    stages {

        stage("Setup") {
            steps {
                sh 'python3 -m pip install --user pyyaml';
                sh 'docker system prune -a -f';
            }
        }

        stage("Checkout master branch") {
            steps {
                checkout([$class: "GitSCM",
                        branches: [[name: "*/master"]],
                        doGenerateSubmoduleConfigurations: false,
                        submoduleCfg: [],
                        userRemoteConfigs: [[credentialsId: "openroad-ci", url: "https://github.com/The-OpenROAD-Project/OpenLane"]]
                ]);
            }
        }

        stage('Checkout PDKs') {
            steps {
                sh 'make pdk';
            }
        }

        stage('Build Docker update OpenROAD commit') {
            steps {
                sh 'PDK_ROOT=$(pwd)/pdks OPENLANE_IMAGE_NAME=efabless/openlane python3 .github/scripts/update_tools.py openroad_app';
            }
        }

        stage('Build Docker base image') {
            steps {
                sh 'make -C docker base_image';
            }
        }

        stage('Build Docker image with openroad/master') {
            steps {
                sh 'make -C docker build-openroad_app';
                sh 'make -C docker export-openroad_app';
                sh 'make -C docker merge';
            }
        }

        stage('Clone Tech') {
            environment {
                ROUTING_CORES = 32;
            }
            matrix {
                axes {
                    axis {
                        name 'DESIGN';
                        // current red designs "BM64", "aes", "aes128", "aes_cipher", "blabla", "chacha", "ldpcenc", "sha512", "y_huff";
                        values "APU", "PPU", "aes_core", "des", "digital_pll_sky130_fd_sc_hd", "genericfir", "inverter", "manual_macro_placement_test", "picorv32a", "s44", "salsa20", "spm", "usb", "usb_cdc_core", "wbqspiflash", "xtea", "zipdiv";
                    }
                }
                stages {
                    stage('test') {
                        steps {
                            sh "make OPENLANE_TAG=current TEST_DESIGN=$DESIGN test";
                        }
                    }
                }
            }
        }

    }

    post {
        always {
            archiveArtifacts artifacts: "**/runs/**/*";
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
