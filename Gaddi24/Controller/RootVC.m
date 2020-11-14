//
//  RootVC.m
//  TrackGaddi
//
//  Created by Jignesh Chauhan on 10/12/16.
//  Copyright (c) 2016 crayonInfotech. All rights reserved.
//

#import "RootVC.h"
#import "LoginVC.h"
#import "TrackVehicleVC.h"
#import "VehicleListVC.h"
#import "MMDrawerController.h"
#import "SettingVC.h"
#import "BirdViewVC.h"
#import "PopoverVC.h"
#import "PlaybackVC.h"
#import "Util.h"
#import "Global.h"
#import "CommandVC.h"

@interface RootVC ()

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialsetup];
}

-(void)showDashboardORBirdView{

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];;
    
    UIViewController * leftDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    
    MMDrawerController *destinationViewController = [[MMDrawerController alloc]init];
    
    UIViewController * center = nil;
    
    
    if([[Util retrieveDefaultForKey:kHomeScreen] integerValue] == BIRDVIEW_TAG){
        storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];;
       center = [storyboard instantiateViewControllerWithIdentifier:@"BirdViewVC"];
    }
    else{
        center = [storyboard instantiateViewControllerWithIdentifier:@"VehicleListVC"];
    }
    
    UINavigationController *navCenter = [[UINavigationController alloc]initWithRootViewController:center];
    
    [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
    
    [destinationViewController setCenterViewController:navCenter];
    
    [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.navigationController pushViewController:destinationViewController animated:NO];
    
}

//DKD added on 18 Apr 2020
-(void)showBireView{

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];;
    
    UIViewController * leftDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    
    MMDrawerController *destinationViewController = [[MMDrawerController alloc]init];
    
    UIViewController * center = [storyboard instantiateViewControllerWithIdentifier:@"VehicleListVC"];
    
    
    
    UINavigationController *navCenter = [[UINavigationController alloc]initWithRootViewController:center];
    
    [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
    
    [destinationViewController setCenterViewController:navCenter];
    
    [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.navigationController pushViewController:destinationViewController animated:NO];
    
}


-(void)initialsetup{
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([Util  retrieveDefaultForKey:kLoginResponse]) {
        [self showDashboardORBirdView];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
        LoginVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:VC animated:NO];
    }
    
     
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    PopoverVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"PopoverVC"];
    [self.navigationController pushViewController:VC animated:NO];
    */
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    PlaybackVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"PlaybackVC"];
    VC.selectedVehicleDict =
    @{@"VehicleId":@413,@"VehicleName":@"X-GJ16Z9068"};
    [self.navigationController pushViewController:VC animated:NO];
     */
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
    BirdViewVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"BirdViewVC"];
    [self.navigationController pushViewController:VC animated:NO];
    */
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
    TrackVehicleVC *VC = [storyboard instantiateViewControllerWithIdentifier:@"TrackVehicleVC"];
    VC.selectedVehicleDict =
    @{@"VehicleId":@54,@"VehicleName":@"X-GJ16Z9068"};
    [self.navigationController pushViewController:VC animated:NO];
    */
    
    
    /*
    UIViewController * leftDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    
    MMDrawerController *destinationViewController = [[MMDrawerController alloc]init];
                                     
    UIViewController * center = [storyboard instantiateViewControllerWithIdentifier:@"VehicleListVC"];
    
    [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
    
    [destinationViewController setCenterViewController:center];
    
    [self.navigationController pushViewController:destinationViewController animated:NO];
     */
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
    UIViewController * leftDrawerViewController = [storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    
    MMDrawerController *destinationViewController = [[MMDrawerController alloc]init];
    
    UIViewController * center = [storyboard instantiateViewControllerWithIdentifier:@"SettingVC"];
    
    [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
    
    [destinationViewController setCenterViewController:center];
    
    [self.navigationController pushViewController:destinationViewController animated:NO];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
