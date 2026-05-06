# 1. Verify Email
resource "aws_ses_email_identity" "notify_email" {
  email = var.target_email
}

# 2. Package Lambda Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/index.py"
  output_path = "${path.module}/src/lambda.zip"
}

# 3. IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.env}-lambda-ses-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.env}-lambda-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 4. Lambda Function
resource "aws_lambda_function" "notifier" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.env}-state-notifier"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SENDER_EMAIL = var.target_email
      ENV          = var.env
    }
  }
}

# 5. S3 Trigger Permission
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifier.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.state_bucket}"
}

# 6. S3 Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.state_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.notifier.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".tfstate"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}
