//
//  ContactVC.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

#import "ContactVC.h"
#import "Util.h"
#import "TableViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "Global.h"
#import "UIView+Style.h"
#import "ConnectionHandler.h"
#import "NSString+NSString_Extended.h"
#import "NSString+Localizer.h"

@interface ContactVC ()<UITableViewDelegate,UITableViewDataSource, ConnectionHandlerDelegate>{
    ConnectionHandler *connectionHandler;

}

@property(nonatomic,strong)NSDictionary *dictContact;
@property (nonatomic,strong)NSMutableDictionary *imageDict;

@end

static const NSInteger SZTEXTVIEW_TAG = 1000;

@implementation ContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialsetup];
}

-(void)initialsetup{
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = [@"ITEM_CONTACT_US" localizableString:@""];
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
    
    [Util showLoader:@"" forView:self.view];
    [self performSelector:@selector(getContactDetail) withObject:nil afterDelay:0.1];
    
    self.imageDict = [[NSMutableDictionary alloc]initWithCapacity:1];
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 51;
}

-(void)getContactDetail{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.trackgaddi.com/api/v1/Contact/ContactUs"]];
    
    self.dictContact = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.tblView.dataSource = self;
    self.tblView.delegate = self;
    [self.tblView reloadData];
    [Util hideLoader:self.view];
    self.tblView.hidden = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat rowheight = 163;
    
    if (indexPath.row == 0) {
        rowheight = 110;
    }
    
    if (indexPath.row == 1) {
        rowheight = 51;
    }
    else if (indexPath.row == 2) {
        rowheight = 163;
    }
   
    else if (indexPath.row == 3) {
        rowheight = 110;
    }
    else if (indexPath.row == 4) {
        rowheight = 200;
    }

    return rowheight;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    
    if (indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell-1"];
        
        if (self.imageDict[self.dictContact[@"LogoUrl"]] == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:self.dictContact[@"LogoUrl"]]];
                UIImage *image = [UIImage imageWithData:imageData];
                cell.imageView1.image = image;
                cell.imageView1.contentMode = UIViewContentModeScaleAspectFit;
                self.imageDict[self.dictContact[@"LogoUrl"]] = image;
                [cell.imageView1 updateStyleWithInfo:@{kCornerRadius:@45,kBorderWidth:@0.5,kBorderColor:[UIColor darkGrayColor]}];
                cell.imageView1.backgroundColor = [UIColor whiteColor];
            });
        }
        else{
            cell.imageView1.image = self.imageDict[self.dictContact[@"LogoUrl"]];
        }
    }
    if (indexPath.row==1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        cell.lbl1.text = [NSString stringWithFormat:@"%@",self.dictContact[@"CompanyName"]];
        cell.lbl7.text = [@"TV_NAME" localizableString:@""];
    }
   else if (indexPath.row==2){
       cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
       cell.lbl1.text = self.dictContact[@"CompanyAddress"];
       cell.lbl7.text = [@"TV_ADDRESS" localizableString:@""];
   }
    else if (indexPath.row==3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        cell.lbl1.text = self.dictContact[@"PhoneNumber"];
        cell.lbl2.text = self.dictContact[@"EmailId"];
        
        cell.lbl7.text = [@"TV_SUPPORT" localizableString:@""];
        cell.lbl8.text = [@"TV_EMAIL" localizableString:@""];
    }

    else if (indexPath.row==4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        [cell.sztextview updateStyleWithInfo:@{kCornerRadius:@5,kBorderWidth:@0.5,kBorderColor:self.tblView.separatorColor}];
        cell.sztextview.placeholder = [@"HINT_MESSAGE" localizableString:@""];
        [cell.btn1 setTitle: [@"BTN_SEND_MESSAGE" localizableString:@""] forState:UIControlStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.view1.backgroundColor = self.tblView.separatorColor;
    
    return cell;
}




#pragma mark button action handling

- (IBAction)btnMenuClicked {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (IBAction)btnSendClicked {
    SZTextView *textview = [self.tblView viewWithTag:SZTEXTVIEW_TAG];
    NSString *textViewText = textview.text;
    if (textViewText.length == 0) {
        [Util showAlert:@"" andMessage:[@"ERROR_MESSAGE" localizableString:@""] forViewController:self];
    }
    else{
        [self.view endEditing:YES];
        [Util showLoader:@"" forView:self.view];
        
        NSString *apiRequest = [NSString stringWithFormat:@"Contact/AskUsPost"];
        
        //NSString *apiRequest = [apiRequest1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //NSString *encodedUrlStr = [apiRequest1 urlencode];

        
        NSDictionary *postData = @{@"Data":textViewText};
        
        NSDictionary *requestDict = @{kApiRequest:apiRequest,kPostData:postData};
        [connectionHandler makeConnectionWithRequestForContact:requestDict];
    }
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
                                                                          
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                [self.view endEditing:YES];
                
                SZTextView *textview = [self.tblView viewWithTag:SZTEXTVIEW_TAG];
                textview.text = @"";
                
            }
            else{
                [Util showAlert:@"" andMessage:responseDict[kResponse][@"Message"] forViewController:self];
            }
        }
        [Util hideLoader:self.view];
    });
}



-(void)showHomePage{
    //NSLog(@"Do nothing");
    [[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kDashboardPage}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
