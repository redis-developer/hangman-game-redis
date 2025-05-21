###########################################
################ Words API ################
###########################################

resource "aws_api_gateway_rest_api" "words_api" {
  depends_on = [aws_lambda_function.words_function]
  name = "words_api"
  description = "Words API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "words_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  parent_id   = aws_api_gateway_rest_api.words_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "words_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  parent_id   = aws_api_gateway_resource.words_api_resource.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "words_resource" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  parent_id   = aws_api_gateway_resource.words_v1_resource.id
  path_part = "words"
}

resource "aws_api_gateway_method" "words_post_method" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "words_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = aws_api_gateway_method.words_post_method.http_method
  integration_http_method = aws_api_gateway_method.words_post_method.http_method
  uri = aws_lambda_function.words_function.invoke_arn
  type = "AWS_PROXY"
}

resource "aws_api_gateway_method_response" "words_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = aws_api_gateway_method.words_post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "words_api_prod" {
  depends_on = [aws_api_gateway_integration.words_post_integration]
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  stage_name = "words_api_prod"
}

###########################################
############# Words API CORS ##############
###########################################

resource "aws_api_gateway_method" "words_options_method" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "words_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = aws_api_gateway_method.words_options_method.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "words_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = aws_api_gateway_method.words_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "words_options_integration_response" {
  depends_on = [aws_s3_bucket.hangman_game_redis]
  rest_api_id = aws_api_gateway_rest_api.words_api.id
  resource_id = aws_api_gateway_resource.words_resource.id
  http_method = aws_api_gateway_method.words_options_method.http_method
  status_code = aws_api_gateway_method_response.words_options_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST'"
    "method.response.header.Access-Control-Allow-Origin" = "'http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}'"
  }
}

###########################################
############### Player API ################
###########################################

resource "aws_api_gateway_rest_api" "player_api" {
  depends_on = [aws_lambda_function.player_function]
  name = "player_api"
  description = "Player API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "player_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  parent_id   = aws_api_gateway_rest_api.player_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "player_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  parent_id   = aws_api_gateway_resource.player_api_resource.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "player_resource" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  parent_id   = aws_api_gateway_resource.player_v1_resource.id
  path_part = "players"
}

resource "aws_api_gateway_method" "player_post_method" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "player_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = aws_api_gateway_method.player_post_method.http_method
  integration_http_method = aws_api_gateway_method.player_post_method.http_method
  uri = aws_lambda_function.player_function.invoke_arn
  type = "AWS_PROXY"
}

resource "aws_api_gateway_method_response" "player_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = aws_api_gateway_method.player_post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "player_api_prod" {
  depends_on = [aws_api_gateway_integration.player_post_integration]
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  stage_name = "player_api_prod"
}

###########################################
############# Player API CORS #############
###########################################

resource "aws_api_gateway_method" "player_options_method" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "player_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = aws_api_gateway_method.player_options_method.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "player_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = aws_api_gateway_method.player_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "player_options_integration_response" {
  depends_on = [aws_s3_bucket.hangman_game_redis]
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.player_resource.id
  http_method = aws_api_gateway_method.player_options_method.http_method
  status_code = aws_api_gateway_method_response.player_options_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST'"
    "method.response.header.Access-Control-Allow-Origin" = "'http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}'"
  }
}

###########################################
############### Game API ##################
###########################################

resource "aws_api_gateway_rest_api" "game_api" {
  depends_on = [aws_lambda_function.game_function]
  name = "game_api"
  description = "Game API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "game_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  parent_id   = aws_api_gateway_rest_api.game_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "game_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  parent_id   = aws_api_gateway_resource.game_api_resource.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "game_resource" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  parent_id   = aws_api_gateway_resource.game_v1_resource.id
  path_part = "game"
}

resource "aws_api_gateway_method" "game_post_method" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "game_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = aws_api_gateway_method.game_post_method.http_method
  integration_http_method = aws_api_gateway_method.game_post_method.http_method
  uri = aws_lambda_function.game_function.invoke_arn
  type = "AWS_PROXY"
}

resource "aws_api_gateway_method_response" "game_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = aws_api_gateway_method.game_post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "game_api_prod" {
  depends_on = [aws_api_gateway_integration.game_post_integration]
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  stage_name = "game_api_prod"
}

###########################################
############## Game API CORS ##############
###########################################

resource "aws_api_gateway_method" "game_options_method" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "game_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = aws_api_gateway_method.game_options_method.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "game_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = aws_api_gateway_method.game_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "game_options_integration_response" {
  depends_on = [aws_s3_bucket.hangman_game_redis]
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  resource_id = aws_api_gateway_resource.game_resource.id
  http_method = aws_api_gateway_method.game_options_method.http_method
  status_code = aws_api_gateway_method_response.game_options_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST'"
    "method.response.header.Access-Control-Allow-Origin" = "'http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}'"
  }
}

