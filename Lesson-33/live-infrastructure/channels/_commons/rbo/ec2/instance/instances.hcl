locals {
  user_data_header = <<EOF
#!/bin/bash
exec > >(tee /var/log/rbua-cloud-init.log|logger -t rbua-cloud-init -s 2>/dev/console) 2>&1
set -e  # Stop on any error
set -x  # Print commands that are executed
EOF

  user_data_body = <<EOF
#tier=$1                     # example: 'is'
#service_name=$2             # example: 'ibank'
#conf_path_prefix=$3         # example: '/DBO' or '/opt'
#appdyn_enabled=$4           # 'true' or 'false'

#We have to check has been configuration updated. Using same as PID approach - saving file with meta data
script_workdir="/opt/rbua-cloud-init"
configured_file="$script_workdir/rbua-cloud-init.configured"

mkdir -p $script_workdir
cd $script_workdir

if test -f "$configured_file"; then
    echo "File '$configured_file' exists, which means configuration is already done. Exiting."
    exit
fi

ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | cut -d'.' -f 3,4 | tr '.' '-')
printf -v server_name "%q" $service_name"-"$ip
printf -v node_name "%q" $server_name"-rbo.rbua"

# Configuring app dynamics
java_agent_conf="$conf_path_prefix/appdynamics/javaagent/ver/conf/controller-info.xml"
machine_agent_conf="$conf_path_prefix/appdynamics/machineagent/conf/controller-info.xml"
machine_agent_analytics_conf="$conf_path_prefix/appdynamics/machineagent/monitors/analytics-agent/conf/analytics-agent.properties"

node_name_tag="<node-name>$server_name<\/node-name>"
unique_host_id="<unique-host-id>$node_name<\/unique-host-id>"
tier_name="<tier-name>$tier<\/tier-name>"

echo "Starting configuring APP Dynamics"

for input in $java_agent_conf $machine_agent_conf $machine_agent_analytics_conf;
 do
    while IFS= read -r app_dynamics_line
        do
          escaped_app_dynamics_line="$(echo $app_dynamics_line | sed 's=/=\\/=g' )"

          case $app_dynamics_line in
          *"<node-name>"*)

            sed -i -e "s/$escaped_app_dynamics_line/$node_name_tag/" $input

            ;;
          esac
          case $app_dynamics_line in
          *"<unique-host-id>"* )

            sed -i -e "s/$escaped_app_dynamics_line/$unique_host_id/" $input
            ;;
          esac
          case $app_dynamics_line in
          "appdynamics.agent.uniqueHostId"*)
            uniq_host_property="appdynamics.agent.uniqueHostId="$server_name
            sed -i -e "s/$escaped_app_dynamics_line/$uniq_host_property/" $input
            ;;
          esac
          case $app_dynamics_line in
          "ad.agent.name"*)
            agent_name="ad.agent.name="$server_name
            sed -i -e "s/$escaped_app_dynamics_line/$agent_name/" $input
            ;;
          esac
          case $app_dynamics_line in
          *"<tier-name>"*)
            sed -i -e "s/$escaped_app_dynamics_line/$tier_name/" $input
            ;;
          esac

        done < "$input"
done

echo "AppDynamics configured successfully "

echo "Starting configure Zabbix"
#Configuring Zabbix agent
zabbix_conf="/etc/zabbix/zabbix_agentd.conf"
server_active="ServerActive=zabbix.infr.kv.aval"
server="Server=zabbix.infr.kv.aval,10.225.102.0\/24,10.225.103.0\/24"

while IFS= read -r zabbix_line
 do
   escaped_zabbix_line="$(echo $zabbix_line | sed 's=/=\\/=g' )"

   case $zabbix_line in
   "ServerActive="*)
      sed -i -e "s/$escaped_zabbix_line/$server_active/" $zabbix_conf
    ;;
   esac

   case $zabbix_line in
   "Server="*)
      sed -i -e "s/$escaped_zabbix_line/$server/" $zabbix_conf
     ;;
   esac

   case $zabbix_line in
   *"ListenIP=0.0.0.0"*)
      listen_ip="#"$zabbix_line
      sed -i -e "s/$escaped_zabbix_line/$listen_ip/" $zabbix_conf
     ;;
   esac
done < "$zabbix_conf"

hostname $node_name
echo $node_name > /etc/hostname

echo "Zabbix configured successfully"

echo $node_name > $configured_file
EOF
}
