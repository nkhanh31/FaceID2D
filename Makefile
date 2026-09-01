TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME = roothide

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FaceID2D
FaceID2D_FILES = Tweak.x
FaceID2D_CFLAGS = -fobjc-arc
FaceID2D_FRAMEWORKS = UIKit AVFoundation Vision CoreGraphics
FaceID2D_LIBRARIES = roothide
FaceID2D_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKEFILE_PATH)/tweak.mk
