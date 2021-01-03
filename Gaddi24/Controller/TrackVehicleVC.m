//
//  TrackVehicleVC.m
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "TrackVehicleVC.h"

#import "Global.h"
#import "TableViewCell.h"
//#import "UIViewController+MMDrawerController.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "UIView+Style.h"
#import "MapViewAnnotation.h"
#import "CollectionViewCell.h"
//#import "NSString+FontAwesome.h"
#import "PlaybackVC.h"
#import "CommandVC.h"
#import "SummaryVC.h"
#import "PopoverVC.h"
#import "MyDateConatiner.h"
#import "NSString+Localizer.h"

#define METERS_PER_MILE 1609.344



@interface TrackVehicleVC ()<ConnectionHandlerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, PlaybackVCDelegate,PopoverVCDelegate,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate,GMSMapViewDelegate,CLLocationManagerDelegate, MyDateConatinerDelegate>{
    ConnectionHandler *connectionHandler;
    NSTimer *timer;
    
    GMSCameraPosition *camera;
    
    NSArray *staticArray;
    
    NSUInteger selectedOption; //Track which option is selected by user
    
    NSMutableArray *points;
    
    NSMutableArray *markersMutArray;
    
    UINavigationController *nav;
    
    UINavigationController *shareNav;

    
    PopoverVC *popoverVC;
    
    PopoverVC *sharePopOver;

    
    NSString *selectedMapType;
    
    
    CGFloat groupInfoMaxHeight;
    
    BOOL flgShare;
    
    NSArray *arrShare;
    
    UIButton *buttonShare;
    
    NSString *selectedShareType;
    
    MyDateConatiner *myDateContainer;
    
    GMSMarker  *marker;

    UIImageView *markerImgView;


    //CLLocationManager *locationManager;
    
    //CLLocation *currentLocation;
}

@property(nonatomic,weak)IBOutlet NSLayoutConstraint *dividerCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightVehicleInfo;
@property(nonatomic,weak)IBOutlet UIView *viewTransparent;
@property(nonatomic,weak)IBOutlet UITableView *tblViewVehicleList;
@property(nonatomic,weak)IBOutlet UIStackView *normalMapStackView;
@property(nonatomic,weak)IBOutlet UIStackView *stopMapStackView;
@end

static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";
static NSString * const kPolyLine = @"kPolyLine";
static NSString * const kGeoAddress = @"kGeoAddress";
static NSString * const kApiAddress = @"kApiAddress";
static const CGFloat animationDuration = 10;
static const CGFloat VEHICLEINFO_CELL_HEIGHT = 47.0F;


@implementation TrackVehicleVC

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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self invaldateTimer];
    //DKD commeneted on 26Feb2020
    //[self.mapView clear];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.trafficEnabled = NO;
    self.buttonTraffic.selected = NO;
    selectedMapType = @"Normal";
}

-(void)invaldateTimer{
    [timer invalidate];
    timer = nil;
}

