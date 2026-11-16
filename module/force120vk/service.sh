#!/system/bin/sh
# Runs late at boot (service). Locks the refresh rate to TARGET Hz and
# re-applies it periodically so the system / OEM / user can't drop it.

MODDIR=${0%/*}
CONF=/data/adb/force120vk.conf
TARGET=120
[ -f "$CONF" ] && . "$CONF"   # optional: put TARGET=90 etc. in this file

# Wait for boot to finish
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 10

apply() {
  # --- AOSP / Pixel / most custom ROMs ---
  settings put system min_refresh_rate "$TARGET"
  settings put system peak_refresh_rate "$TARGET"
  settings put system user_refresh_rate "$TARGET"

  # --- Samsung One UI (2 = high / adaptive-120) ---
  settings put system refresh_rate_mode 2

  # --- Xiaomi / HyperOS / MIUI ---
  settings put system miui_refresh_rate "$TARGET"

  # --- OnePlus / Oppo / Realme (ColorOS / OxygenOS) ---
  settings put system oneplus_screen_refresh_rate 0
  settings put system screen_refresh_rate 0
  settings put secure oplus_customize_screen_refresh_rate 0

  # --- Keep battery saver / smooth-display auto modes from interfering ---
  settings put global low_power 0
  settings put secure smooth_display 1
}

# Stop userspace loggers (logcat daemon + perfetto tracing daemons).
# Safe to re-run; each call is a no-op if the service isn't present.
for svc in logd traced traced_probes; do
  stop "$svc" >/dev/null 2>&1
done

# First apply, then re-apply every 30s forever
while true; do
  # keep loggers down if something restarts them
  for svc in logd traced traced_probes; do
    [ "$(getprop init.svc.$svc)" = "running" ] && stop "$svc" >/dev/null 2>&1
  done
  apply >/dev/null 2>&1
  sleep 30
done
