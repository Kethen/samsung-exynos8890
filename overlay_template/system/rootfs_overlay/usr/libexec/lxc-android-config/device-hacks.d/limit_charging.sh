if [ -e /home/phablet/.config/limit_charging ]
then
	echo 1 > /sys/class/power_supply/battery/store_mode
fi
