//
//  RequestTableViewCell.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/19/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lblRequestFromUser;
@property (weak, nonatomic) IBOutlet UIButton *btnRejectRequest;
@property (weak, nonatomic) IBOutlet UIButton *btnAcceptRequest;




@end
