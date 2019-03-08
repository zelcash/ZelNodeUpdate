# ZelNodeUpdate v1.1
A simple script to assist with updating ZelNodes to the latest version.

## NOTE: This script is the latest version for MainNet ZelNodes.

**NOTE:** This installation guide is provided as is with no warranties of any kind.

**NOTE:** To run this version of the script (v1.1), please use the same login that was used to install the ZelNode.

This script has been tested on Ubuntu Server 16.04 & 18.04.

***
## Requirements
1) **Already running ZelNode that was installed using the previous script**
2) **SSH client such as [Putty](https://www.putty.org/)or [MobaXterm](https://mobaxterm.mobatek.net/)**

***
## Steps

1) **Connect to your VPS server console using PuTTY** terminal program

Please use the same login as was used to install the ZelNode.

2) **Download script & begin update of ZelNode**

**PLEASE BE SURE YOU ARE LOGGED IN AS YOUR USERNAME (not root) BEFORE RUNNING THIS SCRIPT**

```
wget -O zelnodeupdate.sh https://raw.githubusercontent.com/zelcash/ZelNodeUpdate/master/zelnodeupdate.sh && chmod +x zelnodeupdate.sh && bash ./zelnodeupdate.sh
```

The script will update your OS, install the new ZelNode binaries, and create a cron job to compress & rotate zel log files

__NOTE:__ This process may take anywhere from 3 to 5 minutes, depending on your VPS HW specs.

3) **Once the script completes, reboot your VPS** by typing the following command:

```
sudo reboot -n
```

4) **Log back into your VPS and verify your node is running**

```
zelcash-cli getinfo
```

__NOTE:__ Please wait a few minutes for your node to connect and sync with the network before running this command.

5) **Start your ZelNode from within ZelCore or ZelMate wallet**

__NOTE:__ Updated versions of the wallets are required for this otherwise your node will not start.
Please verify you are using one of the following wallet versions:
**ZelCore v1.4.0 or ZelMate v7.1.0**

***
A special thank you to **Skyslayer**, who did the majority of the work on assembling this script, and **OrthoReb** for debugging.

If encountering problems with this script, please visit the official ZelCash FAQ at https://faq.zelcore.io/
For answers to common questions regarding ZelNodes, please visit https://github.com/zelcash/zelcash/wiki/ZelNode-FAQ
