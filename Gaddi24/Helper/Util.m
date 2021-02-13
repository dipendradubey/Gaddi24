//
//  Util.m
//  Aurora
//
//  Created by Dipendra Dubey on 01/11/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "Util.h"
#import "MBProgressHUD.h"
#import "Global.h"
#import <sys/utsname.h>
//#import <SAMKeychain.h>
#import "SAMKeychain.h"
#import "AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+Localizer.h"
#import "TrackVehicleVC.h"

@implementation Util

static UIView *loaderView;
static UIViewController *activeVC;

+(id)checkNullValue:(id)value{
    if (value == [NSNull null] || value == nil) {
        return @"";
    }
    return value;
}

+(void)showAlert:(NSString *)title andMessage:(NSString *)message forViewController:(UIViewController *)VC{
    activeVC = VC;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_OK" localizableString:@""] style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [activeVC presentViewController:alert animated:YES completion:nil];
}

+(UIView *)getLoaderView{
    return loaderView;
}

+(void)hideLoader:(UIView *)view{
    
    //DKD commented on 12 Apr 2020
    //[MBProgressHUD hideAllHUDsForView:view animated:YES];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+(void)showLoader:(NSString *)loaderText forView:(UIView *)view{
    
    loaderView = view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6f];
    
    if(loaderText.length >0){
        //DKD commented on 12 Apr 2020
        //hud.labelText = loaderText;
        hud.label.text = loaderText;
    }
}

+(NSString*) fetchAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark Default setup
+(void)updateDefaultForKey:(NSString *)key toValue:(id)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

+(id)retrieveDefaultForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}

+(NSString *)updateDateFormate:(NSString *)timeString{
    
    ////NSLog(@"timeString =%@",timeString);
    
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat =@"dd/MM/yyyy H:mm:ss";
    
    NSDate *date = [dateFormatter dateFromString:timeString];
    dateFormatter.dateFormat =@"dd-MMM-yyyy hh:mm a";
    return[dateFormatter stringFromDate:date];
     */
    //Swapnil doesn't want date formate
    return timeString;
    
}

+(NSString *)universalDateFormate:(NSDictionary *)dict{
    
    ////NSLog(@"timeString =%@",timeString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = dict[kActualDateFormate]; //@"dd/MM/yyyy H:mm:ss";
    
    NSDate *date = [dateFormatter dateFromString:dict[kDate]];
    dateFormatter.dateFormat =dict[kRequiredDateFormate]; //@"dd-MMM-yyyy hh:mm a";
    return[dateFormatter stringFromDate:date];
    
}


+(NSString *)updateDurationFormate:(NSString *)timeString{
    
    ////NSLog(@"timeString =%@",timeString);
    
    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat =@"HH:mm:ss";
    
    NSDate *date = [dateFormatter dateFromString:timeString];
    dateFormatter.dateFormat =@"HH:mm";
    return[dateFormatter stringFromDate:date];*/
    
    return timeString;
    
}

+(NSDictionary *)beforeYesterdayDateRange{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-2];
    
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    
    //5-2-2017 14_17_12
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *yesterayDateString = [dateFormatter stringFromDate:yesterday];
    
    NSDictionary *dateDict = @{@"date1":[NSString stringWithFormat:@"%@ 00_00_00",yesterayDateString],
                               @"date2":[NSString stringWithFormat:@"%@ 23_59_59",yesterayDateString]
                               };
    
    return dateDict;
}

+(NSDictionary *)weekDateRange{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-6];
    
    NSDate *weekDay = [cal dateByAddingComponents:components toDate:today options:0];
    
    //5-2-2017 14_17_12
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *weekDateString = [dateFormatter stringFromDate:weekDay];
    NSString *todayDateString = [dateFormatter stringFromDate:date];

    
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc]init];
    [dateFormatter3 setDateFormat:@"dd-MMM-yyyy"];
    NSString *date3String = [dateFormatter3 stringFromDate:date];
    NSString *date4String = [dateFormatter3 stringFromDate:weekDay];

    
    date3String = [NSString stringWithFormat:@"%@ 12:00 AM - %@ 11:59 PM",date4String,date3String];
    
    NSDictionary *dateDict = @{@"date1":[NSString stringWithFormat:@"%@ 00_00_00",weekDateString],
                               @"date2":[NSString stringWithFormat:@"%@ 23_59_59",todayDateString],
                               @"date3":date3String
                            };
    
    return dateDict;
}


+(NSDictionary *)yesterdayDateRange{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    
    //5-2-2017 14_17_12
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *yesterayDateString = [dateFormatter stringFromDate:yesterday];
    
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc]init];
    [dateFormatter3 setDateFormat:@"dd-MMM-yyyy"];
    NSString *date3String = [dateFormatter3 stringFromDate:yesterday];
    date3String = [NSString stringWithFormat:@"%@ 12:00 AM - %@ 11:59 PM",date3String,date3String];
    
    NSDictionary *dateDict = @{@"date1":[NSString stringWithFormat:@"%@ 00_00_00",yesterayDateString],
                               @"date2":[NSString stringWithFormat:@"%@ 23_59_59",yesterayDateString],
                               @"date3":date3String

                               };
    
    return dateDict;
}

