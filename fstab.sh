#!/usr/bin/bash
#set -o nounset
#set -o errexit
#set -o xtrace

# Input yaml

# Output fstab file on stdout

# fstab file format (man fstab)
# 1       2       3          4         5       6
# fs_spec fs_file fs_vfstype fs_mntops fs_freq fs_passno

# sample input
#---
#fstab:
#  /dev/sda1:
#    mount: /boot
#    type: xfs
#  /dev/sda2:
#    mount: /
#    type: ext4
#  /deb/sdb1:
#    mount: /var/lib/postgresql
#    type: ext4
#    root-reserve: 10%
#  192.168.4..5:
#    mount: /home
#    export: /var/nfs/home
#    type: nfs
#    options:
#      - noexec
#      - nosuid


fstab_entries=$(yq e '.fstab|keys' fstab.yml -o csv | sed 's/,/ /g' | sed 's/\n//g')

for entry in $fstab_entries
do
  # NFS case needs to fix the fs_spec field and concatenate export value
  yq_path=".fstab[\"$entry\"][\"type\"]"
  fs_vfstype=$(yq eval "$yq_path"  fstab.yml)

  case $fs_vfstype in
  nfs)
    yq_path=".fstab[\"$entry\"][\"export\"]"
    export=$(yq eval "$yq_path"  fstab.yml)
    fs_spec="$entry:$export"
    ;;

  *)
    fs_spec="$entry"
    ;;
  esac

  # Mount point extraction
  yq_path=".fstab[\"$entry\"][\"mount\"]"
  fs_file=$(yq eval "$yq_path"  fstab.yml)

  yq_path=".fstab[\"$entry\"][\"options\"] // [\"defaults\"] "
  fs_mntops=$(yq eval "$yq_path" -o csv fstab.yml)

  # For now fs_freq and fs_passno hardwired to 0 0
  fs_freq=0 
  fs_passno=0

  fstab_line="$fs_spec $fs_file $fs_vfstype $fs_mntops $fs_freq $fs_passno"
  echo $fstab_line
done

