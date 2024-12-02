sudo mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk
(cd /sys/devices/system/cpu && echo performance | tee cpu*/cpufreq/scaling_governor)
