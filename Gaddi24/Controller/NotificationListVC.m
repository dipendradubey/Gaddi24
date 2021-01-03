//
//  NotificationListVC.m
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "NotificationListVC.h"

#import "Global.h"
#import "TableViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "UIView+Style.h"
#import "NotificationDetailVC.h"
#import "VehicleListVC.h"
#import "NSString+Localizer.h"


@interface NotificationListVC ()<UITableViewDataSource,UITableViewDelegate, ConnectionHandlerDelegate, NotificationListDelegate>{
    ConnectionHandler *connectionHandler;
    NSArray *arrNotification;
    
}



@property(nonatomic,weak)IBOutlet NSLayoutConstraint *dividerCenterConstraint;

@end

@implementation NotificationListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}
    
-(void)initialsetup{
    
    //Navigation bar setup
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    
     //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    
    //39, 41, 47
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = [@"TV_NOTIFICATIONS" localizableString:@""];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]}];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(btnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbarButton=[[UIBarButtonItem alloc] init];
    [leftbarButton setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftbarButton;
    
    
    
    UIButton *rightButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton1.frame = CGRectMake(0, 0, 40, 40);
    [rightButton1 setTitle:@"\uf015" forState:UIControlStateNormal];
    rightButton1.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    rightButton1.titleLabel.textColor = [UIColor whiteColor];
    [rightButton1 addTarget:self action:@selector(showHomePage) forControlEvents:UIControlEventTouchUpInside];
    
    //DKD added on 18 Apr 2020
    UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton2.frame = CGRectMake(40, 0, 40, 40);
    [rightButton2 setTitle:@"\uf2b6" forState:UIControlStateNormal]; //f064 f0c9
    rightButton2.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    rightButton2.titleLabel.textColor = [UIColor yellowColor];
    [rightButton2 addTarget:self action:@selector(btnReadAllNotification) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,80, 40)];
    rightView.backgroundColor = [UIColor clearColor];
    [rightView addSubview:rightButton1];
    [rightView addSubview:rightButton2];
    
    UIBarButtonItem *rightbarButton=[[UIBarButtonItem alloc] init];
    [rightbarButton setCustomView:rightView];
    self.navigationItem.rightBarButtonItem=rightbarButton;

    
    
    self.tblView.estimatedRowHeight = 275;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    //Creating connection object
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    [self updateNotificationList];
}

//DKD added on 18 Apr 2020
-(void)btnReadAllNotification{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:[@"ALERT_MARK_ALL_READ" localizableString:@""]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_OK" localizableString:@""] style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                             NSDictionary *requestDict = @{kApiRequest:@"User/AllNotificationRead"};
                                                            [self->connectionHandler makeConnectionWithRequest:requestDict];
                                                            [Util showLoader:@"" forView:self.view];
                                                              
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_CANCEL" localizableString:@""] style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)updateNotificationList{
    [Util showLoader:@"" forView:self.view];
    [self fetchNotificationList];
}

#pragma mark make connection to server and handle response

#pragma mark Connection response handling

-(void)fetchNotificationList{
    NSDictionary *requestDict = @{kApiRequest:@"User/notifications"};
    [connectionHandler makeConnectionWithRequest:requestDict];
    
}

//DKD updated on 18 Apr 2020
-(void)receiveResponse:(id)responseDict{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL hideLoader = true;
        
        if ([responseDict[kResponse] isEqual:[NSNull null]] || responseDict[kResponse] == nil){
            [self alertUserTotakeBack:@"Oops! Something went wrong. We will take care of it soon."];

        }
         else if ([responseDict[kRequest][kApiRequest] isEqualToString:@"User/AllNotificationRead"]){
             if ([responseDict[kResponse][@"IsError"] intValue]==0) {
                 hideLoader = false;
                 [self fetchNotificationList];
             }
         }
        else if ([responseDict[kResponse] isKindOfClass:[NSArray class]]) {
            self->arrNotification = responseDict[kResponse];
            if ([self->arrNotification count]==0) {
                [self alertUserTotakeBack:@"No notifications."];
            }
            
            [self.tblView reloadData];
        }
        
        if (hideLoader)
            [Util hideLoader:self.view];
        
    });
}

-(void)alertUserTotakeBack:(NSString *)msg{
    //No notifications.
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self btnBackClicked];
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark Tableview datasource and delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrNotification count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *dict = arrNotification[indexPath.row];
    
    [cell.lbl1 setText:@"\uf2b7"];
    [cell.lbl2 setFont:[UIFont systemFontOfSize:19.0f]];
    [cell.lbl2 setText:[NSString stringWithFormat:@"%@ (%@)",dict[@"VehicleName"],dict[@"ViolationType"]]];
    [cell.lbl3 setText:dict[@"DateTimeOfLog"]];
    
    //Unread
    if ([dict[@"IsRead"] intValue]==0) {
        [cell.lbl1 setText:@"\uf003"];
        [cell.lbl2 setFont:[UIFont boldSystemFontOfSize:19.0f]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];*/
    NotificationDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationDetailVC"];
    VC.notificationDict = arrNotification[indexPath.row];
    VC.notificationListDelegate = self;
    [self.navigationController pushViewController:VC animated:YES];
}



#pragma mark Button action handling

- (IBAction)btnMenuClicked {
   [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)btnBackClicked{
    //[self.navigationController popViewControllerAnimated:YES];
    
    BOOL flgHomePage = YES;
    
    NSArray *navigationArray = self.navigationController.viewControllers;
    
    for (UIViewController *VC in navigationArray) {
        if ([VC isKindOfClass:[VehicleListVC class]]) {
            [self.navigationController popToViewController:VC animated:YES];
            flgHomePage = NO;
            break;
        }
    }
    
    if (flgHomePage == YES) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kDashboardPage}];
    }
    
    
}

-(void)showHomePage{
    [self btnBackClicked];
}

-(void)showNotificationPage{
    //NSLog(@"Do nothing");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
