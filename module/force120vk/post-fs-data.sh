#!/system/bin/sh
# Runs early at boot (post-fs-data). Sets Vulkan renderer props before
# zygote/SurfaceFlinger start so every process picks them up.

# HWUI (app UI rendering) -> Skia on Vulkan
resetprop ro.hwui.use_vulkan true
resetprop debug.hwui.renderer skiavk

# SurfaceFlinger RenderEngine (composition) -> Skia on Vulkan
# (Android 13+; harmless on older versions)
resetprop debug.renderengine.backend skiavkthreaded
