//
//  LoginVC.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

#import "LoginVC.h"
#import "Util.h"
#import "ConnectionHandler.h"
#import "TableViewCell.h"
#import "Global.h"
#import "VehicleListVC.h"
#import "MMDrawerController.h"
#import "TrackVehicleVC.h"
#import "NSString+Localizer.h"

@import Firebase;

@interface LoginVC ()<ConnectionHandlerDelegate>{
    ConnectionHandler *connectionHandler;
    NSMutableDictionary *userMutDict;
}

@end

static NSString * const kUserName = @"username";
static NSString * const kPassword = @"password";

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblView.estimatedRowHeight = 71.0f;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationController.navigationBar.hidden = YES;
    
    userMutDict = [[NSMutableDictionary alloc]init];
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark Response handling
-(void)receiveResponse:(NSDictionary *)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([responseDict[kResponse] isEqual:[NSNull null]]|| responseDict[kResponse] == nil) {
            [Util showAlert:@"" andMessage:@"Oops! Something went wrong. We will take care of it soon." forViewController:self];
        }
        
        else if (responseDict[kResponse]) {
            [Util updateDefaultForKey:kLoginResponse toValue:responseDict[kResponse]];
            [self showVehicleListing];
            [self fetchAndUploadGCMToken];
            
            
            
        }
    });
}


-(void)fetchAndUploadGCMToken{
    
    
    // [START log_fcm_reg_token]
    NSString *fcmToken = [FIRMessaging messaging].FCMToken;
    NSLog(@"Local FCM registration token: %@", fcmToken);
    
    
    if (fcmToken != nil){
        [Util updateDefaultForKey:kDeviceToken toValue:fcmToken];
        NSString *apiRequest = [NSString stringWithFormat:@"user/registerdevice"];
        NSDictionary *postData = @{@"token":[Util retrieveDefaultForKey:kDeviceToken],@"imei":[Util getUniqueDeviceIdentifierAsString]};
        
        NSDictionary *requestDict = @{kApiRequest:apiRequest,kPostData:postData};
        [connectionHandler makeConnectionForTokenHandling:requestDict];
        
        
        //DKD commneted on 07 July 2019 as now we will use post method to send token
        /*
         dispatch_async(dispatch_get_main_queue(), ^{
         NSString *urlString = [NSString stringWithFormat:@"%@user/registerdevice/%@",ApiPath_V2,[Util retrieveDefaultForKey:kDeviceToken]];
         NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
         
         if (data){
         NSLog(@"upload token response =%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         }
         
         //NSLog(@"registerDevice =%@", responseObject);
         });
         */
        
        
        // [START log_iid_reg_token]
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                            NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error fetching remote instance ID: %@", error);
            } else {
                NSLog(@"Remote instance ID token: %@", result.token);
                //            NSString* message =
                //            [NSString stringWithFormat:@"Remote InstanceID token: %@", result.token];
                NSLog(@"Remote InstanceID token: %@", result.token);
            }
        }];
        // [END log_iid_reg_token]
    }
    
    
}


-(void)showVehicleListing{
    
    UIViewController * leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    
    MMDrawerController *destinationViewController = [[MMDrawerController alloc]init];
    
    UIViewController * center = [self.storyboard instantiateViewControllerWithIdentifier:@"VehicleListVC"];
    
    UINavigationController *navCenter = [[UINavigationController alloc]initWithRootViewController:center];
    
    [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
    
    [destinationViewController setCenterViewController:navCenter];
    
    [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.navigationController pushViewController:destinationViewController animated:NO];

    [self performSelector:@selector(clearLoginPage) withObject:nil afterDelay:0.1];
}

-(void)showVehicleTracking{
    TrackVehicleVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"TrackVehicleVC"];
    VC.selectedVehicleDict = @{@"VehicleId":@"300",@"VehicleName":@"Ajeet Ji Jain",@"Latitude":@"22.17838833333333",@"Longitude":@"72.92697333333334"};
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)clearLoginPage{
    [Util hideLoader:self.view];
    userMutDict[kUserName] = @"";
    userMutDict[kPassword] = @"";
    
    [self.tblView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

#pragma mark Button action handling
-(IBAction)btnLoginclicked:(id)sender{
    if ([self validateField]) {
        [self.view endEditing:YES];
        [Util showLoader:@"" forView:self.view];
        
        NSDictionary *requestDict = @{kApiRequest:[NSString stringWithFormat:@"login/%@/%@",userMutDict[kUserName],userMutDict[kPassword]]};
        [connectionHandler makeConnectionWithRequest:requestDict];
    }
}

#pragma mark validate field
-(BOOL)validateField{
    
    BOOL flgValid = YES;
    if ([userMutDict[kUserName] length]==0) {
        [Util showAlert:@"" andMessage:[@"ERROR_USERNAME" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    else if ([userMutDict[kPassword] length]==0) {
        [Util showAlert:@"" andMessage:[@"ERROR_PASSWORD" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    return flgValid;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
    
    if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        [self changePlaceHolderTextForCell:cell withText:[@"HINT_USERNAME" localizableString:@""]];
        [cell.txtField1 setText:userMutDict[kUserName]];
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        [self changePlaceHolderTextForCell:cell withText:[@"HINT_PASSWORD" localizableString:@""]];
        [cell.txtField1 setText:userMutDict[kPassword]];
    }
    else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        [cell.btn1 setTitle:[@"BTN_LOGIN" localizableString:@""] forState:UIControlStateNormal];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark Textfield updated
-(IBAction)textFieldTextUpdated:(UITextField *)textField{
    NSString *text = textField.text;
    if (textField.tag == 1) {
        userMutDict[kUserName] = text;
    }
    else if (textField.tag == 2){
        userMutDict[kPassword] = text;
    }
}

-(void)changePlaceHolderTextForCell:(TableViewCell *)cell withText:(NSString *)text{
    cell.txtField1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

#pragma mark Button action Handling
- (IBAction)btnShowHidePswdClicked:(UIButton *)button {
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    TableViewCell *cell = [self.tblView cellForRowAtIndexPath:indexPath];
    
    cell.btn1.selected = !cell.btn1.selected;
    
    //if (button.tag == 1) {
        cell.txtField1.secureTextEntry = !button.selected;
    //}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
