//
//  SummaryDetailVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 21/04/17.
//  Copyright © 2017 crayonInfotech. All rights reserved.
//

#import "SummaryDetailVC.h"
#import "ConnectionHandler.h"
#import "Util.h"
#import "Global.h"
#import "PickerContainer.h"
#import "MyDateConatiner.h"
#import "UIView+Style.h"
#import "TableViewCell.h"
#import "ReportDetailVC.h"
#import "NSString+Localizer.h"


@interface SummaryDetailVC ()<ConnectionHandlerDelegate, PickerContainerDelegate,MyDateConatinerDelegate, UITableViewDataSource, UITableViewDelegate>{
    ConnectionHandler *connectionHandler;
    NSMutableArray *mutArrVehicle;
    PickerContainer *pickerContainer;
    MyDateConatiner *myDateContainer;
    CustomButton *activeButton;
    NSArray *vehicleArray;
    NSArray *reportDetailArray;
    NSUInteger initialIndex;
    NSUInteger previousSummaryCount;
    NSMutableDictionary *mutHeaderDict;
    NSString *headerCellId;
    int buttonType; //1 = startDate, 2 = end date
    
    BOOL flgVehicleRequired ;
    BOOL flgTextinputRequired;
    BOOL flgStartDateRequired;
    BOOL flgEndDateRequired;
    NSAttributedString *attribString;
}

@end

@implementation SummaryDetailVC

static NSString * const SPACE_STRING = @"                   ";
static NSString * const key1 = @"Vehicle Name";
static NSString * const key2 = @"key2";
static NSString * const kvalue2 = @"value2";


static NSString * const cellID = @"cellID";
static NSString * const kVehicleName = @"Vehicle Name";
static NSString * const kCellColor = @"kCellColor";
static NSString * const kDivider = @"kDivider";
static NSString * const kShowDetail = @"kShowDetail";

static NSString * const kVehilcleField = @"kVehilcleField";
static NSString * const kSearchField = @"kSearchField";
static NSString * const kStartDate = @"kStartDate";
static NSString * const kEndDate = @"kEndDate";


static NSString * const kReportDict = @"kReportDict";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
}

-(void)initialsetup{
    
     attribString = [self fetchAttributedText];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = self.reportDict[@"ReportName"];
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
    
    //Set button'text to currnt date
    
    [self.btnStartDate setTitle:[Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}] forState:UIControlStateNormal];
    [self.btnEndDate setTitle:[Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}] forState:UIControlStateNormal];
    
    [self.btnStartDate updateStyleWithInfo:@{kCornerRadius:@0.0f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f  blue:170/255.0f  alpha:1],kBorderWidth:@1.0f}];
    [self.btnEndDate updateStyleWithInfo:@{kCornerRadius:@0.0f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f  blue:170/255.0f  alpha:1],kBorderWidth:@1.0f}];
    
    
    self.txtFieldSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    
    //Creating connection object
    connectionHandler = [[ConnectionHandler alloc]init];
    connectionHandler.connectionHandlerDelegate = self;
    
    [self disableAllControls];
    
    //NSLog(@"reportdict =%@",self.reportDict);
    
    
    
    if ([self.reportDict[@"IsVehicleIdRequired"] intValue]) {
        self.customButton.enabled = YES;
        [Util showLoader:@"" forView:self.view];
        [self performSelector:@selector(fetchVehicleList) withObject:nil afterDelay:0.1];
    }
    if ([self.reportDict[@"IsTextInputRequired"] intValue]) {
        self.txtFieldSearch.enabled = YES;
    }
    if ([self.reportDict[@"IsStartDateRequired"] intValue]) {
        self.btnStartDate.enabled = YES;
    }
    if ([self.reportDict[@"IsEndDateRequired"] intValue]) {
        self.btnEndDate.enabled = YES;
    }
    
    
    flgVehicleRequired = [self.reportDict[@"IsVehicleIdRequired"] intValue];
    flgTextinputRequired = [self.reportDict[@"IsTextInputRequired"] intValue];
    flgStartDateRequired = [self.reportDict[@"IsStartDateRequired"] intValue];
    flgEndDateRequired = [self.reportDict[@"IsEndDateRequired"] intValue];
    
    headerCellId = @"cell2"; //All are visible
    
    //Search is not available
    if (flgVehicleRequired && !flgTextinputRequired) {
        headerCellId = @"cell3";
    }
    //Vehicle is not available
    else if (!flgVehicleRequired && flgTextinputRequired) {
        headerCellId = @"cell4";
    }
    //Vehicle, search is not available
    else if (!flgVehicleRequired && !flgTextinputRequired) {
        headerCellId = @"cell5";
    }


    
    mutArrVehicle = [[NSMutableArray alloc]init];
    
    self.tblView.estimatedRowHeight = 130.0f;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    initialIndex = 0;
    
    mutHeaderDict = [[NSMutableDictionary alloc]initWithCapacity:4];
    mutHeaderDict[kVehilcleField] = @{@"VehicleName":@"Vehicle Name",@"VehicleId":@"0"};
    mutHeaderDict[kSearchField] = @"";
    
    NSString *startDate = [Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}];
    NSString *endDate = startDate;

    if(flgEndDateRequired && flgStartDateRequired){
        startDate = [startDate stringByAppendingString:@" 00:00 AM"];
        endDate = [endDate stringByAppendingString:@" 11:59 PM"];
    }
    mutHeaderDict[kStartDate] = startDate;
    mutHeaderDict[kEndDate] = endDate;

    
    //DKD commneted on 15Apr 2020
    //mutHeaderDict[kStartDate] = [Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}];
    //mutHeaderDict[kEndDate] = [Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}];
}

