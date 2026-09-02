TARGET := iphone:clang:latest:15.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FaceID2D

FaceID2D_FILES = Tweak.x
FaceID2D_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
FaceID2D_LDFLAGS = -fuse-ld=lld
FaceID2D_FRAMEWORKS = UIKit AVFoundation Vision

include $(THEOS_MAKEFILE_PATH)/tweak.mk