# haxip

haxip is a bash script that shows you information (ip, country, etc) about anyone who enters your haxball rooms and also for rooms you join

## dependencies

to use haxip you need the following programs installed

- tshark
- xclip
- curl
- jq

## install

```sh
git clone https://github.com/alpheratz0/haxip.git
cd haxip
chmod +x ./haxip.sh
sudo cp haxip.sh /usr/local/bin/haxip
```

## example

copy the last ip detected to the clipboard and display the following information ip, code, country, city and timestamp

```sh
network_interface=$(ip route | awk "/default/ { print \$5 }")
sudo haxip -fCI $network_interface
```
