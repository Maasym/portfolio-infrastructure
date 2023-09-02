variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Get", "Set", "List", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

