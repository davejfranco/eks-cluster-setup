data "aws_iam_policy_document" "oidc_assume_role_cert_manager" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
      ]
      type = "Federated"
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    condition {
      test = "StringEquals"
      values = [
        "system:serviceaccount:cert-manager:cert-manager"
      ]
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
    }
  }

}

data "aws_iam_policy_document" "cert_manager_access" {
  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "cert_manager_access" {
  count  = var.cert_manager_enabled ? 1 : 0
  name   = "${local.cluster.name}-cert-manager-access"
  policy = data.aws_iam_policy_document.cert_manager_access.json
}


resource "aws_iam_role" "cert_manager_access" {
  count              = var.cert_manager_enabled ? 1 : 0
  name               = "CertManagerRole"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_cert_manager.json
}

resource "aws_iam_role_policy_attachment" "cert_manager_access" {
  count      = var.cert_manager_enabled ? 1 : 0
  role       = aws_iam_role.cert_manager_access[0].name
  policy_arn = aws_iam_policy.cert_manager_access[0].arn
}

