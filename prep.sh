if grep -q "tmpfs /mnt/ramdisk tmpfs" /proc/mounts; then
    echo "already mounted tmpfs."
else
    sudo mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk
fi
(cd /sys/devices/system/cpu && echo performance | sudo tee cpu*/cpufreq/scaling_governor)
