# Continuous Integration
OpenLane's CI runs on GitHub Actions.

There are two primary flows: the pull request flow and the deployment flow.

The deployment flow occurs on each push, with an extended test set nightly. The PR flow happens whenever someone creates a new Pull Request. PRs can be created by contributors or by an automated tool updater that runs on a schedule.

* A maintainer cannot review their own code, but they can merge it after a review by another maintainer.

## Required Secrets/Variables
Repository secrets are used to protect certain credentials, while variables are repository-dependent parameters for the CI.

### Common
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `MAIN_BRANCH`  | The main branch for OpenLane. Format: `main`|`master`|`etc` |

| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `BOT_TOKEN`  | A GitHub token for a bot account that is able to create new tags on this repository. |

### CI
| Variable      | Description                                                   |
|---------------|
| `DOCKER_IMAGE` | The name of the resulting Docker image (minus the tag). In our case, we use `ghcr.io/the-openroad-project/openlane`. |
| `TOOL_DOCKER_IMAGE` | The name of the resulting Docker images for tools (minus the tag). In our case, we use `ghcr.io/the-openroad-project/openlane-tools`. |
