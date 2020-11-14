//
//  PlaybackVC.m
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "PlaybackVC.h"

#import "Global.h"
#import "TableViewCell.h"
//#import "UIViewController+MMDrawerController.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "UIView+Style.h"
#import "MapViewAnnotation.h"
#import "CollectionViewCell.h"
//#import "NSString+FontAwesome.h"
#import "PopoverVC.h"
#import "MarkerInfoWindow.h"
#import "MyDateConatiner.h"
#import "VehicleListVC.h"
#import "CommandVC.h"
#import "TrackVehicleVC.h"
#import "SummaryVC.h"
#import "NSString+Localizer.h"

#define METERS_PER_MILE 1609.344



@interface PlaybackVC ()<ConnectionHandlerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate,PopoverVCDelegate,GMSMapViewDelegate, MyDateConatinerDelegate>{
    ConnectionHandler *connectionHandler;
    NSTimer *timer;
    
    NSTimer *timer1;
    
    GMSCameraPosition *camera;
    
    NSArray *staticArray;
    
    NSUInteger selectedOption; //Track which option is selected by user
    
    NSMutableArray *points;
    
    NSMutableArray *markersMutArray;
    
    PopoverVC *popoverVC;
    
    NSString *selectedSpeed;
    
    NSString *selectedTime;
    
    NSString *selectedMapType;
    
    short selectedValue; //1 = Speed, 2= Time, 3= Map type
    
    UINavigationController *nav;
    
    NSArray *routeArray;
    
    NSArray *stopArray;
    
    GMSMarker *marker;
    
    NSTimeInterval timeInterval;
    
    NSUInteger activeIndex;
    
    NSString *startDateString;
    
    NSString *endDateString;
    
    NSDate *dtStartDate;
    
    NSDate *dtEndDate;
    
    MyDateConatiner *myDateContainer;
    
    BOOL flgPlay;
}

@property(nonatomic,weak)IBOutlet NSLayoutConstraint *dividerCenterConstraint;
@end

static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";
static NSString * const kPolyLine = @"kPolyLine";
static NSString * const kGeoAddress = @"kGeoAddress";

static const CGFloat VERY_SLOW = 1.2;
static const CGFloat SLOW = 0.6;
static const CGFloat NORMAL = 0.2;
static const CGFloat FAST = 0.1;
static const CGFloat VERY_FAST = 0.05;

@implementation PlaybackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([Util retrieveDefaultForKey:kDonotshow]==nil) {
        [self showMessage:1];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self invaldateTimer];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.mapView clear];
    [self clearAllSetting];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.trafficEnabled = NO;
}

-(void)invaldateTimer{
    [timer invalidate];
    timer = nil;
    
    [timer1 invalidate];
    timer1 = nil;
}

-(void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval+.1 target:self selector:@selector(moveVehicle) userInfo:nil repeats:NO];
}

