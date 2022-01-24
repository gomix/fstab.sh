# fstab.sh

Simple /etc/fstab generator from yaml formated file.

Sample Input

fstab.yml

    ---
    fstab:
      /dev/sda1:
	mount: /boot
	type: xfs
      /dev/sda2:
	mount: /
	type: ext4
      /deb/sdb1:
	mount: /var/lib/postgresql
	type: ext4
	root-reserve: 10%
      192.168.4.5:
	mount: /home
	export: /var/nfs/home
	type: nfs
	options:
	  - noexec
	  - nosuid

%> ./fstab.sh                                                                                             
/dev/sda1 /boot xfs defaults 0 0                                                                          
/dev/sda2 / ext4 defaults 0 0                                                                             
/deb/sdb1 /var/lib/postgresql ext4 defaults 0 0                                                           
192.168.4.5:/var/nfs/home /home nfs noexec,nosuid 0 0
