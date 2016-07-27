#! /bin/bash

URL=http://releases.ubuntu.com/16.04/ubuntu-16.04-server-amd64.iso
ORIG_ISO="ubuntu-16.04-server-amd64.iso"
OUT_ISO="$(basename "$ISO" .iso)-autoinstall.iso"
BASE="$(pwd)"
WORKDIR="${BASE}/workdir"
TMP="${BASE}/iso_mount"
OUT="${BASE}/output"

rm -rf "$OUT"

mkdir -p "$OUT"

ssh-keygen -t rsa -N '' -C 'test-key for autoinstall.iso' -f "${OUT}/id_rsa"

wget -N "$URL"

rm -r "$TMP" || true
mkdir -p "$TMP"
echo "Sudo to root, required for mounting iso and changing data"

sudo mount -o loop "$ORIG_ISO" "$TMP"
sudo mkdir -p "$WORKDIR"
sudo cp -rT "$TMP" "$WORKDIR"
sudo umount "$TMP"
rm -r "$TMP"
cd $WORKDIR
# Select english for installation lang
sudo chmod 777 isolinux # +rwx
sudo echo en > isolinux/lang
sudo sed -i -e 's#ubuntu-server.seed#ubuntu-server.seed ks=cdrom:/ks.cfg preseed/file=/cdrom/ks.preseed #' isolinux/txt.cfg
sudo sed -i -e 's/timeout 0/timeout 10/' isolinux/isolinux.cfg
sudo chmod 555 isolinux # +rx-w
cd ..
sudo cp ks.cfg ks.preseed $OUT/id_rsa.pub "$WORKDIR"
sudo mkisofs -D -r -V "ATTENDLESS_UBUNTU" -cache-inodes -J -l \
-b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
-boot-load-size 4 -boot-info-table -o ${OUT}/autoinstall.iso "$WORKDIR"
sudo rm -rf $WORKDIR

