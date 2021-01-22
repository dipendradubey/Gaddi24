//
//  AppDelegate.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

#import "AppDelegate.h"
#import "RootVC.h"
#import "Global.h"
#import "Util.h"
#import <UserNotifications/UserNotifications.h>
#import "Global.h"
#import "ConnectionHandler.h"
#import "NotificationDetailVC.h"

@import Firebase;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@import GoogleMaps;

@interface AppDelegate ()<UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate
NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if([Util retrieveDefaultForKey:kLanguage]== nil)
        [Util updateDefaultForKey:kLanguage toValue:@"en"];
    
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    [self registerForRemoteNotification:application];
    
    //Hi
    
    //This will make badge icon count to 0
    application.applicationIconBadgeNumber = 0;
    
    
    
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    [mutArray insertObject:@"0" atIndex:0];
    [mutArray insertObject:@"1" atIndex:1];
    
    
    //NSString *apistring =@"http://www.trackgaddi.com/api/v1/ReportsData/2/729/24-04-2017 00_00_00/null/null";
    //apistring = [apistring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"apistring =%@",apistring);
    
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    
    RootVC *rootVC = [[RootVC alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
    [self.window setRootViewController:nav];
    
    //[self performSelector:@selector(navigateToNotificationDetail:) withObject:@{@"notification_info":@"abc"} afterDelay:5.0];
    
    return YES;
}

- (void)registerForRemoteNotification:(UIApplication *)application {
    
    /*
     // iOS 10 or later
     #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
     UNAuthorizationOptions authOptions =
     UNAuthorizationOptionAlert
     | UNAuthorizationOptionSound
     | UNAuthorizationOptionBadge;
     [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
     }];
     
     // For iOS 10 display notification (sent via APNS)
     [UNUserNotificationCenter currentNotificationCenter].delegate = self;
     // For iOS 10 data message (sent via FCM)
     [FIRMessaging messaging].remoteMessageDelegate = self;
     */
    /*
     UIUserNotificationType allNotificationTypes =
     (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
     UIUserNotificationSettings *settings =
     [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
     [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
     */
    
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
             // ...
         }];
    }
    
    [application registerForRemoteNotifications];
}


#pragma mark - Remote Notification Delegate // <= iOS 9.x

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    ////NSLog(@"Device Token = %@",strDevicetoken);
    
    /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token" message:strDevicetoken delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     [alert show];*/
    
    
    //[Util updateDefaultForKey:kDeviceToken toValue:strDevicetoken];
    
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    /*
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"willPresentNotification" message:[NSString stringWithFormat:@"%@",[userInfo description]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     [alertView show];
     */
    
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    //completionHandler(UNNotificationPresentationOptionNone);
    //completionHandler(UNNotificationPresentationOptionAlert);
    completionHandler(UNNotificationPresentationOptionAlert);
    
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    
    
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"didReceiveNotificationResponse" message:[NSString stringWithFormat:@"%@",[userInfo description]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //    [alertView show];
    
    
    if ([Util  retrieveDefaultForKey:kLoginResponse]) {
        [self performSelector:@selector(navigateToNotificationDetail:) withObject:userInfo afterDelay:1.0];
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler();
}


// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    
    [Util updateDefaultForKey:kDeviceToken toValue:fcmToken];
    
    //Check if user is looged in then directly update token else let's update, once successful login is made
    
    if ([Util  retrieveDefaultForKey:kLoginResponse]) {
        
        //Upload token to server
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             NSString *urlString = [NSString stringWithFormat:@"%@user/registerdevice/%@",ApiPath,[Util retrieveDefaultForKey:kDeviceToken]];
             NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
             if (data){
             NSLog(@"upload token response =%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             }
             */
            NSString *apiRequest = [NSString stringWithFormat:@"user/registerdevice"];
            NSDictionary *postData = @{@"token":[Util retrieveDefaultForKey:kDeviceToken],@"imei":[Util getUniqueDeviceIdentifierAsString]};
            
            NSDictionary *requestDict = @{kApiRequest:apiRequest,kPostData:postData};
            ConnectionHandler *connectionHandler = [[ConnectionHandler alloc] init];
            
            [connectionHandler makeConnectionForTokenHandling:requestDict];
            
        });
        
    }
    
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
//- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
//    NSLog(@"Received data message: %@", remoteMessage.appData);
//}


// [END ios_10_data_message]




- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}


-(void)tempmethod{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kUpdateNotificationDetail object:nil userInfo:@{@"notificationinfo":@{@"IsRead":@"0",@"ViolationId":@"300130",@"AlertMessage":@"Tracking device is disconnected from Vehicle GJ16W9154. At http://maps.google.com/maps?q=21.6233716666667,73.03773",@"DateTimeOfLog":@"19-May-2017 8:09:35",@"ViolationType":@"Disconnected"}}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark NavigateTouser to notification detail

-(void)navigateToNotificationDetail:(NSDictionary *)userInfo{
    
    //Check if there is notification_info in push notification
    if (userInfo[@"notification_info"] == nil) {
        return;
    }
    
    NSData* data = [userInfo[@"notification_info"] dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (dataDict) {
            UIViewController *lastVC = [Util fetchLastViewcontroller];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
            
            NotificationDetailVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationDetailVC"];
            VC.notificationDict = dataDict;//userInfo[@"notification_info"];
            
            for (UIViewController  *VC in lastVC.navigationController.viewControllers) {
                if ([VC isKindOfClass:[NotificationDetailVC class] ]) {
                    [lastVC.navigationController popViewControllerAnimated:NO];
                    break;
                }
            }
            NSLog(@"naviagtionVC =%@",lastVC.navigationController);
            [lastVC.navigationController pushViewController:VC animated:YES];
        }
    }
}


@end
