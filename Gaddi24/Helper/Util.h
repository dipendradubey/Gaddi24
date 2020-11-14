//
//  Util.h
//  Aurora
//
//  Created by Dipendra Dubey on 01/11/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

+(void)showAlert:(NSString *)title andMessage:(NSString *)message forViewController:(UIViewController *)VC;
+(UIView *)getLoaderView;
+(void)hideLoader:(UIView *)view;
+(void)showLoader:(NSString *)loaderText forView:(UIView *)view;
+ (BOOL)validateEmailWithString:(NSString*)checkString;
+(void)updateDefaultForKey:(NSString *)key toValue:(id)value;
+(id)retrieveDefaultForKey:(NSString *)key;
+(NSString *)updateDateFormate:(NSString *)dateFormate;
+(NSString *)updateDurationFormate:(NSString *)timeString;
+(NSDictionary *)beforeYesterdayDateRange;
+(NSDictionary *)yesterdayDateRange;
+(NSDictionary *)todayDateRange;
+(NSDictionary *)hourDateRange;
+(NSDictionary *)weekDateRange;
+(void)removeValueFromDefault:(NSString *)keyName;
+(NSString *)dateString:(NSDate *)date;
+(NSString *)universalDateFormate:(NSDictionary *)dict;
+(NSString *)fromDateToStringConverter:(NSDictionary *)dict;
+(NSDate *)fetchDateFromString:(NSString *)dateString;
+ (NSString*)getUniqueDeviceIdentifierAsString;
+(UIViewController *)fetchLastViewcontroller;
+(void)shareText:(NSString *)endDateString forViewController:(UIViewController *)VC forVehicleID:(NSString *)vehicleID;
+(NSDate *)addTimeinCurrentDate:(NSString *)title;
+(id)checkNullValue:(id)value;
+ (UIColor *)colorWithHexString:(NSString *)str_HEX;
+(NSString *)fetchFontAwesomeString:(NSString *)unicodeString;


@end
