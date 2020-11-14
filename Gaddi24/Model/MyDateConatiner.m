//
//  MyDateConatiner.m
//  PhoneApps4Salons
//
//  Created by Saurabh Joshi on 24/11/14.
//  Copyright (c) 2014 Pulse. All rights reserved.
//

#import "MyDateConatiner.h"

@implementation MyDateConatiner
@synthesize myDateConatinerDelegate;
@synthesize datePicker,toolBar;





- (void) childviewSetup{
  
    
    UIView *btnContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    btnContainer.backgroundColor = [UIColor whiteColor];
    [self addSubview:btnContainer];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 100, 44);
    [closeButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorWithRed:215/255.0 green:75/255.0 blue:28/255.0 alpha:1.0] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(CloseActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [btnContainer addSubview:closeButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(self.bounds.size.width-80, 0, 100, 44);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorWithRed:215/255.0 green:75/255.0 blue:28/255.0 alpha:1.0] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(DoneActionSheet:) forControlEvents:UIControlEventTouchUpInside];

    [btnContainer addSubview:doneButton];
    
    
    datePicker = [[UIDatePicker alloc] init];
    datePicker.frame = CGRectMake(0, 44, self.bounds.size.width, 216);
    datePicker.backgroundColor = [UIColor colorWithRed:224/255.0 green:223/255.0 blue:223/255.0 alpha:1.0];

    [self addSubview:datePicker];
     
     
}




-(void)valueSetUp:(NSDictionary *)dict{
    
    self.datePicker.maximumDate = dict[kMaximumDate];
    if (dict[kMinimumDate]) {
         self.datePicker.minimumDate = dict[kMinimumDate];
    }
    else{
        //I am assuming that user shouldn't able to select start date before a year
        self.datePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:-365*24*3600];
    }
    
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
}


-(void)DoneActionSheet:(id)sender
{
    //NSLog(@"date button clicked");
    [myDateConatinerDelegate dateChanged:datePicker.date];
}

-(void)CloseActionSheet:(id)sender
{
    //NSLog(@"close button clicked");
    [myDateConatinerDelegate cancelButtonPressed];
}

-(void)TitleActionSheet:(id)sender
{
    //Ignore selection of Page.
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
