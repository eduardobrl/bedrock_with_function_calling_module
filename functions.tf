resource "aws_bedrockagent_agent_action_group" "scheduler_assistant" {
  for_each = {
    for index, function in var.functions:
    function.name => function 
  }

  action_group_name           = "${each.value.name}_action_group"
  agent_id                    = aws_bedrockagent_agent.scheduler_assistant.agent_id
  agent_version               = "DRAFT"
  skip_resource_in_use_check  = true

  action_group_executor {
    lambda = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${each.value.name}"
  }

  api_schema {
    payload = file(each.value.schema)
  }
  
  depends_on = [aws_lambda_function.lambda]
  
}

resource "aws_lambda_function" "lambda" {
  for_each = {
    for index, function in var.functions:
    function.name => function 
  }
  filename         = each.value.filename
  function_name    = each.value.name
  role             = aws_iam_role.lambda_role[each.key].arn
  handler          = each.value.handler
  runtime          = each.value.runtime
}

resource "aws_iam_role" "lambda_role" {
  for_each = {
    for index, function in var.functions:
    function.name => function 
  }
  name = "${each.value.name}-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  
}

resource "aws_iam_role_policy_attachment" "bedrock_query_lambda_basic_execution" {
  for_each = {
    for index, function in var.functions:
    function.name => function 
  }
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       =  "${each.value.name}-role"
  depends_on = [aws_iam_role.lambda_role]
}
