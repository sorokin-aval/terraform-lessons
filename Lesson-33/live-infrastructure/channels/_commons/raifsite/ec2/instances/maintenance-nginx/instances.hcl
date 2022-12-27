locals {
  user_data_header = <<EOF
#!/bin/bash
EOF

  user_data_body = <<EOF
## Get maintenance page from S3. If the page doesn't exist in the bucket, the default page will be used

/usr/local/bin/aws s3 ls s3://exchange-336089599776/maintenance_page/index.html && /usr/local/bin/aws s3 cp s3://exchange-336089599776/maintenance_page/index.html /usr/share/nginx/html/index.html

EOF
}