# Controller EC2 Profile
resource "aws_iam_instance_profile" "controller" {
  name = "controller_profile"
  role = aws_iam_role.controller_role.name
}

data "aws_kms_key" "root_boundary_kms" {
  key_id = aws_kms_key.root_kms_key.key_id
}

data "aws_kms_key" "worker_boundary_kms" {
  key_id = aws_kms_key.recovery_kms_key.key_id
}

data "aws_kms_key" "recovery_boundary_kms" {
  key_id = aws_kms_key.recovery_kms_key.key_id
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

# Controller KMS IAM Policy
data "aws_iam_policy_document" "controller_kms_policy" {
  statement {
    effect = "Allow"

    actions = ["kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
    "kms:DescribeKey"]

    resources = [data.aws_kms_key.root_boundary_kms.arn,
                 data.aws_kms_key.recovery_boundary_kms.arn]
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

# Worker EC2 Profile
resource "aws_iam_instance_profile" "worker" {
  name = "worker_profile"
  role = aws_iam_role.worker_role.name
}

# Worker KMS IAM Policy
data "aws_iam_policy_document" "worker_kms_policy" {
  statement {
    effect = "Allow"

    actions = ["kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
    "kms:DescribeKey"]

    resources = [data.aws_kms_key.worker_boundary_kms.arn]
  }
}

resource "aws_iam_policy" "worker_kms_access" {
  name        = "Worker_KMS_access"
  description = "Allows worker instances access to KMS"
  path        = "/"

  policy = data.aws_iam_policy_document.worker_kms_policy.json
}

resource "aws_iam_role" "worker_role" {
  name               = "worker_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_role_policy_attachment" "worker_kms_access" {
  role       = aws_iam_role.worker_role.name
  policy_arn = aws_iam_policy.worker_kms_access.arn
}

data "aws_elb_service_account" "main" {}

# Loadbalancer Log Bucket IAM polic
data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.lb_logs.arn}/*",
    ]

    principals {
      identifiers = [data.aws_elb_service_account.main.arn]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.lb_logs.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.lb_logs.arn]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_lb_to_write_to_s3" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}