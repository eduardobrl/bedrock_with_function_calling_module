data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "scheduler_assistant_agent_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "scheduler_assistant_agent_permissions" {
  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.foundation_model}",
    ]
  }
}

resource "aws_iam_role" "scheduler_assistant" {
  assume_role_policy = data.aws_iam_policy_document.scheduler_assistant_agent_trust.json
  name_prefix        = "AmazonBedrockExecutionRoleForAgents_"
}

resource "aws_iam_role_policy" "scheduler_assistant" {
  policy = data.aws_iam_policy_document.scheduler_assistant_agent_permissions.json
  role   = aws_iam_role.scheduler_assistant.id
}

resource "aws_bedrockagent_agent" "scheduler_assistant" {
  agent_name                  = "${var.app_name}-name"
  agent_resource_role_arn     = aws_iam_role.scheduler_assistant.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.foundation_model
  instruction                 = var.instructions
  description                 = "Bedrock agent for service ${var.app_name}"
}

resource "aws_bedrockagent_agent_alias" "scheduler_assistant" {
  agent_alias_name = var.alias_name
  agent_id         = aws_bedrockagent_agent.scheduler_assistant.agent_id
  description      = "Prodution deployment Alias"
}
