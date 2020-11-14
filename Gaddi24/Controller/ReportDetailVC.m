//
//  ReportDetailVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 21/04/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "ReportDetailVC.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "Global.h"
#import "PickerContainer.h"
#import "MyDateConatiner.h"
#import "UIView+Style.h"
#import "TableViewCell.h"


@interface ReportDetailVC ()<ConnectionHandlerDelegate, PickerContainerDelegate,MyDateConatinerDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *mutArrVehicle;

}

@end

@implementation ReportDetailVC

static NSString * const SPACE_STRING = @"                   ";
static NSString * const key1 = @"Vehicle Name";
static NSString * const key2 = @"key2";
static NSString * const cellID = @"cellID";
static NSString * const kvalue2 = @"value2";
static NSString * const kDivider = @"kDivider";
static NSString * const kCellColor = @"kCellColor";




- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
}

-(void)initialsetup{
    
    /*NSDictionary *summaryDict = self.reportDict[@"SummaryData"];
    self.vehicleName = summaryDict[key1];*/
        
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = self.vehicleName;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]}];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(btnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbarButton=[[UIBarButtonItem alloc] init];
    [leftbarButton setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftbarButton;
    
    
    mutArrVehicle = [[NSMutableArray alloc]init];
    
    self.tblView.estimatedRowHeight = 76.0f;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    NSArray *tempArray = self.reportDict[@"DetailData"];
    
    if(![tempArray isEqual:[NSNull null]] && tempArray != nil & [tempArray count]>0){
            [self processVehicleResponse:tempArray];
    }
    else{
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"Oops! Something went wrong. We will take care of it soon."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}



-(void)processVehicleResponse:(NSArray *)responseArray{
    
    int rowNo = 0;
    
    NSDictionary *dict = nil;

    
    for (NSArray *tempArray in responseArray) {
        
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Index" ascending:YES];
        
        NSArray *summaryArray = [tempArray sortedArrayUsingDescriptors:@[sortDescriptor]];;
        
        //NSLog(@"summaryArray =%@",summaryArray);
        
        UIColor *cellColor = [UIColor whiteColor];
        
        NSUInteger keyCount = [summaryArray count];
        
        if (rowNo%2==0) {
            cellColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:243/255.0f alpha:1];
        }
        
        int i = 0;
        
        for (NSDictionary *tempDict in summaryArray) {
            dict = @{cellID:@"cell1",key2:tempDict[@"Key"],kvalue2:tempDict[@"Value"],kCellColor:cellColor,kDivider:@0};
            if (i==keyCount-1) {
                dict = @{cellID:@"cell1",key2:tempDict[@"Key"],kvalue2:tempDict[@"Value"],kCellColor:cellColor,kDivider:@1};
            }
            i++;
            [mutArrVehicle addObject:dict];

        }
        
        rowNo++;
    }
    
    [self.tblView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button clicked

-(void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Tableview data source & delegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mutArrVehicle count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        NSDictionary *dict = mutArrVehicle[indexPath.row];
    
        TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dict[cellID]];
        cell.lbl1.text = dict[key2];
        cell.lbl2.text = dict[kvalue2];
        cell.contentView.backgroundColor = dict[kCellColor];
        cell.view1.backgroundColor = tableView.separatorColor;
        cell.view1.hidden = ![dict[kDivider] intValue];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
    cell.lbl1.text = self.vehicleName;
    return cell;
}
*/
/*- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.vehicleName;
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
