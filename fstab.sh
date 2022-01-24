#!/usr/bin/bash

# Simple /etc/fstab file generator from yaml formated data (fstab.yml).

# Dependencies:
# yq binary has to be present in your system under your PATH definition
# https://github.com/mikefarah/yq

fstab_entries=$(yq e '.fstab|keys' fstab.yml -o csv | sed 's/,/ /g' | sed 's/\n//g')

for entry in $fstab_entries
do
  # NFS case needs to fix the fs_spec field and concatenate export value
  yq_path=".fstab[\"$entry\"][\"type\"]"
  fs_vfstype=$(yq eval "$yq_path" fstab.yml)

  # fs_spec field definition per fs type
  case $fs_vfstype in
  nfs)
    yq_path=".fstab[\"$entry\"][\"export\"]"
    export=$(yq eval "$yq_path" fstab.yml)
    fs_spec="$entry:$export"
    ;;

  *)
    fs_spec="$entry"
    ;;
  esac

  # Mount point extraction
  yq_path=".fstab[\"$entry\"][\"mount\"]"
  fs_file=$(yq eval "$yq_path" fstab.yml)

  # Mount options extraction
  yq_path=".fstab[\"$entry\"][\"options\"] // [\"defaults\"] "
  fs_mntops=$(yq eval "$yq_path" -o csv fstab.yml)

  # For now fs_freq and fs_passno hardwired to 0 0
  fs_freq=0 
  fs_passno=0

  fstab_line="$fs_spec $fs_file $fs_vfstype $fs_mntops $fs_freq $fs_passno"
  echo $fstab_line
done

