//
//  BirdViewVC.m
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "BirdViewVC.h"

#import "Global.h"
#import "TableViewCell.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "UIView+Style.h"
#import "MapViewAnnotation.h"
#import "CollectionViewCell.h"
//
#import "MarkerView.h"
#import "MarkerInfoWindow.h"
#import "TrackVehicleVC.h"
#import "PopoverVC.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+Localizer.h"


#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface BirdViewVC ()<ConnectionHandlerDelegate,GMSMapViewDelegate,PopoverVCDelegate,UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate>{
    ConnectionHandler *connectionHandler;
    NSTimer *timer;
    
    GMSCameraPosition *camera;
    
    NSArray *staticArray;
    
    NSUInteger selectedOption; //Track which option is selected by user
    
    NSMutableArray *points;
    
    NSMutableArray *markersMutArray;
    
    BOOL flgMapIsZoomed; //This will track if map is zoomed if Yes then no need to update camera position, curently considering when marker is loaded first time then user has zoomed the map
    UINavigationController *nav;
    
    PopoverVC *popoverVC;
    
    NSString *selectedMapType;
    
}

//https://gist.github.com/jonfriskics/11200039      I used this to show mapview

// this will hold the custom info window we're displaying
@property (strong, nonatomic) MarkerInfoWindow *displayedInfoWindow;

/* these three will be used to guess the state of the map animation since there's no
 delegate method to track when the camera update ends */
@property BOOL markerTapped;
@property BOOL cameraMoving;
@property BOOL idleAfterMovement;

/* Since I'm creating the info window based on the marker's position in the
 mapView:idleAtCameraPosition: method, I need a way for that method to know
 which marker was most recently tapped, so I'm using this to store that most
 recently tapped marker */
@property (strong, nonatomic) GMSMarker *currentlyTappedMarker;

@end

static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";
static NSString * const kPolyLine = @"kPolyLine";
static NSString * const kGeoAddress = @"kGeoAddress";

@implementation BirdViewVC

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
    
    [self fetchAllVehicleData];
    //By defalult time should be 30 sec
    if ([[Util retrieveDefaultForKey:kTimeInterval] integerValue] == 0) {
        [Util updateDefaultForKey:kTimeInterval toValue:@30];
    }
    
    //NSLog(@"Default time =%ld",[[Util retrieveDefaultForKey:kTimeInterval] integerValue]);
    
    timer = [NSTimer scheduledTimerWithTimeInterval:[[Util retrieveDefaultForKey:kTimeInterval] integerValue] target:self selector:@selector(fetchAllVehicleData) userInfo:nil repeats:YES];
    
    //DKD added on 18 Apr 2020, as if there is no data then updating vehicle list is not required.
    if ([self.allVehicleArray count] > 0) {
        [self showMarker];
    }

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self invaldateTimer];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView clear];
    [self.displayedInfoWindow removeFromSuperview];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.trafficEnabled = NO;
}

-(void)invaldateTimer{
    [timer invalidate];
    timer = nil;
}

-(void)initialsetup{
    
    //Navigation bar setup
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = [@"ITEM_BIRDVIEW" localizableString:@""];
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"PopoverVC"];
    popoverVC.popoverVCDelegate = self;
    nav = [[UINavigationController alloc]initWithRootViewController:popoverVC];
    
    selectedMapType = @"Normal";

    
    self.markerTapped = NO;
    self.cameraMoving = NO;
    self.idleAfterMovement = NO;
    
    
    markersMutArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    
    //Creating connection object
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    
    self.mapView.delegate = self;
    
    camera = [GMSCameraPosition cameraWithLatitude:72
                                         longitude:37
                                              zoom:15];
    self.mapView.camera = camera;

    
}

-(void)fetchAllVehicleData{
    NSDictionary *requestDict = @{kApiRequest:@"Vehicle/LiveData"};
    [connectionHandler makeConnectionWithRequest:requestDict];
}

