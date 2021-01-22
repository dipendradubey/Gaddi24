//
//  MenuVC.m
//  Appraisal
//
//  Created by Dipendra Dubey on 11/02/16.
//  Copyright (c) 2016 Pulse. All rights reserved.
//

#import "MenuVC.h"
#import "TableViewCell.h"
#import "global.h"
#import "UIViewController+MMDrawerController.h"
#import "LoginVC.h"
#import "Util.h"
#import "ReportVC.h"
#import "NotificationDetailVC.h"
#import "ConnectionHandler.h"
#import "NSString+Localizer.h"

@interface MenuVC ()

@property (nonatomic,strong)NSMutableArray *menuMutArray;
@property (nonatomic,strong)NSArray *menuArray;
@property (nonatomic,strong)NSString *currentTitle;
@property (nonatomic,strong)NSDictionary *eventDict;

@end

@implementation MenuVC

static NSString * const kTitle = @"kTitle";
static NSString * const kFontAwsomeText = @"kFontAwsomeText";
static NSString *const kCellName = @"kCellName";
static NSString *const kNotificationDetail = @"kNotificationDetail";
static NSString *const NOTIFICATION_DETAIL_PAGE = @"NOTIFICATION_DETAIL_PAGE";



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialsetup];

	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)initialsetup{
    
    self.menuMutArray = [[NSMutableArray alloc]init];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
    
    //Dynamic
    self.tableView.estimatedRowHeight = 50.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //This will stop tableview to scroll when content fit in screen
    self.tableView.alwaysBounceVertical = NO;
    
     [self menuSetup:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPage:) name:kMenuNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotificationDetailPage:) name:kUpdateNotificationDetail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuSetup:) name:RELOAD_MENUPAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayFCMToken:)
                                                 name:@"FCMToken"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceLogout:) name:kLogoutNotification object:nil];
    
}
-(void)menuSetup:(id)data{
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    NSString *strVersion = [NSString stringWithFormat:@"Version %@",appVersionString];
    
    self.menuArray= @[@{kCellName:@"Cell0", kTitle:strVersion},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_HOME" localizableString:@""],kFontAwsomeText:@"\uf009"},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_REPORTS" localizableString:@""],kFontAwsomeText:@"\uf080"},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_CONTACT_US" localizableString:@""],kFontAwsomeText:@"\uf095"},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_MY_ACCOUNT" localizableString:@""],kFontAwsomeText:@"\uf2bd"},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_PAY" localizableString:@""],kFontAwsomeText:@"\uf156"},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_SETTINGS" localizableString:@""],kFontAwsomeText:@"\uf013"},
                      @{kCellName:@"Cell1",kTitle:[@"ITEM_LOGOUT" localizableString:@""],kFontAwsomeText:@"\uf08b"}];

    
    [self.tableView reloadData];
}


#pragma mark Tableview datasource and delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.menuArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = self.menuArray[indexPath.row];
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dict[kCellName]];
    
    cell.lbl1.font = [UIFont fontWithName:@"FontAwesome" size:25];
    
    cell.lbl1.text = dict[kFontAwsomeText];
    
    cell.lbl1.textColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0];
    
    cell.lbl2.text = dict[kTitle];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row>0) {
        NSDictionary *dict = self.menuArray[indexPath.row];
        NSString *title = dict[kTitle];
        [self selectOption:title];
       
    }
}


#pragma mark Redirect user

