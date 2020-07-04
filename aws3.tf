resource "aws_s3_bucket" "transferbucket" {
  bucket = "billyboyballintransferbucket"
  acl    = "private"

  versioning {
    enabled = true
  }

}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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
resource "aws_iam_role_policy_attachment" lambda-policy-one {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}
resource "aws_iam_role_policy_attachment" lambda-policy-two {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}
resource "aws_lambda_function" "test_lambda" {
  filename      = "./lambdacode.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.handler"

  vpc_config {
    security_group_ids = [aws_security_group.ssh.id]
    subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  }

  runtime = "python3.8"
}
