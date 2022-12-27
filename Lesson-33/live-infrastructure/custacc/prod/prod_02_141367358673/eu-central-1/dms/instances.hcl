locals {

  user_data_header = <<EOF
#!/bin/bash
exec > >(tee /var/log/rbua-cloud-init.log|logger -t rbua-cloud-init -s 2>/dev/console) 2>&1
set -e  # Stop on any error
set -x  # Print commands that are executed
EOF


  user_data_body = <<EOF
# project=$1                 # example 'dms'
# name=$2                    # example 'canazein'
# device_name = $3           # example '/dev/sdh'

###=========================================
echo "Starting configuring $project"

# Add operation disk
pvcreate $device_name 
vgcreate content $device_name
lvcreate -n $project -l +100%FREE content
mkfs.xfs /dev/content/$project
id=$(blkid | awk '/content-/ {print $2}')
grep -E "^UUID.?* /opt " /etc/fstab && umount /opt && sed -i -e "s/^UUID=.* \/opt .*/$id     \/opt           xfs    defaults,noatime  1   1/" /etc/fstab || echo "$id     /opt           xfs    defaults,noatime  1   1" >> /etc/fstab
mount -a

cat <<\ETF > /usr/local/bin/auto_grow_fs.sh
#!/bin/bash
#=================================================
# Grow FS_xfs
# > run $1 $2             # examples
# > run root /            # grow "/" phisical partition
# > run dms /dev/sdh      # grow "dms":LVM by "/dev/sdh" volume
#=================================================
echo $1 | grep "root" >/dev/null \
  && disk=$(fdisk -l 2>&1    | awk '$0~/^GPT PMBR size mismatch/ || $1~/^Disk$/ {if($1=="GPT"){trigger=1} else if(trigger==1){gsub(":","",$2);print $2; trigger=2}} END {if(trigger!=2){ exit 1 }}') \
  && /usr/bin/lsblk | awk -v part="$2" -v disk="$disk" '{if($6=="disk"){name=$1}; if($7==part && disk!="/dev/"name){exit 1}}' \
  && echo "GPT PMBR size mismatch on: $disk" \
  && sgdisk $disk --backup=/opt/bkp_gpt_$(basename $disk).$(date +%F_%R).dmp \
  && echo "GPT backup created. In: /opt/bkp_gpt_$(basename $disk)*.dmp" \
  && sgdisk $disk -e && partprobe \
  && echo "Fixed!" \
    && /usr/bin/lsblk | awk -v part="$2" '{if($6=="disk"){size=$4}; if($7==part && $4==size){exit 1}}' \
    && echo "Root($2) Partition may be bigger" \
    && sfdisk -d $disk > /opt/bkp_partition_$(basename $disk).$(date +%F_%R).dmp \
    && echo "Update: Partition backup created. In: /opt/bkp_partition_$(basename $disk)*.dmp" \
    && growpart $disk 1 \
    && echo "Update: Partition size changed" \
    && /usr/sbin/xfs_growfs $2 && echo "Update: Xfs upscaled" \
    && echo "Root($2) Partition become bigger!"
# Grow $project-lvm by $device_name=$2
echo $1 | grep "$project" >/dev/null \
  && /usr/bin/lsblk | awk '{if($6=="disk"){size=$4}; if($1~/content-$project/ && $4==size){exit 1}}' \
  && echo "$project: LVM may be bigger" \
  && /usr/sbin/pvresize $2 \
  && echo "Update: PV by $2" \
  && /usr/sbin/lvextend -l +100%FREE /dev/content/$project \
  && echo "Update: LVM extended" \
  && path=$(/usr/bin/lsblk | awk '$1~/content-$project/ {print $7}') \
  && /usr/sbin/xfs_growfs $path && echo "Update: xfs is updated on $path" \
  && echo "$project: LVM become bigger!" 
ETF
sed -i -e "s/\$project/$project/g" /usr/local/bin/auto_grow_fs.sh

cat <<ETF >> /var/spool/cron/root
# Crontab to auto_grow_fs partition "/"
*/10 * * * * bash /usr/local/bin/auto_grow_fs.sh root /
# Crontab to auto_grow_fs "$project" lvm by "$device_name"
*/10 * * * * bash /usr/local/bin/auto_grow_fs.sh $project $device_name
ETF

# Set hostname
host=$(hostname | cut -d'.' -f2-)
hostnamectl set-hostname $name"."$host

# Add project users&group
groupadd -g 204 dba
groupadd -g 206 documaps
groupadd -g 203 dinstall
groupadd -g 207 oracle
groupadd -g 702 dmadmin
groupadd -g 1022 jboss
useradd -u 207 -g 207 -m -s /bin/bash oracle
useradd -u 205 -g 203 -m -s /bin/bash dmadmin
useradd -u 703 -g 203 -m -s /bin/bash dmaps
useradd -u 711 -g 203 -m -s /bin/bash docint
useradd -u 1022 -g 1022 -m -s /bin/bash jboss
usermod -a -G dba docint
usermod -a -G dba,documaps dmaps
usermod -a -G dba oracle
usermod -a -G dba,dinstall dmadmin

# Add previleges
cat <<ETF >> /etc/sudoers.d/$project
%dmadmin        $name = NOPASSWD: /bin/su - dmadmin
%oracle         $name = NOPASSWD: /bin/su - oracle
%dinstall       $name = NOPASSWD: /bin/su - docint
%documaps       $name = NOPASSWD: /bin/su - dmaps,/bin/su - jboss
ETF

# Allow ssh connection from groups: dmadmin, oracle
sed -i -e '/^AllowGroups/ s/$/ dmadmin oracle/' /etc/ssh/sshd_config
service sshd restart

# Add users and grant rights
users="iuad14i7 iuad1at0 iuad0j5k iuad0y3b iuad12x3 iuad0hsj iuad0hf1 iuad1h5b"
start_point=1010
for user in $users;
do  start_point=$((start_point+1)); 
    groupadd -g $start_point $user && adduser -u $start_point -g $start_point -m -s /bin/bash $user;
    ( echo $user | grep "iuad1at0" ) && usermod -a -G dba,oracle $user || usermod -a -G dinstall,documaps,dmadmin $user ;
done

echo "$project product configured successfully "
###=========================================
EOF


  user_data_efs_mount = <<EOF
# mount_point=$1                 # example '10.45.65.31'
# moun_path=$2                     # example '/opt/dms_content'

###=========================================
echo "Starting configuring EFS"

# Mount EFS
mkdir -p $mount_path
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $mount_point:/ $mount_path
echo "$mount_point:/ $mount_path nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
echo "# 10.191.4.124:/opt/dms_content /opt/dms_content nfs4 rw,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.227.47.62,local_lock=none,addr=10.191.4.124" >> /etc/fstab

echo "EFS configured successfully "
###=========================================
EOF
}