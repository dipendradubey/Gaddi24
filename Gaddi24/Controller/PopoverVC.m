//
//  PopoverVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 04/02/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "PopoverVC.h"
#import "TableViewCell.h"

@interface PopoverVC ()

@property(nonatomic,strong)NSArray *contentArray;
@property (nonatomic,assign)NSUInteger selectedRow;

@end

static NSString * const kTitleName = @"kTitleName";
static NSString * const kFontAwsomeName = @"kFontAwsomeName";

@implementation PopoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)updateTableContent:(NSArray *)array withSelectedTitle:(NSString *)selectedTitle1{
    
    self.navigationController.navigationBar.hidden = YES; //Each time creating new navigation
    
    self.selectedRow = -1;
    self.contentArray = array;
    self.selectedTitle = selectedTitle1;
    
    if (self.selectedTitle.length>0) {
        NSUInteger selectedIndex = [array indexOfObject:self.selectedTitle];
        if (selectedIndex != NSNotFound) {
            self.selectedRow = selectedIndex;
        }
    }
    
    [self.tableView reloadData];
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
    return [self.contentArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];    // Configure the cell...
    
    cell.lbl1.text = @"\uf00c";
    cell.lbl1.font = [UIFont fontWithName:@"FontAwesome" size:21.0f];
    
    cell.lbl1.textColor = [UIColor lightGrayColor];
    cell.lbl2.text = self.contentArray[indexPath.row];
    
    if (indexPath.row == self.selectedRow) {
        cell.lbl1.textColor = [UIColor blackColor];
    }
    
    cell.constraint1.constant = 30;
    cell.lbl1.hidden = true;
    
    if (self.showFontAwsome) {
        cell.constraint1.constant = 68;
        cell.lbl1.hidden = false;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //For user defined value each time we need to select the data
    if ([self.contentArray[indexPath.row] isEqualToString:@"User-defined"]) {
        [self.popoverVCDelegate popoverSelected:self.contentArray[indexPath.row]];
    }//DKD added on 21 Feb 2020 self.flgAllowDoubleTap == false so that if user try to share the selected vehicle again then still he will be allowed
    else if ([self.contentArray[indexPath.row] isEqualToString:self.selectedTitle] && self.flgAllowDoubleTap == false) {
        //NSLog(@"Do nothing");
    }
    else{
        [self.popoverVCDelegate popoverSelected:self.contentArray[indexPath.row]];
    }
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
