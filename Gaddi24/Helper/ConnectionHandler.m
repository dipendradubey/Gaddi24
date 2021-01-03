//
//  ConnectionHandler.m
//  Assess Team
//
//  Created by Dipendra Dubey on 25/07/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import "ConnectionHandler.h"
#import "Global.h"
#import "Util.h"
#import "NSString+Localizer.h"

@interface ConnectionHandler ()<NSURLSessionDelegate>

@end

@implementation ConnectionHandler

-(void)postRequestWithRequest:(NSDictionary *)requestDict completionHandler:(postRequestBlock)completed{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ApiPath,requestDict[kApiRequest]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id responseObject = nil;
        
        if ([data length] >0 && error == nil)
        {
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (responseObject == nil) {
                [self showError:error];
            }
        }
        else
        {
            [self showError:error];
            
        }
        completed(error, responseObject);
        
    }] resume];
    
}
-(void)makeConnectionWithRequest:(NSDictionary *)requestDict{
    
        NSString *urlString = [NSString stringWithFormat:@"%@%@",ApiPath,requestDict[kApiRequest]];
       // //NSLog(@"urlString =%@",urlString);
    
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection
         sendAsynchronousRequest:request
         queue:[[NSOperationQueue alloc] init]
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error)
         {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
             NSInteger statuscode = [httpResponse statusCode];
             
             //NSDictionary *responseHeader = [httpResponse allHeaderFields]; //All header key
             
             ////NSLog(@"%@",responseHeader);
             
             NSRange range = [requestDict[kApiRequest] rangeOfString:@"login/"];
             
             if(statuscode == 403 && range.location != NSNotFound){
                 dispatch_async(dispatch_get_main_queue(), ^{
                 [Util showAlert:@"" andMessage:[@"ERROR_INVALID_CREDENTIALS" localizableString:@""] forViewController:(UIViewController *)self.connectionHandlerDelegate];
                 [Util hideLoader:((UIViewController *)self.connectionHandlerDelegate).view];
                 return ;
                 });
             }
                 
             
             if ([data length] >0 && error == nil)
             {
                 id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                 if (responseObject == nil) {
                     [self showError:error];
                 }
                 else{
                 [self.connectionHandlerDelegate receiveResponse:@{kResponse:responseObject,kRequest:requestDict}];
                 }
                 ////NSLog(@"responseObject =%@", responseObject);
            }
             else
             {
                 [self showError:error];
                 
             }
             
         }];
   
}

-(void)makPostRequest:(NSDictionary *)requestDict withResponse:(void (^)(NSData*, NSError*))completionHandler{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ApiPath,requestDict[kApiRequest]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:requestDict[kPostData] options:kNilOptions error:nil];
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"dataString =%@",dataString);
    
    [request setHTTPBody:data];

    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfig];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString =%@",dataString);
        completionHandler(data, error);
    }];
    [dataTask resume];
}

-(void)makeConnectionWithRequestForContact:(NSDictionary *)requestDict{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ApiPath_V2,requestDict[kApiRequest]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    
    NSData *data = [NSJSONSerialization dataWithJSONObject:requestDict[kPostData] options:kNilOptions error:nil];
    
    [request setHTTPBody:data];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         /*NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
         NSInteger statuscode = [httpResponse statusCode];
         
         NSDictionary *responseHeader = [httpResponse allHeaderFields]; //All header key
         
         //NSLog(@"%@",responseHeader);*/
         
         if ([data length] >0 && error == nil)
         {
             id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             if (responseObject == nil) {
                 [self showError:error];
             }
             else{
                 [self.connectionHandlerDelegate receiveResponse:@{kResponse:responseObject,kRequest:requestDict}];
             }
             ////NSLog(@"responseObject =%@", responseObject);
         }
         else
         {
             [self showError:error];
             
         }
         
     }];
    
}

-(void)showError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [Util getLoaderView];
        if (view != nil) {
            //Show alert by making updated action made on alertview
            [Util showAlert:@"" andMessage:kDefaultErrorMsg forViewController:(UIViewController *)self.connectionHandlerDelegate];
            [Util hideLoader:view];
        }
    });
}
-(void)showAlert:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)makeGoogleConnectionWithRequest:(NSDictionary *)requestDict{
    
    //NSLog(@"requestDict =%@",requestDict);
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestDict[kApiRequest]]];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             //DKD updated code on 07 July 2019
             if ([requestDict[kRequestFor] isEqualToString:@"kGeoAddress"]) {
                 id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                 [self.connectionHandlerDelegate receiveGoogleResponse:@{kResponse:responseObject,kRequest:requestDict}];
             }
             else{
                 NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 [self.connectionHandlerDelegate receiveGoogleResponse:@{kResponse:myString,kRequest:requestDict}];
             }
         }
         else
         {
             [self showError:error];
             
         }
         
     }];
    
}

-(void)makeGetRequest:(NSString *)api withResponse:(void (^)(NSData*, NSError*))completionHandler{
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfig];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:api] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionHandler(data, error);
    }];
    [dataTask resume];
}

-(void)makeConnectionForTokenHandling:(NSDictionary *)requestDict{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ApiPath_V2,requestDict[kApiRequest]];
    
    NSLog(@"urlString =%@",urlString);
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:requestDict[kPostData] options:kNilOptions error:nil];
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"dataString =%@",dataString);
    
    [request setHTTPBody:data];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             if (responseObject == nil) {
                 //Print error here
             }
             else{
                 //[self.connectionHandlerDelegate receiveResponse:@{kResponse:responseObject,kRequest:requestDict}];
                 //Token sent successfully
             }
         }
         else
         {
             //Print error here
             
         }
         
     }];
}

@end
