
resource "github_actions_runner_group" "rg" {
  count                   = var.runner_group == null ? 0 : 1
  name                    = var.runner_group
  visibility              = "selected"
  selected_repository_ids = [data.github_repository.repository[*].repo_id]
}
