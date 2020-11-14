//
//  AccountVC.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

#import "AccountVC.h"
#import "Util.h"
#import "ConnectionHandler.h"
#import "TableViewCell.h"
#import "Global.h"
#import "VehicleListVC.h"
#import "UIViewController+MMDrawerController.h"
#import "TrackVehicleVC.h"
#import "NSString+Localizer.h"

@interface AccountVC ()<ConnectionHandlerDelegate>{
    ConnectionHandler *connectionHandler;
    NSMutableDictionary *userMutDict;
    BOOL flgShowPassword;
}

@end

static NSString * const kUserName = @"username";
static NSString * const kPassword = @"password";
static NSString * const kConfirmPassword = @"kConfirmPassword";
static NSString * const kNewPassword = @"kNewPassword";


@implementation AccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = [@"ITEM_MY_ACCOUNT" localizableString:@""];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]}];
    
    
    //f0c9
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    //[leftButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [leftButton setTitle:@"\uf0c9" forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    leftButton.titleLabel.textColor = [UIColor whiteColor];
    
    [leftButton addTarget:self action:@selector(btnMenuClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbarButton=[[UIBarButtonItem alloc] init];
    [leftbarButton setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftbarButton;
    
    UIButton *rightButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton1.frame = CGRectMake(0, 0, 40, 40);
    [rightButton1 setTitle:@"\uf015" forState:UIControlStateNormal];
    rightButton1.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0f];
    rightButton1.titleLabel.textColor = [UIColor whiteColor];
    
    //[rightButton1 setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    [rightButton1 addTarget:self action:@selector(showHomePage) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *rightbarButton=[[UIBarButtonItem alloc] init];
    [rightbarButton setCustomView:rightButton1];
    self.navigationItem.rightBarButtonItem=rightbarButton;
    
    self.tblView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tblView.estimatedRowHeight = 71.0f;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    userMutDict = [[NSMutableDictionary alloc]init];
    
    NSDictionary *dict = [Util retrieveDefaultForKey:kLoginResponse];
    
    userMutDict[kUserName] = dict[@"UserName"];
    userMutDict[kPassword] = @"";
    userMutDict[kNewPassword] = @"";
    userMutDict[kConfirmPassword] = @"";
    
    [self.tblView reloadData];
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    flgShowPassword = NO;
    
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
            
            NSDictionary *dict = responseDict[kResponse];
            
            if ([dict[@"StatusCode"] intValue]==0) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:dict[@"Message"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_OK" localizableString:@""] style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kLogout}];
                                                                          
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else{
            [Util showAlert:@"" andMessage:responseDict[kResponse][@"Message"] forViewController:self];
            }
        }
        [Util hideLoader:self.view];
    });
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
-(IBAction)btnUpdatePassword:(id)sender{
    if ([self validateField]) {
        [self.view endEditing:YES];
        [Util showLoader:@"" forView:self.view];
        
        NSDictionary *requestDict = @{kApiRequest:[NSString stringWithFormat:@"user/changepassword/%@/%@",userMutDict[kPassword],userMutDict[kConfirmPassword]]};
        [connectionHandler makeConnectionWithRequest:requestDict];
    }
}


- (IBAction)btnMenuClicked {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)showHomePage{
    //NSLog(@"Do nothing");
    [[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kDashboardPage}];
}


#pragma mark validate field
-(BOOL)validateField{
    
    BOOL flgValid = YES;
    if ([userMutDict[kPassword] length]==0) {
        [Util showAlert:@"" andMessage:[@"ERROR_OLD_PASSWORD" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    else if ([userMutDict[kNewPassword] length]==0) {
        [Util showAlert:@"" andMessage:[@"ERROR_NEW_PASSWORD" localizableString:@""] forViewController:self];
        flgValid = NO;
    }

    else if ([userMutDict[kConfirmPassword] length]==0) {
        [Util showAlert:@"" andMessage:[@"ERROR_CONFIRM_PASSWORD" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    else if (![userMutDict[kConfirmPassword] isEqualToString:userMutDict[kNewPassword]]) {
        [Util showAlert:@"ERROR_NO_PASSWORD_MATCH" andMessage:[@"" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    return flgValid;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    
   /* if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        [self changePlaceHolderTextForCell:cell withText:@"Username"];
        [cell.txtField1 setText:userMutDict[kUserName]];
        [cell.txtField1 setEnabled:NO];
    }*/
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        [self changePlaceHolderTextForCell:cell withText:[@"HINT_OLD_PASSWORD" localizableString:@""]];
        [cell.txtField1 setText:userMutDict[kPassword]];
        cell.txtField1.tag = 1;
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        [self changePlaceHolderTextForCell:cell withText:[@"HINT_NEW_PASSWORD" localizableString:@""]];
        [cell.txtField1 setText:userMutDict[kNewPassword]];
        cell.txtField1.tag = 2;
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        [self changePlaceHolderTextForCell:cell withText:[@"HINT_CONFIRM_PASSWORD" localizableString:@""]];
        [cell.txtField1 setText:userMutDict[kConfirmPassword]];
        cell.txtField1.tag = 3;
       /* if (flgShowPassword) { //password_secure@3x
            [cell.btn1 setImage:[UIImage imageNamed:@"password_secure.png"] forState:UIControlStateNormal];
            cell.txtField1.secureTextEntry = NO;
        }
        else{
            [cell.btn1 setImage:[UIImage imageNamed:@"password_show.png"] forState:UIControlStateNormal];
            cell.txtField1.secureTextEntry = YES;
        }
        */
        
    }
    else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell4"];
        [cell.btn1 setTitle:[@"BTN_UPDATE_PASSWORD" localizableString:@""] forState:UIControlStateNormal];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark Textfield updated
-(IBAction)textFieldTextUpdated:(UITextField *)textField{
    NSString *text = textField.text;

    if (textField.tag == 1){
        userMutDict[kPassword] = text;
    }
    else if (textField.tag == 2){
        userMutDict[kNewPassword] = text;
    }
    else if (textField.tag == 3){
        userMutDict[kConfirmPassword] = text;
    }

}

-(void)changePlaceHolderTextForCell:(TableViewCell *)cell withText:(NSString *)text{
    cell.txtField1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}

#pragma mark Button clicked action
-(IBAction)btnPasswordClicked:(UIButton *)button{
//    flgShowPassword = !flgShowPassword;
//    [self.tblView reloadData];
    
    NSUInteger row = button.tag - 2001;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    TableViewCell *cell = [self.tblView cellForRowAtIndexPath:indexPath];
    
    cell.btn1.selected = !cell.btn1.selected;
    
    cell.txtField1.secureTextEntry = !button.selected;
    
//    if (button.tag == 1) {
//        cell.txtField1.secureTextEntry = !button.selected;
//    }
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
