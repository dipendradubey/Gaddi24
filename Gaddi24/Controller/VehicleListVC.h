//
//  ViewController.h
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Crashlytics/Crashlytics.h>
#import "MarqueeLabel.h"


@interface VehicleListVC : UIViewController

@property(nonatomic,weak)IBOutlet UITableView *tblView;
@property (nonatomic,assign)BOOL flgGoToDetailPage;
@property (nonatomic,strong)NSDictionary *evnetDict;

@property (nonatomic,weak)IBOutlet UIButton *btnAll;
@property (nonatomic,weak)IBOutlet UIButton *btnActive;
@property (nonatomic,weak)IBOutlet UIButton *btnIdle;
@property (nonatomic,weak)IBOutlet UIButton *btnStop;
@property (nonatomic,weak)IBOutlet UIButton *btnUnavailable;
@property (nonatomic,weak)IBOutlet UIButton *btnInActive; //inActiveArray


@property (nonatomic,weak)IBOutlet UIView *dividerView;
@property (nonatomic,weak)IBOutlet UIView *btnContainer;

@property (nonatomic,weak)IBOutlet UISearchBar *searchBar;
@property(nonatomic,weak)IBOutlet MarqueeLabel *lblMarqee;



@end

