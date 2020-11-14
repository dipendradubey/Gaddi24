//
//  MapViewAnnotation.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 24/12/16.
//  Copyright © 2016 crayonInfotech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic,copy) NSString *title;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate;

@end
