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
    ["${var.runner_basedir}/${repo}/config.sh --url ${var.github_base_url}/${var.github_owner}/${repo}"],
    ["--token ${lookup(data.github_actions_registration_token.token, repo).token}"],
    ["--name ${repo}"],
    ["--unattended"],
    ["--work ${repo}"],
    ["--replace"],
    ["--labels ${join(",", concat(var.runner_labels, [repo]))}"],
    var.runner_group != null ? ["--runnergroup ${github_actions_runner_group.rg[0].id}"] : []
  )) }
  working_dir = { for repo in var.repos : repo => "${var.runner_basedir}/${repo}" }
  config_path = { for repo in var.repos : repo => "${var.runner_basedir}/${repo}/config.sh" }
}

resource "local_file" "supervisorctl" {
  for_each = toset(var.repos)
  filename = "${path.root}/supervisor/${each.value}.conf"
  content = templatefile("${path.module}/templates/supervisorctl.conf.tpl", {
    command   = "${var.runner_basedir}/${each.value}/run.sh"
    directory = "${var.runner_basedir}/${each.value}"
    runner    = each.value
  })
}

resource "null_resource" "install_runner" {
  for_each = toset(var.repos)
  triggers = {
    repos = join(",", var.repos)
  }
  provisioner "local-exec" {
    command = "mkdir -p ${lookup(local.working_dir, each.value)}"
  }

  provisioner "local-exec" {
    command     = "tar vxzf ${var.runner_tarball} >/dev/null 2>/dev/null"
    working_dir = lookup(local.working_dir, each.value)
  }

  depends_on = [
    local_file.supervisorctl
  ]
}

resource "local_file" "env" {
  for_each = toset(var.repos)
  content = templatefile(
    "${path.module}/templates/env",
    merge(var.env_vars, {
      NODE_TLS_REJECT_UNAUTHORIZED = 0
      LANG                         = "en_US.UTF-8"
  }))
  filename = "${lookup(local.working_dir, each.value)}/.env"
}

resource "null_resource" "register_runner" {
  for_each = toset(var.repos)
  triggers = {
    repos = join(",", var.repos)
  }
  provisioner "local-exec" {
    command     = "rm .runner || echo 'No runner to remove'"
    working_dir = lookup(local.working_dir, each.value)
  }

  provisioner "local-exec" {
    command     = "${lookup(local.config_path, each.value)} remove || echo 'No runner to remove'"
    working_dir = lookup(local.working_dir, each.value)
  }

  provisioner "local-exec" {
    command     = "${lookup(local.command, each.value)} || echo 'Runner already exists'"
    working_dir = lookup(local.working_dir, each.value)
  }

  depends_on = [
    local_file.supervisorctl,
    null_resource.install_runner,
    local_file.env
  ]
}

resource "null_resource" "supervisorctl_reload" {
  triggers = {
    repos = join(",", var.repos)
  }
  provisioner "local-exec" {
    command = "supervisorctl reload"
  }
  depends_on = [
    local_file.supervisorctl,
    null_resource.register_runner
  ]
}