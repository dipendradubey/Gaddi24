//
//  NSString+Localizer.h
//  Gaddi24
//
//  Created by Dipendra Dubey on 19/04/20.
//  Copyright © 2020 Dipendra. All rights reserved.
//

//#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Localizer)

//-(void)updateStyleWithInfo:(NSDictionary *)viewDict
-(NSString *)localizableString:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