-(void)disableAllControls{
    self.customButton.enabled = NO;
    self.txtFieldSearch.enabled = NO;
    self.btnStartDate.enabled = NO;
    self.btnEndDate.enabled = NO;
}

-(void)fetchVehicleList{
    NSDictionary *requestDict = @{kApiRequest:@"Vehicle/List"};
    [connectionHandler makeConnectionWithRequest:requestDict];
 
}

#pragma mark Connection response handling
-(void)receiveResponse:(id)responseDict{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([responseDict[kRequest][kApiRequest] isEqualToString:@"Vehicle/List"]) {
            vehicleArray = responseDict[kResponse];
        }
        else{
            id responseValue = responseDict[kResponse];
            
            [self processVehicleResponse:responseValue];

            //NSLog(@"responsevalue =%@", responseValue);
        }
        [Util hideLoader:self.view];
    });
}

-(void)processVehicleResponse:(NSArray *)responseArray{
    
    if ([responseArray isEqual:[NSNull null]]|| responseArray == nil) {
        [Util showAlert:@"" andMessage:@"Oops! Something went wrong. We will take care of it soon." forViewController:self];
        
        return;
    }
    else if([responseArray isKindOfClass:[NSArray class]] && [responseArray count]==0){
     [Util showAlert:@"" andMessage:@"No report data for the selected parameters." forViewController:self];
    }
    
    [mutArrVehicle removeAllObjects];
    
    //We will refresh each time
    initialIndex = 0;
    previousSummaryCount = 0;
    
    reportDetailArray = responseArray;
    
    int rowNo = 0;
    
    for (NSDictionary *responseDict in responseArray) {
        
        NSArray *tempArray = responseDict[@"SummaryData"];

        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Index" ascending:YES];

        NSArray *summaryArray = [tempArray sortedArrayUsingDescriptors:@[sortDescriptor]];;

        ////NSLog(@"summaryArray =%@",summaryArray);
        
        int showDetail = [responseDict[@"HasDetailData"] intValue];
        
        UIColor *cellColor = [UIColor whiteColor];
        
        if (rowNo%2==0) {
            cellColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:243/255.0f alpha:1];
        }
        
        initialIndex = initialIndex + previousSummaryCount;
        
        NSUInteger keyCount = [summaryArray count];
        
        previousSummaryCount = keyCount;
        
        //NSMutableString *mutString = [[NSMutableString alloc]initWithCapacity:10];
        
        NSDictionary *dict = nil;
        
        int i = 0;
        
        for (NSDictionary *tempdict in summaryArray) {
            BOOL flgFirstIndex = NO;
            /* if (i==0) {
                dict = @{cellID:@"cell0",kVehicleName:summaryDict[kVehicleName],kCellColor:cellColor,kShowDetail:@(showDetail)};
            }*/
            if([tempdict[@"Key"] isEqualToString:kVehicleName]){
                ////NSLog(@"We have already taken vehicle name hemce don't take it again");
                dict = @{cellID:@"cell0",kVehicleName:tempdict[@"Value"],kCellColor:cellColor,kShowDetail:@(showDetail),kReportDict:responseDict};
                flgFirstIndex = YES;
            }
            else{
                //[mutString appendFormat:@"\n%@%@%@",key,SPACE_STRING,summaryDict[key]];
                dict = @{cellID:@"cell1",key2:tempdict[@"Key"],kvalue2:tempdict[@"Value"],kCellColor:cellColor,kDivider:@0};
                if (i==keyCount-1) {
                    dict = @{cellID:@"cell1",key2:tempdict[@"Key"],kvalue2:tempdict[@"Value"],kCellColor:cellColor,kDivider:@1};
                }

            }
            i++;
            
            if (flgFirstIndex) {
                
                //NSLog(@"initialIndex =%lu and previousSummaryCount =%lu",initialIndex,previousSummaryCount);
                
                [mutArrVehicle insertObject:dict atIndex:initialIndex];
            }
            else{
                [mutArrVehicle addObject:dict];
            }
        }
        
        //NSDictionary *dict = @{key1:summaryDict[key1],key2:mutString};
        
        
        rowNo ++;
    }
    
    [self.tblView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button clicked

-(IBAction)btnReportDetailClicked:(CustomButton *)customButton{
    NSDictionary *info = customButton.infoDict;
    //NSLog(@"info =%@",info);
    
    ReportDetailVC *reportDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportDetailVC"];
    reportDetail.reportDict = info;
    reportDetail.vehicleName = customButton.string1;
    [self.navigationController pushViewController:reportDetail animated:YES];
}

-(void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnOKClicked:(id)sender {
    if ([self validateAllField]) {
        //All is fine
        
        //api/v1/ReportsData/{reportId}/{vehicleId}/{startDate}/{endDate}/{textFilter}
        NSString *vehicleId = @"0";
        NSString *startDate = @"0";
        NSString *endDate = @"0";
        NSString *textFilter = @"0";
        
        if (flgVehicleRequired) {
            vehicleId = [NSString stringWithFormat:@"%d",[mutHeaderDict[kVehilcleField][@"VehicleId"] intValue]];
        }
        if (flgTextinputRequired){
            textFilter = mutHeaderDict[kSearchField];
        }
        //DKD added this extra condition on 17 Apr 2020
        if (flgStartDateRequired && flgEndDateRequired){
            startDate = [Util universalDateFormate:@{kActualDateFormate:@"dd-MM-yyyy h:mm a", kRequiredDateFormate:@"dd-MM-yyyy HH_mm_ss", kDate:mutHeaderDict[kStartDate]}];
            
            endDate = [Util universalDateFormate:@{kActualDateFormate:@"dd-MM-yyyy h:mm a", kRequiredDateFormate:@"dd-MM-yyyy HH_mm_ss", kDate:mutHeaderDict[kEndDate]}];
            
            NSLog(@"startDate =%@",startDate);
        }
        else if (flgStartDateRequired){
            startDate = [NSString stringWithFormat:@"%@ 00_00_00",mutHeaderDict[kStartDate]];
        }
        else if (flgEndDateRequired){
            endDate = [NSString stringWithFormat:@"%@ 23_59_59",mutHeaderDict[kEndDate]];
        }

        [Util showLoader:@"" forView:self.view];
        
        NSString *api = [NSString stringWithFormat:@"ReportsData/%d/%@/%@/%@/%@",[self.reportDict[@"ReportTypeId"] intValue],vehicleId,startDate,endDate,textFilter ];
        
        api = [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *requestDict = @{kApiRequest:api};
        [connectionHandler makeConnectionWithRequest:requestDict];
    }
    
}

-(BOOL)validateAllField{
    BOOL flgValid = YES;
    if (flgVehicleRequired && [mutHeaderDict[kVehilcleField][@"VehicleId"] intValue] == 0) {
        [Util showAlert:@"" andMessage:[@"ERROR_VEHICLE" localizableString:@""] forViewController:self];
        flgValid = NO;
    }
    else if (flgTextinputRequired && [mutHeaderDict[kSearchField] length]==0) {
        [Util showAlert:@"" andMessage:[NSString stringWithFormat:[@"ERROR_INPUT_FIELD" localizableString:@""],self.reportDict[@"TextInputFieldName"]] forViewController:self];
        flgValid = NO;
    }
    else if (flgStartDateRequired && flgEndDateRequired){
        NSDate *date1 = [Util fetchDateFromString:mutHeaderDict[kStartDate]];
        NSDate *date2 = [Util fetchDateFromString:mutHeaderDict[kEndDate]];
        
        if ([date1 compare:date2] == NSOrderedDescending) {
            [Util showAlert:@"" andMessage:[@"ERROR_END_START_DATE" localizableString:@""] forViewController:self];
            flgValid = NO;
        }
    }
    
    return flgValid;
}

-(IBAction)btnStartDateClicked:(id)sender{
    buttonType = 1;
    activeButton = sender;
    [self createDateView:@{kMaximumDate:[NSDate date],kPickerTitle:@"Please select start date",kMinimumDate:[[NSDate date] dateByAddingTimeInterval:-2016*365*24*3600]}];
}
-(IBAction)btnEndDateClicked:(id)sender{
    buttonType = 2;
    activeButton = sender;
    [self createDateView:@{kMaximumDate:[NSDate date],kPickerTitle:@"Please select end date",kMinimumDate:[[NSDate date] dateByAddingTimeInterval:-2016*365*24*3600]}];
}

-(void)createDateView:(NSDictionary *)dict{
    
    if (!myDateContainer) {
        myDateContainer = [[MyDateConatiner alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 250, self.view.bounds.size.width, 250)];
        myDateContainer.myDateConatinerDelegate = self;

        [self.view addSubview:myDateContainer];
        myDateContainer.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0];

        [myDateContainer childviewSetup];
        
    }
    
   [myDateContainer valueSetUp:dict];
    myDateContainer.datePicker.datePickerMode = flgStartDateRequired&&flgEndDateRequired?UIDatePickerModeDateAndTime:UIDatePickerModeDate;
    myDateContainer.datePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:-2016*365*24*3600];//This will make date to satrt frmom 04 year
    
    [self hideALLView];
    
    myDateContainer.hidden = NO;
    
}


-(IBAction)btnVehicleClicked:(CustomButton *)customButton{
    
    [self hideALLView];
    
    pickerContainer.hidden = NO;
    
    if (!pickerContainer) {
        pickerContainer = [[PickerContainer alloc]init];
        pickerContainer.pickerContainerDelegate = self;
        pickerContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:pickerContainer];
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerContainer]|"
                                                 options:0 metrics:nil
                                                   views:@{@"pickerContainer":pickerContainer}]];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:pickerContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:250.0f];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:pickerContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        
        [self.view addConstraint:heightConstraint];
        [self.view addConstraint:bottomConstraint];
        
        [pickerContainer initialviewsetup];
        
        pickerContainer.backgroundColor = [UIColor whiteColor];
    }
    
    activeButton = customButton;
    
    pickerContainer.pickerArray = vehicleArray;
    pickerContainer.keyName = @"VehicleName";
    [pickerContainer updatePickerContentDict:customButton.infoDict];
}

