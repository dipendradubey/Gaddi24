//
//  Contact.h
//  ContactInfo
//
//  Created by Dipendra Dubey on 8/3/18.
//  Copyright © 2018 Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactScanDelegate <NSObject>
-(void)receivedContact:(NSMutableArray *)contactList;
-(void)showErrorMessage:(NSString *)msg;
@end


@interface ContactsScan : NSObject

@property(nonatomic,strong)NSString *firstName;
@property(nonatomic,strong)NSString *lastName;
@property(nonatomic,weak)id<ContactScanDelegate> contactScanDelegate;

- (void)retriveContactList;


 /*
 Contact *newContact = [[Contact alloc] init];
 newContact.firstName = contact.givenName;
 newContact.lastName = contact.familyName;
 UIImage *image = [UIImage imageWithData:contact.imageData];
 newContact.image = image;
 for (CNLabeledValue *label in contact.phoneNumbers) {
 NSString *phone = [label.value stringValue];
 if ([phone length] > 0) {
 [contact.phones addObject:phone];
 }
 */


@end
