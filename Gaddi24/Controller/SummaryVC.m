//
//  SummaryVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "SummaryVC.h"
#import "TableViewCell.h"
#import "CollectionViewCell.h"
#import "Global.h"
#import "VehicleListVC.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "TrackVehicleVC.h"
#import "PlaybackVC.h"
#import "CommandVC.h"
#import "UIView+Style.h"
#import "NSString+Localizer.h"
#import "MyDateConatiner.h"

@interface SummaryVC ()<ConnectionHandlerDelegate, MyDateConatinerDelegate>{
    NSArray *staticArray;
    NSUInteger selectedOption;
    ConnectionHandler *connectionHandler;
    
    NSTimer *timer;
    NSArray *arrDataList;
    
    NSArray *dayArray;
    UILabel *lblWidthCalculator;
    NSInteger selectedDay;
    NSDate *firstDate;
    NSDate *secondDate;
    
    MyDateConatiner *myDateContainer;
    
    UIButton *selectedButton;
}

@end

static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";


@implementation SummaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)initialsetup{
    
    selectedDay = 1;
    firstDate = [NSDate date];
    secondDate = [NSDate date];
    
    NSString *todayStr = [NSString stringWithFormat:@"%@",[@"ITEM_TODAY" localizableString:@""]];
    NSString *yesterdayStr = [NSString stringWithFormat:@"%@",[@"ITEM_YESTERDAY" localizableString:@""]];
    NSString *weekStr = [NSString stringWithFormat:@"%@",[@"ITEM_WEEK" localizableString:@""]];
    NSString *userDefinedStr = [NSString stringWithFormat:@"%@",[@"ITEM_USER_DEFINED" localizableString:@""]];

    dayArray = @[[todayStr uppercaseString],
                 [yesterdayStr uppercaseString],
                 [weekStr uppercaseString],
                 [userDefinedStr uppercaseString]];
    
    
    
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
    
    selectedOption = 3;
    
    lblWidthCalculator = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 18)];
    lblWidthCalculator.numberOfLines = 1;
    lblWidthCalculator.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.collectionView reloadData];
    [self.timeCollectionView reloadData];
    [self.valueCollectionView reloadData];
    
    [self customDayRangeLayoutSetUp];
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    [self updateTimeLabelAndLoadData: [Util yesterdayDateRange]];
}

-(void)customDayRangeLayoutSetUp{
    //Set button'text to currnt date
       
       [self.btnStartDate setTitle:[Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}] forState:UIControlStateNormal];
       [self.btnEndDate setTitle:[Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}] forState:UIControlStateNormal];
       
       [self.btnStartDate updateStyleWithInfo:@{kCornerRadius:@0.0f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f  blue:170/255.0f  alpha:1],kBorderWidth:@1.0f}];
       
    [self.btnEndDate updateStyleWithInfo:@{kCornerRadius:@0.0f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f  blue:170/255.0f  alpha:1],kBorderWidth:@1.0f}];
    
    _staticLblStartDate.text = [@"TV_START_DATE_TIME" localizableString:@""];
    _staticLblEndDate.text = [@"TV_END_DATE_TIME" localizableString:@""];
    
    [_btnOK setTitle:[@"ALERT_BUTTON_OK" localizableString:@""] forState:UIControlStateNormal];
}

