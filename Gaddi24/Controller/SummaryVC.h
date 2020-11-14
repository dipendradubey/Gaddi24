//
//  SummaryVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryVC : UIViewController

@property(nonatomic,weak)IBOutlet UICollectionView *timeCollectionView;
@property(nonatomic,weak)IBOutlet UICollectionView *valueCollectionView;
@property(nonatomic,weak)IBOutlet UILabel *lblTime;
@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong)NSDictionary *selectedVehicleDict;
@property(nonatomic,weak)IBOutlet UILabel *staticLblStartDate;
@property(nonatomic,weak)IBOutlet UILabel *staticLblEndDate;
@property(nonatomic,weak)IBOutlet UIButton *btnStartDate;
@property(nonatomic,weak)IBOutlet UIButton *btnEndDate;
@property(nonatomic,weak)IBOutlet UIButton *btnOK;
@property(nonatomic,weak)IBOutlet UIView *viewCustomRange;

@property(nonatomic,weak)IBOutlet UIView *viewTransparent;


@end
