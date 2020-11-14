//
//  ResellerInfoVC.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

#import "ResellerInfoVC.h"
#import "Util.h"
#import "TableViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "Global.h"


@interface ResellerInfoVC ()<UITableViewDelegate,UITableViewDataSource>{}

@end


@implementation ResellerInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialsetup];
}

-(void)initialsetup{
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"Reseller Info";
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
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat rowheight = 51;
    
    if (indexPath.row == 1) {
        rowheight = 118;
    }
    else if (indexPath.row == 3) {
        rowheight = 147;
    }

    return rowheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
    
    if (indexPath.row==1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    }
    else if (indexPath.row==2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    }
    else if (indexPath.row==3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.view1.backgroundColor = self.tblView.separatorColor;
    
    return cell;
}




#pragma mark button action handling

- (IBAction)btnMenuClicked {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
