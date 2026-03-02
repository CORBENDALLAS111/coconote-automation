ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
TWEAK_NAME = CoconoteAutoRecording
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit AVFoundation
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
