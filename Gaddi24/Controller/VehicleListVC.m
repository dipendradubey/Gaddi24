//
//  VehicleListVC.m
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "VehicleListVC.h"
#import "Global.h"
#import "TableViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "UIView+Style.h"
#import "TrackVehicleVC.h"
#import "BirdViewVC.h"
#import "NotificationListVC.h"
#import "NSString+Localizer.h"
#import "ContactsScan.h"
#import "AppDelegate.h"
@import Firebase;

@interface VehicleListVC ()<UITableViewDataSource,UITableViewDelegate, ConnectionHandlerDelegate,UISearchBarDelegate>{
    ConnectionHandler *connectionHandler;
    NSArray *allVehicleArray;
    NSArray *filteredVehicleArray;
    NSArray *activeVehicleArray;
    NSArray *idleVehicleArray;
    NSArray *stopVehicleArray;
    NSArray *unavailableVehicleArray;
    NSArray *inActiveArray;
    ContactsScan *contactsScan;
    NSArray *arrContactList;

    short selectedButton; //1=All, 2=Active, 3=Idle, 4=Stop
    NSTimer *timer;
    AppDelegate *appDelegate;
    
}
@property(nonatomic,weak)IBOutlet NSLayoutConstraint *dividerwidthConstraint;

@property(nonatomic,weak)IBOutlet NSLayoutConstraint *dividerLeadinConstraint;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint *stackViewWidth;


@end

@implementation VehicleListVC
static const NSInteger NOTIFICATION_TAG = 1021;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(appDelegate.showBirdView){
           appDelegate.showBirdView = false;
           [self showAllVehicle];
       }
    
    //DKD added on 18 Apr 2020
    [self callApiForNotificationCount];
    [self callApiForMarqueeString];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [Util showLoader:@"" forView:self.view];
    
    selectedButton = 1;
    
    [self processRespose];
    
    [self fetchVehicleList];
    
    //By defalult time should be 30 sec
    if ([[Util retrieveDefaultForKey:kTimeInterval] integerValue] == 0) {
        [Util updateDefaultForKey:kTimeInterval toValue:@30];
    }
    
    //NSLog(@"Default time =%ld",[[Util retrieveDefaultForKey:kTimeInterval] integerValue]);
    
    timer = [NSTimer scheduledTimerWithTimeInterval:[[Util retrieveDefaultForKey:kTimeInterval] integerValue] target:self selector:@selector(fetchVehicleList) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self invaldateTimer];
}

-(void)invaldateTimer{
    [timer invalidate];
    timer = nil;
}

-(void)fetchVehicleList{
    NSDictionary *requestDict = @{kApiRequest:@"Vehicle/LiveData"};
    [connectionHandler makeConnectionWithRequest:requestDict];

}

-(void)initialsetup{
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    if(screenWidth > _stackViewWidth.constant){
        _stackViewWidth.constant = screenWidth;
    }
    
    contactsScan = [[ContactsScan alloc] init];
    contactsScan.contactScanDelegate = self;
    
    //Navigation bar setup
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"Dashboard";
    self.navigationItem.title = [@"ITEM_HOME" localizableString:@""];
    /*[self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]}];*/ //Roboto-Regular
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]}];
    
    //f0c9
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    //[leftButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [leftButton setTitle:@"\uf0c9" forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    leftButton.titleLabel.textColor = [UIColor whiteColor];
    [leftButton addTarget:self action:@selector(btnMenuClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbarButton=[[UIBarButtonItem alloc] init];
    [leftbarButton setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftbarButton;
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,80, 40)];
    rightView.backgroundColor = [UIColor clearColor];
    
    UIButton *rightButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton1.frame = CGRectMake(0, 0, 40, 40);
    [rightButton1 setImage:[UIImage imageNamed:@"videoicon.png"] forState:UIControlStateNormal];
    [rightButton1 addTarget:self action:@selector(showAllVehicle) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightButton1];
    
    
    UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton2.frame = CGRectMake(40, 0, 40, 40);
    [rightButton2 setImage:[UIImage imageNamed:@"full_bell_white.png"] forState:UIControlStateNormal];
    [rightButton2 addTarget:self action:@selector(showNotificationPage) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightButton2];
    
    
    //DKD added on 18 Apr 2020
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(57, 7, 18, 18)];
    label2.font = [UIFont systemFontOfSize:10]; //[UIFont boldSystemFontOfSize:9];
    label2.backgroundColor = [UIColor colorWithRed:54/255.0f green:92/255.0f blue:145/255.0f alpha:1];
    label2.textColor = [UIColor whiteColor];
    label2.hidden = true;
    label2.textAlignment = NSTextAlignmentCenter;
    [label2 updateStyleWithInfo:@{kBorderColor:label2.backgroundColor,kBorderWidth:@(1.0f),kCornerRadius:@(9)}];
    [rightView addSubview:label2];
    label2.tag = NOTIFICATION_TAG;
    
    UIBarButtonItem *rightbarButton=[[UIBarButtonItem alloc] init];
    [rightbarButton setCustomView:rightView];
    self.navigationItem.rightBarButtonItem=rightbarButton;
    
    
    self.tblView.estimatedRowHeight = 275;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    //Creating connection object
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    self.searchBar.placeholder = [@"HINT_SEARCH" localizableString:@""];

    [contactsScan retriveContactList];
    
}

