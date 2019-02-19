resource "aws_iam_role" "lambda-certificate-provisioner-role" {
  name        = "${var.name}-role"
  description = "Role for lambda-certificate-provisioner Lambda Function"

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

resource "aws_iam_role_policy" "lambda-certificate-provisioner-role-policy" {
  name = "lambda-certificate-provisioner-role-policy"
  role = "${aws_iam_role.lambda-certificate-provisioner-role.id}"

  policy = "${data.template_file.lambda-certificate-provisioner-role-policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "lambda-certificate-provisioner-role-policy-attachment" {
  role       = "${aws_iam_role.lambda-certificate-provisioner-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "lambda-certificate-provisioner" {
  filename         = "${data.archive_file.lambda-zipper.output_path}"
  function_name    = "${var.name}"
  role             = "${aws_iam_role.lambda-certificate-provisioner-role.arn}"
  handler          = "certbot-aws.handler"
  runtime          = "python3.6"
  timeout          = "${var.timeout}"
  memory_size      = "${var.memory-size}"
  description      = "Lambda Function for automatic update of certificates"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda-zipper.output_path}"))}"
  depends_on       = ["data.archive_file.lambda-zipper"]

  vpc_config = {
    subnet_ids         = "${var.subnet-ids}"
    security_group_ids = "${var.sg-ids}"
  }

  tags = "${merge(var.default-tags)}"

  environment = {
    variables = "${merge(
                  map("slack_channel", "${var.slack-channel}"),
                  map("slack_token", "${var.slack-token}"),
                  map("certificate_domains", "${var.certificate-domains}"),
                  map("certificate_email", "${var.certificate-email}")
    )}"
  }
}

resource "aws_lambda_permission" "allow-cloudwatch-cron" {
  statement_id  = "allow-cloudwatch-cron"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-certificate-provisioner.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.certificate-provisioner-cron-runner.arn}"
}

resource "aws_cloudwatch_event_rule" "certificate-provisioner-cron-runner" {
  name                = "certificate-provisioner-cron-runner"
  description         = "Execute 'lambda-certificate-provisioner' Lambda function by cron"
  schedule_expression = "${var.cron-expression}"
}

resource "aws_cloudwatch_event_target" "certificate-provisioner-cron" {
  rule = "${aws_cloudwatch_event_rule.certificate-provisioner-cron-runner.name}"
  arn  = "${aws_lambda_function.lambda-certificate-provisioner.arn}"

  input = "{}"
}