-(void)updateTimeLabelAndLoadData:(NSDictionary *)dict{
    
    self.lblTime.text = dict[@"date3"];
    
    [Util showLoader:@"" forView:self.view];
    
    NSString *dateApi = [NSString stringWithFormat:@"%@/%@",dict[@"date1"],dict[@"date2"]];
    
    NSString *encodedLink = [dateApi stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    
    NSString *api = [NSString stringWithFormat:@"%@Reports/SummaryData/%d/%@",ApiPath, [self.selectedVehicleDict[@"VehicleId"] intValue],encodedLink];
    
    NSLog(@"api =%@", api);
    
    [connectionHandler makeGetRequest:api withResponse:^(NSData *data, NSError *error) {
        if (error == nil && data!= nil) {
            NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",tempArray);

            dispatch_async(dispatch_get_main_queue(), ^{
                if(tempArray){
                    arrDataList = tempArray;
                }
                [Util hideLoader:self.view];
                [self.valueCollectionView reloadData];
                self.valueCollectionView.hidden = false;
            });
        }
    }];

}

#pragma mark Collection view datasource & delegate method

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = [staticArray count];
    if(collectionView.tag == 1002)
        count = dayArray.count;
    else if(collectionView.tag == 1003)
        count = arrDataList.count;
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    
    
    if(collectionView.tag == 1002){
        cell.lbl1.text = dayArray[indexPath.row];
        
        cell.view1.backgroundColor = indexPath.row == selectedDay ? [UIColor colorWithRed:59/255.0f green:134/255.0f blue:226/255.0f alpha:1] : [UIColor lightGrayColor];
        
        [cell.view1 updateStyleWithInfo:@{kBorderColor: cell.view1.backgroundColor, kBorderWidth:@1.0f, kCornerRadius:@(cell.view1.frame.size.height/2)}];
        }
    else if(collectionView.tag == 1003){
        NSDictionary *dict = arrDataList[indexPath.row];
        [cell.view1 updateStyleWithInfo:@{kBorderColor: [UIColor lightGrayColor], kBorderWidth:@1.0f, kCornerRadius:@(5.0)}];
        cell.lbl1.text = dict[@"HeaderName"];
        cell.lbl1.textColor = [Util colorWithHexString:dict[@"HeaderColor"]];
        
        cell.lbl2.text = dict[@"Value"];
        cell.lbl2.textColor = [Util colorWithHexString:dict[@"ValueColor"]];
        
        cell.lbl3.text = [Util fetchFontAwesomeString:dict[@"Icon"]];
        cell.lbl3.textColor = [Util colorWithHexString:dict[@"IconColor"]];
    }
    else{
        NSDictionary *dict = staticArray[indexPath.row];
        cell.lbl1.text = [NSString stringWithFormat:@"%@", dict[kFontAwsomeName]];
        cell.lbl2.text = [NSString stringWithFormat:@"%@", dict[kTitleName]];
        
        cell.lbl1.textColor = DEFAULT_COLOR;
        cell.lbl2.textColor = DEFAULT_COLOR;
        
        if (indexPath.row == selectedOption) {
            cell.lbl1.textColor = SELECTED_COLOR;//[UIColor colorWithRed:68/255.0 green:68/255.0 blue:224/255.0 alpha:1];
            cell.lbl2.textColor = SELECTED_COLOR;//[UIColor whiteColor];
        }
    }
     
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
   

    CGSize size = collectionView.frame.size;
    size.height = size.height;
    size.width = size.width/staticArray.count;
    if(collectionView.tag == 1002){
        lblWidthCalculator.text = dayArray[indexPath.row];
        [lblWidthCalculator sizeToFit];
        size.width = lblWidthCalculator.frame.size.width + 40;
        
        NSLog(@"text=%@ & size =%@",lblWidthCalculator.text,NSStringFromCGSize(size));
    }
    else if(collectionView.tag == 1003){
        size.width = (collectionView.frame.size.width - 20)/2;
        size.height = 0.7*size.width - 10;
        NSLog(@"text=%@ & size =%@",lblWidthCalculator.text,NSStringFromCGSize(size));
    }
       
    
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView.tag == 1002){
        [self handleForDay:indexPath];
    }
    else if(collectionView.tag == 1001){
        [self handleForBottomTab:indexPath];
    }
}

-(void)handleForDay:(NSIndexPath *)indexPath{
    //For user defined make user to allow click again
    if(selectedDay == indexPath.row && (indexPath.row != dayArray.count -1))
        return;
        
   
        selectedDay = indexPath.row;
        [_timeCollectionView reloadData];
        
    switch (indexPath.row) {
        case 0:
            [self updateTimeLabelAndLoadData:[Util todayDateRange]];
            break;
        case 1:
            [self updateTimeLabelAndLoadData:[Util yesterdayDateRange]];
            break;
        case 2:
            [self updateTimeLabelAndLoadData:[Util weekDateRange]];
            break;
            
        default:
            [self showHideCustomRange:false];
            break;
    }
        
}

