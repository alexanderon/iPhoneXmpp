//
//  Rest.m
//  iPhoneXMPP
//
//  Created by RAHUL on 11/4/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "Rest.h"

@interface Rest()

@property (nonatomic,strong)NSString *username,*password;

@end

@implementation Rest

static  Rest *rest =nil;

+(Rest *)sharedInstance
{
    
    if (!rest) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            rest=[[self alloc]init];
        });
    }
    return rest;
}

+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *))completionHandler
{
    // Instantiate a session configuration object.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Instantiate a session object.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            // If no error occurs, check the HTTP status code.
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            // If it's other than 200, then show it on the console.
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %d", (int)HTTPStatusCode);
            }
            
            // Call the completion handler with the returned data on the main thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data);
            }];
        }
    }];
    
    // Resume the task.
    [task resume];
}

-(void)setUser:(NSString *)user Password:(NSString *)password
{
    
    self.username=user;
    self.password=password;
}

-(NSMutableURLRequest *)RequestWithHttpMethod:(NSString *)httpMethod
                                  ContentType:(NSString *)contentType
                                       Accept:(NSString *)acceptType
                                   RequestURL:(NSURL    *)baseURL
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:baseURL];
    NSString *auth=[self getAuthString:self.username   Password:self.password OfType:@"Basic"];
    [request setHTTPMethod:httpMethod];
    [request setValue:contentType  forHTTPHeaderField:@"Content-type"];
    [request setValue:acceptType forHTTPHeaderField:@"Accept"];
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    
    return request;
}


-(NSString *)getAuthString:(NSString *)userName
                  Password:(NSString *)password
                    OfType:(NSString *)authType
{
    
    NSString* loginString = [NSString stringWithFormat:@"%@:%@", self.username  ,self.password];
    NSData *    loginData =[loginString dataUsingEncoding:(NSUTF8StringEncoding)];
    NSString * base64LoginString =  [loginData base64EncodedStringWithOptions:nil];
    NSLog(@"%@",base64LoginString);
    NSString *auth =[NSString stringWithFormat:@"%@ \(%@)",authType,base64LoginString];
    if (auth) {
        return  auth;
    }
    return @"";
}

-(void)getRosterItemsforUser:(NSString *)username
{
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/users/%@/roster",username];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];

    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    
    
    
}

-(void)getGroupsItemsforUser:(NSString *)username
{
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/users/%@/groups",username];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    


}

-(void)createGroupWithName:(NSString *)groupName Description:(NSString *)description
{

    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/groups"];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/xml"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    NSString *xmlString =[NSString stringWithFormat:@"<group><name>%@</name><description>%@</description></group>",groupName,description];
    
    [request setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%d",(int)[xmlString length]]forHTTPHeaderField:@"Content-length"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@",responseCode);
    }];
    
    
}

-(void)addUser:(NSString *)username ToGroup:(NSString *)group
{
    
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/users/%@/groups/%@",username,group];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@",responseCode);
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    

}

-(void)removeUser:(NSString *)username FromGroup:(NSString *)group
{
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/users/%@/groups/%@",username,group];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"DELETE"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@",responseCode);
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];

}

-(void)lockoutUser:(NSString *)username 
{

    
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/lockouts/%@",username];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@",responseCode);
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    

    
}

-(void)unlockUser:(NSString *)username
{
    
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/lockouts/%@",username];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"DELETE"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@",responseCode);
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];

}

-(void)getChatRooms
{

    NSString *urlstring =@"http://192.168.0.120:9090/plugins/restapi/v1/chatrooms";
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    

}

-(void)getChatRoomWithName:(NSString *)roomName
{
    NSString *urlstring =[NSString stringWithFormat:@"http://192.168.0.120:9090/plugins/restapi/v1/chatrooms/%@",roomName];

    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    

}



@end