###########################################
############## Metrics API ################
###########################################

resource "aws_api_gateway_rest_api" "metrics_api" {
  depends_on = [aws_lambda_function.metrics_function]
  name = "metrics_api"
  description = "Metrics API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "metrics_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  parent_id   = aws_api_gateway_rest_api.metrics_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "metrics_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  parent_id   = aws_api_gateway_resource.metrics_api_resource.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "metrics_resource" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  parent_id   = aws_api_gateway_resource.metrics_v1_resource.id
  path_part   = "metrics"
}

resource "aws_api_gateway_method" "metrics_post_method" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "metrics_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = aws_api_gateway_method.metrics_post_method.http_method
  integration_http_method = aws_api_gateway_method.metrics_post_method.http_method
  uri = aws_lambda_function.metrics_function.invoke_arn
  type = "AWS_PROXY"
}

resource "aws_api_gateway_method_response" "metrics_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = aws_api_gateway_method.metrics_post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "metrics_api_prod" {
  depends_on = [aws_api_gateway_integration.metrics_post_integration]
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  stage_name = "metrics_api_prod"
}

###########################################
############# Metrics API CORS ############
###########################################

resource "aws_api_gateway_method" "metrics_options_method" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "metrics_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = aws_api_gateway_method.metrics_options_method.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "metrics_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = aws_api_gateway_method.metrics_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "metrics_options_integration_response" {
  depends_on = [aws_s3_bucket.hangman_game_redis]
  rest_api_id = aws_api_gateway_rest_api.metrics_api.id
  resource_id = aws_api_gateway_resource.metrics_resource.id
  http_method = aws_api_gateway_method.metrics_options_method.http_method
  status_code = aws_api_gateway_method_response.metrics_options_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST'"
    "method.response.header.Access-Control-Allow-Origin" = "'http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}'"
  }
}

###########################################
############# Words Function ##############
###########################################

resource "aws_iam_role_policy" "words_role_policy" {
  role = aws_iam_role.words_role.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "words_role" {
  name = "words_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "words_function" {
  depends_on = [rediscloud_essentials_database.hangman_game_redis]
  function_name = "words-function"
  description = "Backend function for the Words API"
  filename = "../target/hangman-game-redis-1.0.jar"
  handler = "io.redis.hangman.game.cloud.LambdaFunctionHandler"
  role = aws_iam_role.metrics_role.arn
  runtime = "java17"
  memory_size = 256
  timeout = 60
  architectures = ["arm64"]
  environment {
    variables = {
      REDIS_CONNECTION_URL = "redis://default:${rediscloud_essentials_database.hangman_game_redis.password}@${rediscloud_essentials_database.hangman_game_redis.public_endpoint}"
      ALLOWED_ORIGINS = "http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}"
    }
  }
}

resource "aws_lambda_permission" "words_function_api_gateway_trigger" {
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.words_function.function_name
  source_arn = "${aws_api_gateway_rest_api.words_api.execution_arn}/${aws_api_gateway_deployment.words_api_prod.stage_name}/*/*"
}

resource "aws_lambda_permission" "words_function_cloudwatch_trigger" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  function_name = aws_lambda_function.words_function.function_name
  source_arn = aws_cloudwatch_event_rule.words_function_every_minute.arn
}

resource "aws_cloudwatch_event_rule" "words_function_every_minute" {
  name = "${random_string.generated.result}-execute-words-function-every-minute"
  description = "Execute the words function every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "words_function_every_minute" {
  rule = aws_cloudwatch_event_rule.words_function_every_minute.name
  target_id = aws_lambda_function.words_function.function_name
  arn = aws_lambda_function.words_function.arn
  input = "{\"message\": \"Wake up...\"}"
}

###########################################
############ Player Function ##############
###########################################

resource "aws_iam_role_policy" "player_role_policy" {
  role = aws_iam_role.player_role.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "player_role" {
  name = "player_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "player_function" {
  depends_on = [rediscloud_essentials_database.hangman_game_redis]
  function_name = "player-function"
  description = "Backend function for the Player API"
  filename = "../target/hangman-game-redis-1.0.jar"
  handler = "io.redis.hangman.game.cloud.LambdaFunctionHandler"
  role = aws_iam_role.metrics_role.arn
  runtime = "java17"
  memory_size = 256
  timeout = 60
  architectures = ["arm64"]
  environment {
    variables = {
      REDIS_CONNECTION_URL = "redis://default:${rediscloud_essentials_database.hangman_game_redis.password}@${rediscloud_essentials_database.hangman_game_redis.public_endpoint}"
      ALLOWED_ORIGINS = "http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}"
    }
  }
}

resource "aws_lambda_permission" "player_function_api_gateway_trigger" {
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.player_function.function_name
  source_arn = "${aws_api_gateway_rest_api.player_api.execution_arn}/${aws_api_gateway_deployment.player_api_prod.stage_name}/*/*"
}

resource "aws_lambda_permission" "player_function_cloudwatch_trigger" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  function_name = aws_lambda_function.player_function.function_name
  source_arn = aws_cloudwatch_event_rule.player_function_every_minute.arn
}

