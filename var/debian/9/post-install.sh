echo -e "[Match]\nName=ens3\n[Network]\nDHCP=yes" > /etc/systemd/network/ens3.network
cat /etc/systemd/network/ens3.network
ln -vs /lib/systemd/system/systemd-networkd.service /etc/systemd/system/multi-user.target.wants/systemd-networkd.service
exit 0
