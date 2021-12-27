# Openlane CI/CD
There are two primary flows: the pull request flow and the deployment flow.

The deployment flow occurs on a daily basis. The PR flow happens whenever someone creates a new Pull Request. PRs can be created by contributors or by an automated tool updater that runs on a schedule.

![A Diagram Of The Flow](./diagrams/flow.png)
* A maintainer cannot review their own code, but they can merge it after a review by another maintainer.

# Required Secrets
Repository secrets are used to protect certain credentials, but also as repository-dependent parameters for the CI.

## Common
| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `MAIN_BRANCH`  | The main branch for OpenLane. Format: `main`|`master`|`etc` |

## CI

| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `DOCKER_IMAGE` | The name of the resulting Docker image (minus the tag). In our case, we use `efabless/openlane`. |
| `TOOL_DOCKER_IMAGE` | The name of the resulting Docker images for tools (minus the tag). In our case, we use `efabless/openlane-tools`. |
| `DOCKERHUB_USER`  | A username for a user that has push access to the organization that owns `DOCKER_IMAGE` on Docker Hub. In our case, that's an Efabless Employee with push access. |
| `DOCKERHUB_PASSWORD`  | The password/token for the given username that has push access to the organization that owns `DOCKER_IMAGE` on Docker Hub.|
| `LOG_UPLOAD_INFO` | **Currently unused**: Information on a cloud platform to upload buckets to, in the format `platform:bucket:encoded_credentials`, where `platform` can be `gcp`/`aws`/etc, `bucket` is the bucket name, and `encoded_credentials` are simply the relevant credentials encoded in base64. It's a bit convoluted, but it makes it so different CI users can switch the platform out by changing a single secret. Currently, only the Google Cloud Platform is supported. Support for other platforms can be added to `upload_log_tarballs.py`. If this secret is not specified, the logs will not be uploaded. |

## Tool Updater

| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `FORK_NAME` | A fork to push branches for tool updates to. Format `bot-account/OpenLane`  |
| `MY_TOKEN`  | A token for the bot account that owns the fork. |