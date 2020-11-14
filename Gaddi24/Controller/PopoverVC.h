//
//  PopoverVC.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 04/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverVCDelegate <NSObject>

@optional
-(void)popoverSelected:(NSString *)title;
-(void)hidePopover;

@end

@interface PopoverVC : UITableViewController
@property(nonatomic,weak)id<PopoverVCDelegate> popoverVCDelegate;
@property (nonatomic,strong)NSString *selectedTitle;
@property(nonatomic,assign)BOOL showFontAwsome;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint *constraint1;
-(void)updateTableContent:(NSArray *)array withSelectedTitle:(NSString *)selectedTitle;
@property(nonatomic,assign)BOOL flgAllowDoubleTap;


@end
