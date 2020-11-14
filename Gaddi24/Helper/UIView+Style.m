//
//  UIView+Style.m
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "UIView+Style.h"
#import "Global.h"

@implementation UIView (Style)

-(void)updateStyleWithInfo:(NSDictionary *)viewDict{
    
    self.layer.cornerRadius = [viewDict[kCornerRadius] floatValue];
    self.clipsToBounds = YES;
    self.layer.borderColor = ((UIColor *)viewDict[kBorderColor]).CGColor;
    self.layer.borderWidth = [viewDict[kBorderWidth] floatValue];
    
}

@end
