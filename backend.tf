terraform {
  backend "s3" {
    bucket  = "terraform-state-davidmenezes" # Nome do bucket do S3
    key     = "site/terraform.tfstate" # Nome do arquivo de estado do Terraform
    region  = "us-east-1" # Região do Terraform
    encrypt = true # Encriptar o estado do Terraform
    use_lockfile = true # Usar o lockfile para evitar conflitos de estado
  }
}