-(void)initialsetup{
    
    //Navigation bar setup
    
     selectedShareType = @"";
    
    arrShare = @[[@"ITEM_ONE_DAY" localizableString:@""], [@"ITEM_TWO_DAY" localizableString:@""], [@"ITEM_WEEK" localizableString:@""], [@"ITEM_USER_DEFINED" localizableString:@""]];

       
       groupInfoMaxHeight = [[UIScreen mainScreen] bounds].size.height -49-2*50;//49 navigation bar height, 50 distance from top & bottom
       self.tblViewVehicleList.rowHeight = UITableViewAutomaticDimension;
       self.tblViewVehicleList.estimatedRowHeight = VEHICLEINFO_CELL_HEIGHT;
    
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
    
    /*
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,80, 40)];
    rightView.backgroundColor = [UIColor clearColor];
    */
     
    UIButton *rightButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton1.frame = CGRectMake(0, 0, 40, 40);
    //[leftButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [rightButton1 setTitle:@"\uf0d1" forState:UIControlStateNormal]; //f064 f0c9
    rightButton1.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:21.0f];
    rightButton1.titleLabel.textColor = [UIColor redColor];
    [rightButton1 addTarget:self action:@selector(showAllVehicle) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton2.frame = CGRectMake(40, 0, 40, 40);
    [rightButton2 setTitle:@"\uf064" forState:UIControlStateNormal]; //f064 f0c9
    rightButton2.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:21.0f];
    rightButton2.titleLabel.textColor = [UIColor yellowColor];
    [rightButton2 addTarget:self action:@selector(btnShareClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightView addSubview:rightButton1];
    [rightView addSubview:rightButton2];
     */
    
    //buttonShare = rightButton2;
    
    UIBarButtonItem *rightbarButton=[[UIBarButtonItem alloc] init];
    [rightbarButton setCustomView:rightButton1];
    self.navigationItem.rightBarButtonItem=rightbarButton;
    
    
    markerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    markerImgView.image = [Util mapImage:self.selectedVehicleDict[@"VehicleType"]];
    markerImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    //Creating connection object
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;

    
    [Util showLoader:@"" forView:self.view];
    [self performSelector:@selector(fetchLatestVehicleData) withObject:nil afterDelay:0.1];
    
    //By defalult time should be 30 sec
    if ([[Util retrieveDefaultForKey:kTimeInterval] integerValue] == 0) {
        [Util updateDefaultForKey:kTimeInterval toValue:@30];
    }
    
    //NSLog(@"Default time =%ld",[[Util retrieveDefaultForKey:kTimeInterval] integerValue]);
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:[[Util retrieveDefaultForKey:kTimeInterval] integerValue] target:self selector:@selector(fetchLatestVehicleData) userInfo:nil repeats:YES];
    
    
    
    self.mapView.delegate = self;
    
    selectedOption = 0;
    
    selectedMapType = @"Normal";
    
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
    
    //Track view setup
    //DKD commneted on 12 Apr 2020
    id flag  = @"\uf041"; //[NSString fontAwesomeIconStringForEnum:FAMapMarker];
    self.lblLocationIcon.text = [NSString stringWithFormat:@"%@", flag];
    self.lblLocationIcon.textColor = [UIColor whiteColor];
    
    
    staticArray = @[@{kTitleName:[@"ITEM_TRACK" localizableString:@""],kFontAwsomeName:@"\uf278"},
    @{kTitleName:[@"ITEM_HISTORY" localizableString:@""],kFontAwsomeName:@"\uf04b"},
    @{kTitleName:[@"ITEM_ENGINE" localizableString:@""],kFontAwsomeName:@"\uf046"},
                    @{kTitleName:[@"ITEM_SUMMARY" localizableString:@""],kFontAwsomeName:@"\uf200"},
    ];
   
    [self.btnHide setTitle:[@"BTN_HIDE" localizableString:@""] forState:UIControlStateNormal];

    
    points = [[NSMutableArray alloc]initWithCapacity:10]; //This will hold all the oordinate
    markersMutArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    camera = [GMSCameraPosition cameraWithLatitude:[self.selectedVehicleDict[@"Latitude"] doubleValue]
                                         longitude:[self.selectedVehicleDict[@"Longitude"] doubleValue]
                                              zoom:15];
    self.mapView.camera = camera;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTrackVehicle) name:kTrackVehicleNotification object:nil];
    
    self.btnShowHideMap.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:20];
    [self.btnShowHideMap setTitle:@"\uf100" forState:UIControlStateNormal];
    [self.btnShowHideMap setTitle:@"\uf101" forState:UIControlStateSelected];
    
    self.buttonParking.selected = [self.vehicleDataDict[@"ParkingMode"] boolValue];
    
}

#pragma mark Navigation bar setup
-(void)showAllVehicle{
    [self showHideAllVehicleList:NO];
    
    CGFloat expectedHeight = [self.allVehicleArray count]*VEHICLEINFO_CELL_HEIGHT;
    //Check if height is more than max height if yes then select height to max else this will be expected height
    if (expectedHeight>=groupInfoMaxHeight) {
        expectedHeight = groupInfoMaxHeight;
    }
    
    self.constraintHeightVehicleInfo.constant = expectedHeight;
}

