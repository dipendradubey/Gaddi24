//
//  ReportVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportVC : UIViewController

@property (nonatomic,strong)NSDictionary *selectedVehicleDict;
@property (nonatomic,weak)IBOutlet UITableView *tblView;

@end
