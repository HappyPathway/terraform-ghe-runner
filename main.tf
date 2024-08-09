data "github_actions_registration_token" "token" {
  for_each   = toset(var.repos)
  repository = each.value
}

data "github_repository" "repository" {
  for_each = toset(var.repos)
  owner    = var.github_owner
  name     = each.value
}


resource "github_actions_runner_group" "rg" {
  count                   = var.runner_group == null ? 0 : 1
  name                    = var.runner_group
  visibility              = "selected"
  selected_repository_ids = [data.github_repository.repository[*].repo_id]
}

locals {
  command = join(" ", concat(
    ["./config.sh --url ${var.github_base_url}/${var.github_owner}/${each.value}"],
    ["--token ${self.triggers.token}"],
    ["--name ${each.value}"],
    length(var.runner_labels) > 0 ? ["--labels ${join(",", var.runner_labels)}"] : [],
    var.runner_group != null ? ["--runnergroup ${github_actions_runner_group.rg[0].id}"] : []
  ))
}
resource "null_resource" "register_runner" {
  for_each = toset(var.repos)
  triggers = {
    token = lookup(data.github_actions_registration_token.token, each.value).token
  }

  provisioner "local-exec" {
    command = "echo ${local.command}"
  }
}