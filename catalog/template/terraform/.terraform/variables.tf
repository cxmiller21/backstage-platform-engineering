variable "aws_region" {
  default = "${{ values.region }}"
}

variable "project" {
  default = "${{ values.name }}"
}
