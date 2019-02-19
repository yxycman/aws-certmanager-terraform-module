{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLogGroups",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "cloudwatch:PutMetricData",
                "acm:ImportCertificate",
                "acm:DescribeCertificate",
                "acm:ListCertificates"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "route53:GetChange",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${r53-zone-id}",
                "arn:aws:route53:::change/*"
            ]
        }
    ]
}