-(void)showMarker{
    
    //We will clear all previously hold data
    [self.mapView clear];
    [markersMutArray removeAllObjects];
    
    for (NSDictionary *dict in self.allVehicleArray) {
        
        ////NSLog(@"Marker is created & added");
        
        GMSMarker  *marker = [[GMSMarker alloc] init];
        
        marker.userData = dict;//This will hold the dictinary needed to show on marker when selected
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([dict[@"Latitude"] doubleValue], [dict[@"Longitude"] doubleValue]);
        
        marker.position = coordinate;
        
        MarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"VehicleSmallView" owner:self options:nil] objectAtIndex:0];
        
        markerView.lbl1.frame = CGRectMake(10, 10, 320, 11);
        markerView.lbl1.text = dict[@"VehicleName"];
        markerView.lbl1.numberOfLines = 0;
        [markerView.lbl1 sizeToFit];
        
        CGRect vehicleNameFrame = markerView.lbl1.frame;
        markerView.view1.frame = CGRectMake(0, 0, vehicleNameFrame.size.width+20, 31);
        [markerView.view1 updateStyleWithInfo:@{kCornerRadius:@3.0f, kBorderWidth:@1.0f,kBorderColor:[UIColor colorWithRed:227/255.0f green:224/255.0f blue:216/255.0f alpha:1.0f]}];
        
        CGFloat triangleOrignin = markerView.view1.center.x-(markerView.imageView1.frame.size.width)/2;//sice triangle xorigin = markerView.view1.center.x - triangle.width/2
        markerView.imageView1.frame = CGRectMake(triangleOrignin, 21, 20, 20);
        
        CGFloat vehicleOrignin = markerView.view1.center.x-(markerView.imageView2.frame.size.width)/2;//sice vehicle xorigin = markerView.view1.center.x - vehicle.width/2
        
        
        markerView.imageView2.image = [Util mapImage:dict[@"VehicleType"]];
        markerView.imageView2.contentMode = UIViewContentModeScaleAspectFit;
        markerView.imageView2.tintColor = [Util vehicleColor:dict];
        markerView.imageView2.frame = CGRectMake(vehicleOrignin, 36, 30, 30);
        markerView.imageView2.transform = CGAffineTransformMakeRotation([dict[@"Direction"] floatValue]); //DKD added on 27Feb2020 as need tp show vehicle direction.
        
        
        //DKD added this to set manually set size of markerview so as label increses size will also be icreased
        CGRect markerFrame = CGRectMake(0, 0, 212, 70);
        markerFrame.size.width = markerView.view1.frame.size.width;
        markerView.frame = markerFrame;
        markerView.backgroundColor = [UIColor clearColor];
        
        marker.iconView = markerView;
        
        marker.map = self.mapView;

        
        [markersMutArray addObject:marker];
    }
    
    
    if (flgMapIsZoomed == NO) {
        [self updateCameraPosition];
        flgMapIsZoomed = YES;
    }
    
}

-(void)updateCameraPosition{
    GMSMutablePath *path = [GMSMutablePath path];
    
    for (GMSMarker *marker in markersMutArray) {
        [path addCoordinate: marker.position];
    }
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
}

#pragma mark make connection to server and handle response
#pragma mark Connection response handling
-(void)receiveResponse:(id)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([responseDict[kResponse] isEqual:[NSNull null]]|| responseDict[kResponse] == nil) {
            [Util showAlert:@"" andMessage:@"Oops! Something went wrong. We will take care of it soon." forViewController:self];
        }
        
        else if (responseDict[kResponse]) {
            self.allVehicleArray = responseDict[kResponse];
            [self showMarker];
        }
        [Util hideLoader:self.view];
    });
}



#pragma mark Button action handling


#pragma mark Button action handling

