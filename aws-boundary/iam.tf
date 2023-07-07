resource "aws_iam_instance_profile" "controller" {
  name = "controller_profile"
  role = aws_iam_role.controller_role.name
}

data "aws_kms_key" "boundary_kms" {
  key_id = aws_kms_key.kms_key.key_id
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "controller_kms_policy" {
  statement {
    effect = "Allow"

    actions = ["kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
    "kms:DescribeKey"]

    resources = ["${data.aws_kms_key.boundary_kms.arn}"]
  }
}

resource "aws_iam_policy" "controller_kms_access" {
  name        = "Controller_KMS_access"
  description = "Allows controller instances access to KMS"
  path        = "/"

  policy = data.aws_iam_policy_document.controller_kms_policy.json
}

resource "aws_iam_role" "controller_role" {
  name               = "controller_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_role_policy_attachment" "controller_kms_access" {
  role       = aws_iam_role.controller_role.name
  policy_arn = aws_iam_policy.controller_kms_access.arn
}