TARGET := iphone:clang:16.5:15.0
ARCHS := arm64 arm64e

THEOS_PACKAGE_SCHEME = rootless

PREFIX = $(THEOS)/toolchain/linux/iphone/bin/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FaceID2D

FaceID2D_FILES = Tweak.x
FaceID2D_CFLAGS = -fobjc-arc
FaceID2D_FRAMEWORKS = UIKit AVFoundation Vision LocalAuthentication

include $(THEOS)/makefiles/tweak.mk
