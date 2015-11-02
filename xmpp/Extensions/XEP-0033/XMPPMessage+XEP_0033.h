//
//  XMPPMessage+XEP_0033.h
//  iPhoneXMPP
//
//  Created by RAHUL on 11/2/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@interface XMPPMessage (XEP_0033)

+ (XMPPMessage *)multicastMessageWithType:(NSString *)type jids:(NSArray *)jids module:(NSString*)module;

/**
 * @param jids
 *   Supports both NSString or XMPPJID instances.
 **/
- (id)initWithType:(NSString *)type jids:(NSArray *)jids module:(NSString *)module;

- (BOOL)isMulticast;
- (NSArray *)jids;
- (NSArray *)jidStrings;

@end
