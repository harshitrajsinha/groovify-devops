resource "aws_cognito_user_pool" "groovify_cognito_user_pool" {
  name                     = "groovify-cognito-user-pool"
  auto_verified_attributes = ["email"]
  deletion_protection      = "INACTIVE" # To be set ACTIVE in production
  tags = {
    Project   = var.project_name_tag
    Terraform = "true"
  }

}

# ---------------------------------------------------

resource "aws_cognito_user_pool_domain" "groovify_cognito_user_pool_domain" {

  domain          = var.cognito_domain
  certificate_arn = data.aws_acm_certificate.groovify_domain_certificate.arn
  user_pool_id    = aws_cognito_user_pool.groovify_cognito_user_pool.id
}

output "cognito_domain_cloudfront_distribution" {
  value = aws_cognito_user_pool_domain.groovify_cognito_user_pool_domain.cloudfront_distribution # To be added to Domain provider as CNAME
}

# ---------------------------------------------------

resource "aws_cognito_user_pool_client" "groovify_cognito_user_pool_client" {
  name = "groovify-cognito-user-pool-client"

  user_pool_id                         = aws_cognito_user_pool.groovify_cognito_user_pool.id
  generate_secret                      = true
  callback_urls                        = ["https://${var.my_domain_name}/auth-callback", "http://localhost/auth-callback"]
  logout_urls                          = ["https://${var.my_domain_name}", "http://localhost"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO", "Google"]

  depends_on = [aws_cognito_identity_provider.cognito_google_provider]
}

# ---------------------------------------------------

resource "aws_cognito_identity_provider" "cognito_google_provider" {

  count         = var.google_client_id != "null" && var.google_client_secret != "null" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.groovify_cognito_user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email       = "email"
    username    = "sub"
    given_name  = "given_name"
    family_name = "family_name"
    picture     = "picture"
  }
}