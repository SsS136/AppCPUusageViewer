ARCHS = armv7 armv7s arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppCPUusageViewer

AppCPUusageViewer_FILES = Tweak.xm NSString+split.m
AppCPUusageViewer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