-(IBAction)btnShareClicked:(UIButton*)sender{
    flgShare = true;
    
    if (sharePopOver==nil) {
        [self createSharePopover];
    }
    
    sharePopOver.flgAllowDoubleTap = YES;
    [sharePopOver updateTableContent:arrShare withSelectedTitle:selectedShareType];
    sharePopOver.showFontAwsome = true;
    shareNav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover = shareNav.popoverPresentationController;
    sharePopOver.preferredContentSize = CGSizeMake(180, 120);
    popover.delegate = self;
    popover.barButtonItem = self.navigationItem.rightBarButtonItems[0];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:shareNav animated:YES completion:nil];
}

-(void)createSharePopover{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    sharePopOver = [storyboard instantiateViewControllerWithIdentifier:@"PopoverVC"];
    sharePopOver.popoverVCDelegate = self;
    shareNav = [[UINavigationController alloc]initWithRootViewController:sharePopOver];
}

/*-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
     currentLocation = [locations lastObject];
    //   NSDate* eventDate = location.timestamp;
    // NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    double latitud = currentLocation.coordinate.latitude;
    double longitud = currentLocation.coordinate.longitude;
    NSLog(@"%f,%f",latitud,longitud);
    
    [Util showAlert:@"" andMessage:[NSString stringWithFormat:@"%f and %f",latitud,longitud] forViewController:self];
    
    [locationManager stopUpdatingLocation];
    
}*/


-(void)fetchLatestVehicleData{
    //NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/%@/LiveData",self.selectedVehicleDict[@"VehicleId"]];
    
    NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/%d/LiveData",[self.selectedVehicleDict[@"VehicleId"] intValue]];
    
    //NSLog(@"apiRequest =%@",apiRequest);
    
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
            ////NSLog(@"vehcile data =%@",responseDict[kResponse]);
            self.vehicleDataDict = responseDict[kResponse][0];
            [self processRespose];
        }
        [Util hideLoader:self.view];
    });
}

-(void)processRespose__09Feb2020{
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    
    //This will clear all existing marker
    //DKD commneted on 09 Feb 2020
    
    /*
    for (GMSMarker *marker in markersMutArray) {
        marker.map = nil;
    }
     */
    
    CGFloat currentZoom = self.mapView.camera.zoom;
    
    camera = [GMSCameraPosition cameraWithLatitude:[self.vehicleDataDict[@"Latitude"] doubleValue]
                                         longitude:[self.vehicleDataDict[@"Longitude"] doubleValue]
                                              zoom:currentZoom];
    self.mapView.camera = camera;
    
    GMSMarker  *marker = [[GMSMarker alloc] init];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.vehicleDataDict[@"Latitude"] doubleValue], [self.vehicleDataDict[@"Longitude"] doubleValue]);
    
    marker.position = coordinate;
    
    marker.rotation = [self.vehicleDataDict[@"Direction"] floatValue];
    
    [points addObject:[NSValue valueWithMKCoordinate:coordinate]];
    
    marker.icon = [UIImage imageNamed:@"unreachable_car.png"];
    
    //Active
    if ([self.vehicleDataDict[@"VehicleState"] intValue]==1) {
        marker.icon = [UIImage imageNamed:@"active_car.png"];
    }
    //Idle
    else if ([self.vehicleDataDict[@"VehicleState"] intValue]==2){
        marker.icon = [UIImage imageNamed:@"idel_car.png"];
    }
    else if ([self.vehicleDataDict[@"VehicleState"] intValue]==3){
        marker.icon = [UIImage imageNamed:@"stop_car.png"];
    }
    
    
    
    marker.map = self.mapView;

    [markersMutArray addObject:marker];
    
    self.mapView.hidden = NO;
    self.buttonTraffic.hidden = self.mapView.hidden;
    self.buttonMap.hidden = self.mapView.hidden;
    self.buttonDirection.hidden = self.mapView.hidden;
    
    [self drawLineBetweenLocation]; //Draw line between location
    //DKD added this on 07 July 2019
    [self getGeoAddress: [self.vehicleDataDict[@"LoadFromGoogle"] intValue]?YES:NO];
    
    //I will update collection view when trackview container is visible
    
    if (self.trackViewContainer.hidden == NO) {
        [self.collectionView2 reloadData];
    }
    self.lblTime.text = [Util updateDateFormate:self.vehicleDataDict[@"DateTimeOfLog"]] ;
    
    [self.collectionView2 reloadData];

}

