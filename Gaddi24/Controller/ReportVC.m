//
//  ReportVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "ReportVC.h"
#import "TableViewCell.h"
#import "CollectionViewCell.h"
#import "Global.h"
#import "VehicleListVC.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "TrackVehicleVC.h"
#import "PlaybackVC.h"
#import "CommandVC.h"
#import "UIViewController+MMDrawerController.h"
#import "SummaryDetailVC.h"
#import "NSString+Localizer.h"


@interface ReportVC ()<UITableViewDelegate,UITableViewDataSource,ConnectionHandlerDelegate>{
    NSArray *reportArray;
    NSUInteger selectedOption;
    ConnectionHandler *connectionHandler;
    NSArray *staticArray;
}

@end

static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";

@implementation ReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    // Do any additional setup after loading the view.
}

-(void)initialsetup{
    //Report
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = [@"ITEM_REPORTS" localizableString:@""];

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
    
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    [self fetchReport];
}

-(void)fetchReport{
    NSString *apiRequest = [NSString stringWithFormat:@"Reports/Type"];
    NSDictionary *requestDict = @{kApiRequest:apiRequest};
    [connectionHandler makeConnectionWithRequest:requestDict];
}

#pragma mark Connection response handling
-(void)receiveResponse:(id)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (responseDict[kResponse]) {
            reportArray = responseDict[kResponse];
            if ([reportArray isKindOfClass:[NSArray class]] && [reportArray count]>0) {
                [self.tblView reloadData];
            }
        }
        [Util hideLoader:self.view];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Tableview datasource & delegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [reportArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *dict = reportArray[indexPath.row];
    cell.lbl1.text = dict[@"ReportName"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Fourth" bundle:nil];
    SummaryDetailVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"SummaryDetailVC"];
    VC.reportDict = reportArray[indexPath.row];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark Button action handling
-(void)btnBackClicked{
    
    NSArray *navigationarray = self.navigationController.viewControllers;
    
    for (UIViewController *VC in navigationarray) {
        if ([VC isKindOfClass:[VehicleListVC class]]) {
            [self.navigationController popToViewController:VC animated:YES];
            break;
        }
    }
}

-(void)showHomePage{
[[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kDashboardPage}];}

- (IBAction)btnMenuClicked {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
