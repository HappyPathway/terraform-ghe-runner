data "github_actions_organization_registration_token" "token" {
  count = local.has_repos ? 0 : 1
}

locals {
  org_command = concat(
    ["${var.runner_basedir}/${var.github_owner}/config.sh --url ${var.github_base_url}/${var.github_owner}"],
    ["--token ${data.github_actions_organization_registration_token.token[0].token}"],
    ["--name ${var.github_owner}"],
    ["--unattended"],
    ["--work ${var.github_owner}"],
    ["--replace"],
    ["--labels ${join(",", concat(var.runner_labels, [var.github_owner]))}"],
    var.runner_group != null ? ["--runnergroup ${github_actions_runner_group.rg[0].id}"] : []
  )
  org_working_dir = "${var.runner_basedir}/${var.github_owner}"
  org_config_path = "${var.runner_basedir}/${var.github_owner}/config.sh"
}

resource "local_file" "org_supervisorctl" {
  count    = local.has_repos ? 0 : 1
  filename = "${path.root}/supervisor/${var.github_owner}.conf"
  content = templatefile("${path.module}/templates/supervisorctl.conf.tpl", {
    command     = "${local.org_working_dir}/run.sh"
    directory   = "${local.org_working_dir}"
    runner      = var.github_owner
    autorestart = var.autorestart
  })
}

resource "null_resource" "install_org_runner" {
  count = local.has_repos ? 0 : 1

  provisioner "local-exec" {
    command = "mkdir -p ${local.org_working_dir}"
  }

  provisioner "local-exec" {
    command     = "tar vxzf ${var.runner_tarball} >/dev/null 2>/dev/null"
    working_dir = local.org_working_dir
  }

  depends_on = [
    local_file.org_supervisorctl
  ]
}

resource "local_file" "org_env" {
  count = local.has_repos ? 0 : 1
  content = templatefile(
    "${path.module}/templates/env",
    merge(var.env_vars, {
      NODE_TLS_REJECT_UNAUTHORIZED = 0
      LANG                         = "en_US.UTF-8"
  }))
  filename = "${local.org_working_dir}/.env"
}

resource "null_resource" "register_org_runner" {
  count = local.has_repos ? 0 : 1
  provisioner "local-exec" {
    command     = "rm .runner || echo 'No runner to remove'"
    working_dir = local.org_working_dir
  }

  provisioner "local-exec" {
    command     = "${local.org_config_path} remove || echo 'No runner to remove'"
    working_dir = local.org_working_dir
  }

  provisioner "local-exec" {
    command     = "${local.org_command} || echo 'Runner already exists'"
    working_dir = local.org_working_dir
  }

  depends_on = [
    local_file.org_supervisorctl,
    null_resource.install_org_runner,
    local_file.org_env
  ]
}