-(void)initialsetup{
    
    //Navigation bar setup
    
    
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
    
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,80, 40)];
    rightView.backgroundColor = [UIColor clearColor];
    
    //Creating button
    UIButton *rightButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton1.frame = CGRectMake(0, 0, 40, 40);
    [rightButton1 setTitle:@"\uf0e4" forState:UIControlStateNormal];
    rightButton1.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    rightButton1.titleLabel.textColor = [UIColor whiteColor];
    [rightButton1 addTarget:self action:@selector(btnSpeedClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightButton1];
    
    
    UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton2.frame = CGRectMake(40, 0, 40, 40);
    [rightButton2 setTitle:@"\uf017" forState:UIControlStateNormal];
    rightButton2.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    rightButton2.titleLabel.textColor = [UIColor whiteColor];
    [rightButton2 addTarget:self action:@selector(btnTimeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightButton2];
    
    UIBarButtonItem *rightbarButton=[[UIBarButtonItem alloc] init];
    [rightbarButton setCustomView:rightView];
    self.navigationItem.rightBarButtonItem=rightbarButton;
    
    
    self.lblStaticSpeed.text = @"\uf0e4";
    self.lblStaticSpeed.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    
    self.lblStaticDate.text = @"\uf017";
    self.lblStaticDate.font = [UIFont fontWithName:@"FontAwesome" size:19.0f];
    
    [self.alertView updateStyleWithInfo:@{kCornerRadius:@15.0f, kBorderWidth:@0.5f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0f]}];
    
    self.lblStaticDateText.text = [@"TV_DATE_INFO" localizableString:@""];
    self.lblStaticSpeedText.text = [@"TV_SPEED_INFO" localizableString:@""];
       
       [self.btnOK1 setTitle:[@"ALERT_BUTTON_OK" localizableString:@""] forState:UIControlStateNormal];
       [self.btnOK2 setTitle:[@"ALERT_BUTTON_OK" localizableString:@""] forState:UIControlStateNormal];
       [self.btndonotshow setTitle:[@"BTN_DONT_SHOW_AGAIN" localizableString:@""] forState:UIControlStateNormal];

       
       selectedSpeed = [@"ITEM_NORMAL" localizableString:@""];
    selectedTime = @"";
    selectedMapType = @"Normal";
    
    timeInterval = NORMAL;
    activeIndex = 0;
    
    /*
    NSDictionary *dict = [Util todayDateRange];//NSDictionary *dict = [Util todayDateRange];
    
    startDateString = dict[@"date1"];
    
    endDateString = dict[@"date2"];
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"PopoverVC"];
    popoverVC.popoverVCDelegate = self;
    nav = [[UINavigationController alloc]initWithRootViewController:popoverVC];
    

    //Creating connection object
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;

    [self.collectionView1 reloadData];
    
    staticArray = @[@{kTitleName:[@"ITEM_TRACK" localizableString:@""],kFontAwsomeName:@"\uf278"},
    @{kTitleName:[@"ITEM_HISTORY" localizableString:@""],kFontAwsomeName:@"\uf04b"},
    @{kTitleName:[@"ITEM_ENGINE" localizableString:@""],kFontAwsomeName:@"\uf046"},
                    @{kTitleName:[@"ITEM_SUMMARY" localizableString:@""],kFontAwsomeName:@"\uf200"},
    ];
    
    selectedOption = 1;
    
    points = [[NSMutableArray alloc]initWithCapacity:10]; //This will hold all the oordinate
    markersMutArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    camera = [GMSCameraPosition cameraWithLatitude:[self.selectedVehicleDict[@"Latitude"] doubleValue]
                                         longitude:[self.selectedVehicleDict[@"Longitude"] doubleValue]
                                              zoom:15];
    self.mapView.camera = camera;
    
    routeArray = [Util retrieveDefaultForKey:@"routeArray"];
    
    self.mapView.delegate = self;
    
    [self.btnPlay bringSubviewToFront:self.view];
    [self.slider bringSubviewToFront:self.view];
    
    
    
    
    //[self createDateView:@{kMaximumDate:[NSDate date],kPickerTitle:@"Please select start date"}];
    
}

-(void)fetchTrackedCordinate{
    //NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/%@/LiveData",self.selectedVehicleDict[@"VehicleId"]];
    
    
    
    //NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/PlayBackData/%d/5-2-2017 14_17_12/5-2-2017 15_17_12",[self.selectedVehicleDict[@"VehicleId"] intValue]];
    
     NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/PlayBackData/%d/%@/%@",[self.selectedVehicleDict[@"VehicleId"] intValue],startDateString,endDateString];
    
    apiRequest = [apiRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *requestDict = @{kApiRequest:apiRequest};
    [connectionHandler makeConnectionWithRequest:requestDict];
    
}

#pragma mark make connection to server and handle response
#pragma mark Connection response handling
-(void)receiveResponse:(id)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([responseDict[kResponse] isEqual:[NSNull null]]|| responseDict[kResponse] == nil) {
            [Util showAlert:@"" andMessage:@"Oops! Something went wrong. We will take care of it soon." forViewController:self];
        }

        
        else if (responseDict[kResponse]) {
            [Util hideLoader:self.view];
            routeArray = responseDict[kResponse][@"RouteData"];
            stopArray = responseDict[kResponse][@"StoppageData"];
            
            [Util updateDefaultForKey:@"routeArray" toValue:routeArray];
            [Util updateDefaultForKey:@"StoppageData" toValue:stopArray];
            
            if ([routeArray isKindOfClass:[NSArray class]]&& [routeArray count]>0) {
                [self processRespose];
            }
            else if([routeArray count]==0){
                [Util showAlert:@"" andMessage:@"No moving data available for the selected period." forViewController:self];
            }
            
        }
        [Util hideLoader:self.view];
    });
}

-(void)processRespose{
    
    self.slider.maximumValue = [routeArray count];
    
    activeIndex = 0;
    
    [self drawLineBetweenLocation];
    
    [self showStoppageMarker];
    
    [self invaldateTimer];
    
    flgPlay = NO;
    
    self.sliderTransparentView.hidden = NO;
    self.slider.hidden = NO;
    self.btnPlay.hidden = NO;
    [self.btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    self.lblSpeed.text = @"";
    self.lblDate.text = @"";
    
    //[self moveVehicle];
    
}

-(void)drawLineBetweenLocation{
    GMSMutablePath *path = [GMSMutablePath path];
    for (NSDictionary *dict in routeArray) {
        [path addLatitude:[dict[@"Latitude"] floatValue] longitude:[dict[@"Longitude"] floatValue]];
    }
    
    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
    singleLine.strokeWidth = 2.0f;
    singleLine.strokeColor = [UIColor colorWithRed:73/255.0f green:134/255.0f blue:231/255.0f alpha:1];
    singleLine.map = self.mapView;
}

-(void)showStoppageMarker{
    for (NSDictionary *pointDict in stopArray) {
        GMSMarker *stopMarker = [[GMSMarker alloc] init];
        stopMarker.position = CLLocationCoordinate2DMake([pointDict[@"Latitude"] doubleValue], [pointDict[@"Longitude"] doubleValue]);
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        view.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:view.bounds];
        imageView.image = [UIImage imageNamed:@"stop_marker.png"];
        [view addSubview:imageView];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:imageView.bounds];
        lbl.font = [UIFont systemFontOfSize:10.0f];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.text = [NSString stringWithFormat:@"%d",[pointDict[@"StoppageNumber"] intValue]];
        lbl.textAlignment = NSTextAlignmentCenter;
        [view addSubview:lbl];
        
        stopMarker.iconView = view;
        stopMarker.map = self.mapView;
        
        stopMarker.userData = pointDict;
    }
}

-(void)moveVehicle{
    
    self.slider.value = activeIndex + 1;
    
    NSUInteger index = activeIndex;
    
    NSDictionary *pointDict = routeArray[index];
    
    //NSLog(@"pointdict =%@",pointDict);
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([pointDict[@"Latitude"] doubleValue], [pointDict[@"Longitude"] doubleValue]);
    
    self.lblDate.text = @"";
    self.lblSpeed.text = @"";
    
    NSString *time = @"";
    NSString *speed = @"";
    
    
    NSRange range = [pointDict[@"Time"] rangeOfString:@"To"];
    
    if (range.location == NSNotFound) {
        time = pointDict[@"Time"];
        speed = [NSString stringWithFormat:@"%.2f km/h",[pointDict[@"Speed"] doubleValue]];
    }
    
    self.lblDate.text = time;
    self.lblSpeed.text = speed;
    
    
    ////NSLog(@"latitude =%f & longitude =%f",coordinate.latitude,coordinate.longitude);
    
    CGFloat zoomValue = self.mapView.camera.zoom;
    
    if (!marker) {
        marker = [[GMSMarker alloc] init];
        marker.position = coordinate;
        marker.icon = [UIImage imageNamed:@"vehicle_icon.png"];
        marker.map = self.mapView;
        marker.rotation = [pointDict[@"Direction"] floatValue];
        
        camera =
        [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                    longitude:coordinate.longitude zoom:zoomValue];
        
        
        [self.mapView animateToCameraPosition:camera];
    }
    else{
        camera =
        [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                    longitude:coordinate.longitude zoom:zoomValue];
        [self.mapView animateToCameraPosition:camera];
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:timeInterval];
        marker.position = coordinate;
        marker.rotation = [pointDict[@"Direction"] floatValue];
        [CATransaction commit];
    }
    
    if (index+1<[routeArray count]) {
        //[self performSelector:@selector(moveVehicle:) withObject:@(index+1) afterDelay:1.1];
        
        activeIndex = index+1;
        
        [self invaldateTimer];
        [self startTimer];
    }
    
    //Play is completed hence show pause button & make slider value to 0
    if (index == [routeArray count]-1) {
        [timer1 invalidate];
        timer1 = nil;
        timer1 =  [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(startTrackingAgain) userInfo:nil repeats:NO];
    }

}

-(void)startTrackingAgain{
    flgPlay = NO;
    activeIndex = 0;
    self.slider.value = activeIndex;
    [self.btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    self.lblDate.text = @"";
    self.lblSpeed.text = @"";
}

#pragma mark Collection view datasource & delegate method

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger cellCount = staticArray.count;
    if (collectionView.tag == 1002) {
        cellCount = 6;
    }
    return cellCount;
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
    
    //We want to disable the button when transparent view is active
    if (self.transparentView.hidden==NO) {
        return;
    }
        
    
    NSArray *navigationarray = self.navigationController.viewControllers;
    
    for (UIViewController *VC in navigationarray) {
        if ([VC isKindOfClass:[VehicleListVC class]]) {
            [self.navigationController popToViewController:VC animated:YES];
            break;
        }
    }
}

-(void)btnSpeedClicked:(UIButton *)button{
    
    //We want to disable the button when transparent view is active
    if (self.transparentView.hidden==NO) {
        return;
    }
    
    selectedValue = 1;
     [popoverVC updateTableContent:@[[@"ITEM_VERY_SLOW" localizableString:@""],[@"ITEM_SLOW" localizableString:@""],[@"ITEM_NORMAL" localizableString:@""],[@"ITEM_FAST" localizableString:@""],[@"ITEM_VERY_FAST" localizableString:@""]] withSelectedTitle:selectedSpeed];
    nav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover = nav.popoverPresentationController;
    popoverVC.preferredContentSize = CGSizeMake(175, 160);
    popover.delegate = self;
    popover.barButtonItem = self.navigationItem.rightBarButtonItems[0];
    popover.sourceRect = CGRectMake(80, 100, 0, 0);
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)btnTimeClicked:(UIButton *)button{
    
    //We want to disable the button when transparent view is active
    if (self.transparentView.hidden==NO) {
        return;
    }
    
    selectedValue = 2;
    [popoverVC updateTableContent:@[[@"ITEM_TODAY" localizableString:@""],[@"ITEM_YESTERDAY" localizableString:@""],[@"ITEM_BEFORE_YESTERDAY" localizableString:@""],[@"ITEM_HOUR_AGO" localizableString:@""],[@"ITEM_USER_DEFINED" localizableString:@""]] withSelectedTitle:selectedTime];
    nav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover = nav.popoverPresentationController;
    popoverVC.preferredContentSize = CGSizeMake(215, 160);
    popover.delegate = self;
    popover.barButtonItem = self.navigationItem.rightBarButtonItems[0];
    popover.sourceRect = CGRectMake(0, 100, 0, 0);
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)btnMapClicked:(id)sender{
    selectedValue = 3;
     [popoverVC updateTableContent:@[[@"ITEM_NORMAL" localizableString:@""],[@"ITEM_SATELLITE" localizableString:@""],[@"ITEM_TERRAIN" localizableString:@""]] withSelectedTitle:selectedMapType];
    nav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover = nav.popoverPresentationController;
    popoverVC.preferredContentSize = CGSizeMake(140, 90);
    popover.delegate = self;
     popover.sourceView = self.buttonTemp;
    //popover.sourceRect = CGRectMake(0, 100, 0, 0);
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)btnTrafficClicked:(id)sender{
    UIButton *btnTraffic = sender;
    btnTraffic.selected = !btnTraffic.selected;
    self.mapView.trafficEnabled = btnTraffic.selected;
}

-(IBAction)btnInfoClicked:(id)sender{
    
    self.alertView.hidden = !self.alertView.hidden;
    
    if(self.alertView.hidden==NO){
        [self showMessage:0];
    }
    
}

-(void)showMessage:(int)show{
    
    self.alertView.hidden = NO;
    self.transparentView.hidden = NO;
    
    [self hideAllAlertButton];
    if (show==1) {
        self.btnOK1.hidden = NO;
        self.btndonotshow.hidden = NO;
        self.verticalDevider.hidden = NO;
    }
    else{
        self.btnOK2.hidden = NO;
    }
}

-(void)hideAllAlertButton{
    self.btnOK1.hidden = YES;
    self.btnOK2.hidden = YES;
    self.btndonotshow.hidden = YES;
    self.verticalDevider.hidden = YES;
}

-(IBAction)btnOKForAlertClicked:(id)sender{
    self.alertView.hidden = YES;
    self.transparentView.hidden = YES;

}

-(IBAction)btndonotshowForAlertClicked:(id)sender{
    [Util updateDefaultForKey:kDonotshow toValue:@1];
    self.alertView.hidden = YES;
    self.transparentView.hidden = YES;
}


-(IBAction)btnPlayClicked:(id)sender{
    
    flgPlay = !flgPlay;
    
    [self invaldateTimer];
    //User tap play button
    if (flgPlay) {
        [self startTimer];
        [self.btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }//User tap pause button
    else{
         [self.btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

#pragma mark Mapview delegate method
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker1{
   
    //DKD added so that for stoppage marker we will show date time etc
    MarkerInfoWindow *markerView = nil;
    
    if (marker1.userData) {
        markerView = [[[NSBundle mainBundle] loadNibNamed:@"MarkerWindow1" owner:self options:nil] objectAtIndex:0];
        markerView.lbl1.text = [NSString stringWithFormat:@"Arr. Time: %@",[Util updateDateFormate:marker1.userData[@"StartTime"]]] ;
        markerView.lbl2.text = [NSString stringWithFormat:@"Dep. Time: %@",[Util updateDateFormate:marker1.userData[@"EndTime"]]] ;
        markerView.lbl3.text = [NSString stringWithFormat:@"Duration: %@",marker1.userData[@"Duration"]] ;
        markerView.lbl4.text = [NSString stringWithFormat:@"Distance Travalled: %@ km",marker1.userData[@"DistanceTravalled"]] ;
    }
    
    return markerView;
}


#pragma mark UIPopover delegate method
-(UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller
{
    return UIModalPresentationNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearAllSetting{
    [self invaldateTimer];
    [self.mapView clear];
    self.slider.value = 0;
    activeIndex = 0;
    marker = nil;
    
    timeInterval = NORMAL; //When user select date range then time should be normal
    
    self.sliderTransparentView.hidden = YES;
    self.btnPlay.hidden = YES;
    self.slider.hidden = YES;
    self.lblSpeed.text = @"";
    self.lblDate.text = @"";
    flgPlay = NO;
    [self.btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    selectedTime = @"";

}

#pragma mark Popoverdelegate method
-(void)popoverSelected:(NSString *)title{
    //Speed // [popoverVC updateTableContent:@[@"Very slow",@"Slow",@"Normal",@"Fast",@"Very fast"] withSelectedTitle:selectedSpeed];
    if (selectedValue == 1) {
        selectedSpeed = title;
        if ([selectedSpeed isEqualToString:[@"ITEM_VERY_SLOW" localizableString:@""]]) {
            timeInterval = VERY_SLOW;
        }
        else if ([selectedSpeed isEqualToString:[@"ITEM_SLOW" localizableString:@""]]) {
            timeInterval = SLOW;
        }
        else if ([selectedSpeed isEqualToString:[@"ITEM_NORMAL" localizableString:@""]]) {
            timeInterval = NORMAL;
        }
        else if ([selectedSpeed isEqualToString:[@"ITEM_FAST" localizableString:@""]]) {
            timeInterval = FAST;
        }
        else if ([selectedSpeed isEqualToString:[@"ITEM_VERY_FAST" localizableString:@""]]) {
            timeInterval = VERY_FAST;
        }
        
    }
    else if (selectedValue == 2){
        [self clearAllSetting];
        selectedTime = title;
        
        if ([selectedTime isEqualToString:[@"ITEM_USER_DEFINED" localizableString:@""]]) {
            startDateString = @"";
            endDateString = @""; //@"Please select start date"
            [self createDateView:@{kMaximumDate:[NSDate date],kPickerTitle:@""}];
        }
        else{
            NSDictionary *dict = nil;
            
            if ([selectedTime isEqualToString:[@"ITEM_TODAY" localizableString:@""]]) {
                dict = [Util todayDateRange];
            }
            else if ([selectedTime isEqualToString:[@"ITEM_YESTERDAY" localizableString:@""]]) {
                dict = [Util yesterdayDateRange];
            }
            else if ([selectedTime isEqualToString:[@"ITEM_BEFORE_YESTERDAY" localizableString:@""]]) {
                dict = [Util beforeYesterdayDateRange];
            }
            else if ([selectedTime isEqualToString:[@"ITEM_HOUR_AGO" localizableString:@""]]) {
                dict = [Util hourDateRange];
            }
            startDateString = dict[@"date1"];
            
            endDateString = dict[@"date2"];
            
            [Util showLoader:@"" forView:self.view];
            
            [self fetchTrackedCordinate];
        }
        
    }
    else if (selectedValue == 3){
        selectedMapType = title; //[popoverVC updateTableContent:@[@"Normal",@"Satellite",@"Terrain"] withSelectedTitle:selectedMapType];
        if ([selectedMapType isEqualToString:[@"ITEM_NORMAL" localizableString:@""]]) {
            self.mapView.mapType = kGMSTypeNormal;
        }
        else if ([selectedMapType isEqualToString:[@"ITEM_SATELLITE" localizableString:@""]]) {
            self.mapView.mapType = kGMSTypeSatellite;
        }
        else if ([selectedMapType isEqualToString:[@"ITEM_TERRAIN" localizableString:@""]]) {
            self.mapView.mapType = kGMSTypeTerrain;
        }
    }
    /*
     
     */
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)createDateView:(NSDictionary *)dict{
    
    if (!myDateContainer) {
        myDateContainer = [[MyDateConatiner alloc] init];
        myDateContainer.myDateConatinerDelegate = self;
        [myDateContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:myDateContainer];
        
        //Mydate container width should be same to self.view
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:myDateContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [self.view addConstraint:widthConstraint];
        
        //Make height to 250
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:myDateContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:250];
        [self.view addConstraint:heightConstraint];
        
        NSLayoutConstraint *bottomMargin = [NSLayoutConstraint constraintWithItem:myDateContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.view addConstraint:bottomMargin];
        
        myDateContainer.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0];
        
        [myDateContainer childviewSetup];
    }
    
    [myDateContainer valueSetUp:dict];
    myDateContainer.hidden = NO;

}


-(void)hidePopover{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MyDateConatiner delegate method
-(void)dateChanged:(NSDate *)date{
    
    myDateContainer.hidden = YES;
    
    if (startDateString.length == 0) {
        dtStartDate = date;
        startDateString = [Util dateString:date];
        
        //If max date is bigger than current date then it we will set max date as current date
        NSDate *maxDate = [dtStartDate dateByAddingTimeInterval:24*2*60*60];
        if ([maxDate compare:[NSDate date]]==NSOrderedDescending) {
            maxDate = [NSDate date];
        }
        //Minimum date should be max 2 years
        [self createDateView:@{kMinimumDate:dtStartDate,kPickerTitle:@"Please select end date",kMaximumDate:maxDate}] ;
        myDateContainer.hidden = NO;
    }
    else{
        endDateString = [Util dateString:date];
        dtEndDate = date;
        [Util showLoader:@"" forView:self.view];
        [self fetchTrackedCordinate];
    }
}

-(void)cancelButtonPressed{
    myDateContainer.hidden = YES;
}

@end
