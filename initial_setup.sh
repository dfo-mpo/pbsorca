sudo apt update && sudo apt install git wget ffmpeg pulseaudio

cd

# Get GO
wget https://dl.google.com/go/go1.14.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.14.linux-armv6l.tar.gz
rm go1.14.linux-armv6l.tar.gz

# Add GO to path
echo "export PATH=\$PATH:/usr/local/go/bin:~/go/bin" | tee -a ~/.bashrc
source ~/.bashrc

# Get azcopy and install to ~/go/bin/azure-storage-azcopy
wget https://github.com/Azure/azure-storage-azcopy/archive/10.3.4.tar.gz
tar zxvf 10.3.4.tar.gz
cd azure-storage-azcopy-10.3.4/
go install
cd
rm 10.3.4.tar.gz

# Backup directory in case ram drive mount fails
sudo mkdir /mnt/rd
sudo chmod 777 /mnt/rd
echo "tmpfs   /mnt/rd    tmpfs    defaults,noatime,nosuid,mode=0777,size=1024m    0 0" | sudo tee -a /etc/fstab
sudo mount -a
