//
//  TableViewCell.h
//  Aurora
//
//  Created by Dipendra Dubey on 18/10/16.
//  Copyright © 2016 Pulse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "CustomButton.h"


@interface TableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIView *view1;

@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;

@property(nonatomic,weak)IBOutlet UIImageView *imageView1;
@property(nonatomic,weak)IBOutlet UIImageView *imageView2;
@property(nonatomic,weak)IBOutlet UIImageView *imageView3;

@property(nonatomic,weak)IBOutlet UILabel *lbl1;
@property(nonatomic,weak)IBOutlet UILabel *lbl2;
@property(nonatomic,weak)IBOutlet UILabel *lbl3;
@property(nonatomic,weak)IBOutlet UILabel *lbl4;
@property(nonatomic,weak)IBOutlet UILabel *lbl5;
@property(nonatomic,weak)IBOutlet UILabel *lbl6;
@property(nonatomic,weak)IBOutlet UILabel *lbl7;
@property(nonatomic,weak)IBOutlet UILabel *lbl8;

@property(nonatomic,weak)IBOutlet UIButton *btn1;
@property(nonatomic,weak)IBOutlet UIButton *btn2;
@property(nonatomic,weak)IBOutlet UIButton *btn3;
@property(nonatomic,weak)IBOutlet UIButton *btn4;

//@property(nonatomic,weak)IBOutlet APAspectFitImageView *spectFitImageView;


@property (nonatomic,weak)IBOutlet UITextField *txtField1;
@property (nonatomic,weak)IBOutlet UITextField *txtField2;


//@property(nonatomic,strong) APAspectFitImageView *prgSpectFitImageView;
@property(nonatomic,strong) UILabel *prgLbl1;
@property(nonatomic,strong) UILabel *prgLbl2;

@property(nonatomic,weak)IBOutlet SZTextView *sztextview;

@property(nonatomic,weak)IBOutlet UISlider *slider;

@property(nonatomic, weak)IBOutlet CustomButton *customButton1;
@property(nonatomic, weak)IBOutlet CustomButton *customButton2;
@property(nonatomic, weak)IBOutlet CustomButton *customButton3;

@property(nonatomic,weak)IBOutlet NSLayoutConstraint *constraint1;



@end
