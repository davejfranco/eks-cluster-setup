data "aws_iam_policy_document" "oidc_assume_role_external_dns" {
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
        "system:serviceaccount:external-dns:external-dns"
      ]
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
    }
  }

}

data "aws_iam_policy_document" "external_dns_access" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns_access" {
  count  = var.external_dns_enabled ? 1 : 0
  name   = "${local.cluster.name}-external-dns-access"
  policy = data.aws_iam_policy_document.external_dns_access.json
}

resource "aws_iam_role" "external_dns_access" {
  count              = var.external_dns_enabled ? 1 : 0
  name               = "ExternalDNSRole"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns_access" {
  count      = var.external_dns_enabled ? 1 : 0
  role       = aws_iam_role.external_dns_access[0].name
  policy_arn = aws_iam_policy.external_dns_access[0].arn
}
