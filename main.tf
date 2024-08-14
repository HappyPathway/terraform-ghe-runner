data "github_actions_registration_token" "token" {
  for_each   = toset(var.repos)
  repository = each.value
}

data "github_repository" "repository" {
  for_each = toset(var.repos)
  name     = each.value
}

resource "github_actions_runner_group" "rg" {
  count                   = var.runner_group == null ? 0 : 1
  name                    = var.runner_group
  visibility              = "selected"
  selected_repository_ids = [data.github_repository.repository[*].repo_id]
}

locals {
  command = { for repo in var.repos : repo => join(" ", concat(
    ["${var.runner_basedir}/${each.value}/config.sh --url ${var.github_base_url}/${var.github_owner}/${repo}"],
    ["--token ${lookup(data.github_actions_registration_token.token, repo).token}"],
    ["--name ${repo}"],
    ["--unattended"],
    ["--work ${repo}"],
    ["--replace"],
    ["--labels ${join(",", concat(var.runner_labels, [repo]))}"],
    var.runner_group != null ? ["--runnergroup ${github_actions_runner_group.rg[0].id}"] : []
  )) }
}

resource "local_file" "supervisorctl" {
  for_each = toset(var.repos)
  filename = "${path.root}/supervisor/${each.value}.conf"
  content = templatefile("${path.module}/templates/supervisorctl.conf.tpl", {
    command   = lookup(local.command, each.value)
    directory = "${var.runner_basedir}/${each.value}"
    runner    = each.value
  })
}

resource "null_resource" "register_runner" {
  for_each = toset(var.repos)
  triggers = {
    token = lookup(data.github_actions_registration_token.token, each.value).token
  }

  provisioner "local-exec" {
    command = "mkdir -p ${var.runner_basedir}/${each.value} || echo 'Directory already exists'"
  }

  provisioner "local-exec" {
    command     = "tar vxzf ${var.runner_tarball} >/dev/null 2>/dev/null"
    working_dir = "${var.runner_basedir}/${each.value}"
  }
  depends_on = [local_file.supervisorctl]
}

resource "null_resource" "supervisorctl_reload" {
  triggers = {
    token = join(",", [for token in data.github_actions_registration_token.token : token.token])
  }
  provisioner "local-exec" {
    command = "supervisorctl reload"
  }
  depends_on = [
    local_file.supervisorctl,
    null_resource.register_runner
  ]
}