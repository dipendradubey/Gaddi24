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

@protocol PlaybackVCDelegate <NSObject>

@optional
-(void)selectedOtherOption:(NSUInteger)selectedIndex;

@end

@interface PlaybackVC : UIViewController

@property (nonatomic,strong)NSDictionary *selectedVehicleDict;

@property(nonatomic,weak)IBOutlet UICollectionView *collectionView1;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property(nonatomic,weak)id<PlaybackVCDelegate> playbackVCDelegate;

@property (nonatomic,weak)IBOutlet UIButton *btnPlay;

@property (nonatomic,weak)IBOutlet UISlider *slider;

@property (nonatomic,weak)IBOutlet UIView *sliderTransparentView;

@property (nonatomic,weak)IBOutlet UIButton *buttonTemp;

@property(nonatomic,weak)IBOutlet UILabel *lblDate;

@property(nonatomic,weak)IBOutlet UILabel *lblSpeed;

@property(nonatomic,weak)IBOutlet UILabel *lblStaticSpeed;

@property(nonatomic,weak)IBOutlet UILabel *lblStaticDate;

@property(nonatomic,weak)IBOutlet UIView *alertView;

@property(nonatomic,weak)IBOutlet UIButton *btnOK1;

@property(nonatomic,weak)IBOutlet UIButton *btnOK2;

@property(nonatomic,weak)IBOutlet UIButton *btndonotshow;

@property(nonatomic,weak)IBOutlet UIView *verticalDevider;

@property(nonatomic,weak)IBOutlet UIView *transparentView;

@property(nonatomic,weak)IBOutlet UILabel *lblStaticDateText;
@property(nonatomic,weak)IBOutlet UILabel *lblStaticSpeedText;



@end

