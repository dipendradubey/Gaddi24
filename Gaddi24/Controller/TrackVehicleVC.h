//
//  ViewController.h
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TrackVehicleVC : UIViewController

@property(nonatomic,weak)IBOutlet UITableView *tblView;
@property (nonatomic,strong)NSDictionary *selectedVehicleDict;
@property (nonatomic,strong)NSDictionary *vehicleDataDict;



@property(nonatomic,weak)IBOutlet UICollectionView *collectionView1;
@property(nonatomic,weak)IBOutlet UICollectionView *collectionView2;

@property(nonatomic,weak)IBOutlet UILabel *lblLocation;
@property(nonatomic,weak)IBOutlet UILabel *lblLocationIcon;
@property(nonatomic,weak)IBOutlet UILabel *lblTime;

@property(nonatomic,weak)IBOutlet UIButton *btnHide;
@property(nonatomic,weak)IBOutlet UIView *trackViewContainer;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic,weak)IBOutlet UIButton *buttonTraffic;
@property (nonatomic,weak)IBOutlet UIButton *buttonMap;
@property (nonatomic,weak)IBOutlet UIButton *buttonDirection;

@property (nonatomic,weak)IBOutlet UIButton *buttonTraffic1;
@property (nonatomic,weak)IBOutlet UIButton *buttonMap1;
@property (nonatomic,weak)IBOutlet UIButton *buttonDirection1;
@property (nonatomic,weak)IBOutlet UIButton *buttonParking;

@property (nonatomic,weak)IBOutlet UIButton *buttonTemp;
@property(nonatomic,strong)NSArray *allVehicleArray;
@property(nonatomic,weak)IBOutlet UIButton *btnShowHideMap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewTrailing;
@end

