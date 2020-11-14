//
//  PickerContainer.m
//  Aurora
//
//  Created by Dipendra Dubey on 19/11/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "PickerContainer.h"

@interface PickerContainer ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *pickerView;
    
}

@end

@implementation PickerContainer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)initialviewsetup{
    
    //Toolbar setup
    UIToolbar* toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.barTintColor = [UIColor whiteColor];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:toolBar];
    
    //xorigin constrint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:toolBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1. constant:0]];
    
    //equal width constrint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:toolBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1. constant:0]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(btnCancelClicked:)];
    
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:215/255.0 green:75/255.0 blue:28/255.0 alpha:1.0],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(btnDoneClicked:)];
    
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:215/255.0 green:75/255.0 blue:28/255.0 alpha:1.0],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton,flexibleSpace, doneButton, nil]];
    
    
    //UIpicker setup
    pickerView = [[UIPickerView alloc] init];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.backgroundColor = [UIColor colorWithRed:224/255.0 green:223/255.0 blue:223/255.0 alpha:1.0];
    pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:pickerView];
    
    //xorigin constrint, picker should start from the bottom of toolbar
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pickerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeBottom multiplier:1. constant:0]];
    
    //picker width should be same to the parent
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pickerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1. constant:0]];
    //picker bottom should be bottom of parent
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pickerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1. constant:0]];
}

-(void)updatePickerContent:(NSString *)selectedValue{
    [pickerView reloadAllComponents];
    
    NSUInteger selectedIndex = [self.pickerArray indexOfObject:selectedValue];
    if (selectedIndex == NSNotFound) {
        selectedIndex = 0;
    }
    [pickerView selectRow:selectedIndex inComponent:0 animated:NO];
}

-(void)updatePickerContentDict:(NSDictionary *)selectedDict{
    [pickerView reloadAllComponents];
    
    NSUInteger selectedIndex = [self.pickerArray indexOfObject:selectedDict];
    if (selectedIndex == NSNotFound) {
        selectedIndex = 0;
    }
    [pickerView selectRow:selectedIndex inComponent:0 animated:NO];
}


#pragma mark UIPicker datasource and delegate method

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    if (self.keyName != nil){
        NSDictionary *dict = self.pickerArray[row];
        title = dict [self.keyName];
    }
    else{
        title = [self.pickerArray objectAtIndex:row];
    }
    return title;
}



//- (UIView *)pickerView:(UIPickerView *)pickerView1 viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    
//    NSString *title = @"";
//    if (self.keyName != nil && self.keyName.length>0) {
//        NSDictionary *dict = self.pickerArray[row];
//        title = dict [self.keyName];
//    }
//    else{
//        title = [self.pickerArray objectAtIndex:row];
//    }
//    
//    UILabel* tView = (UILabel*)view;
//    if (!tView){
//        tView = [[UILabel alloc] init];
//        tView.font = [UIFont fontWithName:@"System" size:17];
//        tView.textAlignment = NSTextAlignmentCenter;
//        tView.backgroundColor = [UIColor redColor];
//        
//        /*
//        tView.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        //originx will be same to pickerview
//        [pickerView addConstraint:[NSLayoutConstraint constraintWithItem:tView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pickerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
//        
//        //originy will be same to pickerview
//        [pickerView addConstraint:[NSLayoutConstraint constraintWithItem:tView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:pickerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
//        
//        //originy
//        [pickerView addConstraint:[NSLayoutConstraint constraintWithItem:tView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pickerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
//        
//        
//        //Equal width
//        [pickerView addConstraint:[NSLayoutConstraint constraintWithItem:tView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pickerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
//        
//        //Made height to 35
//        [pickerView addConstraint:[NSLayoutConstraint constraintWithItem:tView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:35]];
//         */
//        
//    }
//    // Fill the label text here
//    //...
//    tView.text = title;
//    return tView;
//}

-(void)btnDoneClicked:(id)sender{
    NSUInteger selectedRow = [pickerView selectedRowInComponent:0];
    [self.pickerContainerDelegate pickerSelected:self.pickerArray[selectedRow]];
    
}

-(void)btnCancelClicked:(id)sender{
    self.hidden = YES;
}

@end