-(void)handleForBottomTab:(NSIndexPath *)indexPath{
    
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
    else if (indexPath.row == 2){
        
        BOOL flgCommand = YES;
        
         NSArray *array = self.navigationController.viewControllers;
        
        for (UIViewController *VC in array) {
            if ([VC isKindOfClass:[CommandVC class]]) {
                [self.navigationController popToViewController:VC animated:NO];
                flgCommand = NO;
                break;
            }
        }
        
        if (flgCommand) {
            CommandVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommandVC"];
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

-(IBAction)btnCustomRangeClicked:(UIButton *)btn{
    selectedButton = btn;
    if(btn.tag == 1){
        [self createDateView:@{kPickerTitle:@"",kMaximumDate:[NSDate date]} ];
    }
    else if(btn.tag == 2){
        [self createDateView:@{kPickerTitle:@"",kMaximumDate:[NSDate date]} ];
    }
    else{
        if([self validateField]){
            [self showHideCustomRange:true];
            myDateContainer.hidden = true;
            
           NSString *strDate = [Util universalDateFormate:@{kActualDateFormate:@"dd-MM-yyyy", kRequiredDateFormate:@"dd-MMM-yyyy", kDate:_btnStartDate.titleLabel.text}];
            
            NSString *enDate = [Util universalDateFormate:@{kActualDateFormate:@"dd-MM-yyyy", kRequiredDateFormate:@"dd-MMM-yyyy", kDate:_btnEndDate.titleLabel.text}];
            
           NSString *date3String = [NSString stringWithFormat:@"%@ 12:00 AM - %@ 11:59 PM",strDate,enDate];
            
            NSDictionary *dateDict = @{@"date1":[NSString stringWithFormat:@"%@ 00_00_00",_btnStartDate.titleLabel.text],
                                       @"date2":[NSString stringWithFormat:@"%@ 23_59_59",_btnEndDate.titleLabel.text],
            @"date3":date3String

            };
            
            [self updateTimeLabelAndLoadData:dateDict];
        }
    }
    
}

-(BOOL)validateField{
    BOOL flgValid = true;
    NSDate *date1 = [Util fetchDateFromString:_btnStartDate.titleLabel.text];
    
    NSDate *date2 = [Util fetchDateFromString:_btnEndDate.titleLabel.text];
    
    if ([date1 compare:date2] == NSOrderedDescending) {
        [Util showAlert:@"" andMessage:[@"ERROR_END_START_DATE" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    
    return flgValid;
}

#pragma mark Create Dateview

-(void)createDateView:(NSDictionary *)dict{
    
    if (!myDateContainer) {
        myDateContainer = [[MyDateConatiner alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 250, self.view.bounds.size.width, 250)];
        myDateContainer.myDateConatinerDelegate = self;

        [self.view addSubview:myDateContainer];
        myDateContainer.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0];

        [myDateContainer childviewSetup];
        
    }
    
   [myDateContainer valueSetUp:dict];
    myDateContainer.datePicker.datePickerMode = UIDatePickerModeDate;
    myDateContainer.datePicker.maximumDate = [NSDate date];
    
    myDateContainer.hidden = NO;
    
}

-(void)dateChanged:(NSDate *)date{
    myDateContainer.hidden = YES;
    
    //DKD added this on 16 Apr 2020
    NSString *dateFormate = @"dd-MM-yyyy";
    
    [selectedButton setTitle:[Util fromDateToStringConverter:@{kActualDateFormate:dateFormate,kDate:date}] forState:UIControlStateNormal];
    
}

-(void)cancelButtonPressed{
    myDateContainer.hidden = YES;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch view]==self.viewTransparent) {
        [self showHideCustomRange:YES];
        myDateContainer.hidden = true;
    }
}

-(void)showHideCustomRange:(BOOL)flag{
    self.viewTransparent.hidden = flag;
    self.viewCustomRange.hidden = flag;
}

@end
