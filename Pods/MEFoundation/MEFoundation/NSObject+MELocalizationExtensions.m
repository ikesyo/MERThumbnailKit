//
//  NSObject+MELocalizationExtensions.m
//  MEFrameworks
//
//  Created by William Towe on 8/13/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//

#import "NSObject+MELocalizationExtensions.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIScreen.h>
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <AppKit/NSScreen.h>
#import <CoreServices/CoreServices.h>
#endif

NSString *const MELocalizationUserDefaultsKeySelectedLocalization = @"MELocalizationUserDefaultsKeySelectedLocalization";

NSString *const MELocalizationNotificationSelectedLocalizationDidChange = @"MELocalizationNotificationSelectedLocalizationDidChange";
NSString *const MELocalizationUserInfoKeySelectedLocalization = @"MELocalizationUserInfoKeySelectedLocalization";

@implementation NSObject (MELocalizationExtensions)

+ (NSString *)ME_defaultLocalization {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)ME_selectedLocalization {
    return ([[NSUserDefaults standardUserDefaults] objectForKey:MELocalizationUserDefaultsKeySelectedLocalization]) ?: [self ME_defaultLocalization];
}
+ (void)ME_setSelectedLocalization:(NSString *)selectedLocalization {
    NSString *localization = (selectedLocalization) ?: [self ME_defaultLocalization];
    
    [[NSUserDefaults standardUserDefaults] setObject:localization forKey:MELocalizationUserDefaultsKeySelectedLocalization];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MELocalizationNotificationSelectedLocalizationDidChange object:self userInfo:@{MELocalizationUserInfoKeySelectedLocalization : localization}];
}

+ (NSString *)ME_displayNameForSelectedLocalization {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[self ME_selectedLocalization]];
    
    return [locale displayNameForKey:NSLocaleIdentifier value:[self ME_selectedLocalization]];
}

@end

@implementation NSBundle (MELocalizationExtensions)

- (NSString *)ME_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName; {
    NSURL *bundleURL = [self URLForResource:[self.class ME_selectedLocalization] withExtension:@"lproj"];
    
    if (!bundleURL)
        bundleURL = [[NSBundle mainBundle] URLForResource:[self.class ME_defaultLocalization] withExtension:@"lproj"];
    
    return [[NSBundle bundleWithURL:bundleURL] localizedStringForKey:key value:value table:tableName];
}

- (NSURL *)ME_localizedURLForResource:(NSString *)name withExtension:(NSString *)extension subdirectory:(NSString *)subpath localization:(NSString *)localizationName; {
    NSString *uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    
    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        BOOL retina = ([UIScreen mainScreen].scale == 2);
#else
        BOOL retina = ([NSScreen mainScreen].backingScaleFactor == 2);
#endif
        
        if (retina)
            name = [name stringByAppendingString:@"@2x"];
        
        NSURL *retval = [self URLForResource:name withExtension:extension subdirectory:subpath localization:localizationName];
        
        if (retina && !retval)
            retval = [self URLForResource:[name substringToIndex:[name rangeOfString:@"@2x"].location] withExtension:extension subdirectory:subpath localization:localizationName];
        
        if (!retval) {
            retval = [self URLForResource:name withExtension:extension subdirectory:subpath localization:[self.class ME_defaultLocalization]];
            
            if (retina && !retval)
                retval = [self URLForResource:[name substringToIndex:[name rangeOfString:@"@2x"].location] withExtension:extension subdirectory:subpath localization:[self.class ME_defaultLocalization]];
        }
        
        return retval;
    }
    else {
        NSURL *retval = [self URLForResource:name withExtension:extension subdirectory:subpath localization:localizationName];
        
        if (!retval)
            retval = [self URLForResource:name withExtension:extension subdirectory:subpath localization:[self.class ME_defaultLocalization]];
        
        return retval;
    }
}

@end
