#!/usr/bin/env python3.6

'''
Script for updating ACM certificates with LetsEncrypt
'''

import boto3
import certbot.main
import datetime
import os
import json
import subprocess
from botocore.vendored import requests
import logging

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
SLACK_CHANNEL = os.environ['slack_channel']
SLACK_TOKEN = os.environ['slack_token']
LETSENCRYPT_DOMAINS = os.environ['certificate_domains']
FIRST_LETSENCRYPT_DOMAIN = LETSENCRYPT_DOMAINS.split(',')[0]
LETSENCRYPT_EMAIL = os.environ['certificate_email']
CLIENT = boto3.client('acm')


def read_file(path):
    with open(path, 'r') as file:
        contents = file.read()
    return contents


def send_slack(message):
    '''Send slack message function'''

    LOGGER.info(f'Sending {message}')

    message2send = {
        "username": 'Lambda certificate privisioner',
        "channel": SLACK_CHANNEL,
        "token": SLACK_TOKEN,
        "attachments": json.dumps([message])

    }
    requests.post('https://slack.com/api/chat.postMessage', data=message2send)


def upload_cert_to_acm(cert, provision_arn):
    if provision_arn == 'NewARN':
        acm_response = CLIENT.import_certificate(
            Certificate=cert['certificate'],
            PrivateKey=cert['private_key'],
            CertificateChain=cert['certificate_chain']
        )
    else:
        acm_response = CLIENT.import_certificate(
            CertificateArn=provision_arn,
            Certificate=cert['certificate'],
            PrivateKey=cert['private_key'],
            CertificateChain=cert['certificate_chain']
        )

    return acm_response['CertificateArn']


def get_letsencrypt_certificate():

    certbot.main.main([
        'certonly',                             # Obtain a cert but don't install it
        '-n',                                   # Run in non-interactive mode
        '-q',                                   # Be more quiet
        '--agree-tos',                          # Agree to the terms of service,
        '--email', LETSENCRYPT_EMAIL,           # Email
        '--dns-route53',                        # Use dns challenge with route53
        '-d', LETSENCRYPT_DOMAINS,              # LETSENCRYPT_DOMAINS to provision certs for
        # '--staging',                          # In case of testing, un-comment this line
        # Override directory paths so script doesn't have to be run as root
        '--config-dir', '/tmp/config-dir/',
        '--work-dir', '/tmp/work-dir/',
        '--logs-dir', '/tmp/logs-dir/',
    ])

    path = '/tmp/config-dir/live/' + FIRST_LETSENCRYPT_DOMAIN + '/'

    return {
        'certificate': read_file(path + 'cert.pem'),
        'private_key': read_file(path + 'privkey.pem'),
        'certificate_chain': read_file(path + 'chain.pem')
    }


def check_expire(certificate):
    now = datetime.datetime.now(datetime.timezone.utc)
    not_after = certificate['Certificate']['NotAfter']

    if (not_after - now).days <= 30:
        return True
    else:
        return False


def handler(event, context):
    provision_arn = False
    certificate_dict = {}

    try:
        for cert_record in CLIENT.list_certificates()['CertificateSummaryList']:
            certificate_dict[cert_record['DomainName']] = cert_record['CertificateArn']

        if FIRST_LETSENCRYPT_DOMAIN in certificate_dict:
            certificate_arn = certificate_dict[FIRST_LETSENCRYPT_DOMAIN]
            certificate = CLIENT.describe_certificate(CertificateArn=certificate_arn)
            expiration = check_expire(certificate)
            if expiration:
                provision_arn = certificate_arn

        else:
            LOGGER.info(f'No primary DomainName:{FIRST_LETSENCRYPT_DOMAIN} certificate exist. Will provision new one')
            provision_arn = 'NewARN'

        if provision_arn:
            letsencrypt_certificate = get_letsencrypt_certificate()
            uploaded_certificate_arn = upload_cert_to_acm(letsencrypt_certificate, provision_arn)
            send_slack({
                "color": "good",
                "title": LETSENCRYPT_DOMAINS,
                "text": "Certificate uploaded successfuly:\n" + uploaded_certificate_arn
            })

        else:
            LOGGER.info(f'No certificates for DomainName:{LETSENCRYPT_DOMAINS} needs provisioning or update')

    except Exception as exception:
        LOGGER.info(exception)
        send_slack(
            {
                "color": "warning",
                "title": LETSENCRYPT_DOMAINS,
                "text": str(exception)
            })