#pragma mark -
#pragma mark ContactScan delegate method
-(void)receivedContact:(NSMutableArray *)arrMut{
    if ([arrMut count]>0) {
        arrContactList = [arrMut copy];
    }
    else{
        [Util hideLoader:self.view];
    }
    
    if(arrMut > 0){
        NSDictionary *dict = @{@"deviceIMEI": [Util getUniqueDeviceIdentifierAsString],
                               @"contacts":arrMut
                               };
        [connectionHandler makPostRequest:@{kApiRequest:@"Contact/SyncContact", kPostData:dict} withResponse:^(NSData *data, NSError *error) {
            NSLog(@"data =%@", data);
        }];
        
        
    }
    
}

-(void)showErrorMessage:(NSString *)errorMsg{
  [Util showAlert:@"" andMessage:errorMsg forViewController:self];
}



#pragma mark make connection to server and handle response

#pragma mark Connection response handling

//DKD added on 18 Apr 2020
-(void)callApiForNotificationCount{
    //NSDictionary *loginResponse = [Util retrieveDefaultForKey:kLoginResponse][0];
    
    NSString *api = [NSString stringWithFormat:@"%@User/UnReadNotificationCount",ApiPath];
    
    [connectionHandler makeGetRequest:api withResponse:^(NSData *data, NSError *error) {
        if (error == nil && data!= nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);

            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dict[@"IsError"] intValue]==0) {
                    UILabel *lbl1 = [self.navigationController.navigationBar viewWithTag:NOTIFICATION_TAG];
                    if ([dict[@"Message"] intValue]>0) {
                        lbl1.text = [NSString stringWithFormat:@"%d",[dict[@"Message"] intValue]];
                        lbl1.hidden = false;
                    }
                    else{
                        lbl1.hidden = true;
                    }
                }
            });
        }
    }];
    
}

//DKD added on 21 June 2020
-(void)callApiForMarqueeString{
    //NSDictionary *loginResponse = [Util retrieveDefaultForKey:kLoginResponse][0];
    //http://www.trackgaddi.com/api/v1/user/rightsandlinks
    NSString *api = [NSString stringWithFormat:@"%@user/rightsandlinks",ApiPath];
    
    [connectionHandler makeGetRequest:api withResponse:^(NSData *data, NSError *error) {
        if (error == nil && data!= nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);

            dispatch_async(dispatch_get_main_queue(), ^{
               if(dict)
                   [Util updateDefaultForKey:kMarqueeResult toValue:dict];
                    NSArray *arrMsgUser = dict[@"MessagesToUser"];
                    NSString *marqueeText = [arrMsgUser componentsJoinedByString:@"\t\t\t\t\t"];
                    marqueeText = [NSString stringWithFormat:@"\t\t\t\t\t%@",marqueeText];
                    self.lblMarqee.text = marqueeText;
            });
        }
    }];
    
}

-(void)receiveResponse:(id)responseDict{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([responseDict[kResponse] isEqual:[NSNull null]]|| responseDict[kResponse] == nil) {
            [Util showAlert:@"" andMessage:@"Oops! Something went wrong. We will take care of it soon." forViewController:self];
        }
        
        else if (responseDict[kResponse]) {
            ////NSLog(@"vehcile list =%@",responseDict[kResponse]);
            
            if ([responseDict[kResponse] isKindOfClass:[NSDictionary class]]) {
                [Util showAlert:@"" andMessage:responseDict[kResponse][@"Message"] forViewController:self];
            }
            else{
                allVehicleArray = responseDict[kResponse];
                [self processRespose];
            }
        }

        [Util hideLoader:self.view];
    });
}

-(void)processRespose{
    
    
    filteredVehicleArray = allVehicleArray;
    
    inActiveArray = [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"IsExpired == %d",1]];

    
    activeVehicleArray = [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"VehicleStateName == %@ AND IsExpired == %d",@"Active",0]];
    
    idleVehicleArray = [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"VehicleStateName == %@ AND IsExpired == %d",@"Idle", 0]];
        
    stopVehicleArray = [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"VehicleStateName == %@ AND IsExpired == %d",@"Stop", 0]];
    
    unavailableVehicleArray = [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"VehicleStateName == %@ AND IsExpired == %d",@"Unreachable", 0]];
    
    //self.lblCommandTime.text = [NSString stringWithFormat:[@"TV_COMMAND_COUNTDOWN" localizableString:@""],(int)(30-secs)];
    
    [self.btnAll setTitle:[NSString stringWithFormat:[@"TAB_ALL" localizableString:@""],(unsigned long)[allVehicleArray count]] forState:UIControlStateNormal];
    
    [self.btnActive setTitle:[NSString stringWithFormat:[@"TAB_ACTIVE" localizableString:@""],(unsigned long)[activeVehicleArray count]] forState:UIControlStateNormal];
    
    [self.btnIdle setTitle:[NSString stringWithFormat:[@"TAB_IDLE" localizableString:@""],(unsigned long)[idleVehicleArray count]] forState:UIControlStateNormal];
    
    [self.btnStop setTitle:[NSString stringWithFormat:[@"TAB_STOP" localizableString:@""],(unsigned long)[stopVehicleArray count]] forState:UIControlStateNormal];
    
    [self.btnUnavailable setTitle:[NSString stringWithFormat:[@"TAB_UNREACHABLE" localizableString:@""],(unsigned long)[unavailableVehicleArray count]] forState:UIControlStateNormal];
    
     [self.btnInActive setTitle:[NSString stringWithFormat:[@"TAB_INACTIVE" localizableString:@""],(unsigned long)[inActiveArray count]] forState:UIControlStateNormal];
    
    [self.btnAll sizeToFit];
    [self.btnActive sizeToFit];
    [self.btnIdle sizeToFit];
    [self.btnStop sizeToFit];
    [self.btnUnavailable sizeToFit];
    [self.btnInActive sizeToFit];
    
    
//    for (int btnTag = 1; btnTag<=6; btnTag++) {
//        [self updateButtonWidth:[self.view viewWithTag:btnTag]];
//    }
    
    
    CGFloat stackViewWidth = _btnAll.frame.size.width + _btnActive.frame.size.width + _btnIdle.frame.size.width + _btnStop.frame.size.width + _btnUnavailable.frame.size.width + _btnInActive.frame.size.width;
      _stackViewWidth.constant = stackViewWidth;
    
    
    if (selectedButton == 1) {
        [self btnVehicleStateClicked:self.btnAll];
    }
    else if (selectedButton == 2){
        [self btnVehicleStateClicked:self.btnActive];
    }
    else if (selectedButton == 3){
        [self btnVehicleStateClicked:self.btnIdle];
    }
    else if (selectedButton == 4){
        [self btnVehicleStateClicked:self.btnStop];
    }
    else if (selectedButton == 5){
        [self btnVehicleStateClicked:self.btnUnavailable];
    }
    else if (selectedButton == 6){
        [self btnVehicleStateClicked:self.btnInActive];
    }

  
    
//    _btnAll.backgroundColor = [UIColor redColor];
//    _btnActive.backgroundColor = [UIColor yellowColor];
//    _btnIdle.backgroundColor = [UIColor cyanColor];
//    _btnStop.backgroundColor = [UIColor blackColor];
//    _btnUnavailable.backgroundColor = [UIColor orangeColor];
//    _btnInActive.backgroundColor = [UIColor blueColor];
    
    
}


#pragma mark Tableview datasource and delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [filteredVehicleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *dict = filteredVehicleArray[indexPath.row];
    
    [cell.view1 updateStyleWithInfo:@{kBorderColor:[UIColor clearColor],kCornerRadius:@(cell.view1.frame.size.width/2),kBorderWidth:@0}];
    
    [cell.view1 setBackgroundColor:[UIColor colorWithRed:143/255.0f green:144/255.0f blue:145/255.0f alpha:1]];
    //Active
    if ([dict[@"VehicleState"] intValue]==1) {
        [cell.view1 setBackgroundColor:[UIColor colorWithRed:107/255.0f green:205/255.0f blue:78/255.0f alpha:1]];
    }
    //Idle
    else if ([dict[@"VehicleState"] intValue]==2){
        [cell.view1 setBackgroundColor:[UIColor colorWithRed:255/255.0f green:143/255.0f blue:51/255.0f alpha:1]];
    }
    //Inactive
    else if ([dict[@"VehicleState"] intValue]==4){
           [cell.view1 setBackgroundColor:[UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1]];
       }
    else if ([dict[@"VehicleState"] intValue]==3){
        [cell.view1 setBackgroundColor:[UIColor redColor]];
    }
    
    cell.lbl1.text = dict[@"VehicleName"];
    cell.lbl2.text = dict[@"DateTimeOfLog"];
    /*cell.lbl2.text = [Util universalDateFormate:@{kActualDateFormate:@"dd/MM/yyyy h:mm:ss",kRequiredDateFormate:@"dd/MM/yyyy HH:mm a",kDate:dict[@"DateTimeOfLog"]}];//[Util updateDateFormate:dict[@"DateTimeOfLog"]] ;*/
    
    cell.imageView1.image = [UIImage imageNamed:@"battery_red.png"];
    if ([dict[@"BatteryStatus"] intValue]==1) {
        cell.imageView1.image = [UIImage imageNamed:@"battery_green.png"];
    }
    
    cell.imageView2.image = [UIImage imageNamed:@"ac_idle.png"];
     if ([dict[@"ACStatus"] intValue]==1) {
    cell.imageView2.image = [UIImage imageNamed:@"ac_normal.png"];
     }
    
    BOOL flgExpired = [dict[@"IsExpired"] boolValue];
    
    if(flgExpired)
        cell.view1.backgroundColor = self.navigationController.navigationBar.barTintColor;
    
    [cell.contentView setBackgroundColor: flgExpired ?  [UIColor colorWithRed:255/255.0f green:255/255.0f blue:0/255.0f alpha:.1] :
     [UIColor whiteColor]];
    cell.imageView1.hidden = flgExpired;
    cell.imageView2.hidden = flgExpired;
    cell.customButton1.hidden = !flgExpired;
    cell.customButton1.infoDict = dict;
    [cell.customButton1 setTitle:[@"BTN_RENEW" localizableString:@""] forState:UIControlStateNormal];
    
    cell.imageView3.image = [Util normalImage:dict[@"VehicleType"]];
    cell.imageView3.tintColor = cell.view1.backgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    
    if([filteredVehicleArray[indexPath.row][@"IsExpired"] boolValue])
        return;
        
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    TrackVehicleVC *VC = [storyBoard instantiateViewControllerWithIdentifier:@"TrackVehicleVC"];
    VC.allVehicleArray =  [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"IsExpired == %d",0]];
    VC.selectedVehicleDict = filteredVehicleArray[indexPath.row];
    [self.navigationController pushViewController:VC animated:YES];
}



#pragma mark Button action handling
-(IBAction)btnVehicleStateClicked:(UIButton *)button{
    
    
    
    _dividerwidthConstraint.constant = button.frame.size.width - 5;
    
    _dividerLeadinConstraint.constant = 10 + button.frame.origin.x + ((button.frame.size.width - _dividerwidthConstraint.constant)/2);
    
    [self defaultColor];

    //All button clicked
    if (button.tag ==1) {
        filteredVehicleArray = allVehicleArray;
        selectedButton = 1;
        [self.btnAll setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
    }
    //Active button clicked
    else if (button.tag ==2) {
        filteredVehicleArray = activeVehicleArray;
        selectedButton = 2;
        [self.btnActive setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
    }
    //Idle button clicked
    else if (button.tag ==3) {
        filteredVehicleArray = idleVehicleArray;
        selectedButton = 3;
        [self.btnIdle setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
    }
    //Stop button clicked
    else if (button.tag ==4) {
        filteredVehicleArray = stopVehicleArray;
        selectedButton = 4;
        [self.btnStop setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
    }
    //Unreachable button clicked
    else if (button.tag ==5) {
        filteredVehicleArray = unavailableVehicleArray;
        selectedButton = 5;
        [self.btnUnavailable setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
    }
    //Inactive button clicked
    else if (button.tag ==6) {
        filteredVehicleArray = inActiveArray;
        selectedButton = 6;
        [self.btnInActive setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
    }
    
    [self.tblView reloadData];
    
    [self.searchBar resignFirstResponder];
    
    self.searchBar.text = @"";
    
}

-(void)defaultColor{
    [self.btnAll setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
    [self.btnActive setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
    [self.btnIdle setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
    [self.btnStop setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
    [self.btnUnavailable setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
    [self.btnInActive setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];

}


-(void)showAllVehicle{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    BirdViewVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"BirdViewVC"];
    VC.allVehicleArray = [allVehicleArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"IsExpired == %d",0]];
    [self.navigationController pushViewController:VC animated:NO];
}


#pragma mark Button Renew Clicked
-(IBAction)btnRenewClicked:(CustomButton *)customButton{
    //http://trackgaddi.com/api/v1/Vehicle/Renew/
    
    [Util showLoader:@"" forView:self.view];
    
    NSString *api = [NSString stringWithFormat:@"%@Vehicle/Renew/%d",ApiPath, [customButton.infoDict[@"VehicleId"] intValue]];
     [connectionHandler makeGetRequest:api withResponse:^(NSData *data, NSError *error) {
         if (error == nil && data!= nil) {
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
             NSLog(@"%@",dict);

             dispatch_async(dispatch_get_main_queue(), ^{
                 [Util hideLoader:self.view];
                 BOOL flgSuccess = false;
                 if ([dict[@"IsError"] intValue] == 0) {
                    [Util updateDefaultForKey:kCommandDate toValue:[NSDate date]];
                    flgSuccess = true;
                }
                 if (flgSuccess) {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                                message:dict[@"Message"]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_OK" localizableString:@""] style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                        [self fetchVehicleList];

                    }];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                 else
                     [Util showAlert:@"" andMessage:dict[@"Message"] forViewController:self];
                 
            });
         }
     }];
}

#pragma mark Search bar delegate method

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    //NSLog(@"serach text");
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"VehicleName CONTAINS [cd] %@ ",searchText];
    
    NSArray *tempArray = nil;
    if (selectedButton == 1) {
        tempArray = allVehicleArray;
    }
    else if (selectedButton == 2) {
        tempArray = activeVehicleArray;
    }
    else if (selectedButton == 3) {
        tempArray = idleVehicleArray;
    }
    else if (selectedButton == 4) {
        tempArray = stopVehicleArray;
    }
    
    //We will integrate filtering when only search text is bigger
    if (searchText.length>0) {
         filteredVehicleArray = [tempArray filteredArrayUsingPredicate:predicate];
    }
    else{
        filteredVehicleArray = tempArray;
    }
    
    //NSLog(@"filteredVehicleArray =%@",filteredVehicleArray);
    
    [self.tblView reloadData];
    
    
}


- (IBAction)btnMenuClicked {
   [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)showNotificationPage{
    //NSLog(@"Do nothing");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
    NotificationListVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationListVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