-(void)selectOption:(NSString *)title{
    
    if ([title isEqualToString:kLogout] ||[title isEqualToString:[@"ITEM_LOGOUT" localizableString:@""]]){
        [self showLoginPage];
    }
    else{
        UIViewController *centerViewController;
        
        UIStoryboard *storyboard = nil;
        NSString *storyboardId = @"";
        
        if ([title isEqualToString:[@"ITEM_REPORTS" localizableString:@""]]) {
            storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
            storyboardId = @"ReportVC";
        }
        else if ([title isEqualToString:kNotificationPage]) {
            storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
            storyboardId = kNotificationPage;
        }
        else if ([title isEqualToString:[@"ITEM_SETTINGS" localizableString:@""]]) {
            storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            storyboardId = @"SettingVC";
        }
       else if ([title isEqualToString:[@"ITEM_CONTACT_US" localizableString:@""]]) {
            storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
            storyboardId = @"ContactVC";
        }
        else if ([title isEqualToString:[@"ITEM_MY_ACCOUNT" localizableString:@""]]) {
           storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
           storyboardId = @"AccountVC";
       }
        else if ([title isEqualToString:kDashboardPage] || [title isEqualToString:[@"ITEM_HOME" localizableString:@""]]) {
            storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            storyboardId = @"VehicleListVC";
        }
        else if ([title isEqualToString:[@"ITEM_PAY" localizableString:@""]]) {
            storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            storyboardId = @"WebVC";
        }
        
        centerViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
        
        if (centerViewController) {
            self.currentTitle = title;
            
            //NSLog(@"navigtaioncontroller =%@",centerViewController.navigationController);
            
            UINavigationController *nav = nil;
            
            nav = [[UINavigationController alloc]initWithRootViewController:centerViewController];
            
            [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
            
            [self.tableView reloadData];
        }
        else {
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        }
    }
}

-(void)showComingSoon{
    [Util showAlert:@"" andMessage:@"Coming soon" forViewController:self];
    return;
}

-(void)showPage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    [self selectOption:userInfo[kShowPage]];
    
}

-(void)showLoginPage{
    
    if ([Util retrieveDefaultForKey:kDeviceToken]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //DKD added this on 07 July 2019 as now method is updated to POST
            if ([Util retrieveDefaultForKey:kDeviceToken]) {
                NSString *apiRequest = [NSString stringWithFormat:@"user/unregisterdevice"];
                NSDictionary *postData = @{@"token":[Util retrieveDefaultForKey:kDeviceToken],@"imei":[Util getUniqueDeviceIdentifierAsString]};
                ConnectionHandler *connectionHandler = [[ConnectionHandler alloc] init];
                NSDictionary *requestDict = @{kApiRequest:apiRequest,kPostData:postData};
                [connectionHandler makeConnectionForTokenHandling:requestDict];
            }
            
            
            //DKD commneted this on 07 July 2019 as now method is updated to POST
            /*
             NSString *urlString = [NSString stringWithFormat:@"%@user/unregisterdevice/%@",ApiPath,[Util retrieveDefaultForKey:kDeviceToken]];
             NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
             
             if (data){
             NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"dataString =%@",dataString);
             }
             */
            
            //NSLog(@"unregister response =%@", responseObject);
        });
    }
    
    
    [Util removeValueFromDefault:kLoginResponse];
    
    NSArray *vcArray = self.mm_drawerController.navigationController.viewControllers;
    
    BOOL flgLoginPageFound = NO;
    
    for (UIViewController *VC in vcArray) {
        if ([VC isKindOfClass:[LoginVC class]]) {
            [self.navigationController popToViewController:VC animated:YES];
            flgLoginPageFound = YES;
            break;
        }
    }
    
    if (!flgLoginPageFound) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
        LoginVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:VC animated:NO];
    }
    
}

#pragma mark handling notification received

-(void)forceLogout:(NSNotification *)notification{
    [self showLoginPage];
}

-(void)showNotificationDetailPage:(NSNotification *)notification{
    
    NSDictionary *userInfo = notification.userInfo;
    
    //First check if notification has notificationinfo if yes then only send notification
    if (userInfo[@"notificationinfo"]!=nil){
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
    
    NotificationDetailVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationDetailVC"];
    
    VC.notificationDict = userInfo[@"notificationinfo"];
    
    UINavigationController *nav = nil;
        
    nav = [[UINavigationController alloc]initWithRootViewController:VC];
        
    [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
    }
    
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) displayFCMToken:(NSNotification *) notification {
    
    //We can upload token to server
    
//    NSString* message =
//    [NSString stringWithFormat:@"Received FCM token: %@", notification.userInfo[@"token"]];
//
//    NSLog(@"%@",message);
//
//    [Util updateDefaultForKey:kDeviceToken toValue:notification.userInfo[@"token"]];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *urlString = [NSString stringWithFormat:@"%@user/registerdevice/%@",ApiPath,[Util retrieveDefaultForKey:kDeviceToken]];
//        NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
//
//        NSError *error = nil;
//
//        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//
//        //NSLog(@"registerDevice =%@", responseObject);
//    });
}

@end
