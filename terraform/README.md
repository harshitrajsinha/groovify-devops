# Wrt App server infrastructure

## To be checked

1. For development -
- AMI of app server is changed to custom AMI that has pre-installed packages (to save cost on NAT)
- NAT gateway is removed (would make work only with vpc endpoints). Note that GoogleOAuth won't work without NAT.

2. Is MONGODB_URI value in .env of backend correctly url-encoded as per password stored in secrets manager? 

3. The following parameters needs to be already present in AWS System manager Parameter store (as they are static values) -
- `/groovify/ADMIN_EMAIL`
- `/groovify/COGNITO_DOMAIN`
- `/groovify/COGNITO_REDIRECT_URI`
- `/groovify/FRONTEND_URL`
- `/groovify/NODE_ENV`
- `/groovify/PORT`
- `/groovify/VITE_BACKEND_URL`
- `/groovify/VITE_COGNITO_DOMAIN`
- `/groovify/VITE_MODE`
- `/groovify/AWS_REGION`

4. Ensure that VPC, IGW, security groups, key pairs etc. have not reached creation limit.

## Pre applying

1. Terraform plan, apply and destroy will prompt for three inputs -
- DocumentDB master username
- Cognito GoogleOAuth client id
- Cognito GoogleOAuth client secret
- Project environment: "production" or "development"
- Public key for SSH connection

## Post applying

2. Terraform will output following important values
- ALB dns, which needs to be nslookedup and configured in DNS provider
- Cognito cloudfront, which needs to be configured in DNS provider as CNAME
- Public IP of bastion host and Private IP of App server (for SSH)


# Wrt bastion infrastructure

## Pre applying

1. Terraform plan, apply and destroy will prompt for three inputs -
- Public key for SSH connection