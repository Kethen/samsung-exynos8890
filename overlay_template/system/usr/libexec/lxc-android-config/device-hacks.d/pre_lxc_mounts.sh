# mounts for lxc

# no tmpfs was mounted on /mnt for the fstab it found on this port
mount -t tmpfs android_mnt /var/lib/lxc/android/rootfs/mnt

# from xenial port

# manually trigger nonencrypted
mount -o bind /opt/halium-overlay/system/etc/init/hw/init.rc /var/lib/lxc/android/rootfs/system/etc/init/hw/init.rc

# enable audio hal
mount -o bind /opt/halium-overlay/system/etc/init/init.disabled.rc /var/lib/lxc/android/rootfs/system/etc/init/init.disabled.rc

# compat audio hal
mount -o bind /android/system/lib64/hw/audio.hidl_compat.default.so /android/vendor/lib64/hw/audio.primary.default.so

# bind mount efs and cpefs for samsung
mount -o bind /android/efs /var/lib/lxc/android/rootfs/efs
mount -o bind /android/cpefs /var/lib/lxc/android/rootfs/cpefs

# bind mount cache
mount -o bind /android/cache /var/lib/lxc/android/rootfs/cache

# do not override keymaster and cause log spam
mount -o bind /opt/halium-overlay/system/etc/vintf/manifest.xml /var/lib/lxc/android/rootfs/system/etc/vintf/manifest.xml

# disable wifi hal
mount -o bind /dev/null /android/vendor/etc/init/android.hardware.wifi@1.0-service.rc
mount -o bind /dev/null /android/vendor/etc/init/android.hardware.wifi.supplicant-service.rc
mount -o bind /dev/null /android/vendor/etc/init/hostapd.android.rc

# disable bluetooth hal
mount -o bind /dev/null /android/vendor/etc/init/android.hardware.bluetooth@1.0-service.rc

# overlay fingerprint hal init for starting it later with setprop
#mount -o bind /opt/halium-overlay/vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.samsung.rc /android/vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.samsung.rc

# overlay gnss hal init for starting it later with setprop
#mount -o bind /opt/halium-overlay/vendor/etc/init/vendor.samsung.hardware.gnss@1.0-service.rc /android/vendor/etc/init/vendor.samsung.hardware.gnss@1.0-service.rc

# disable usb init
mount -o bind /dev/null /android/vendor/etc/init/hw/init.samsungexynos8890.usb.rc

# disable livedisplay, not like UT uses it
mount -o bind /dev/null /android/vendor/etc/init/vendor.lineage.livedisplay@2.1-service.universal8890.rc

# mount binary patched sensor hub
mount -o bind /opt/halium-overlay/vendor/lib64/sensors.sensorhub.so /android/vendor/lib64/sensors.sensorhub.so

# load pie firmware
mount -o bind /opt/halium-overlay/vendor/etc/wifi /android/vendor/etc/wifi

# allow users to override mixer paths if they wish to
if ! [ -e /home/phablet/.config/samsung_mixer_paths_0_override.xml ]
then
    if ! [ -d /home/phablet/.config ]
    then
        mkdir -p /home/phablet/.config
        chown phablet: /home/phablet
        chown phablet: /home/phablet/.config
    fi
    cp /vendor/etc/mixer_paths_0.xml /home/phablet/.config/samsung_mixer_paths_0_override.xml
fi
chmod 644 /home/phablet/.config/samsung_mixer_paths_0_override.xml
chown root: /home/phablet/.config/samsung_mixer_paths_0_override.xml
mount -o bind,ro /home/phablet/.config/samsung_mixer_paths_0_override.xml /vendor/etc/mixer_paths_0.xml

# allow users to override aidl power config if they wish to
if ! [ -e /home/phablet/.config/powerhint.json ]
then
    cp /vendor/etc/powerhint.json /home/phablet/.config/powerhint.json
fi
chmod 644 /home/phablet/.config/powerhint.json
chown root: /home/phablet/.config/powerhint.json
mount -o bind,ro /home/phablet/.config/powerhint.json /vendor/etc/powerhint.json

# mounts for rootfs
# hide extra power_supply sysfs nodes that present themselves as batteries
mount -o ro -t tmpfs tmpfs /sys/class/power_supply/max77854-fuelgauge
mount -o ro -t tmpfs tmpfs /sys/class/power_supply/p9220-charger

mount -o bind /opt/rootfs-overlay/etc/default/usb-moded.d/device-specific-config.conf /etc/default/usb-moded.d/device-specific-config.conf
mount -o bind /opt/rootfs-overlay/etc/gbinder.conf /etc/gbinder.conf
mount -o bind /opt/rootfs-overlay/etc/profile.d/qtwebengine-gpu.sh /etc/profile.d/qtwebengine-gpu.sh
mount -o bind /opt/rootfs-overlay/etc/pulse/touch.pa /etc/pulse/touch.pa

mount -o bind /dev/null /usr/lib/aarch64-linux-gnu/qt5/qml/Morph/Web/scrollbar-theme.js
mount -o bind /opt/rootfs-overlay/usr/lib/aarch64-linux-gnu/qt5/qml/Morph/Web/MorphWebContext.qml /usr/lib/aarch64-linux-gnu/qt5/qml/Morph/Web/MorphWebContext.qml

mount -o bind /opt/rootfs-overlay/usr/libexec/lxc-android-config/device-hacks /usr/libexec/lxc-android-config/device-hacks

echo === pre_lxc_mounts.sh has finished === > /dev/kmsg
