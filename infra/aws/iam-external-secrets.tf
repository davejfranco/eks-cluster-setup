data "aws_iam_policy_document" "oidc_assume_role_external_secrets" {
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
        "system:serviceaccount:external-secrets:external-secrets"
      ]
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
    }
  }
}

data "aws_iam_policy_document" "external_secrets_access" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:*"
    ]
  }
}

resource "aws_iam_policy" "external-secrets" {
  count  = var.external_secrets_enabled ? 1 : 0
  name   = "${local.cluster.name}-external-secrets-access"
  policy = data.aws_iam_policy_document.external_secrets_access.json
}

resource "aws_iam_role" "external-secrets" {
  count              = var.external_secrets_enabled ? 1 : 0
  name               = "ExternalSecretsRole"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_external_secrets.json
}
