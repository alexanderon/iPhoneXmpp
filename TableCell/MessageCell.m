//
//  MessageCell.m
//  ChatDemo
//
//  Created by 9SPL_Mac on 19/10/15.
//  Copyright © 2015 9SPL_Mac. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
    // Initialization code
    [self.lblMessageRight setNumberOfLines:0];
    [self.lblMessageRight setLineBreakMode:NSLineBreakByWordWrapping];
    [self.lblMessageLeft setNumberOfLines:0];
    [self.lblMessageLeft setLineBreakMode:NSLineBreakByWordWrapping];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
