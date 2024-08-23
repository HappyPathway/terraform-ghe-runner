variable "repos" {
  type        = list(string)
  description = "List of repositories to add runners to"
  default     = []
}

variable "github_base_url" {
  type        = string
  description = "Base URL for the GitHub API"
  default     = "https://api.github.com"
}

variable "github_owner" {
  type        = string
  description = "Owner of the repositories"
}

variable "runner_group" {
  type        = string
  description = "Runner group to add runners to"
  default     = null
}

variable "runner_labels" {
  type        = list(string)
  description = "Labels to assign to the runner"
  default     = []
}

variable "removal_tokens" {
  type        = map(string)
  description = "Map of repository to token for removing runners"
  default     = {}
}

variable "runner_tarball" {
  type        = string
  description = "Path to the runner tarball"
}

variable "runner_basedir" {
  type        = string
  description = "Base directory for the runners"
  default     = "/opt/actions-runner"
}

variable autorestart {
  type = bool
  default = true
}

variable "env_vars" {
  type        = map(string)
  description = "Environment variables to set for the runners"
  default     = {}
}
