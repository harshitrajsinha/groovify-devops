resource "aws_ssm_parameter" "cognito_clientid" {
  name      = "/groovify/COGNITO_CLIENT_ID"
  type      = "SecureString"
  value     = aws_cognito_user_pool_client.groovify_cognito_user_pool_client.id
  overwrite = true
}

resource "aws_ssm_parameter" "cognito_clientsec" {
  name      = "/groovify/COGNITO_CLIENT_SECRET"
  type      = "SecureString"
  value     = aws_cognito_user_pool_client.groovify_cognito_user_pool_client.client_secret
  overwrite = true
}

resource "aws_ssm_parameter" "cognito_userpoolid" {
  name      = "/groovify/COGNITO_USER_POOL_ID"
  type      = "SecureString"
  value     = aws_cognito_user_pool.groovify_cognito_user_pool.id
  overwrite = true
}

resource "aws_ssm_parameter" "vite_cognito_clientid" {
  name      = "/groovify/VITE_COGNITO_CLIENT_ID"
  type      = "SecureString"
  value     = aws_cognito_user_pool_client.groovify_cognito_user_pool_client.id
  overwrite = true
}

resource "aws_ssm_parameter" "s3_bucket_groovify" {
  name      = "/groovify/S3_BUCKET_NAME"
  type      = "String"
  value     = var.s3_bucket_name_groovify
  overwrite = true
}
