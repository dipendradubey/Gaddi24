#import <Contacts/Contacts.h>
#import "ContactsScan.h"

@implementation ContactsScan

- (void) retriveContactList
{
    if ([CNContactStore class]) {
        //ios9 or later
        CNEntityType entityType = CNEntityTypeContacts;
        if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined)
         {
             CNContactStore * contactStore = [[CNContactStore alloc] init];
             [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 if(granted){
                     [self getAllContact];
                 }
             }];
         }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized)
        {
            [self getAllContact];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusRestricted)
        {
            [self.contactScanDelegate showErrorMessage:@"Parental controls being in place"];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusDenied)
        {
            [self.contactScanDelegate showErrorMessage:@"Enable phone number access from setting"];
        }
    }
}



-(void)getAllContact{
            //ios 9+
            CNContactStore *store = [[CNContactStore alloc] init];
            //keys with fetching properties
            NSMutableArray* arrConts = [[NSMutableArray alloc] init];
            NSArray *keys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                NSLog(@"error fetching contacts %@", error);
                NSString *errorMsg = [NSString stringWithFormat:@"error fetching contacts %@", error];
                [self.contactScanDelegate showErrorMessage:errorMsg];
            } else {
                
                for (CNContact *contact in cnContacts)
                {
                    NSMutableArray *mutArr = [NSMutableArray new];
                    for (CNLabeledValue *label in contact.phoneNumbers)
                    {
                       
                        //DKD commnetd this on 21 Jan 2019 as this was giving unformated data i.e country code etc
                        /*
                        NSString *phone = [label.value stringValue];
                        NSString *newString = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                        newString = [newString stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        newString = [newString stringByReplacingOccurrencesOfString:@")" withString:@""];
                        newString = [newString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        
                        [mutArr addObject:newString];
                         NSLog(@"phone =%@",newString);
                         */
                        
                        //DKD added this on 21 Jan 2019 as this was giving unformated data i.e country code etc
                        NSString *digitNumber = [label.value valueForKey:@"digits"];
                        
                        if (digitNumber == nil) {
                            digitNumber = @"";
                        }
                        [mutArr addObject:digitNumber];
                        }
                    
                    
                    NSString* strGivenName = [contact givenName];
                    NSMutableDictionary* dictCont = [[NSMutableDictionary alloc] init];
                    [dictCont setValue:strGivenName forKey:@"name"];
                    [dictCont setValue:mutArr forKey:@"numbers"];
                    [arrConts addObject:dictCont];
                }
                
                //[self.contactScanDelegate receivedContact:mutArr];
                [self.contactScanDelegate receivedContact:arrConts];
            }
    }

@end