-(void)processRespose{
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    
    //This will clear all existing marker
    //DKD commneted on 09 Feb 2020
    
    /*
    for (GMSMarker *marker in markersMutArray) {
        marker.map = nil;
    }
     */
    
    CGFloat currentZoom = self.mapView.camera.zoom;
    
    camera = [GMSCameraPosition cameraWithLatitude:[self.vehicleDataDict[@"Latitude"] doubleValue]
                                         longitude:[self.vehicleDataDict[@"Longitude"] doubleValue]
                                              zoom:currentZoom];
    self.mapView.camera = camera;
    
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.vehicleDataDict[@"Latitude"] doubleValue], [self.vehicleDataDict[@"Longitude"] doubleValue]);
    
    [self.mapView animateToCameraPosition:camera];
    
    if (!marker){
        marker = [[GMSMarker alloc] init];
        marker.position = coordinate;
        markerImgView.image = [Util mapImage:self.vehicleDataDict[@"VehicleType"]];
        marker.iconView = markerImgView;
        markerImgView.tintColor = [Util vehicleColor:self.vehicleDataDict];
        marker.rotation = [self.vehicleDataDict[@"Direction"] floatValue];
        marker.map = self.mapView;
       }else{
           [CATransaction begin];
           [CATransaction setAnimationDuration:[[Util retrieveDefaultForKey:kTimeInterval] integerValue]]; //animationduration
           marker.position = coordinate;
           markerImgView.image = [Util mapImage:self.vehicleDataDict[@"VehicleType"]];
           marker.iconView = markerImgView;
           markerImgView.tintColor = [Util vehicleColor:self.vehicleDataDict];
           marker.rotation = [self.vehicleDataDict[@"Direction"] floatValue];
           [CATransaction commit];
       }
    
    [points addObject:[NSValue valueWithMKCoordinate:coordinate]];
    
    [markersMutArray addObject:marker];
    
    self.mapView.hidden = NO;
    self.buttonTraffic.hidden = self.mapView.hidden;
    self.buttonMap.hidden = self.mapView.hidden;
    self.buttonDirection.hidden = self.mapView.hidden;
    
    
    //DKD added this on 09 Feb 2020
    [self performSelector:@selector(drawLineBetweenLocation) withObject:nil afterDelay:animationDuration];
    //[self drawLineBetweenLocation]; //Draw line between location
    
    //DKD added this on 07 July 2019
    [self getGeoAddress: [self.vehicleDataDict[@"LoadFromGoogle"] intValue]?YES:NO];
    
    //I will update collection view when trackview container is visible
    
    if (self.trackViewContainer.hidden == NO) {
        [self.collectionView2 reloadData];
    }
    self.lblTime.text = [Util updateDateFormate:self.vehicleDataDict[@"DateTimeOfLog"]] ;
    
    NSLog(@"parking mmode =%d",[self.vehicleDataDict[@"ParkingMode"] boolValue]);
    
    self.buttonParking.selected = [self.vehicleDataDict[@"ParkingMode"] boolValue];
    
    [self.collectionView2 reloadData];

}

