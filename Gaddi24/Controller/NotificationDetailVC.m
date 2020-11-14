//
//  NotificationDetailVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 02/04/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "NotificationDetailVC.h"
#import "Global.h"
#import "ConnectionHandler.h"
#import "VehicleListVC.h"
//#import "NotificationListVC.m"

@interface NotificationDetailVC ()<ConnectionHandlerDelegate>{
    ConnectionHandler *connectionHandler;

}

@end

@implementation NotificationDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    // Do any additional setup after loading the view.
}

-(void)initialsetup{
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"Notifications";
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
    
    //[rightButton1 setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    [rightButton1 addTarget:self action:@selector(showHomePage) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *rightbarButton=[[UIBarButtonItem alloc] init];
    [rightbarButton setCustomView:rightButton1];
    self.navigationItem.rightBarButtonItem=rightbarButton;
    
    /*
     [cell.lbl2 setText:dict[@"ViolationType"]];
     [cell.lbl3 setText:dict[@"DateTimeOfLog"]];
     */
    
    self.lbl1.text = self.notificationDict[@"ViolationType"];
    self.lbl2.text = self.notificationDict[@"DateTimeOfLog"];

    self.txtview.text = self.notificationDict[@"AlertMessage"];
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    [self readNotification];

    
}

-(void)readNotification{
    
    NSDictionary *requestDict = @{kApiRequest:[NSString stringWithFormat:@"User/NotificationRead/%@",self.notificationDict[@"ViolationId"]]};
    [connectionHandler makeConnectionWithRequest:requestDict];
    
}

-(void)receiveResponse:(id)responseDict{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (responseDict[kResponse]) {
        }
        
    });
}


- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    // Do whatever you want here
    //NSLog(@"%@", URL); // URL is an instance of NSURL of the tapped link
    return YES; // Return NO if you don't want iOS to open the link
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button action handling
-(void)btnBackClicked{
    
    //This will make sure that user has come from notification listing page
    if (self.notificationListDelegate) {
        if ([self.notificationDict[@"IsRead"] intValue]==0) {
            [self.notificationListDelegate updateNotificationList];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kNotificationPage}];
        }

    /*
    BOOL flgNotificationListExist = NO;
    
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *VC in array) {
        if ([VC isKindOfClass:[NotificationListVC class]]) {
            flgNotificationListExist = YES;
            break;
        }
    }
    
    
    //WE will check if notification list exist if yes then we will popup otherwise we will push
    if (flgNotificationListExist) {
        if ([self.notificationDict[@"IsRead"] intValue]==0) {
            [self.notificationListDelegate updateNotificationList];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
        NotificationListVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationListVC"];
        [self.navigationController pushViewController:VC animated:YES];
    */
    
}

-(void)showHomePage{
    //NSLog(@"Do nothing");
    /*[[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kDashboardPage}];*/
    
    NSArray *array = self.navigationController.viewControllers;
    
    for (UIViewController *VC in array) {
        if ([VC isKindOfClass:[VehicleListVC class]]) {
            [self.navigationController popToViewController:VC animated:YES];
            break;
        }
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
