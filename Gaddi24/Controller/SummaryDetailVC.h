//
//  SummaryDetailVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 21/04/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface SummaryDetailVC : UIViewController
@property(nonatomic,strong)NSDictionary *reportDict;
@property(nonatomic,weak)IBOutlet CustomButton *customButton;
@property (nonatomic,weak)IBOutlet UITextField *txtFieldSearch;
@property(nonatomic,weak)IBOutlet CustomButton *btnStartDate;
@property(nonatomic,weak)IBOutlet CustomButton *btnEndDate;
@property(nonatomic,weak)IBOutlet UITableView *tblView;


@end
