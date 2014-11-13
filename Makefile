ARCHS = armv7 armv7s
TARGET := iphone:clang
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0
TARGET_CC = xcrun -sdk iphoneos clang
TARGET_CXX = xcrun -sdk iphoneos clang++
TARGET_LD = xcrun -sdk iphoneos clang++
SHARED_CFLAGS = -fobjc-arc
ADDITIONAL_OBJCFLAGS = -fobjc-arc -Wall
GO_EASY_ON_ME = 1


include theos/makefiles/common.mk

TWEAK_NAME = RCKVKAppTweak

RCKVKAppTweak_FILES =   Classes/Categories/NSObject+RCKNetworkUtilities.m \
                        Classes/Categories/NSURLRequest+RCKUtilities.m \
                        Classes/Categories/UIAlertView+RCKTweak.m \
                        \
                        Classes/Model/RCKAudio.m \
                        Classes/Model/RCKAudio+Addition.m \
                        Classes/Model/RCKAudioManager.m \
                        Classes/Model/RCKCoreDataManager.m \
                        Classes/Model/RCKCoreDataModelSerialization.m \
                        Classes/Model/RCKError.m \
                        Classes/Model/RCKErrorManager.m \
                        \
                        Classes/Tweak/RCKTweakAFJSONRequestOperation.xm \
                        Classes/Tweak/RCKTweakAudioPlayer.xm \
                        Classes/Tweak/RCKTweakIOS7AudioController.xm \
                        Classes/Tweak/RCKTweakNSMutableURLRequest.xm \
                        \
                        Classes/RCKFileDownloader.m \
                        Classes/RCKLoadingView.m \
                        Classes/RCKSettings.m \
                        Classes/RCKViewController.m

RCKVKAppTweak_CFLAGS += -IClasses/ \
                        -IClasses/Tweak/ \
                        -IClasses/Model/ \
                        -IClasses/Categories/ \
                        -IClasses/VKAppHeaders/ \
                        -IAFNetworking/AFNetworking

RCKVKAppTweak_FRAMEWORKS = UIKit AVFoundation CFNetwork AudioToolbox CoreMedia CoreData CoreGraphics QuartzCore SystemConfiguration

include $(THEOS_MAKE_PATH)/tweak.mk