-(void)drawLineBetweenLocation{
    //Api request to provide actual path between 2 coordinate
    /*
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           [self.selectedVehicleDict[@"Latitude"] doubleValue],
                           [self.selectedVehicleDict[@"Longitude"] doubleValue],
                           [self.vehicleDataDict[@"Latitude"] doubleValue],
                           [self.vehicleDataDict[@"Longitude"] doubleValue],
                           GOOGLE_API_KEY];
    
    NSDictionary *requestDict = @{kApiRequest:urlString,kRequestFor:kPolyLine};
    [connectionHandler makeGoogleConnectionWithRequest:requestDict];
     */
    //Here we have more than 1 coordinate hence draw line between them
    if ([points count]>1) {
        CLLocationCoordinate2D coordinate1 = [[points objectAtIndex:[points count]-2] MKCoordinateValue]; //Second last element in array
        CLLocationCoordinate2D coordinate2 = [[points objectAtIndex:[points count]-1] MKCoordinateValue];//last element in array
        
        GMSMutablePath *path = [GMSMutablePath path];
        [path addCoordinate:coordinate1];
        [path addCoordinate:coordinate2];
        
        GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
        singleLine.strokeWidth = 4.0f;
        singleLine.strokeColor = [UIColor colorWithRed:73/255.0f green:134/255.0f blue:231/255.0f alpha:1];
        singleLine.map = _mapView;
    }
}

-(void)getGeoAddress:(BOOL)flgFromGoogle{
    //NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",[self.vehicleDataDict[@"Latitude"] doubleValue],[self.vehicleDataDict[@"Longitude"] doubleValue]];
    
    //check isloadfromgoogle from vehicleDataDict field then use from google otherwise use below in case if no data from google then use below
    
    //http://www.gaddi24.com/api/v1/
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.gaddi24.com/api/v1/Location/Address/%f/%f/",[self.vehicleDataDict[@"Latitude"] doubleValue],[self.vehicleDataDict[@"Longitude"] doubleValue]];
    
    NSString *address = kApiAddress;
    if (flgFromGoogle) {
        
        //https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,
        // +Mountain+View,+CA&key=YOUR_API_KEY
        
        //http://maps.googleapis.com/maps/api/geocode/json?latlng=23.646046,88.126381&sensor=true,key=AIzaSyCiCktshcTFOH3GA8--Jt4nTZhx-2Uv5yE
        //        https://maps.googleapis.com/maps/api/geocode/json?latlng=23.646046,88.126381&sensor=true&key=AIzaSyCgiKrrND8U_543Fl2Om8eifjNN93JO8-s
        
        urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true&key=%@",[self.vehicleDataDict[@"Latitude"] doubleValue],[self.vehicleDataDict[@"Longitude"] doubleValue],GOOGLE_API_KEY];
        address = kGeoAddress;
    }
    
    NSDictionary *requestDict = @{kApiRequest:urlString,kRequestFor:address};
    [connectionHandler makeGoogleConnectionWithRequest:requestDict];
}

-(void)receiveGoogleResponse:(id)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([(responseDict[kRequest][kRequestFor]) isEqualToString:kPolyLine]) {
            GMSPath *path =[GMSPath pathFromEncodedPath:responseDict[kResponse][@"routes"][0][@"overview_polyline"][@"points"]];
            GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
            singleLine.strokeWidth = 4;
            singleLine.strokeColor = [UIColor blueColor];
            singleLine.map = self.mapView;
        }
        else if ([(responseDict[kRequest][kRequestFor]) isEqualToString:kGeoAddress]) {
            
            NSArray *resultArray = responseDict[kResponse][@"results"];
            if ([resultArray count]>0) {
                NSDictionary *dict= resultArray[0];
                self.lblLocation.text = dict[@"formatted_address"];
            }
            else{
                [self getGeoAddress:false];
            }
        }
        else{
            if ([responseDict[kResponse] isKindOfClass:[NSString class]] && ![responseDict[kResponse] isEqual:[NSNull null]] && responseDict[kResponse] != nil) {
                NSString *text = [responseDict[kResponse] stringByReplacingOccurrencesOfString:@"\""
                                                                                    withString:@""];;
                self.lblLocation.text = text;
            }
            else{
                self.lblLocation.text = @"";
            }
        }
        
    });
}

