#!/bin/bash

# Set up bfq scheduler
modprobe bfq
echo bfq >> /etc/modules
echo 'ACTION=="add|change", KERNEL=="sd*[!0-9]|sr*", ATTR{queue/scheduler}="bfq"' >> /etc/udev/rules.d/60-scheduler.rules

apt update -y
apt dist-upgrade -y
apt autoremove -y
apt clean -y
apt autoclean -y

# Enable installing i386 packages
dpkg --add-architecture i386
apt install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

# install htop
apt install -y htop

# install JDK 11
apt install -y openjdk-11-jdk

apt install -y apktool dex2jar anbox
apt install -y python3-pip
apt install -y clang-9 clang++-9 llvm-9 libclang-9-dev
apt install -y radare2-cutter
apt install -y lib32z1
apt install -y menulibre
apt install -y mesa-vulkan-drivers
apt install -y docker docker-compose

pip3 install -U pip
pip3 install oletools yara-python frida

# Install Volatility 3
mkdir -p ~/src/
cd ~/src
git clone https://github.com/volatilityfoundation/volatility3.git
cd volatility3
python3.9 setup.py build
python3.9 setup.py install
cd /usr/local/lib/python3.9/dist-packages/volatility-*.egg/volatility/symbols
wget https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip
wget https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip
wget https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip

# Install FFDec
wget https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version11.2.0/ffdec_11.2.0.deb
dpkg -i ffdec_11.2.0.deb
rm ffdec_11.2.0.deb
echo '/usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar /usr/share/java/ffdec/ffdec.jar "$@"' > /usr/bin/ffdec

# Install JAD (Java Decompiler)
wget https://varaneckas.com/jad/jad158e.linux.static.zip
unzip jad158e.linux.static.zip -d /usr/local/bin jad

git clone https://github.com/ckane/officeparser.git
cd officeparser && python3 setup.py install
cd ..
rm -rf officeparser

# Make sure postgresql is running and starts on boot up
systemctl enable postgresql.service
systemctl start postgresql.service

# install VBoxGuestAdditions

# install Ghidra
wget -O ghidra.zip https://ghidra-sre.org/ghidra_9.1.1_PUBLIC_20191218.zip
unzip ghidra.zip -d /opt

# install android studio
wget https://dl.google.com/dl/android/studio/ide-zips/3.5.3.0/android-studio-ide-191.6010548-linux.tar.gz
tar xzf android-studio-ide-191.6010548-linux.tar.gz -C /opt/

# Set up msfdb
msfdb init

# Make Android "platform tools" available
echo -e '# Add Android platform tools to the run path\nPATH="${PATH}:/root/Android/Sdk/platform-tools"' >> /root/.bashrc

# Symlink helpful utilities into ${PATH}
ln -s ../../../opt/android-studio/studio.sh /usr/local/bin/android-studio.sh
ln -s ../../../opt/ghidra_9.1.1_PUBLIC/ghidraRun /usr/local/bin/

# Download Unity Support Test binary to help diagnose 3dgfx issues
wget -O /usr/local/bin/unity_support_test http://www.thinkpenguin.com/files/unity_support_test
chmod 755 /usr/local/bin/unity_support_test

# Set up docker images for elasticsearch and kibana
docker-compose -f kibana-docker-compose.yaml up -d
docker-compose -f kibana-docker-compose.yaml down
