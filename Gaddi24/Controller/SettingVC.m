//
//  SettingVC.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

//DKD updated setting screen 0n 18Apr2020

#import "SettingVC.h"
#import "Util.h"
#import "TableViewCell.h"
#import "Global.h"
#import "UIViewController+MMDrawerController.h"
#import "CollectionViewCell.h"
#import "NSString+Localizer.h"

@interface SettingVC ()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    NSInteger timeInterval;
    NSInteger homeScreenTag;
    NSInteger languageTag;
}

@end


@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
}

-(void)initialsetup{
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = [@"ITEM_SETTINGS" localizableString:@""];
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
    
    
    self.tblView.estimatedRowHeight = 228;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    
    if ([[Util retrieveDefaultForKey:kTimeInterval] integerValue]==0) {
        [Util updateDefaultForKey:kTimeInterval toValue:@30];
    }
    
    if ([[Util retrieveDefaultForKey:kHomeScreen] integerValue]==0) {
        [Util updateDefaultForKey:kHomeScreen toValue:@(DASHBOARD_TAG)];
    }
    
    timeInterval = [[Util retrieveDefaultForKey:kTimeInterval] integerValue];
    homeScreenTag = [[Util retrieveDefaultForKey:kHomeScreen] integerValue];
    
    NSString *lnguageString = [Util retrieveDefaultForKey:kLanguage];
    
    languageTag = 3001;
    if ([lnguageString isEqualToString:@"hi"]) {
        languageTag = 3002;
    }
    else if ([lnguageString isEqualToString:@"gu"]) {
        languageTag = 3003;
    }
    
    [self.tblView reloadData];
}


-(void)updateAllButton{
    
    UIButton *button10 = [self.tblView viewWithTag:10];
    UIButton *button20 = [self.tblView viewWithTag:20];
    UIButton *button30 = [self.tblView viewWithTag:30];
    UIButton *button60 = [self.tblView viewWithTag:60];
    
    [button10 setSelected:NO];
    [button20 setSelected:NO];
    [button30 setSelected:NO];
    [button60 setSelected:NO];
    
    UIButton *button = [self.tblView viewWithTag:timeInterval];
    [button setSelected:YES];
    //[button setImage:[UIImage imageNamed:@"Radio_Checked.png"] forState:UIControlStateNormal];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark Response handling
-(void)receiveResponse:(NSDictionary *)responseDict{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
    
    if (indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        
        UIButton *button10 = [cell viewWithTag:10];
        UIButton *button20 = [cell viewWithTag:20];
        UIButton *button30 = [cell viewWithTag:30];
        UIButton *button60 = [cell viewWithTag:60];
        
        //NSLog(@"button10 =%@",button10);
        button10.selected = NO;
        button20.selected = NO;
        button30.selected = NO;
        button60.selected = NO;
        
        UIButton *button = [cell viewWithTag:timeInterval];
        button.selected = YES;
        
        cell.lbl7.text = [@"TV_AUTO_REFRESH" localizableString:@""];
        [cell.btn1 setTitle:[@"RB_10" localizableString:@""] forState:UIControlStateNormal];
        [cell.btn2 setTitle:[@"RB_20" localizableString:@""] forState:UIControlStateNormal];
        [cell.btn3 setTitle:[@"RB_30" localizableString:@""] forState:UIControlStateNormal];
        [cell.btn4 setTitle:[@"RB_60" localizableString:@""] forState:UIControlStateNormal];

    }
    else if (indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        UIButton *button10 = [cell viewWithTag:DASHBOARD_TAG];
        UIButton *button20 = [cell viewWithTag:BIRDVIEW_TAG];
        
        button10.selected = NO;
        button20.selected = NO;
        
        UIButton *button = [cell viewWithTag:homeScreenTag];
        button.selected = YES;
        
        [cell.lbl1 setText:[@"TV_STARTUP_SCREEN" localizableString:@""]];
        [cell.btn1 setTitle:[@"ITEM_HOME" localizableString:@""] forState:UIControlStateNormal];
        [cell.btn2 setTitle:[@"ITEM_BIRDVIEW" localizableString:@""] forState:UIControlStateNormal];
    }
    
    else if (indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
               [cell.lbl1 setText:[@"TV_LANGUAGE" localizableString:@""]];

               UIButton *button10 = [cell viewWithTag:3001];
               UIButton *button20 = [cell viewWithTag:3002];
               UIButton *button30 = [cell viewWithTag:3003];
               
               //NSLog(@"button10 =%@",button10);
               button10.selected = NO;
               button20.selected = NO;
               button30.selected = NO;
               
               UIButton *button = [cell viewWithTag:languageTag];
               button.selected = YES;
    }
    else{
        [cell.btn1 setTitle:[@"BTN_SAVE_SETTINGS" localizableString:@""] forState:UIControlStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark Collection view handling

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    
    cell.lbl1.text = [NSString stringWithFormat:@"%ld",indexPath.row*10];
    ////NSLog(@"Collectionview cell=%@ and label=%@",cell,cell.lbl1);
    
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = collectionView.frame.size;
    size.width = 40;
    
    ////NSLog(@"collection view cell size =%@",NSStringFromCGSize(size));
    
    return size;
}

#pragma mark button action handling

- (IBAction)btnMenuClicked {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)showHomePage{
    
     [[NSNotificationCenter defaultCenter]postNotificationName:@"ReloadMenu" object:nil];
    
    //NSLog(@"Do nothing");
    [[NSNotificationCenter defaultCenter]postNotificationName:kMenuNotification object:nil userInfo:@{kShowPage:kDashboardPage}];
    
}

- (IBAction)btnPushnotificatioAction {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(IBAction)btnSaveClicked:(id)sender{
    [Util updateDefaultForKey:kTimeInterval toValue:@(timeInterval)];
    [Util updateDefaultForKey:kHomeScreen toValue:@(homeScreenTag)];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:[@"ALERT_SAVE_SETTINGS" localizableString:@""]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[@"ALERT_BUTTON_OK" localizableString:@""] style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                           [self showHomePage];
                                                          
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
   
}

-(IBAction)btnRadioClicked:(UIButton *)button{
   
    timeInterval = [button tag];
    [self updateAllButton];
}

-(IBAction)btnDashboardORBirdViewClicked:(UIButton *)button{
   
    homeScreenTag = button.tag;
    
    UIButton *button10 = [self.tblView viewWithTag:DASHBOARD_TAG];
    UIButton *button20 = [self.tblView viewWithTag:BIRDVIEW_TAG];
    
    
    [button10 setSelected:NO];
    [button20 setSelected:NO];
    
    
    UIButton *button1 = [self.tblView viewWithTag:homeScreenTag];
    [button1 setSelected:YES];
}

-(IBAction)btnLanguageClicked:(UIButton *)button{
    [self deselectAllLaunguage];
    languageTag = button.tag;
    UIButton *button1 = [self.tblView viewWithTag:languageTag];
    [button1 setSelected:YES];
    
    if(languageTag == 3001)
        [Util updateDefaultForKey:kLanguage toValue:@"en"];
    else if(languageTag == 3002)
        [Util updateDefaultForKey:kLanguage toValue:@"hi"];
    else
        [Util updateDefaultForKey:kLanguage toValue:@"gu"];
    
}

-(void)deselectAllLaunguage{
        UIButton *english = [self.tblView viewWithTag:3001];
       UIButton *hindi = [self.tblView viewWithTag:3002];
        UIButton *guj = [self.tblView viewWithTag:3003];
       
       
       [english setSelected:NO];
       [hindi setSelected:NO];
       [guj setSelected:NO];
       
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
