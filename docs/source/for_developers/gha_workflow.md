# Continuous Integration
OpenLane's CI runs on GitHub Actions.

There are two primary flows: the pull request flow and the deployment flow.

The deployment flow occurs on a daily basis. The PR flow happens whenever someone creates a new Pull Request. PRs can be created by contributors or by an automated tool updater that runs on a schedule.

![A Diagram Of The Flow](../../_static/gha.png)
* A maintainer cannot review their own code, but they can merge it after a review by another maintainer.

## Required Secrets
Repository secrets are used to protect certain credentials, but also as repository-dependent parameters for the CI.

### Common
| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `MAIN_BRANCH`  | The main branch for OpenLane. Format: `main`|`master`|`etc` |
| `MY_TOKEN`  | A token for a bot account that: 1. owns the fork for the tool update. 2. has write access to the volare repo to push newly-built PDKs to. |

### CI

| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `DOCKER_IMAGE` | The name of the resulting Docker image (minus the tag). In our case, we use `efabless/openlane`. |
| `TOOL_DOCKER_IMAGE` | The name of the resulting Docker images for tools (minus the tag). In our case, we use `efabless/openlane-tools`. |
| `DOCKERHUB_USER`  | A username for a user that has push access to the organization that owns `DOCKER_IMAGE` on Docker Hub. In our case, that's an Efabless Employee with push access. |
| `DOCKERHUB_PASSWORD`  | The password/token for the given username that has push access to the organization that owns `DOCKER_IMAGE` on Docker Hub. |
| `VOLARE_OWNER`/`VOLARE_REPO` | (optional) A volare repo to cache builds in. In our case, `VOLARE_OWNER` would be `efabless` and `VOLARE_REPO` would be `volare`. |

### Tool Updater

| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `FORK_NAME` | A fork to push branches for tool updates to. Format `bot-account/OpenLane`  |
| `BOT_AUTHOR_LINE`  | A git author line for the bot account, i.e. `Firstname Lastname <email@example.com>`. |