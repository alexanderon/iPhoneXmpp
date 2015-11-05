//
//  Rest.h
//  iPhoneXMPP
//
//  Created by RAHUL on 11/4/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rest : NSObject

+(Rest *)sharedInstance;
+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void(^)(NSData *data))completionHandler;
-(void)getChatRooms;
-(void)getChatRoomWithName:(NSString *)roomName;
-(void)getRosterItemsforUser:(NSString *)username;
-(void)getGroupsItemsforUser:(NSString *)username;
-(void)createGroupWithName:(NSString *)groupName Description:(NSString *)description;
-(void)addUser:(NSString *)username ToGroup:(NSString *)group;
-(void)removeUser:(NSString *)username FromGroup:(NSString *)group;
-(void)lockoutUser:(NSString *)username ;
-(void)setUser:(NSString *)user Password:(NSString *)password;
-(NSString *)getAuthString:(NSString *)userName Password:(NSString *)password OfType:(NSString *)authType;
-(NSMutableURLRequest *)RequestWithHttpMethod:(NSString *)httpMethod
                                  ContentType:(NSString *)contentType
                                       Accept:(NSString *)acceptType
                                   RequestURL:(NSURL    *)baseURL;

@end
