//
//  PickerContainer.h
//  Aurora
//
//  Created by Dipendra Dubey on 19/11/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerContainerDelegate <NSObject>

@optional
-(void)pickerSelected:(id)selectedValue;

@end


@interface PickerContainer : UIView

@property(nonatomic, strong)NSString *dataType;
@property(nonatomic, strong)NSString *keyName;
@property(nonatomic, strong)NSArray *pickerArray;
@property(nonatomic,weak)id<PickerContainerDelegate> pickerContainerDelegate;

-(void)initialviewsetup;
-(void)updatePickerContent:(NSString *)selectedValue;
-(void)updatePickerContentDict:(NSDictionary *)selectedDict;



@end
