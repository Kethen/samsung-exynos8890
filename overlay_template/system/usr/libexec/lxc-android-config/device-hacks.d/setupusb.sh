get_modes() {
    echo -n "mtp adb mtp_adb rndis rndis_adb"
}

write() {
    if [ ! -e "$1" ]; then
        return
    fi
    echo "writing to: $1"
    echo -n "$2" >"$1"
}

symlink() {
    ln -s "$1" "$2"
}

setup_mtp() {
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 04e8
    write /sys/class/android_usb/android0/idProduct 6860
    write /sys/class/android_usb/android0/functions mtp
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state mtp
}

setup_adb() {
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 04e8
    write /sys/class/android_usb/android0/idProduct 6860
    write /sys/class/android_usb/android0/functions adb
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state adb
}

setup_mtp_adb() {
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 04e8
    write /sys/class/android_usb/android0/idProduct 6860
    write /sys/class/android_usb/android0/functions mtp,adb
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state mtp,adb
}

setup_rndis() {
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 04e8
    write /sys/class/android_usb/android0/idProduct 6863
    write /sys/class/android_usb/android0/functions rndis
    write /sys/class/android_usb/android0/bDeviceClass 224
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state rndis
}

setup_rndis_adb() {
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 04e8
    write /sys/class/android_usb/android0/idProduct 6864
    write /sys/class/android_usb/android0/functions rndis,adb
    write /sys/class/android_usb/android0/bDeviceClass 224
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state rndis,adb
}

reset_usb() {
    echo nothing to do for reset
}

setup_boot() {
    if [ -e /dev/.usb_setup_done ]; then
        #echo "Boot setup done"
        return
    fi

    write /sys/class/android_usb/android0/iManufacturer $(getprop ro.product.manufacturer)
    write /sys/class/android_usb/android0/iProduct $(getprop ro.product.model)
    write /sys/class/android_usb/android0/iSerial $(getprop ro.serialno)
    write /sys/class/android_usb/android0/f_mass_storage/inquiry_string "Samsung"
    mkdir /dev/usb-ffs
    mkdir /dev/usb-ffs/adb
    mount -t functionfs -o uid=phablet,gid=phablet adb /dev/usb-ffs/adb
    chmod 775 /dev/usb-ffs
    chown root:plugdev /dev/usb-ffs
    chmod 775 /dev/usb-ffs/adb
    chown root:plugdev /dev/mtp_usb
    chmod 660 /dev/mtp_usb
    write /sys/class/android_usb/android0/f_ffs/aliases adb
	write /sys/class/android_usb/android0/f_rndis/ethaddr 1
    touch /dev/.usb_setup_done
}

setup_boot

if [ "$1" == "rndis" ]; then
    setup_rndis
elif [ "$1" == "rndis_adb" ]; then
    setup_rndis_adb
elif [ "$1" == "mtp" ]; then
    setup_mtp
elif [ "$1" == "adb" ]; then
    setup_adb
elif [ "$1" == "mtp_adb" ]; then
    setup_mtp_adb
elif [ "$1" == "get_modes" ]; then
    get_modes
elif [ "$1" == "reset" ]; then
    reset_usb
else
    echo "No configuration selected."
fi

exit 0
