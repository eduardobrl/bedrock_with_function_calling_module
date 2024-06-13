variable "foundation_model" {
  description = "The name foundation model to use for the Bedrock agent"
  type        = string
  default     = "claude-v1"
}

variable "instructions" {
  description = "The instructions for bedrock agent"
  type        = string
  default     = "claude-v1"
}

variable "app_name" {
  description = "The name of ther service"
  type        = string
}

variable "alias_name" {
  description = "The name of ther service"
  type        = string
  default = "prod"
}

variable "functions" {
  description = "Lambda functions to handle bedrock tools"
  type        = set(object({
    name     = string
    handler  = string
    runtime  = string
    filename = string
    schema   = string
  }))
}