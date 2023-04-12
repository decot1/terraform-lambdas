provider "aws" {
  region = var.aws_region
}

# Gateway

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "api_gateway"
  description = "API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "Error" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "product"
}
resource "aws_api_gateway_method" "createproduct" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.Error.id
  http_method   = "POST"
  authorization = "NONE"
}

# IAM
resource "aws_iam_role" "LambdaRole" {
  name               = "LambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
data "template_file" "lambdapolicy" {
  template = "${file("${path.module}/policy.json")}"
}
resource "aws_iam_policy" "LambdaPolicy" {
  name        = "LambdaPolicy"
  path        = "/"
  description = "IAM policy for error lambda functions"
  policy      = data.template_file.productlambdapolicy.rendered
}
resource "aws_iam_role_policy_attachment" "LambdaRolePolicy" {
  role       = aws_iam_role.LambdaRole.name
  policy_arn = aws_iam_policy.LambdaPolicy.arn
}