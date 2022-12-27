locals {
  user_data_header = <<EOF
#!/bin/bash
exec > >(tee /var/log/rbua-cloud-init.log|logger -t rbua-cloud-init -s 2>/dev/console) 2>&1
set -e  # Stop on any error
set -x  # Print commands that are executed
EOF

  user_data_body = <<EOF

ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | cut -d'.' -f 3,4 | sed 's/\./-/g')
node_name=$service_name"-"$ip"-web-rbua"

[[ $(hostname) != "$node_name" ]] && hostnamectl set-hostname $node_name
EOF
}