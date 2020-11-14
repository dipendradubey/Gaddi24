//
//  CommandVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommandVC : UIViewController

@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong)NSDictionary *selectedVehicleDict;
@property (nonatomic,weak)IBOutlet UITableView *tblView;
@property (nonatomic,weak)IBOutlet UILabel *lblCommandTime;

@end
