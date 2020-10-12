resource "aws_iam_policy" "dns01" {
  name        = "cert-manager-writh-dns"
  path        = "/"
  description = "Allow cert-manager to perform DNS challenge"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "cert_manager_attach" {
  user       = "cert-manager"
  policy_arn = aws_iam_policy.dns01.arn
}

resource "aws_iam_user" "cert_manager_user" {
  name = "cert-manager"
  path = "/"
  //   tags =
  //     {
  //       name = "certificate manager user"
  //     }
}

resource "aws_iam_access_key" "cert_manager_user" {
  user = aws_iam_user.cert_manager_user.id
}

resource "aws_iam_group" "cert_manager_group" {
  name = "cert-manager-group"
}

resource "aws_iam_user_group_membership" "cert_manager_group_membership" {
  user   = aws_iam_user.cert_manager_user.name
  groups = [
    aws_iam_group.cert_manager_group.name]
}

output "access_key" {
  value = aws_iam_access_key.cert_manager_user
}