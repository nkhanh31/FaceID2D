THEOS ?= $(THEOS_STAGING_DIR)/..
THEOS_PACKAGE_SCHEME = roothide
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FaceID2D
FaceID2D_FILES = Tweak.x
FaceID2D_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
FaceID2D_FRAMEWORKS = UIKit AVFoundation Vision CoreGraphics
FaceID2D_LIBRARIES = roothide
FaceID2D_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKEFILE_PATH)/tweak.mk

BUNDLE_NAME = FaceID2DPrefs
FaceID2DPrefs_FILES = FaceID2DPrefsController.m
FaceID2DPrefs_FRAMEWORKS = UIKit
FaceID2DPrefs_PRIVATE_FRAMEWORKS = Preferences
FaceID2DPrefs_INSTALL_PATH = /Library/PreferenceBundles
FaceID2DPrefs_CFLAGS = -fobjc-arc
FaceID2DPrefs_LIBRARIES = roothide

include $(THEOS_MAKEFILE_PATH)/bundle.mk
