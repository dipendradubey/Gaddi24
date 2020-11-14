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

@interface BirdViewVC : UIViewController

@property(nonatomic,weak)IBOutlet UITableView *tblView;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic,strong)NSArray *allVehicleArray;

@property (nonatomic,weak)IBOutlet UIButton *buttonTemp;


@end