+(NSDictionary *)todayDateRange{
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *date1String = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH_mm_ss"];
    NSString *date2String = [dateFormatter stringFromDate:date];
    
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc]init];
    [dateFormatter3 setDateFormat:@"dd-MMM-yyyy"];
    NSString *date3String = [dateFormatter3 stringFromDate:date];
    date3String = [NSString stringWithFormat:@"%@ 12:00 AM - %@ 11:59 PM",date3String,date3String];
    
    NSDictionary *dateDict = @{@"date1":[NSString stringWithFormat:@"%@ 00_00_00",date1String],
                               @"date2":[NSString stringWithFormat:@"%@",date2String],
                               @"date3":date3String
                               };
    
    return dateDict;
}


+(NSDictionary *)hourDateRange{
    
    
    NSDate *date = [NSDate date];
    
    NSDate *hourAgoDate = [date dateByAddingTimeInterval:-60*60];
    
    //5-2-2017 14_17_12
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH_mm_ss"];
    NSString *date1String = [dateFormatter stringFromDate:hourAgoDate];
    NSString *date2String = [dateFormatter stringFromDate:date];
    
    NSDictionary *dateDict = @{@"date1":date1String,
                               @"date2":date2String
                               };
    
    return dateDict;
}

+(void)removeValueFromDefault:(NSString *)keyName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:keyName];
    [defaults synchronize];
}

+(NSString *)dateString:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+(NSDate *)fetchDateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    return [dateFormatter dateFromString:dateString];
}


+(NSString *)fromDateToStringConverter:(NSDictionary *)dict{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dict[kActualDateFormate]];
    NSString *dateString = [dateFormatter stringFromDate:dict[kDate]];
    return dateString;
}

+ (NSString*)getUniqueDeviceIdentifierAsString {
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey: (NSString*) kCFBundleNameKey];
    NSString* strApplicationUUID = [SAMKeychain passwordForService: appName account: @"incoding"];
    if (strApplicationUUID == nil) {
        strApplicationUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SAMKeychain setPassword: strApplicationUUID forService: appName account: @"incoding"];
    }
    NSLog(@"device id=%@",strApplicationUUID);
    return strApplicationUUID;
}

+(UIViewController *)fetchLastViewcontroller{
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
    
    UIViewController *viewcontroller = nil;
    
    NSLog(@"%@",navigationController.viewControllers);
    
if ([navigationController respondsToSelector:@selector(viewControllers)]) {
        viewcontroller = [navigationController.viewControllers lastObject];
    }
    else{
        MMDrawerController *VC = (MMDrawerController *)navigationController;
        viewcontroller = VC.centerViewController;
    }
    
    //MMDrawerController *VC = viewcontroller
    
    UINavigationController *nav1 = (UINavigationController *)[(MMDrawerController*)viewcontroller centerViewController];
    
    NSLog(@"centerVC =%@",nav1.viewControllers);
    
    return [nav1.viewControllers lastObject];
}


+(NSDate *)addTimeinCurrentDate:(NSString *)title{
    NSDate *updatedDate = [[NSDate date] dateByAddingTimeInterval: [self fetchSecondFromTitle:title]];
    return updatedDate;
}

+(int)fetchSecondFromTitle:(NSString *)title{
    
    //arrShare = @[@"30 Minutes", @"2 Hours", @"4 Hours", @"8 Hours", @"12 Hours", @"24 Hours", @"Custom"];
    
    int secondTime = 24*60*60;
    
    if ([title isEqualToString:@"1 Day"]) {
        secondTime = 24*60*60;
    }
    else if ([title isEqualToString:@"2 Day"]) {
        secondTime = 48*60*60;
    }
    else if ([title isEqualToString:@"Week"]) {
        secondTime = 168*60*60;
    }
    
    return  secondTime;
}

