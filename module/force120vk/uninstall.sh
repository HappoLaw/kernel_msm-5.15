#!/system/bin/sh
# Runs when the module is removed: restore default refresh behavior.
settings delete system min_refresh_rate
settings delete system peak_refresh_rate
settings delete system user_refresh_rate
rm -f /data/adb/force120vk.conf
