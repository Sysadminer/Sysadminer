# aws-s3
# List buckets
aws s3api list-buckets
aws s3api list-buckets --query "Buckets[].Name"
#------------------------------------------------------------------------------
## Powershell
#------------------------------------------------------------------------------
# List buckets and lifecycle configuration
#------------------------------------------------------------------------------
# Define the AWS region
$region = "af-south-1"

# Get the list of bucket names
$bucketNames = aws s3api list-buckets --query "Buckets[].Name" --output json | ConvertFrom-Json

# Iterate over each bucket and display its lifecycle policy
foreach ($bucketName in $bucketNames) {
    Write-Output "Bucket: $($bucketName)"
    aws s3api get-bucket-lifecycle-configuration --bucket $bucketName --region af-south-1
    Write-Output "---------------------------------------"
}

#------------------------------------------------------------------------------
# Get lifecycle policy for one bucket
#------------------------------------------------------------------------------
$bucketName="logicmonitorawsbillingbucket"
aws s3api get-bucket-lifecycle-configuration --bucket $bucketName

#------------------------------------------------------------------------------
# Get lifecycle policy for all buckets
#------------------------------------------------------------------------------
# Get the list of bucket names
$bucketNamesResponse = aws s3api list-buckets --query "Buckets[].Name" --output json
$bucketNames = $bucketNamesResponse | ConvertFrom-Json

# Iterate over each bucket

foreach ($bucketName in $bucketNames) {
    Write-Output "Bucket: $($bucketName)"

    # Retrieve and display the lifecycle configuration for the current bucket
    try {
        aws s3api get-bucket-lifecycle-configuration --bucket $bucketName --region af-south-1
    }
    catch {
        Write-Output "Error occurred: $_"
    }

    Write-Output "---------------------------------------"
}

#------------------------------------------------------------------------------
# Apply lifecycle policy to all buckets
#------------------------------------------------------------------------------

# Define the path to the lifecycle policy file
$lifecyclePolicyPath = "C:\tempdata\git\aws-s3\aws-s3\aws-s3-lifecycle-tag-based-1year.json"

# Get the list of bucket names
$bucketNamesResponse = aws s3api list-buckets --query "Buckets[].Name" --output json

$bucketNames = $bucketNamesResponse | ConvertFrom-Json

# Check if there are any buckets
if ($null -eq $bucketNames) {
    Write-Output "No buckets found."
    exit
}

# Iterate over each bucket
foreach ($bucketName in $bucketNames) {
    Write-Output "Bucket: $($bucketName)"

    # Apply the lifecycle policy to the current bucket
    try {
        aws s3api put-bucket-lifecycle-configuration --bucket $bucketName --lifecycle-configuration file://$lifecyclePolicyPath

        # Retrieve and display the updated lifecycle configuration for the current bucket
        $updatedLifecycle = aws s3api get-bucket-lifecycle-configuration --bucket $bucketName
        Write-Output "Updated Lifecycle Configuration:"
        Write-Output $updatedLifecycle
    }
    catch {
        Write-Output "Error occurred: $_"
    }

    Write-Output "---------------------------------------"
}

#------------------------------------------------------------------------------
# Apply to all buckets based on tags
#------------------------------------------------------------------------------

# Apply to all buckets
# Define the tag key and value
$tagKey = "retention"
$tagValue = "1-year"

#------------------------------------------------------------------------------
# Define the path to the lifecycle policy file and apply it
$policyPath = "C:\tempdata\git\aws-s3\aws-s3\aws-s3-lifecycle-tag-based-1-year.json"
#------------------------------------------------------------------------------

# Get the list of bucket ARNs with the specified tag
$bucketARNsWithRetentionTag = aws resourcegroupstaggingapi get-resources --tag-filters "Key=$tagKey,Values=$tagValue" --resource-type-filters s3 --query "ResourceTagMappingList[].ResourceARN" --output json | ConvertFrom-Json

# Iterate over each bucket with the specified tag
foreach ($bucketARN in $bucketARNsWithRetentionTag) {
    # Extract the bucket name from the ARN
    $bucketName = ($bucketARN -split ":::")[-1]

    Write-Output "Bucket: $bucketName"

    # Apply the lifecycle policy to the current bucket
    aws s3api put-bucket-lifecycle-configuration --bucket $bucketName --lifecycle-configuration file://$policyPath

    Write-Output "Lifecycle policy applied to bucket: $bucketName"
    Write-Output "---------------------------------------"
}
#------------------------------------------------------------------------------
# Apply 1-year on all buckets
# Define the lifecycle policy path
$lifecyclePolicyPath = "C:\tempdata\git\aws-s3\aws-s3\aws-s3-lifecycle-tag-based-1year.json"

# Get the list of bucket names
$bucketNamesResponse = aws s3api list-buckets --query "Buckets[].Name" --output json
$bucketNames = $bucketNamesResponse | ConvertFrom-Json

# Check if there are any buckets
if ($null -eq $bucketNames) {
    Write-Output "No buckets found."
    exit
}

# Loop through each bucket and apply the lifecycle policy
foreach ($bucket in $bucketNames.Buckets) {
    Write-Output "Applying one-year lifecycle policy to bucket: $($bucket.Name)"
    $result = aws s3api put-bucket-lifecycle-configuration --bucket $bucket.Name --lifecycle-configuration file://$lifecyclePolicyPath
    
    # Check for errors
    if ($null -ne $result) {
        Write-Output "Error applying lifecycle policy to bucket: $($bucket.Name)"
        Write-Output $result
    } else {
        Write-Output "Lifecycle policy applied to bucket: $($bucket.Name)"
    }
    Write-Output "---------------------------------------"
}

