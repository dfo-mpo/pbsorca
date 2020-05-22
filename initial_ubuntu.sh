# Ubuntu 20.04LTS on a Pi 4

sudo apt update
sudo apt install golang ffmpeg git alsa-utils libffi-dev build-essential gcc g++ make python3-dev

# Get azcopy and install to ~/go/bin/azure-storage-azcopy
wget https://github.com/Azure/azure-storage-azcopy/archive/10.4.3.tar.gz
tar zxvf 10.4.3.tar.gz 
cd azure-storage-azcopy-10.4.3/
go build
go install

# add to path
echo "export PATH=\$PATH:~/go/bin" | tee -a ~/.bashrc
source ~/.bashrc

# Backup directory in case ram drive mount fails
sudo mkdir /mnt/rd
sudo chmod 777 /mnt/rd
echo "tmpfs   /mnt/rd    tmpfs    defaults,noatime,nosuid,mode=0777,size=1024m    0 0" | sudo tee -a /etc/fstab
sudo mount -a

curl -L https://aka.ms/InstallAzureCli | bash