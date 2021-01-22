//
//  CollectionViewCell.h
//  TrackGaddi
//
//  Created by Dipendra Dubey on 25/12/16.
//  Copyright © 2016 crayonInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UILabel *lbl1;
@property(nonatomic,weak)IBOutlet UILabel *lbl2;
@property(nonatomic,weak)IBOutlet UILabel *lbl3;
@property(nonatomic,weak)IBOutlet UIView *view1;
@property(nonatomic,weak)IBOutlet UIImageView *imageView1;
@property(nonatomic,weak)IBOutlet UIImageView *imageView2;


@end
