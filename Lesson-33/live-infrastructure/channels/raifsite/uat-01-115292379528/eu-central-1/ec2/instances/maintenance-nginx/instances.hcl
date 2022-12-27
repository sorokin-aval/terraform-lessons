locals {
  user_data_header = <<EOF
#!/bin/bash
exec > >(tee /var/log/rbua-cloud-init.log|logger -t rbua-cloud-init -s 2>/dev/console) 2>&1
set -e  # Stop on any error
set -x  # Print commands that are executed
EOF

  user_data_body = <<EOF
## Get maintenance page from S3. If the page doesn't exist in the bucket, the default page will be used

/usr/local/bin/aws s3 ls s3://exchange-115292379528/maintenance_page/index.html && /usr/local/bin/aws s3 cp s3://exchange-115292379528/maintenance_page/index.html /usr/share/nginx/html/index.html

EOF
}