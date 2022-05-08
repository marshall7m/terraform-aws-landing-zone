# Terraform AWS Custom Landing Zone

## Modules

`account-config`:
    
    - Applies account-level AWS Config custom or managed rules
    - Creates AWS S3 bucket with KMS encryption to store Config logs

`org-config`:
    
    - Applies organization-level AWS Config custom or managed rules and/or conformance packs
    - Creates AWS Lambda function to host each custom rule
    - Creates AWS S3 bucket with KMS encryption to store AWS Config logs

`accounts`:

    - Creates AWS organization within calling AWS account
    - Provisions member accounts with a role that a root organization entity can assume for Administrative access to the account
    - Apply organization-level or account-level policies to member accounts

`cloudtrail`:

    - Apply organization-level or account-level CloudTrail services
    - Attaches an IAM role to the CloudTrail service with the necessary permissions
    - Creates AWS S3 bucket with KMS encryption to store CloudTrail logs
    - Allows the user to explicitly define a separate AWS account provider to store the CloudTrail logs. See for an example: `tests/cloudtrail`

`guardduty`:

    - Apply organization-level or account-level Guardduty service
    - Creates AWS S3 bucket with KMS encryption to store Guardduty findings


`base`:

    - Configures all of the organization-level modules mentioned above into one easily definable module
    - Applies default managed AWS Config rules: (all of which should be covered by this module)
        - CLOUD_TRAIL_ENABLED
        - GUARDDUTY_ENABLED_CENTRALIZED
        - CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED
        - ACCOUNT_PART_OF_ORGANIZATIONS
    - Provisions AWS Config and AWS GuardDuty within the AWS account that is labeled as the `is_cfg` account
    - Provisions separate AWS S3 buckets to store AWS Guardduty, Config, and CloudTrail logs within the AWS account that is labeled as the `is_logs` account