-(IBAction)btnMapClicked:(id)sender{
    [popoverVC updateTableContent:@[@"Normal",@"Satellite",@"Terrain"] withSelectedTitle:selectedMapType];
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

//DKD added on 18 Apr 2020
-(void)btnBackClicked{
    
    if([[Util retrieveDefaultForKey:kHomeScreen] integerValue] == BIRDVIEW_TAG){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
        UIViewController *center = [storyboard instantiateViewControllerWithIdentifier:@"VehicleListVC"];
        UINavigationController *navCenter = [[UINavigationController alloc]initWithRootViewController:center];
        [self.mm_drawerController setCenterViewController:navCenter];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnVideoClicked{
    //NSLog(@"Video calling handle");
}

-(void)showNotificationPage{
    //NSLog(@"Do nothing");
}

-(IBAction)btnTrackClicked:(id)sender{
    TrackVehicleVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"TrackVehicleVC"];
    VC.selectedVehicleDict = self.currentlyTappedMarker.userData;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Mapview delegate method


// Since we want to display our custom info window when a marker is tapped, use this delegate method
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    
    // A marker has been tapped, so set that state flag
    self.markerTapped = YES;
    
    // If a marker has previously been tapped and stored in currentlyTappedMarker, then nil it out
    if(self.currentlyTappedMarker) {
        self.currentlyTappedMarker = nil;
    }
    
    // make this marker our currently tapped marker
    self.currentlyTappedMarker = marker;
    
    // if our custom info window is already being displayed, remove it and nil the object out
    if([self.displayedInfoWindow isDescendantOfView:self.view]) {
        [self.displayedInfoWindow removeFromSuperview];
        self.displayedInfoWindow = nil;
    }
    
    /* animate the camera to center on the currently tapped marker, which causes
     mapView:didChangeCameraPosition: to be called */
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:marker.position];
    [self.mapView animateWithCameraUpdate:cameraUpdate];
    
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    /* if we got here after we've previously been idle and displayed our custom info window,
     then remove that custom info window and nil out the object */
    if(self.idleAfterMovement) {
        if([self.displayedInfoWindow isDescendantOfView:self.view]) {
            [self.displayedInfoWindow removeFromSuperview];
            self.displayedInfoWindow = nil;
        }
    }
    
    // if we got here after a marker was tapped, then set the cameraMoving state flag to YES
    if(self.markerTapped) {
        self.cameraMoving = YES;
    }
}

// This method gets called whenever the map was moving but has now stopped
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    
    /* if we got here and a marker was tapped and our animate method was called, then it means we're ready
     to show our custom info window */
    if(self.markerTapped && self.cameraMoving) {
        
        // reset our state first
        self.cameraMoving = NO;
        self.markerTapped = NO;
        self.idleAfterMovement = YES;
        
        // create our custom info window UIView and set the color to blueish
        self.displayedInfoWindow = [[[NSBundle mainBundle] loadNibNamed:@"MarkerWindow" owner:self options:nil] objectAtIndex:0];;
        
        
        /* pointForCoordinate: takes a lat/lng and converts it into that lat/lngs current equivalent screen point.
         We'll use this to offset the display of the bottom of the custom info window so it doesn't overlap
         the marker icon. */
        CGPoint markerPoint = [self.mapView.projection pointForCoordinate:self.currentlyTappedMarker.position];
        
        int originX = 78;
        
        //Added a patch to handle the window in ipad
        if ( IDIOM == IPAD ) {
            
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
                originX = 400;
            }
            else{
                originX = 270;
            }
        }
       
        self.displayedInfoWindow.frame = CGRectMake(originX, markerPoint.y-175, 212, 140);
        
        self.displayedInfoWindow.lbl1.text = self.currentlyTappedMarker.userData[@"VehicleName"];
        self.displayedInfoWindow.lbl2.text = [Util updateDateFormate:self.currentlyTappedMarker.userData[@"DateTimeOfLog"]] ;
        self.displayedInfoWindow.lbl3.text = self.currentlyTappedMarker.userData[@"VehicleStateName"];
        [self.displayedInfoWindow.btn1 addTarget:self action:@selector(btnTrackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.displayedInfoWindow.btn1 setTitle:[@"BTN_TRACK_VEHICLE" localizableString:@""] forState:UIControlStateNormal];

        
        [self.displayedInfoWindow.view1 updateStyleWithInfo:@{kBorderColor:[UIColor clearColor],kCornerRadius:@(7.5f),kBorderWidth:@0}];
        
        [self.displayedInfoWindow.view1 setBackgroundColor:[UIColor redColor]];
        //Active
        if ([self.currentlyTappedMarker.userData[@"VehicleState"] intValue]==1) {
            [self.displayedInfoWindow.view1 setBackgroundColor:[UIColor colorWithRed:107/255.0f green:205/255.0f blue:78/255.0f alpha:1]];
        }
        //Idle
        else if ([self.currentlyTappedMarker.userData[@"VehicleState"] intValue]==2){
            [self.displayedInfoWindow.view1 setBackgroundColor:[UIColor colorWithRed:255/255.0f green:143/255.0f blue:51/255.0f alpha:1]];
        }
        
        [self.displayedInfoWindow updateStyleWithInfo:@{kCornerRadius:@3.0f, kBorderWidth:@1.0f,kBorderColor:[UIColor colorWithRed:227/255.0f green:224/255.0f blue:216/255.0f alpha:1.0f]}];
        
        [self.view addSubview:self.displayedInfoWindow];
    }
}

/* If the map is tapped on any non-marker coordinate, reset the currentlyTappedMarker and remove our
 custom info window from self.view */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if(self.currentlyTappedMarker) {
        self.currentlyTappedMarker = nil;
    }
    
    if([self.displayedInfoWindow isDescendantOfView:self.view]) {
        [self.displayedInfoWindow removeFromSuperview];
        self.displayedInfoWindow = nil;
    }
}

/* When the button is clicked, verify that we've got access to the correct marker.
 You might use this button to push a new VC with detail about that marker onto the navigation stack. */
- (void)buttonClicked:(id)sender
{
    //NSLog(@"button clicked for this marker: %@",self.currentlyTappedMarker);
}

#pragma mark Popoverdelegate method
-(void)popoverSelected:(NSString *)title{
    
    selectedMapType = title; //[popoverVC updateTableContent:@[@"Normal",@"Satellite",@"Terrain"] withSelectedTitle:selectedMapType];
    if ([selectedMapType isEqualToString:@"Normal"]) {
        self.mapView.mapType = kGMSTypeNormal;
    }
    else if ([selectedMapType isEqualToString:@"Satellite"]) {
        self.mapView.mapType = kGMSTypeSatellite;
    }
    else if ([selectedMapType isEqualToString:@"Terrain"]) {
        self.mapView.mapType = kGMSTypeTerrain;
    }
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller
{
    return UIModalPresentationNone;
}



@end