-(void)hideALLView{
    pickerContainer.hidden = YES;
    myDateContainer.hidden = YES;
}

#pragma mark Pickercontainer delegate method
-(void)pickerSelected:(NSDictionary *)selectedValue{
    self.customButton.infoDict = selectedValue;
    
    mutHeaderDict[kVehilcleField] = selectedValue;
    
    [activeButton setTitle:selectedValue[@"VehicleName"] forState:UIControlStateNormal];
    pickerContainer.hidden = YES;
}

-(void)dateChanged:(NSDate *)date{
    myDateContainer.hidden = YES;
    
    //DKD added this on 16 Apr 2020
    NSString *dateFormate = flgStartDateRequired && flgEndDateRequired?@"dd-MM-yyyy h:mm a":@"dd-MM-yyyy";
    
    
    NSString *buttonTitle = [Util fromDateToStringConverter:@{kActualDateFormate:dateFormate,kDate:date}];
    
    [activeButton setTitle:[Util fromDateToStringConverter:@{kActualDateFormate:dateFormate,kDate:date}] forState:UIControlStateNormal];
    
    activeButton.infoDict = @{kDate:date};
    
    if (buttonType == 1) {
        mutHeaderDict[kStartDate] = buttonTitle;
    }
    else{
        mutHeaderDict[kEndDate] = buttonTitle;
    }
    
}

