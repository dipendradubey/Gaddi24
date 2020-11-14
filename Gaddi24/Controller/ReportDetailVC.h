//
//  ReportDetailVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 21/04/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface ReportDetailVC : UIViewController
@property(nonatomic,strong)NSDictionary *reportDict;
@property(nonatomic,weak)IBOutlet UITableView *tblView;
@property(nonatomic,strong)NSString *vehicleName;


@end
