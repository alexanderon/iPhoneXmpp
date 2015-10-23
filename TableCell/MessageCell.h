//
//  MessageCell.h
//  ChatDemo
//
//  Created by 9SPL_Mac on 19/10/15.
//  Copyright © 2015 9SPL_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (nonatomic,strong)IBOutlet UILabel *senderAndTimeLabel;
@property (nonatomic,strong)IBOutlet UILabel *lblMessageLeft,*lblMessageRight;

@property (nonatomic,strong)IBOutlet UIView *ViewLeft,*ViewRight;
@property (nonatomic,strong)IBOutlet UIImageView *ivLeft,*ivRight;

@end
