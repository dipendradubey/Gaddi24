//
//  NSString+Localizer.m
//  Gaddi24
//
//  Created by Dipendra Dubey on 19/04/20.
//  Copyright © 2020 Dipendra. All rights reserved.
//

#import "NSString+Localizer.h"
#import "Util.h"
#import "Global.h"

//#import <AppKit/AppKit.h>


@implementation NSString (Localizer)

-(NSString *)localizableString:(NSString *)loc{
    NSString *str = [Util retrieveDefaultForKey:kLanguage];
    NSString *path = [[NSBundle mainBundle] pathForResource:[Util retrieveDefaultForKey:kLanguage] ofType:@"lproj"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return [bundle localizedStringForKey:self value:@"" table:nil];
}

@end
