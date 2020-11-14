//
//  MyDateConatiner.h
//  PhoneApps4Salons
//
//  Created by Saurabh Joshi on 24/11/14.
//  Copyright (c) 2014 Pulse. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kPickerTitle = @"kPickerTitle";
static NSString * const kPickerDate = @"kPickerDate";
static NSString * const kMaximumDate = @"kMaximumDate";
static NSString * const kMinimumDate = @"kMinimumDate";

@protocol MyDateConatinerDelegate <NSObject>

@optional
-(void)dateChanged:(NSDate *)date;
-(void)cancelButtonPressed;

@end

@interface MyDateConatiner : UIView
{   // UIDatePicker *datePicker;
    
}

@property(nonatomic,weak)id<MyDateConatinerDelegate> myDateConatinerDelegate;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UIToolbar *toolBar;
- (void)childviewSetup;
-(void)valueSetUp:(NSDictionary *)dict;

@end
