//
//  XMPPMessage+XEP_0033.m
//  iPhoneXMPP
//
//  Created by RAHUL on 11/2/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "XMPPMessage+XEP_0033.h"
#import "XMPPJID.h"

#import "NSXMLElement+XMPP.h"
#if TARGET_OS_IPHONE
#import "DDXML.h"
#endif

static NSString *const xmlns_multicast = @"http://jabber.org/protocol/address";

@implementation XMPPMessage (XEP_0033)

+ (XMPPMessage *)multicastMessageWithType:(NSString *)type jids:(NSArray *)jids module:(NSString*)module
{
    return [[XMPPMessage alloc] initWithType:type jids:jids module:module];
}

- (id)initWithType:(NSString *)type jids:(NSArray *)jids module:(NSString *)module
{
    if ((self = [super initWithName:@"message"]))
    {
        if (type)
            [self addAttributeWithName:@"type" stringValue:type];
        
        if (module)
            [self addAttributeWithName:@"to" stringValue:module];
        
        
        NSXMLElement *multicast = [NSXMLElement elementWithName:@"addresses" xmlns:xmlns_multicast];
        [self addChild:multicast];
        
        for (id recipient in jids)
        {
            NSString *jidStr = nil;
            if ([recipient isKindOfClass:[XMPPJID class]])
                jidStr = [(XMPPJID *)recipient full];
            else if ([recipient isKindOfClass:[NSString class]])
                jidStr = (NSString *)recipient;
            
            if (jidStr)
            {
                NSXMLElement *address =  [NSXMLElement elementWithName:@"address" ];
                [address addAttributeWithName:@"type" stringValue:@"to"];
                [address addAttributeWithName:@"jid" stringValue:jidStr];
                [multicast addChild:address];
            }
        }
    }
    return self;
}

- (BOOL)isMulticast
{
    return ([[self elementsForXmlns:xmlns_multicast] count] > 0);
}

- (NSArray *)jids
{
    NSMutableArray *jids = nil;
    
    NSXMLElement *multicast = [self elementForName:@"addresses"];
    if (multicast)
    {
        NSArray *addresses = [multicast elementsForName:@"address"];
        
        jids = [[NSMutableArray alloc] initWithCapacity:[addresses count]];
        for (NSXMLElement* address in  addresses)
        {
            NSString *jidStr = [[address attributeForName:@"jid"] stringValue];
            XMPPJID *jid = [XMPPJID jidWithString:jidStr];
            if (jid) {
                [jids addObject:jid];
            }
        }
    }
    
    return jids;
}

- (NSArray *)jidStrings
{
    NSMutableArray *jids = nil;
    
    NSXMLElement *multicast = [self elementForName:@"addresses"];
    if (multicast)
    {
        NSArray *addresses = [multicast elementsForName:@"address"];
        jids = [[NSMutableArray alloc] initWithCapacity:[addresses count]];
        
        for (NSXMLElement *address in addresses)
        {
            NSString *jid = [[address attributeForName:@"jid"] stringValue];
            if (jid) {
                [jids addObject:jid];
            }
        }
    }
    
    return jids;
}

@end