-(void)cancelButtonPressed{
    myDateContainer.hidden = YES;
}

#pragma mark Tableview data source & delegate method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mutArrVehicle count] + 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:headerCellId];
        
        //Set button'text to currnt date
        
        /*
         mutHeaderDict = [[NSMutableDictionary alloc]initWithCapacity:4];
         mutHeaderDict[kVehilcleField] = @{@"VehicleName":@"Vehicle Name",@"VehicleId":@""};
         mutHeaderDict[kSearchField] = @"";
         mutHeaderDict[kStartDate] = [Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}];
         mutHeaderDict[kEndDate] = [Util fromDateToStringConverter:@{kActualDateFormate:@"dd-MM-yyyy",kDate:[NSDate date]}];
         
         */
        
        NSDictionary *dict = mutHeaderDict[kVehilcleField];
        
        [cell.customButton3 setTitle:dict[@"VehicleName"] forState:UIControlStateNormal];
        [cell.customButton1 setTitle:mutHeaderDict[kStartDate] forState:UIControlStateNormal];
        
        //DKD added on 15 Apr 2020
        cell.customButton1.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.customButton1.titleLabel.textAlignment = NSTextAlignmentCenter;
        cell.customButton2.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.customButton2.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        ///////
        
        [cell.customButton2 setTitle:mutHeaderDict[kEndDate] forState:UIControlStateNormal];
        
        [cell.customButton1 updateStyleWithInfo:@{kCornerRadius:@0.0f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f  blue:170/255.0f  alpha:1],kBorderWidth:@1.0f}];
        [cell.customButton2 updateStyleWithInfo:@{kCornerRadius:@0.0f,kBorderColor:[UIColor colorWithRed:170/255.0f green:170/255.0f  blue:170/255.0f  alpha:1],kBorderWidth:@1.0f}];
        
        cell.txtField1.placeholder = [@"" localizableString:@"HINT_SEARCH"];

        cell.txtField1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.reportDict[@"TextInputFieldName"] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        //End date is not there hence hide
        if ([self.reportDict[@"IsEndDateRequired"] intValue]==0) {
            cell.lbl1.hidden = YES;
            cell.customButton2.hidden = YES;
        }
               cell.lbl7.text = [@"TV_START_DATE_TIME" localizableString:@""];
               cell.lbl1.text = [@"TV_END_DATE_TIME" localizableString:@""];
               [cell.btn4 setTitle:[@"ALERT_BUTTON_OK" localizableString:@""] forState:UIControlStateNormal];
        
    }
    
    else{
        NSDictionary *dict = mutArrVehicle[indexPath.row - 1];
        
        if ([dict[cellID] isEqualToString:@"cell0"]) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:dict[cellID]];
            cell.lbl1.text = dict[kVehicleName];
            cell.customButton1.hidden = ![dict[kShowDetail] intValue];
            cell.customButton1.infoDict = dict[kReportDict];
            cell.customButton1.string1 = dict[kVehicleName];
            cell.contentView.backgroundColor = dict[kCellColor];
            
            NSString *fontawsomeCode = @"\uf0d1";
            cell.lbl2.text = fontawsomeCode;
            cell.lbl2.textColor = [UIColor colorWithRed:150/255.0f green:150/255.0f blue:150/255.0f alpha:1];
            cell.lbl2.backgroundColor = [UIColor clearColor];
        }
        else if ([dict[cellID] isEqualToString:@"cell1"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:dict[cellID]];
            cell.lbl1.text = dict[key2];
            cell.lbl2.text = dict[kvalue2];
            cell.contentView.backgroundColor = dict[kCellColor];
            cell.view1.backgroundColor = tableView.separatorColor;
            cell.view1.hidden = ![dict[kDivider] intValue];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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

#pragma mark Textfield updated

-(IBAction)textFieldValueUpdated:(UITextField *)textfield{
    mutHeaderDict[kSearchField] = textfield.text;
}

-(NSAttributedString *)fetchAttributedText{
    
    UIFont *font1 = [UIFont systemFontOfSize:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:font1,
                            NSForegroundColorAttributeName: [UIColor darkGrayColor]
    };
    NSAttributedString *attribString = [[NSAttributedString alloc] initWithString:[@"TV_VIEW_DETAILS" localizableString:@""] attributes:dict1];
    
    return attribString;
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
