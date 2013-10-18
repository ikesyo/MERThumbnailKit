//
//  NSObject+MELocalizationExtensions.h
//  MEFrameworks
//
//  Created by William Towe on 8/13/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MELocalizedString(key,comment) \
    [[NSBundle mainBundle] ME_localizedStringForKey:(key) value:@"" table:nil]

#define MELocalizedStringFromTable(key,tableName,comment) \
    [[NSBundle mainBundle] ME_localizedStringForKey:(key) value:@"" table:(tableName)]

#define MELocalizedStringFromTableInBundle(key,tableName,bundle,comment) \
    [bundle ME_localizedStringForKey:(key) value:@"" table:(tableName)]

#define MELocalizedURLForResourceWithExtension(resource,extension) \
    [[NSBundle mainBundle] ME_localizedURLForResource:(resource) withExtension:(extension) subdirectory:@"" localization:[NSObject ME_selectedLocalization]]

#define MELocalizedURLForResourceWithExtensionInBundle(resource,extension,bundle) \
    [bundle ME_localizedURLForResource:(resource) withExtension:(extension) subdirectory:@"" localization:[NSObject ME_selectedLocalization]]

extern NSString *const MELocalizationUserDefaultsKeySelectedLocalization;

extern NSString *const MELocalizationNotificationSelectedLocalizationDidChange;
extern NSString *const MELocalizationUserInfoKeySelectedLocalization;

@interface NSObject (MELocalizationExtensions)

+ (NSString *)ME_defaultLocalization;

+ (NSString *)ME_selectedLocalization;
+ (void)ME_setSelectedLocalization:(NSString *)selectedLocalization;

+ (NSString *)ME_displayNameForSelectedLocalization;

@end

@interface NSBundle (MELocalizationExtensions)

- (NSString *)ME_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

- (NSURL *)ME_localizedURLForResource:(NSString *)name withExtension:(NSString *)extension subdirectory:(NSString *)subpath localization:(NSString *)localizationName;

@end