resource "aws_cloudwatch_event_rule" "player_function_every_minute" {
  name = "${random_string.generated.result}-execute-player-function-every-minute"
  description = "Execute the player function every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "player_function_every_minute" {
  rule = aws_cloudwatch_event_rule.player_function_every_minute.name
  target_id = aws_lambda_function.player_function.function_name
  arn = aws_lambda_function.player_function.arn
  input = "{\"message\": \"Wake up...\"}"
}

###########################################
############## Game Function ##############
###########################################

resource "aws_iam_role_policy" "game_role_policy" {
  role = aws_iam_role.game_role.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "game_role" {
  name = "game_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "game_function" {
  depends_on = [rediscloud_essentials_database.hangman_game_redis]
  function_name = "game-function"
  description = "Backend function for the Game API"
  filename = "../target/hangman-game-redis-1.0.jar"
  handler = "io.redis.hangman.game.cloud.LambdaFunctionHandler"
  role = aws_iam_role.metrics_role.arn
  runtime = "java17"
  memory_size = 256
  timeout = 60
  architectures = ["arm64"]
  environment {
    variables = {
      REDIS_CONNECTION_URL = "redis://default:${rediscloud_essentials_database.hangman_game_redis.password}@${rediscloud_essentials_database.hangman_game_redis.public_endpoint}"
      ALLOWED_ORIGINS = "http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}"
    }
  }
}

resource "aws_lambda_permission" "game_function_api_gateway_trigger" {
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.game_function.function_name
  source_arn = "${aws_api_gateway_rest_api.game_api.execution_arn}/${aws_api_gateway_deployment.game_api_prod.stage_name}/*/*"
}

resource "aws_lambda_permission" "game_function_cloudwatch_trigger" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  function_name = aws_lambda_function.game_function.function_name
  source_arn = aws_cloudwatch_event_rule.game_function_every_minute.arn
}

resource "aws_cloudwatch_event_rule" "game_function_every_minute" {
  name = "${random_string.generated.result}-execute-game-function-every-minute"
  description = "Execute the game function every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "game_function_every_minute" {
  rule = aws_cloudwatch_event_rule.game_function_every_minute.name
  target_id = aws_lambda_function.game_function.function_name
  arn = aws_lambda_function.game_function.arn
  input = "{\"message\": \"Wake up...\"}"
}

###########################################
############ Metrics Function #############
###########################################

resource "aws_iam_role_policy" "metrics_role_policy" {
  role = aws_iam_role.metrics_role.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "metrics_role" {
  name = "metrics_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "metrics_function" {
  depends_on = [rediscloud_essentials_database.hangman_game_redis]
  function_name = "metrics-function"
  description = "Backend function for the Metrics API"
  filename = "../target/hangman-game-redis-1.0.jar"
  handler = "io.redis.hangman.game.cloud.LambdaFunctionHandler"
  role = aws_iam_role.metrics_role.arn
  runtime = "java17"
  memory_size = 256
  timeout = 60
  architectures = ["arm64"]
  environment {
    variables = {
      REDIS_CONNECTION_URL = "redis://default:${rediscloud_essentials_database.hangman_game_redis.password}@${rediscloud_essentials_database.hangman_game_redis.public_endpoint}"
      ALLOWED_ORIGINS = "http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}"
    }
  }
}

resource "aws_lambda_permission" "metrics_function_api_gateway_trigger" {
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.metrics_function.function_name
  source_arn = "${aws_api_gateway_rest_api.metrics_api.execution_arn}/${aws_api_gateway_deployment.metrics_api_prod.stage_name}/*/*"
}

resource "aws_lambda_permission" "metrics_function_cloudwatch_trigger" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  function_name = aws_lambda_function.metrics_function.function_name
  source_arn = aws_cloudwatch_event_rule.metrics_function_every_minute.arn
}

resource "aws_cloudwatch_event_rule" "metrics_function_every_minute" {
  name = "${random_string.generated.result}-execute-metrics-function-every-minute"
  description = "Execute the metrics function every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "metrics_function_every_minute" {
  rule = aws_cloudwatch_event_rule.metrics_function_every_minute.name
  target_id = aws_lambda_function.metrics_function.function_name
  arn = aws_lambda_function.metrics_function.arn
  input = "{\"message\": \"Wake up...\"}"
}