+(void)shareText:(NSString *)endDateString forViewController:(UIViewController *)VC forVehicleID:(NSString *)vehicleID{
    
    NSString *startDateString = [Util fromDateToStringConverter:@{kActualDateFormate:SHARE_REQUIRED_DATE,kDate:[NSDate date]}];
    
    NSString *shareLink = [NSString stringWithFormat:@"%@%@/%@/%@",ShareApiPath,vehicleID,startDateString,endDateString];
    
    NSString *encodedLink = [shareLink stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
//    shareLink = @"http://www.trackgaddi.com/api/v1/ShareVehicle/ShareVehicleLink/2114/19-02-2020%2000_12_22/21-02-2020%2000_12_22";
    
    //http://www.trackgaddi.com/api/v1/ShareVehicle/ShareVehicleLink/
    
    NSLog(@"encodedLink =%@",encodedLink);
    
    //http://www.trackgaddi.com/api/v1/ShareVehicle/ShareVehicleLink/2114/19-02-2020%2000_12_22/21-02-2020%2000_12_22

    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedLink]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
         NSInteger statuscode = [httpResponse statusCode];


         if ([data length] >0 && error == nil)
         {
             id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSLog(@"status =%ld-----resposeobject=%@",(long)statuscode,responseObject);
             
             if (responseObject == nil) {
                 //Handle error
             }
             else{
                //Got response
                 
                 if ([responseObject[@"StatusCode"] intValue] != 1) {
                     return;
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSString *shareLink = responseObject[@"Message"];
                     NSArray *activityItems = @[shareLink];
                     UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                     activityViewControntroller.excludedActivityTypes = @[];
                     [VC presentViewController:activityViewControntroller animated:true completion:nil];

                     if (IDIOM == IPAD) {
                         activityViewControntroller.popoverPresentationController.sourceView =
                         VC.view;
                     }
                 });
                 

             }
             ////NSLog(@"responseObject =%@", responseObject);
         }
         else
         {
             //Handle error

         }
     }];

}

+ (UIColor *)colorWithHexString:(NSString *)str_HEX{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+(NSString *)fetchFontAwesomeString:(NSString *)unicodeString{
    NSScanner *scanner = [NSScanner scannerWithString:unicodeString];
    unsigned unicode;
    [scanner scanHexInt:&unicode];
    NSString *stringWithUnicodeChar = [NSString stringWithFormat:@"%C", (unichar)unicode];
    return stringWithUnicodeChar;
}

+(UIImage *)normalImage:(NSString *)imageName{
    UIImage *defaultImage = [UIImage imageNamed:[imageName lowercaseString]];
    if(defaultImage == nil)
        defaultImage = [UIImage imageNamed:@"truck"];
    return defaultImage;
}

+(UIImage *)mapImage:(NSString *)imageName{
    NSString *mapImageName = [NSString stringWithFormat:@"%@_map",
                              [imageName lowercaseString]];
    UIImage *defaultImage = [UIImage imageNamed:mapImageName];
    if(defaultImage == nil){
        defaultImage = [UIImage imageNamed:@"truck_map"];
        NSLog(@"image name =%@",mapImageName);
    }
    
    return defaultImage;
}

+(CGRect)FetchVehicleFrame:(NSString *)imageName1{
    
    NSString *imageName = [imageName1 lowercaseString];
    CGRect frame = CGRectMake(0, 0, 50, 50);
    if([imageName isEqualToString:@"car"] ||
       [imageName isEqualToString:@"taxi"]){
        frame = CGRectMake(0, 0, 35, 35);
    }
    return  frame;
}

+(CGRect)FetchVehicleFrameOnTracking:(NSString *)imageName1{
    
    NSString *imageName = [imageName1 lowercaseString];
    CGRect frame = CGRectMake(0, 0, 45, 45);
    if([imageName isEqualToString:@"car"] ||
       [imageName isEqualToString:@"taxi"]){
        frame = CGRectMake(0, 0, 30, 30);
    }
    return  frame;
}

+(void)shareLatLong:(NSDictionary *)vehicleDataDict forViewController:(TrackVehicleVC *)VC forButton:(UIButton *)btn{
    
    NSString *shareLink = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=&daddr=%lf,%lf",[vehicleDataDict[@"Latitude"] doubleValue],[vehicleDataDict[@"Longitude"] doubleValue]];
    
    NSArray *activityItems = @[shareLink];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    [VC presentViewController:activityViewControntroller animated:true completion:nil];

    if (IDIOM == IPAD) {
        activityViewControntroller.popoverPresentationController.sourceView =
       btn;
    }
}

+(UIColor *)vehicleColor:(NSDictionary *)dict{
    
    UIColor *defaultColor = [UIColor colorWithRed:143/255.0f green:144/255.0f blue:145/255.0f alpha:1];
    
    //Active
    if ([dict[@"VehicleState"] intValue]==1) {
        defaultColor = [UIColor colorWithRed:107/255.0f green:205/255.0f blue:78/255.0f alpha:1];
    }
    //Idle
    else if ([dict[@"VehicleState"] intValue]==2){
        defaultColor = [UIColor colorWithRed:255/255.0f green:143/255.0f blue:51/255.0f alpha:1];
    }
    //Inactive
    else if ([dict[@"VehicleState"] intValue]==4){
        defaultColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
       }
    else if ([dict[@"VehicleState"] intValue]==3){
        defaultColor = [UIColor redColor];
    }
    
    return defaultColor;
}

@end

