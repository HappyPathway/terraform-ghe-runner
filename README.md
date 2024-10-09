# terraform-ghe-runner
Terraform Module
=======

[![Terraform Validation](https://github.com/HappyPathway/terraform-ghe-runner/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-ghe-runner/actions/workflows/terraform.yaml)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_runner_group.rg](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/actions_runner_group) | resource |
| [local_file.env](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.supervisorctl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.install_runner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.register_runner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.supervisorctl_reload](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [github_actions_registration_token.token](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/actions_registration_token) | data source |
| [github_repository.repository](https://registry.terraform.io/providers/hashicorp/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autorestart"></a> [autorestart](#input\_autorestart) | n/a | `bool` | `true` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to set for the runners | `map(string)` | `{}` | no |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | Base URL for the GitHub API | `string` | `"https://api.github.com"` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | Owner of the repositories | `string` | n/a | yes |
| <a name="input_removal_tokens"></a> [removal\_tokens](#input\_removal\_tokens) | Map of repository to token for removing runners | `map(string)` | `{}` | no |
| <a name="input_repos"></a> [repos](#input\_repos) | List of repositories to add runners to | `list(string)` | `[]` | no |
| <a name="input_runner_basedir"></a> [runner\_basedir](#input\_runner\_basedir) | Base directory for the runners | `string` | `"/opt/actions-runner"` | no |
| <a name="input_runner_group"></a> [runner\_group](#input\_runner\_group) | Runner group to add runners to | `string` | `null` | no |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels) | Labels to assign to the runner | `list(string)` | `[]` | no |
| <a name="input_runner_tarball"></a> [runner\_tarball](#input\_runner\_tarball) | Path to the runner tarball | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
