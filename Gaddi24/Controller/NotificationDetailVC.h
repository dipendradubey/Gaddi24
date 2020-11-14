//
//  NotificationDetailVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 02/04/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotificationListVC;

@protocol NotificationListDelegate <NSObject>

@optional
-(void)updateNotificationList;

@end

@interface NotificationDetailVC : UIViewController

@property(nonatomic,weak)IBOutlet UILabel *lbl1;
@property(nonatomic,weak)IBOutlet UILabel *lbl2;

@property(nonatomic,weak)IBOutlet UITextView *txtview;
@property(nonatomic,strong)NSDictionary *notificationDict;
@property(nonatomic,weak)id<NotificationListDelegate> notificationListDelegate;


@end
