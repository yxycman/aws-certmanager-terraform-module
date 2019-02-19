data "archive_file" "lambda-zipper" {
  type        = "zip"
  source_dir  = "${path.module}/python_code/"
  output_path = "${path.module}/${var.name}.zip"
}

data "aws_route53_zone" "camelot-global" {
  name = "${var.r53-zone-name}"
}

data "template_file" "lambda-certificate-provisioner-role-policy" {
  template = "${file("${path.module}/policies/lambda-certificate-provisioner-role-policy.tpl")}"

  vars {
    r53-zone-id = "${data.aws_route53_zone.camelot-global.zone_id}"
  }
}
