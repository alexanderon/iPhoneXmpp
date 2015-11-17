//
//  Rest.m
//  iPhoneXMPP
//
//  Created by RAHUL on 11/4/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "Rest.h"
#import "iPhoneXMPPAppDelegate.h"

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

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    NSString *user =[self appDelegate].myJid;
    NSString *pass=[self appDelegate].password;
    if ([user containsString:@"@"]) {
        
        user=[[user componentsSeparatedByString:@"@"]firstObject];
    }
    
    
    NSString *auth=[self getAuthString:user  Password:pass OfType:@"Basic"];
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
    
    NSString* loginString = [NSString stringWithFormat:@"%@:%@", @"dipesh" ,@"Test105*"];
    NSData *    loginData =[loginString dataUsingEncoding:(NSUTF8StringEncoding)];
    NSString * base64LoginString =  [loginData base64EncodedStringWithOptions:nil];
    NSLog(@"%@",base64LoginString);
    NSString *auth =[NSString stringWithFormat:@"%@ \(%@)",authType,base64LoginString];
    if (auth) {
        return  auth;
    }
    return @"";
}

-(void)getRosterItemsforUser:(NSString *)username withCompletionHandler:(void (^)(NSData *))completionHandler
{
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/users/%@/roster",servername,username];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];

    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
        completionHandler(responseData);
    }];
    
    
    
}

-(void)getGroupsItemsforUser:(NSString *)username  withCompletionHandler:(void (^)(NSData *))completionHandler
{
    
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/users/%@/groups",servername,username];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    NSLog(@"%@",request.URL);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
            NSLog(@"%@",[[NSMutableString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]);
        completionHandler(responseData);
    }];
    


}

-(void)createGroupWithName:(NSString *)groupName Description:(NSString *)description withCompletionHandler:(void (^)(int data))completionHandler
{

    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/groups",servername];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/xml"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    NSString *xmlString =[NSString stringWithFormat:@"<group><name>%@</name><description>%@</description></group>",groupName,description];
    
    [request setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%d",(int)[xmlString length]]forHTTPHeaderField:@"Content-length"];
    
     //[[[NSURLConnection alloc]initWithRequest:request delegate:self]start];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError)
    {
       
        NSLog(@"%@",responseCode);
        NSLog(@"%@",responseData);
        completionHandler(201);
    }];
    
    
}


-(void)removeUser:(NSString *)username FromGroup:(NSString *)group
{
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/users/%@/groups/%@",servername,username,group];
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

    
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/lockouts/%@",servername,username];
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
    
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/lockouts/%@",servername,username];
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
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/chatrooms",servername];
    
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"GET"
                                                  ContentType:@"application/json"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError]);
    }];
    

}

-(void)createChatRoomWithName:(NSString *)roomName Description:(NSString *)description withCompletionHandler:(void (^)(int data))completionHandler
{
   NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/chatrooms",servername];
    
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/xml"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    NSString *xmlString =[NSString stringWithFormat:@"<chatRoom><naturalName>%@</naturalName>                    <roomName>%@</roomName><description>%@</description></chatRoom>",roomName,roomName,description];
    
    [request setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%d",(int)[xmlString length]]forHTTPHeaderField:@"Content-length"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError)
     {
         
         NSLog(@"%@",responseCode);
         NSLog(@"%@",responseData);
         completionHandler(201);
     }];
    
    

}

-(void)addUser:(NSString *)username ToGroup:(NSString *)group
{
    if ([username containsString:@"@"]) {
        username=[[username componentsSeparatedByString:@"@"] firstObject];
    }
    
    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/users/%@/groups/%@",servername,username,group];
    NSURL *baseUrl=[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/xml"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    
    
    
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue  currentQueue] completionHandler:^(NSURLResponse *responseCode, NSData *responseData, NSError *responseError) {
        NSLog(@"%@, %@, %@",responseCode,responseData,responseError);
    }];
    
    
}

-(void)addUser:(NSString *)user ToChatRoom:(NSString *)chatRoom Role:(NSString *)role
{
    if ([user containsString:@"@"]) {
        user=[[user componentsSeparatedByString:@"@"] firstObject];
    }

    NSString *urlstring =[NSString stringWithFormat:@"http://%@:9090/plugins/restapi/v1/chatrooms/%@/members/%@",servername,chatRoom,user];
    NSURL *baseUrl =[NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request =[self RequestWithHttpMethod:@"POST"
                                                  ContentType:@"application/xml"
                                                       Accept:@"application/json"
                                                   RequestURL:baseUrl];
    NSURLConnection *connection =[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}
@end
