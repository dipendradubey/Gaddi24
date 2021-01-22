//
//  Global.h
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#ifndef Global_h
#define Global_h

//#define LiveApi

//static NSString *const GOOGLE_API_KEY = @"AIzaSyA4sIg6uDtqFu13BCA-vZtYV8-PfERQYb8";


#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

static const NSInteger DASHBOARD_TAG = 1021;
static const NSInteger BIRDVIEW_TAG = 1022;

static NSString *const GOOGLE_API_KEY = @"AIzaSyDyOd6SupKcM3YhisYN-WIMXcRazw8KJZg";


static NSString * const kUserId = @"inUserId";
static NSString * const kUserToken = @"stToken";
static NSString * const kDeviceToken = @"stDeviceToken";
static NSString *const SHARE_REQUIRED_DATE = @"dd-MM-yyyy HH_mm_ss";


static NSString * const kCornerRadius = @"kCornerRadius";
static NSString * const kBorderColor = @"kBorderColor";
static NSString * const kBorderWidth = @"kBorderWidth";
static NSString * const kBgColor = @"kBgColor";
static NSString * const kMarqueeResult = @"kMarqueeResult";


static NSString * const kUrl = @"kImageUrl";

static NSString * const kLoginResponse = @"kLoginResponse";

//static NSString * const ApiPath = @"http://www.trackgaddi.com:81/api/v1/";
static NSString * const ApiPath = @"http://www.gaddi24.com/api/v1/";
static NSString * const ApiPath_V2 = @"http://www.gaddi24.com/api/v2/";
static NSString * const ShareApiPath = @"http://www.gaddi24.com/api/v1/ShareVehicle/ShareVehicleLink/";


static NSString * const kApiName = @"kApiName";
static NSString * const kData = @"kData";
static NSString * const kApiRequest = @"kApiRequest";
static NSString * const kPostData = @"kPostData";

static NSString * const kRequest = @"kRequest";
static NSString * const kRequestFor = @"kRequestFor";

static NSString * const kResponse = @"kResponse";

static NSString * const kTimeInterval = @"kTimeInterval";
static NSString * const kHomeScreen = @"kHomeScreen";
static NSString * const kLanguage = @"kLanguage";


static NSString * const kMenuNotification = @"kMenuNotification";
static NSString * const kShowPage = @"kShowPage";
static NSString * const kNotification = @"kNotification";


static NSString * const kDashboardPage = @"Dashboard";

static NSString * const kBirdViewPage = @"Birdview";

static NSString * const kNotificationPage = @"NotificationListVC";

static NSString * const kUpdateNotificationDetail = @"kUpdateNotificationDetail";

static NSString *const RELOAD_MENUPAGE = @"ReloadMenu";


static NSString * const kLogout = @"Logout";


static NSString * const kDefaultErrorMsg = @"Your internet connection may be down or our servers may be inaccessible. Please try again later.";

static NSString * const kCommandDate = @"kCommandDate";

static NSString * const kTrackVehicleNotification = @"kTrackVehicleNotification";

static NSString * const kActualDateFormate = @"kActualDateFormate";

static NSString * const kRequiredDateFormate = @"kRequiredDateFormate";

static NSString * const kDate = @"kDate";

static NSString * const kDonotshow = @"kDonotshow";

static NSString * const kLoginDate = @"kLoginDate";
static NSString * const kLogoutNotification = @"kLogoutNotification";



#define DEFAULT_COLOR [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1]
#define SELECTED_COLOR [UIColor colorWithRed:255.0/255.0f green:156.0/255.0f blue:55.0/255.0f alpha:1]

#endif /* Global_h */
