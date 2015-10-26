//
//  ImageViewCell.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/26/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgRight,*imgLeft;
@property (weak, nonatomic) IBOutlet UIView *leftView,*rightView;

@end
