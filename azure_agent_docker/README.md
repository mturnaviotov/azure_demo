# Azure DevOps Agent Docker - Local Build

This guide explains how to build a Docker image for an Azure DevOps agent from this directory.

## Prerequisites

- Docker or Docker Desktop installed on your machine
- Azure DevOps Personal Access Token (PAT)
- Agent pool name in your Azure DevOps organization

## Steps

1. **Clone or prepare this directory**

    Ensure you have all necessary files (e.g., `Dockerfile`, agent scripts) in this directory. Use proper arm64 or Wintel image

2. **Build the Docker image**

    ```bash
    docker build -t azure-devops-agent .
    ```

3. **Run the Docker container**

    Replace `<AZP_URL>`, `<AZP_TOKEN>`, and `<AZP_POOL>` with your values.

    ```bash
    docker run -e AZP_URL=https://dev.azure.com/your_organization \
                  -e AZP_TOKEN=your_pat_token \
                  -e AZP_POOL=your_agent_pool \
                  azure-devops-agent
    # OR
    docker run --env-file ../env.vars azure-devops-agent
    ```

## Environment Variables

- `AZP_URL`: Azure DevOps organization URL
- `AZP_TOKEN`: Personal Access Token
- `AZP_POOL`: Agent pool name

## References

- [Azure DevOps Agent Docker Docs](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker)
- [Microsoft Docs: Self-hosted Agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux)
- [Microsoft Docs: Self-hosted Docker Agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops)