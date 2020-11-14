//
//  CommandVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "CommandVC.h"
#import "TableViewCell.h"
#import "CollectionViewCell.h"
#import "Global.h"
#import "VehicleListVC.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "TrackVehicleVC.h"
#import "PlaybackVC.h"
#import "PlaybackVC.h"
#import "SummaryVC.h"
#import "UIView+Style.h"
#import "NSString+Localizer.h"

@interface CommandVC ()<UITableViewDelegate,UITableViewDataSource,ConnectionHandlerDelegate>{
    NSArray *staticArray;
    NSUInteger selectedOption;
    ConnectionHandler *connectionHandler;
    int inCommandStatus; //1 = Enabled, 2 = Disabled
    NSTimer *timer;
    NSArray *arrCommandList;
    
    UIColor *setColor;
    UIColor *setBgColor;
    
    UIColor *queueColor;
    UIColor *queueBgColor;
    
    UIColor *failedColor;
    UIColor *failedBgColor;
       
    UIColor *expColor;
    UIColor *expBgColor;
    
    NSArray *titleArray;
}

@end

//static NSString * const titleArray[4] = {@"Cut-off Engine",@"Restore Engine",@"Cut-off AC",@"Restore AC"};
static NSString * const imageArray[4] = {@"Cutoff_Engine.png",@"Restore_Engine.png",@"ac_idle.png",@"ac_normal.png"};
static NSString * const disableImageArray[4] = {@"Cutoff_Engine.png",@"Cutoff_Engine.png",@"ac_idle.png",@"ac_idle.png"};
static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";

static NSString * const CommandCell = @"CommandCell";
static NSString * const TimeCell = @"TimeCell";
static NSString * const StaticCell = @"StaticCell";
static NSString * const CommandHistoryCell = @"CommandHistoryCell";

static NSString * const COMMAND_SET = @"Set";
static NSString * const COMMAND_QUEUE = @"InQueue";
static NSString * const COMMAND_FAILED = @"Failed";
static NSString * const COMMAND_EXPIRED = @"Expired";

@implementation CommandVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    if(!timer){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCommandTime) userInfo:nil repeats:YES];
        [self updateCommandTime];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

-(void)initialsetup{
    
    titleArray = @[[@"TV_CUT_OFF_ENGINE" localizableString:@""], [@"TV_RESTORE_ENGINE" localizableString:@""],[@"TV_CUT_OFF_AC" localizableString:@""],[@"TV_RESTORE_AC" localizableString:@""]];
    

    setColor = [UIColor colorWithRed:0 green:103/255.0f blue:0 alpha:1];
    setBgColor = [UIColor colorWithRed:0 green:103/255.0f blue:0 alpha:0.3];
    
    //204,162,34 138,110,23
    queueColor = [UIColor colorWithRed:138/255.0f green:110/255.0f blue:23/255.0f alpha:1];
    queueBgColor = [UIColor colorWithRed:204/255.0f green:162/255.0f blue:34/255.0f alpha:0.4];
    
    failedColor = [UIColor colorWithRed:179/255.0f green:0/255.0f blue:0/255.0f alpha:1];
    failedBgColor = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:0.3];
    
    expColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:48/255.0f alpha:1];
    expBgColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:48/255.0f alpha:0.3];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = self.selectedVehicleDict[@"VehicleName"];
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

    
    staticArray = @[@{kTitleName:[@"ITEM_TRACK" localizableString:@""],kFontAwsomeName:@"\uf278"},
    @{kTitleName:[@"ITEM_HISTORY" localizableString:@""],kFontAwsomeName:@"\uf04b"},
    @{kTitleName:[@"ITEM_ENGINE" localizableString:@""],kFontAwsomeName:@"\uf046"},
                    @{kTitleName:[@"ITEM_SUMMARY" localizableString:@""],kFontAwsomeName:@"\uf200"},
    ];
    
    selectedOption = 2;
    
    [self.collectionView reloadData];
    
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 70;
    self.tblView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tblView.hidden = true;
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    inCommandStatus = 2;
    
    if ([self commandStatus]) {
        inCommandStatus = 1;
    }
    
    [self fetchCommandList:nil];
    
}

-(void)updateCommandTime{
    
    self.lblCommandTime.hidden = YES;
    int status = 1;
    NSString *text = @"";
    
    if ([self commandStatus]==NO) {
        NSDate *currentDate = [NSDate date];
        NSDate *commandDate = [Util retrieveDefaultForKey:kCommandDate];
        NSTimeInterval secs = [currentDate timeIntervalSinceDate:commandDate];
        //self.lblCommandTime.text = [NSString stringWithFormat:@"Please wait %d seconds to access command",(int)(30-secs)];
        self.lblCommandTime.text = [NSString stringWithFormat:[@"TV_COMMAND_COUNTDOWN" localizableString:@""],(int)(30-secs)];
        self.lblCommandTime.hidden = NO;
        //text = [NSString stringWithFormat:@"Please wait %d seconds to access command",(int)(30-secs)];
        text = [NSString stringWithFormat:[@"TV_COMMAND_COUNTDOWN" localizableString:@""],(int)(30-secs)];
        
        status = 2;
        
    }
    
    if (status != inCommandStatus) {
        inCommandStatus = status;
        //[self.tblView reloadData];
    }
    
    if(inCommandStatus == 2){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0]; //4
        TableViewCell *cell = [self.tblView cellForRowAtIndexPath:indexPath];
        if(cell)
            cell.lbl5.text = text;
    }
    
    [self.tblView reloadData];
}

//DKD added on 21 June 2020
-(IBAction)fetchCommandList:(id)sender{
 
    [Util showLoader:@"" forView:self.view];
    
    NSString *api = [NSString stringWithFormat:@"%@Vehicle/Controlling/Commands/%d",ApiPath, [self.selectedVehicleDict[@"VehicleId"] intValue]];
    
    [connectionHandler makeGetRequest:api withResponse:^(NSData *data, NSError *error) {
        if (error == nil && data!= nil) {
            NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",tempArray);

            dispatch_async(dispatch_get_main_queue(), ^{
                if(tempArray){
                    NSMutableArray *mutArray = [tempArray mutableCopy];
                    [mutArray insertObject:[NSNull null] atIndex:0]; //Adding this show the heaser
                    arrCommandList = mutArray;
                }
                [Util hideLoader:self.view];
                [self.tblView reloadData];
                self.tblView.hidden = false;
            });
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Tableview datasource & delegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 2; //4
    if (inCommandStatus == 2)
        rowCount = 3; //5
    
    if(arrCommandList.count>0)
        rowCount = rowCount + arrCommandList.count;
    
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommandCell];
    
    
    if(indexPath.row <= 1){ //3
        cell.imageView1.image = [UIImage imageNamed:imageArray[indexPath.row]];
        cell.lbl1.text = titleArray[indexPath.row];
        cell.lbl1.textColor = [UIColor blackColor];
        
        if (inCommandStatus == 2) {
            cell.imageView1.image = [UIImage imageNamed:disableImageArray[indexPath.row]];
            cell.lbl1.textColor = [UIColor colorWithRed:154/255.0f green:154/255.0f  blue:154/255.0f  alpha:1];
        }
    }
    else if(indexPath.row == 2 && inCommandStatus == 2){ //4
        cell = [tableView dequeueReusableCellWithIdentifier:TimeCell];
        
    }
    else if(arrCommandList.count > 0){
        
        NSUInteger index = indexPath.row - 2; //4
        if(inCommandStatus == 2)
            index = indexPath.row - 3; //5
        
        cell = [tableView dequeueReusableCellWithIdentifier:StaticCell];
        cell.lbl1.text = [@"TV_COMMAND_STATUS" localizableString:@""];
        NSDictionary *dict = arrCommandList[index];
        if(dict != (id)[NSNull null]){
            cell = [tableView dequeueReusableCellWithIdentifier:CommandHistoryCell];
            cell.lbl1.text = dict[@"CommandString"];
            cell.lbl2.text = dict[@"InitiatedOn"];
            NSString *text = @"-";
            if([[Util checkNullValue:dict[@"ProcessedOn"]] length]>0)
                text = dict[@"ProcessedOn"];
            cell.lbl3.text = text;
            
            NSString *status = dict[@"Status"];
            UIColor *txtColor = nil;
            UIColor *bgColor = nil;
            
            if([status isEqualToString:COMMAND_SET]){
                txtColor = setColor;
                bgColor = setBgColor;
            }
            else if([status isEqualToString:COMMAND_QUEUE]){
                txtColor = queueColor;
                bgColor = queueBgColor;
                status = @"In Queue";
            }
            else if([status isEqualToString:COMMAND_EXPIRED]){
               txtColor = expColor;
               bgColor = expBgColor;
            }
           else if([status isEqualToString:COMMAND_FAILED]){
               txtColor = failedColor;
               bgColor = failedBgColor;
           }
            
            cell.lbl4.text = status;
            cell.lbl4.textColor = txtColor;
            cell.lbl4.backgroundColor = bgColor;
            
            cell.lbl5.text = [@"ITEM_COMMAND" localizableString:@""];
            cell.lbl6.text = [@"TV_INITIATED_ON" localizableString:@""];
            cell.lbl7.text = [@"TV_PROCESSED_ON" localizableString:@""];
            
            //[cell.view1 updateStyleWithInfo:@{kCornerRadius:@5.0f}];
            cell.view1.layer.cornerRadius = 5.0f;
        }
        
    }
    
    
    
//    if(indexPath.row == 4)
//        cell = [tableView dequeueReusableCellWithIdentifier:TimeCell];
//    else if(indexPath.row == 5)
//        cell = [tableView dequeueReusableCellWithIdentifier:StaticCell];
//    else if(indexPath.row == 6)
//        cell = [tableView dequeueReusableCellWithIdentifier:CommandHistoryCell];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Do nothing if user taps on other cell
    if(indexPath.row >3)
        return;
    
    BOOL flgCommand = NO;
    
    if ([Util retrieveDefaultForKey:kCommandDate]==nil) {
        flgCommand = YES;
    }
    else{
        NSDate *currentDate = [NSDate date];
        NSDate *commandDate = [Util retrieveDefaultForKey:kCommandDate];
        NSTimeInterval secs = [currentDate timeIntervalSinceDate:commandDate];
        if (secs>=30) {
            flgCommand = YES;
        }
    }
    
    if (flgCommand) {
        [Util showLoader:@"" forView:self.view];
        
        NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/Controlling/IgnitionOff/%d",[self.selectedVehicleDict[@"VehicleId"] intValue]];
        
        if (indexPath.row == 1) {
            apiRequest = [NSString stringWithFormat:@"Vehicle/Controlling/IgnitionOn/%d",[self.selectedVehicleDict[@"VehicleId"] intValue]];
        }
        else if (indexPath.row == 2) {
            apiRequest = [NSString stringWithFormat:@"Vehicle/Controlling/ACoff/%d",[self.selectedVehicleDict[@"VehicleId"] intValue]];
        }
        else if (indexPath.row == 3) {
            apiRequest = [NSString stringWithFormat:@"Vehicle/Controlling/ACon/%d",[self.selectedVehicleDict[@"VehicleId"] intValue]];
        }
        NSDictionary *requestDict = @{kApiRequest:apiRequest};
        [connectionHandler makeConnectionWithRequest:requestDict];
    }
    
    
}

-(BOOL)commandStatus{
    
    BOOL flgCommand = NO;
    
    if ([Util retrieveDefaultForKey:kCommandDate]==nil) {
        flgCommand = YES;
    }
    else{
        NSDate *currentDate = [NSDate date];
        NSDate *commandDate = [Util retrieveDefaultForKey:kCommandDate];
        NSTimeInterval secs = [currentDate timeIntervalSinceDate:commandDate];
        if (secs>=30) {
            flgCommand = YES;
        }
    }
    
    return flgCommand;
}


//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Remove seperator inset
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//
//    // Prevent the cell from inheriting the Table View's margin settings
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//
//    // Explictly set your cell's layout margins
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

#pragma mark Collection view datasource & delegate method

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [staticArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *dict = staticArray[indexPath.row];
    cell.lbl1.text = [NSString stringWithFormat:@"%@", dict[kFontAwsomeName]];
    cell.lbl2.text = [NSString stringWithFormat:@"%@", dict[kTitleName]];
    
    cell.lbl1.textColor = DEFAULT_COLOR;
    cell.lbl2.textColor = DEFAULT_COLOR;
    
    if (indexPath.row == selectedOption) {
        cell.lbl1.textColor = SELECTED_COLOR;//[UIColor colorWithRed:68/255.0 green:68/255.0 blue:224/255.0 alpha:1];
        cell.lbl2.textColor = SELECTED_COLOR;//[UIColor whiteColor];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = collectionView.frame.size;
    size.width = size.width/staticArray.count;
    size.height = size.height;
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        NSArray *array = self.navigationController.viewControllers;
        if (indexPath.row == 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kTrackVehicleNotification object:nil];
            for (UIViewController *VC in array) {
                if ([VC isKindOfClass:[TrackVehicleVC class]]) {
                    [self.navigationController popToViewController:VC animated:NO];
                    break;
                }
            }
            
        }
    }
    else if (indexPath.row == 1){
        
        BOOL flgPlayback = YES;
        
        NSArray *array = self.navigationController.viewControllers;
        
        for (UIViewController *VC in array) {
            if ([VC isKindOfClass:[PlaybackVC class]]) {
                [self.navigationController popToViewController:VC animated:NO];
                flgPlayback = NO;
                break;
            }
        }
        
        if (flgPlayback) {
            PlaybackVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlaybackVC"];
            VC.selectedVehicleDict = self.selectedVehicleDict;
            [self.navigationController pushViewController:VC animated:NO];
            
        }
    }
    else if (indexPath.row == 3){
        
        BOOL flgReport = YES;
        NSArray *array = self.navigationController.viewControllers;
        for (UIViewController *VC in array) {
            if ([VC isKindOfClass:[SummaryVC class]]) {
                [self.navigationController popToViewController:VC animated:NO];
                flgReport = NO;
                break;
            }
        }
        
        if (flgReport) {
            SummaryVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"SummaryVC"];
            VC.selectedVehicleDict = self.selectedVehicleDict;
            [self.navigationController pushViewController:VC animated:NO];
            
        }
    }
}

#pragma mark Button action handling
-(void)btnBackClicked{
    
    NSArray *navigationarray = self.navigationController.viewControllers;
    
    for (UIViewController *VC in navigationarray) {
        if ([VC isKindOfClass:[VehicleListVC class]]) {
            [self.navigationController popToViewController:VC animated:YES];
            break;
        }
    }
}

-(void)showHomePage{
    [self btnBackClicked];
}

#pragma mark make connection to server and handle response
#pragma mark Connection response handling
-(void)receiveResponse:(id)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([responseDict[kResponse] isEqual:[NSNull null]]|| responseDict[kResponse] == nil) {
            [Util showAlert:@"" andMessage:@"Oops! Something went wrong. We will take care of it soon." forViewController:self];
        }
        else if (responseDict[kResponse]) {
            BOOL flgShowHome = false;
            NSDictionary *response = responseDict[kResponse];
            if ([response[@"IsError"] intValue] == 0) {
                [Util updateDefaultForKey:kCommandDate toValue:[NSDate date]];
                flgShowHome = true;
            }
            if (flgShowHome) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:response[@"Message"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_OK" localizableString:@""] style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                    [self showHomePage];
                    
                }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
                [Util showAlert:@"" andMessage:response[@"Message"] forViewController:self];
        }
        [Util hideLoader:self.view];
    });
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
