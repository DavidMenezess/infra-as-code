resource "aws_ecr_repository" "ecr_docker_image" {
  name                 = "site_prod"
  image_tag_mutability = "MUTABLE"

}