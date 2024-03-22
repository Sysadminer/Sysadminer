# Get list of all buckets
$buckets = aws s3api list-buckets --query 'Buckets[*].Name' --output text

# Loop through each bucket
foreach ($bucket in $buckets) {
    # Exclude certain buckets by name
    if ($bucket -ne "excluded-bucket1" -and $bucket -ne "excluded-bucket2") {
        # Apply versioning
        aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled

        # Apply lifecycle policy
        aws s3api put-bucket-lifecycle-configuration --bucket $bucket --lifecycle-configuration file://lifecycle.json
    }
    else {
        Write-Host "Skipping bucket: $bucket"
    }
}

#------------------------
# Bucket acl policy
#------------------------

# Define variables
$bucketName = "your-bucket-name"
$policyJson = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$bucketName/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "192.168.1.0/24"  # Change this IP address range to match your requirements
        }
      }
    }
  ]
}
"@

# Convert the policy JSON to a single line and escape special characters
$policyJson = $policyJson.Replace("`n", "").Replace("`r", "") -replace '(")', '\"'

# Apply the policy to the S3 bucket
aws s3api put-bucket-policy --bucket $bucketName --policy $policyJson

#------------------------
# Bucket acl policy 2
#------------------------

# Policy 1: Allow public read access to objects in the bucket
$policy1Json = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$bucketName/*"
    }
  ]
}
"@

# Policy 2: Restrict access to specific IAM users or roles
$policy2Json = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotPrincipal": {
        "AWS": [
          "arn:aws:iam::111122223333:user/username1",
          "arn:aws:iam::111122223333:role/role1"
        ]
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$bucketName",
        "arn:aws:s3:::$bucketName/*"
      ]
    }
  ]
}
"@

# Convert the policies JSON to single-line strings and escape special characters
$policy1Json = $policy1Json.Replace("`n", "").Replace("`r", "") -replace '(")', '\"'
$policy2Json = $policy2Json.Replace("`n", "").Replace("`r", "") -replace '(")', '\"'

# Apply Policy 1 to the S3 bucket
aws s3api put-bucket-policy --bucket $bucketName --policy $policy1Json

# Apply Policy 2 to the S3 bucket
aws s3api put-bucket-policy --bucket $bucketName --policy $policy2Json

#------------------------
# 
#------------------------

# Define variables
$bucketName = "your-bucket-name"

# Policy JSON for enforcing encryption, versioning, and automatic tiering
$policyJson = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$bucketName",
        "arn:aws:s3:::$bucketName/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
	
#------------------------
# 
#------------------------	

# Define variables
$bucketName = "your-bucket-name"

# Policy JSON for enforcing encryption with AES-256
$policyJsonAES = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$bucketName",
        "arn:aws:s3:::$bucketName/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
"@

# Policy JSON for enforcing encryption with AWS KMS
$policyJsonKMS = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$bucketName",
        "arn:aws:s3:::$bucketName/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
"@

# Convert the policy JSON to a single-line string and escape special characters
$policyJsonAES = $policyJsonAES.Replace("`n", "").Replace("`r", "") -replace '(")', '\"'
$policyJsonKMS = $policyJsonKMS.Replace("`n", "").Replace("`r", "") -replace '(")', '\"'

# Apply the policy enforcing AES-256 encryption to the S3 bucket
aws s3api put-bucket-policy --bucket $bucketName --policy $policyJsonAES

# Apply the policy enforcing AWS KMS encryption to the S3 bucket
aws s3api put-bucket-policy --bucket $bucketName --policy $policyJsonKMS

#------------------------
# multiple buckets
#------------------------	

# Define an array of bucket names
$bucketNames = @("bucket1", "bucket2", "bucket3")  # Add more bucket names as needed

# Policy JSON for enforcing encryption with AES-256
$policyJsonAES = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::$bucketName",
        "arn:aws:s3:::$bucketName/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
"@

# Convert the policy JSON to a single-line string and escape special characters
$policyJsonAES = $policyJsonAES.Replace("`n", "").Replace("`r", "") -replace '(")', '\"'

# Apply the policy to each bucket
foreach ($bucketName in $bucketNames) {
    # Apply the policy enforcing AES-256 encryption to the S3 bucket
    aws s3api put-bucket-policy --bucket $bucketName --policy $policyJsonAES
}

#------------------------
# Bash
#------------------------


#!/bin/bash

# Get list of all buckets
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket
for bucket in $buckets; do
    # Exclude certain buckets by name
    if [[ "$bucket" != "excluded-bucket1" && "$bucket" != "excluded-bucket2" ]]; then
        # Apply versioning
        aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled

        # Apply lifecycle policy
        aws s3api put-bucket-lifecycle-configuration --bucket "$bucket" --lifecycle-configuration file://lifecycle.json
    else
        echo "Skipping bucket: $bucket"
    fi
done


# Manually
aws s3api put-bucket-lifecycle-configuration --bucket your-bucket-name --lifecycle-configuration file://lifecycle.json

{
    "Rules": [
        {
            "ID": "MoveToGlacierRule",
            "Filter": {
                "Prefix": ""
            },
            "Status": "Enabled",
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "GLACIER"
                }
            ]
        }
    ]
}

