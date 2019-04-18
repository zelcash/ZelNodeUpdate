#Version V2 04/17/2019 Update ZelNode Daemon to Version 3.1.1 via APT


COIN_NAME='zelcash'
#wallet information
ZIPTAR='unzip'
CONFIG_FILE='zelcash.conf'
PORT=16125
COIN_DAEMON='zelcashd'
COIN_CLI='zelcash-cli'
COIN_TX='zelcash-tx'
COIN_PATH='/usr/local/bin'
USERNAME=$(who -m | awk '{print $1;}')
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'
STOP='\e[0m'
FETCHPARAMS='https://raw.githubusercontent.com/zelcash/zelcash/master/zcutil/fetch-params.sh'
#end of required details

#Display script name and version
clear
echo -e '\033[1;33m==================================================================\033[0m'
echo -e 'ZelNode Update, v2.0'
echo -e '\033[1;33m==================================================================\033[0m'
echo -e '\033[1;34m19 April. 2019, by dk808zelnode, Goose-Tech & Skyslayer\033[0m'
echo -e
echo -e '\033[1;36mZelNode update starting, press [CTRL-C] to cancel.\033[0m'
sleep 3
echo -e

#check for correct user
USERNAME=$(who -m | awk '{print $1;}')
echo -e "\033[1;36mYou are currently logged in as \033[0m$USERNAME\033[1;36m.\n\n"
read -p 'Was this the username used to install the ZelNode? [Y/n] ' -n 1 -r
if [[ $REPLY =~ ^[Nn]$ ]]
then
    echo ""
    echo -e "\033[1;33mPlease log out and login with the username you created for your ZelNode.\033[0m"
      exit 1
fi

#Closing zelcash daemon
echo -e "\033[1;33mStopping The ZelCash Node Daemon...\033[0m"
sudo systemctl stop zelcash > /dev/null 2>&1 && sleep 3
sudo zelcash-cli stop > /dev/null 2>&1 && sleep 5
sudo killall $COIN_DAEMON > /dev/null 2>&1
#Removing old zelcash files
sudo apt-get purge zelcash -y
sudo rm -rf /usr/bin/zelcash* > /dev/null 2>&1
echo -e "\033[1;33mDownloading new wallet binaries...\033[0m"
#adding ZelCash APT Repo
if [ -f /etc/apt/sources.list.d/zelcash.list ]; then
    echo -e "\033[1;36mExisting repo found, backing up to ~/zelcash.list.old ...\033[0m"
    sudo mv /etc/apt/sources.list.d/zelcash.list ~/zelcash.list.old;
    sleep 2
fi
echo 'deb https://zelcash.github.io/aptrepo/ all main' | sudo tee --append /etc/apt/sources.list.d/zelcash.list > /dev/null
gpg --keyserver keyserver.ubuntu.com --recv 4B69CA27A986265D > /dev/null
gpg --export 4B69CA27A986265D | sudo apt-key add -
sudo apt-get update -y
#Installing ZelCash via APT if it is not installed already via APT or update if it is
sudo apt-get install zelcash
chmod 755 /usr/local/bin/zelcash*
#Install Ubuntu updates
echo -e "\033[1;33m=======================================================\033[0m"
echo "Updating your OS..."
echo -e "\033[1;33m=======================================================\033[0m"
echo "Installing package updates..."
#Hold back sysbench updates for benchmarks
sudo apt-mark hold sysbench
sudo apt-get update -y
sudo apt-get upgrade -y
echo -e "\033[1;32mLinux Packages Updates complete...\033[0m"
sleep 2
#Setup log rotation
echo -e "\n\033[1;33mConfiguring log rotate function...\033[0m"
sleep 1
if [ -f /etc/logrotate.d/zeldebuglog ]; then
    echo -e "\033[1;36mExisting log rotate conf found, backing up to ~/zeldebuglogrotate.old ...\033[0m"
    sudo mv /etc/logrotate.d/zeldebuglog ~/zeldebuglogrotate.old;
    sleep 2
fi
touch /home/$USERNAME/zeldebuglog
cat <<EOM > /home/$USERNAME/zeldebuglog
/home/$USERNAME/.zelcash/debug.log {
    compress
    copytruncate
    missingok
    daily
    rotate 7
}
EOM
cat /home/$USERNAME/zeldebuglog | sudo tee -a /etc/logrotate.d/zeldebuglog > /dev/null
rm /home/$USERNAME/zeldebuglog
sudo logrotate --force /etc/logrotate.d/zeldebuglog
echo -e "\n\033[1;32mLog rotate configuration complete.\n~/.zelcash/debug.log file will be backed up daily for 7 days then rotated.\033[0m"
sleep 5

# change zelcash service file to reflect new daemon path
echo -e "\033[1;32mUpdating system service...\033[0m"
sudo touch /etc/systemd/system/$COIN_NAME.service
sudo chown $USERNAME:$USERNAME /etc/systemd/system/$COIN_NAME.service
cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
Type=forking
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/home/$USERNAME/.zelcash/
ExecStart=$COIN_PATH/$COIN_DAEMON -datadir=/home/$USERNAME/.zelcash/ -conf=/home/$USERNAME/.zelcash/$CONFIG_FILE -daemon
ExecStop=-$COIN_PATH/$COIN_CLI stop
Restart=always
RestartSec=3
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
sudo chown root:root /etc/systemd/system/$COIN_NAME.service
sudo systemctl daemon-reload
sleep 3
sudo systemctl enable $COIN_NAME.service &> /dev/null

echo -e "\033[1;33mSystemctl Complete....\033[0m"

cd
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
#Notice to user we are complete and request a reboot
echo -e "\033[1;32mUpdate complete.\nPlease reboot the VPS by typing: \033[0msudo reboot -n\033[1;32m."
echo -e "Then verify the ZelCash daemon has started by typing: \033[0mzelcash-cli getinfo\033[1;32m.\033[0m"
