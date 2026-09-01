TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FaceID2DPreferences

FaceID2DPreferences_FILES = FIDRootListController.m
FaceID2DPreferences_FRAMEWORKS = UIKit
FaceID2DPreferences_PRIVATE_FRAMEWORKS = Preferences
FaceID2DPreferences_INSTALL_PATH = /Library/PreferenceBundles
FaceID2DPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
