//
//  MapViewAnnotation.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 24/12/16.
//  Copyright © 2016 crayonInfotech. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize coordinate=_coordinate;

@synthesize title=_title;

-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate

{
    
    self = [super init];
    
    _title = title;
    
    _coordinate = coordinate;
    
    return self;
    
}

@end


