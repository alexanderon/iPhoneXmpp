//
//  musicTableViewCell.h
//  iPhoneXMPP
//
//  Created by RAHUL on 11/17/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface musicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblSongName;
@property (weak, nonatomic) IBOutlet UILabel *lblSingerName;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@end