#------------------------------------------------------------------------------

# Apply 1-month lifecycle policy on a bucket
aws s3api put-bucket-lifecycle-configuration `
    --bucket cf-templates-dq1w4sluki6i-af-south-1 `
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-1month.json

#------------------------------------------------------------------------------

# View resources with 1-year
# Retrieve all bucket names
$bucketNames = aws s3api list-buckets --query "Buckets[].Name" --output json | ConvertFrom-Json
$policyPath = .\aws-s3-lifecycle-tag-based-1year.json

# Iterate over each bucket and apply based on buckets with 1-year

foreach ($bucketName in $bucketNames) {
    Write-Output "Bucket: $($bucketName)"

    # Get tags for the current bucket
    $tags = aws s3api get-bucket-tagging --bucket $bucketName

    # Check if tags exist for the bucket
    if ($tags -and $tags.TagSet) {
        # Check if the 'retention' tag exists and has the value '6-months'
        $retentionTag = $tags.TagSet | Where-Object { $_.Key -eq 'retention' -and $_.Value -eq '6-months' }
        if ($retentionTag) {
            Write-Output "Applying lifecycle policy to bucket: $bucketName"

            # Apply the lifecycle policy to the current bucket
            $policyPath = "aws-s3-lifecycle-tag-based-6months.json"  # Replace with the appropriate policy file path
            aws s3api put-bucket-lifecycle-configuration --bucket $bucketName --lifecycle-configuration file://$policyPath
        } else {
            Write-Output "Bucket does not have the required tag 'retention:6-months'."
        }
    } else {
        Write-Output "No tags found for the bucket."
    }

    Write-Output "---------------------------------------"
}
#------------------------------------------------------------------------------

# Apply based on 1-month tag

$bucket = bucket_name

aws s3api put-bucket-lifecycle-configuration `
    --bucket YOUR_BUCKET_NAME `
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-6months.json

aws s3api put-bucket-lifecycle-configuration `
    --bucket YOUR_BUCKET_NAME `
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-1year.json

aws s3api put-bucket-lifecycle-configuration `
    --bucket YOUR_BUCKET_NAME `
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-forever.json

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Bash #
#------------------------------------------------------------------------------

# List buckets
aws s3api list-buckets

# View lifecycle policies on all buckets
aws s3api list-buckets --query "Buckets[].Name" --output text | 
    while read -r bucket; do 
        echo "Bucket: $bucket"; 
        aws s3api get-bucket-lifecycle-configuration --bucket "$bucket"; 
        echo "---------------------------------------"; 
    done

#------------------------------------------------------------------------------

# Lifecycle policies
aws s3api put-bucket-lifecycle-configuration \
    --bucket cf-templates-dq1w4sluki6i-af-south-1 \
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-1month.json

#------------------------------------------------------------------------------

aws resourcegroupstaggingapi get-resources --tag-filters Key=retention,Values=1-month --resource-type-filters s3 | jq -r '.ResourceTagMappingList[].ResourceARN' | while read bucket; do
    aws s3api put-bucket-lifecycle-configuration --bucket "$bucket" --lifecycle-configuration file://aws-s3-lifecycle-tag-based-1month.json
done

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

#!/bin/bash

# Define the lifecycle policy path
lifecyclePolicyPath="/path/to/aws-s3-lifecycle-tag-based-1year.json"

# Get the list of bucket names
bucketNames=$(aws s3api list-buckets --query "Buckets[].Name" --output json)

# Loop through each bucket and apply the lifecycle policy
for bucket in $(echo "$bucketNames" | jq -r '.[]'); do
    echo "Applying one-year lifecycle policy to bucket: $bucket"

    # Get the current lifecycle policy configuration
    currentPolicy=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket --output json)

    # Apply the new lifecycle policy configuration
    aws s3api put-bucket-lifecycle-configuration --bucket $bucket --lifecycle-configuration file://$lifecyclePolicyPath

    # Get the updated lifecycle policy configuration
    updatedPolicy=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket --output json)

    # Check if the policy was updated
    if [ "$currentPolicy" != "$updatedPolicy" ]; then
        echo "New lifecycle policy applied:"
        echo "$updatedPolicy"
    else
        echo "No updates required. Lifecycle policy already applied."
    fi

    echo "---------------------------------------"
done
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

# Apply on one bucket at a time
# Define the bucket name
bucketName="YOUR_BUCKET_NAME"

# Define the lifecycle policy path
lifecyclePolicyPath="/path/to/aws-s3-lifecycle-tag-based-1year.json"

# Apply the lifecycle policy configuration to the bucket
aws s3api put-bucket-lifecycle-configuration \
    --bucket "$bucketName" \
    --lifecycle-configuration file://"$lifecyclePolicyPath"

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

aws s3api put-bucket-lifecycle-configuration \
    --bucket YOUR_BUCKET_NAME \
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-6months.json
#------------------------------------------------------------------------------

aws s3api put-bucket-lifecycle-configuration \
    --bucket YOUR_BUCKET_NAME \
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-1year.json
#------------------------------------------------------------------------------

aws s3api put-bucket-lifecycle-configuration \
    --bucket YOUR_BUCKET_NAME \
    --lifecycle-configuration file://aws-s3-lifecycle-tag-based-forever.json
#------------------------------------------------------------------------------
