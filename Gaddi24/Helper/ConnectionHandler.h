//
//  ConnectionHandler.h
//  Assess Team
//
//  Created by Dipendra Dubey on 25/07/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionHandlerDelegate <NSObject>

@optional
-(void)receiveResponse:(id)data;
-(void)receiveGoogleResponse:(id)data;
-(void)saveDataResponse:(id)data;
-(void)receiveAuthResponse:(id)data;

@end

@interface ConnectionHandler : NSObject
typedef void(^postRequestBlock)(NSError *error, NSDictionary *dict);

-(void)makeConnectionWithRequest:(NSDictionary *)requestDict;
-(void)makeGoogleConnectionWithRequest:(NSDictionary *)requestDict;
-(void)makeConnectionWithRequestForContact:(NSDictionary *)requestDict;
-(void)makeConnectionForTokenHandling:(NSDictionary *)requestDict;
@property (nonatomic,weak)id<ConnectionHandlerDelegate> connectionHandlerDelegate;
-(void)postRequestWithRequest:(NSDictionary *)requestDict completionHandler:(postRequestBlock)completed;
-(void)makeGetRequest:(NSString *)api withResponse:(void (^)(NSData*, NSError*))completionHandler;
-(void)makPostRequest:(NSDictionary *)requestDict withResponse:(void (^)(NSData*, NSError*))completionHandler;


@end
