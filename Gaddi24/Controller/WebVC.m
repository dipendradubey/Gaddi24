//
//  WebVC.m
//  TrackGaddi
//
//  Created by Dipendra Dubey on 21/06/20.
//  Copyright © 2020 crayonInfotech. All rights reserved.
//

#import "WebVC.h"
#import <WebKit/WebKit.h>
#import "Util.h"
#import "Global.h"
#import "UIViewController+MMDrawerController.h"


@interface WebVC ()

@property(nonatomic,strong)WKWebView *webView;
@end

@implementation WebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialsetup];
    // Do any additional setup after loading the view.
}

-(void)initialsetup{
    [self navaigationBarSetUp];
    NSDictionary *dict = [Util retrieveDefaultForKey:kMarqueeResult];
    NSURL *url = [NSURL URLWithString:dict[@"PaymentGatewayDetails"][@"PageUrl"]];
    //NSURL *url = [NSURL URLWithString:@"https://www.google.com/"];

   NSURLRequest *request = [NSURLRequest requestWithURL:url];

   _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
   [_webView loadRequest:request];
   _webView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
   [self.view addSubview:_webView];
}

-(void)navaigationBarSetUp{
    self.navigationController.navigationBar.hidden = NO;
       
       self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
       self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:47/255.0f alpha:1];
       self.navigationController.navigationBar.translucent = NO;
       
       self.navigationItem.title = [Util retrieveDefaultForKey:kMarqueeResult][@"PaymentGatewayDetails"][@"PartyName"];
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
