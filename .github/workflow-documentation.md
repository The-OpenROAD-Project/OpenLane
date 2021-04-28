# Openlane CI/CD

🚧 Under construction 🚧

# Required Tokens

For internal builds the following tokens are required to be defined as secrets:

| Secret      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `DOCKERHUB_USER`  | A Username for a user that has push access to the efabless organization on Dockerhub. |
| `DOCKERHUB_PASSWORD`  | The password for the given username that has push access to the efabless organization on Dockerhub. |
| `DOCKER_IMAGE` | The name of the Docker image used. While it is not technically a secret, we don't want to define it on the repository level as that would create complications with forks. |
| `MY_TOKEN`  | A user Github with push access to the repository. Despite Github Actions internally providing GITHUB_TOKEN for the action to use. pushing/creating a branch with this token will prevent Github Actions from running on the created branch/pushed commit/submitted PR. This is a policy by Github Actions to prevent circular calls as a general rule while still providing a way for the user to do it if they know what they are doing. |

# Best Practices

1. Workflows cannot be updated with external PRs. These updates must be submitted through internal PRs.
2. Make sure to delete branches after merging or closing a pull request.