#pragma mark Collection view datasource & delegate method

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger cellCount = staticArray.count;
    if (collectionView.tag == 1002) {
        cellCount = 4;
    }
    return cellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (collectionView.tag == 1001) {
        
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
    
    else if (collectionView.tag == 1002) {
        
        NSString *fontawsomeCode = @"";
        NSString *title = @"";
        UIImage *image = [UIImage imageNamed:@""];
        
        cell.view1.hidden = YES;
        
        if (indexPath.row == 0) {
            
            //fontawsomeCode = @"\uf0d1";
            
            [cell.view1 updateStyleWithInfo:@{kBorderColor:[UIColor clearColor],kCornerRadius:@(cell.view1.frame.size.width/2),kBorderWidth:@0}];
            
            [cell.view1 setBackgroundColor:[UIColor colorWithRed:143/255.0f green:144/255.0f blue:145/255.0f alpha:1]];
            title = @"Unreachable";
            //Active
            if ([self.vehicleDataDict[@"VehicleState"] intValue]==1) {
                [cell.view1 setBackgroundColor:[UIColor colorWithRed:107/255.0f green:205/255.0f blue:78/255.0f alpha:1]];
                title = @"Active";
            }
            //Idle
            else if ([self.vehicleDataDict[@"VehicleState"] intValue]==2){
                [cell.view1 setBackgroundColor:[UIColor colorWithRed:255/255.0f green:143/255.0f blue:51/255.0f alpha:1]];
                title = @"Idle";
            }
            else if ([self.vehicleDataDict[@"VehicleState"] intValue]==3){
                [cell.view1 setBackgroundColor:[UIColor redColor]];
                title = @"Stop";
            }
            
             //cell.view1.hidden = NO;
            image = [Util normalImage:self.vehicleDataDict[@"VehicleType"]];
            cell.imageView1.tintColor = [Util vehicleColor:self.vehicleDataDict];
            
        }
        else if (indexPath.row==1 && [self.vehicleDataDict[@"BatteryStatus"] intValue]) {
            title = @"Full";
            image = [UIImage imageNamed:@"battery_vertical_green.png"];
        }
        else if (indexPath.row==1 && ![self.vehicleDataDict[@"BatteryStatus"] intValue]) {
            title = @"Empty";
            image = [UIImage imageNamed:@"battery_vertical_red.png"];
        }
        
//        else if (indexPath.row==2 && [self.vehicleDataDict[@"ACStatus"] intValue]) {
//            title = @"AC On";
//            image = [UIImage imageNamed:@"ac_normal.png"];
//        }
//        else if (indexPath.row==2 && ![self.vehicleDataDict[@"ACStatus"] intValue]) {
//            title = @"AC Off";
//            image = [UIImage imageNamed:@"ac_idle.png"];
//        }
        else if (indexPath.row==2){
            fontawsomeCode = @"\uf0e4";
            title = [NSString stringWithFormat:@"%.2f km/h",[self.vehicleDataDict[@"Speed"] floatValue]];
        }
        else if (indexPath.row==3){
            fontawsomeCode = @"\uf017";
            title = [Util updateDurationFormate:self.vehicleDataDict[@"Duration"]];
        }
//        else if (indexPath.row==5){
//            image = [UIImage imageNamed:@"fuelpump_icon.png"];
//            title = [NSString stringWithFormat:@"%.2f Ltr",[self.vehicleDataDict[@"FuelReading"] doubleValue]];
//        }

        cell.imageView1.image = image;
        cell.lbl1.textColor = [UIColor whiteColor];
        
        cell.lbl1.text = [NSString stringWithFormat:@"%@", fontawsomeCode];
        cell.lbl2.text = title;
        
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = collectionView.frame.size;
    //Loading track view content
    if (collectionView.tag == 1002) {
        size.width = size.width/4.0f;
    }
    else{
        size.width = size.width/staticArray.count;
    }
    
    size.height = size.height;
    
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    if (collectionView.tag == 1001 && indexPath.row == 0) {
        
        
        self.trackViewContainer.hidden = !self.trackViewContainer.hidden;
        self.btnHide.hidden = !self.btnHide.hidden;
        
        
        selectedOption = indexPath.row;
        [self.collectionView1 reloadData];
        [self.collectionView2 reloadData];
    }
    
    else if (collectionView.tag == 1001 && indexPath.row == 1){
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
    
    else if (collectionView.tag == 1001 && indexPath.row == 2){
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
    else if (collectionView.tag == 1001 && indexPath.row == 3){
        
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

-(void)createPopover{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"PopoverVC"];
    popoverVC.popoverVCDelegate = self;
    nav = [[UINavigationController alloc]initWithRootViewController:popoverVC];
}


#pragma mark ---------------------Working on it-------------------


-(IBAction)btnMapClicked:(id)sender{
    
    //UIButton *button = (UIButton *)sender;
    
    if (popoverVC==nil) {
        [self createPopover];
    }
    
    [popoverVC updateTableContent:@[[@"ITEM_NORMAL" localizableString:@""],[@"ITEM_SATELLITE" localizableString:@""],[@"ITEM_TERRAIN" localizableString:@""]] withSelectedTitle:selectedMapType];
    nav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover = nav.popoverPresentationController;
    popoverVC.preferredContentSize = CGSizeMake(140, 90);
    popover.delegate = self;
    popover.sourceView = sender; //self.buttonTemp
    //popover.sourceRect = button.frame;
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)btnTrafficClicked:(id)sender{
    UIButton *btnTraffic = sender;
    btnTraffic.selected = !btnTraffic.selected;
    self.mapView.trafficEnabled = btnTraffic.selected;
}

-(IBAction)btnDirectionClicked:(id)sender{
    
    //https://developers.google.com/maps/documentation/urls/ios-urlscheme#check_the_availability_of_the_google_maps_app_on_the_device
    
    //Below is required to make proper formatting of address(city, state, zipcode)
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSString * dest_addr = [self.lblLocation.text stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    //URL to open in Apple map
    NSString *directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&dirflg=d",[self.selectedVehicleDict[@"Latitude"] floatValue],[self.selectedVehicleDict[@"Longitude"] floatValue]];
    
    //Check if link can be opened in google map
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        directionsURL =[NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving",[self.selectedVehicleDict[@"Latitude"] floatValue],[self.selectedVehicleDict[@"Longitude"] floatValue]];
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
    }
}

- (IBAction)btnParkingClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    NSString *apiRequest = [NSString stringWithFormat:@"Vehicle/Controlling/SetParkingMode/%d/%d",[self.selectedVehicleDict[@"VehicleId"] intValue],sender.selected];
    NSDictionary *requestDict = @{kApiRequest:apiRequest};
    
    [Util showLoader:@"" forView:self.view];
    
    [connectionHandler postRequestWithRequest:requestDict completionHandler:^(NSError *error, NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *message = @"Parking mode deactivated.";
            
            if (error) {
                sender.selected = !sender.selected;
            }
            else if (dict){
                //[[Util checkNullValue:dict[@"Message"]] length]==0 || [dict[@"Message"] isEqualToString:@"Success"] == false
                if ([dict[@"IsError"] intValue] == 1){
                    sender.selected = !sender.selected;
                }
                if (sender.selected) {
                    message = @"Parking mode activated.";
                }
                [Util showAlert:@"" andMessage:message forViewController:self];
            }
            [Util hideLoader:self.view];
            NSLog(@"parking response =%@", dict);
        });
    }];
}

-(void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnHideClicked:(id)sender{
    self.btnHide.hidden = YES;
    self.trackViewContainer.hidden = YES;
}

-(void)btnVideoClicked{
    //NSLog(@"Video calling handle");
}

-(void)showNotificationPage{
    //NSLog(@"Do nothing");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Popoverdelegate method
-(void)popoverSelected:(NSString *)title{
   
    if (flgShare) {
        selectedShareType = title;
        if ([title isEqualToString:@"User-defined"]) {
            [self dismissViewControllerAnimated:true completion:^{
                [self createDateView:@{kMinimumDate:[NSDate date]}];
            }];
        }
        else{
            NSString *endDateString = [Util fromDateToStringConverter:@{kActualDateFormate:SHARE_REQUIRED_DATE,kDate:[Util addTimeinCurrentDate:title]}];

            [self dismissViewControllerAnimated:true completion:^{
                [self shareText:endDateString];
            }];
        }
    }
    else{
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)shareText:(NSString *)endDateString{
    //NSDictionary *dict = flgShare.infoDict;
    [Util shareText:endDateString forViewController:self forVehicleID:self.selectedVehicleDict[@"VehicleId"]];
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
    myDateContainer.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    myDateContainer.datePicker.minimumDate = [NSDate date];//This will make date to satrt frmom 04 year
    myDateContainer.datePicker.date = [NSDate date];
    myDateContainer.hidden = NO;
}

#pragma mark MyDateConatiner delegate method
-(void)dateChanged:(NSDate *)date{
    myDateContainer.hidden = YES;
    NSString *endDateText = [Util fromDateToStringConverter:@{kActualDateFormate:SHARE_REQUIRED_DATE,kDate:date}];
    [self shareText:endDateText];
}

-(void)cancelButtonPressed{
    myDateContainer.hidden = YES;
}

-(UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller
{
    return UIModalPresentationNone;
}


#pragma mark playback delegate method
-(void)showTrackVehicle{
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self collectionView:_collectionView1 didSelectItemAtIndexPath:indexpath];
    
    self.trackViewContainer.hidden = YES;
    self.btnHide.hidden = YES;
    
    [Util showLoader:@"" forView:self.view];
    [self performSelector:@selector(fetchLatestVehicleData) withObject:nil afterDelay:0.1];

    timer = [NSTimer scheduledTimerWithTimeInterval:[[Util retrieveDefaultForKey:kTimeInterval] integerValue] target:self selector:@selector(fetchLatestVehicleData) userInfo:nil repeats:YES];
}

#pragma mark dealloc 

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Since we want to display our custom info window when a marker is tapped, use this delegate method
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    self.trackViewContainer.hidden = !self.trackViewContainer.hidden;
    self.btnHide.hidden = !self.btnHide.hidden;
    
    return YES;
}


#pragma mark Bthshowhidemap clicked

- (IBAction)btnShowHideMapClicked:(UIButton *)sender {
    
    
    self.stopMapStackView.hidden = true;
    self.normalMapStackView.hidden = true;
    
    if ([self.vehicleDataDict[@"VehicleState"] intValue] == 3) {
        self.stopMapStackView.hidden = false;
    }
    else{
       self.normalMapStackView.hidden = false;
    }
    
    
    if (self.stackViewTrailing.constant > 0) {
        self.stackViewTrailing.constant = -40;
    }else{
        self.stackViewTrailing.constant = 15;
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:2 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        sender.selected = !sender.selected;
    }];
    
}

#pragma mark -
#pragma mark Tableview datasource & delegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.allVehicleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor whiteColor];
    NSDictionary *dict = self.allVehicleArray[indexPath.row];
    cell.lbl1.text = dict[@"VehicleName"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self invaldateTimer];
    [self.mapView clear];
    [markersMutArray removeAllObjects];
    [points removeAllObjects];
    
    //DKD added this on 09Feb2020
    marker = nil;
    
    self.selectedVehicleDict = self.allVehicleArray[indexPath.row];
    self.navigationItem.title = self.selectedVehicleDict[@"VehicleName"];
    [Util showLoader:@"" forView:self.view];
    [self performSelector:@selector(fetchLatestVehicleData) withObject:nil afterDelay:0.1];
    [self showHideAllVehicleList:YES];
    
    //DKD added this on 18Apr2020 hide the map view if vehicle selected
    if (self.stackViewTrailing.constant > 0) {
        [self btnShowHideMapClicked:nil];
    }
    
    //self.btnHide.hidden = NO;
    //self.trackViewContainer.hidden = NO;
    
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

-(IBAction)btnShowVehicleClicked:(UIButton *)button{
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch view]==self.viewTransparent) {
        [self showHideAllVehicleList:YES];
    }
}

-(void)showHideAllVehicleList:(BOOL)flag{
    self.viewTransparent.hidden = flag;
    self.tblViewVehicleList.hidden = flag;
}

@end
