//
//  TwitterConnection.m
//  TwitterWorld
//
//  Created by Emmanuel Garnier on 16/04/13.
//  Copyright (c) 2013 Emmanuel Garnier. All rights reserved.
//

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TwitterConnection.h"

#define TWITTER_FOLLOWINGS_URL @"https://api.twitter.com/1/following.json"
#define TWITTER_NEAR_FEED_URL @"https://api.twitter.com/1.1/search/tweets.json"
#define TWITTER_FRIENDS_URL @"https://api.twitter.com/1.1/friends/list.json"

#define ERROR_LOCATION_FAILED @"Failed to get you current location"
#define ERROR_NO_DATA @"Could not retrieve your data.. try later"
#define ERROR_TWITTER_ACCESS @"In order to use Twitter functionality, please add your Twitter account in Settings."
#define ERROR_TWITTER_LIMIT @"Twitter rate limit... =^("
#define ERROR_PARSING @"Json error"
#define ERROR_SERVER @"Server error %i... please try later =^("

#define MESSAGE_TWEET @"Hey twitto! check this funny image of you haha =^]"


@implementation TwitterConnection

+ (void)twitterConnectionWithApiUrl:(NSString *)urlStr params:(NSDictionary *)params target:(NSObject *)target selector:(SEL)responseSelector
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [accountStore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            ACAccount *twitterAccount = [twitterAccounts lastObject];
            NSURL *url = [NSURL URLWithString:urlStr];
            // Uncomment to use a specific username as screen name
//            params = [NSMutableDictionary dictionaryWithDictionary:params];
//            [params setObject:@"some_user_name" forKey:@"screen_name"];
            SLRequest *request =
            [SLRequest requestForServiceType:SLServiceTypeTwitter
                               requestMethod:SLRequestMethodGET
                                         URL:url
                                  parameters:params];
            
            [request setAccount:twitterAccount];
            
            [request performRequestWithHandler:^(NSData *responseData,
                                                 NSHTTPURLResponse *urlResponse,
                                                 NSError *error) {
                if (responseData) {
                    if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                        NSError *jsonError;
                        NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                        
                        if (timelineData) {
//                            NSLog(@"Timeline Response: %@\n", timelineData);
                            
                            [target performSelectorOnMainThread:responseSelector withObject:timelineData waitUntilDone:NO];
                            
                        }
                        else {
                            // Our JSON deserialization went awry
                            NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                            [target performSelectorOnMainThread:responseSelector withObject:ERROR_PARSING waitUntilDone:NO];
                        }
                    }
                    else {
                        // The server did not respond successfully... were we rate-limited?
                        NSLog(@"The response status code is %d", urlResponse.statusCode);
                        if (urlResponse.statusCode >= 420 && urlResponse.statusCode < 430) {
                            [target performSelectorOnMainThread:responseSelector withObject:ERROR_TWITTER_LIMIT waitUntilDone:NO];
                        }
                        else {
                            [target performSelectorOnMainThread:responseSelector withObject:[NSString stringWithFormat:ERROR_SERVER, urlResponse.statusCode] waitUntilDone:NO];
                        }
                    
                    }
                }
                else
                {
                    [target performSelectorOnMainThread:responseSelector withObject:[error localizedDescription] waitUntilDone:NO];
                }
            }];
        }
        else
        {
            [target performSelectorOnMainThread:responseSelector withObject:ERROR_TWITTER_ACCESS waitUntilDone:NO];
        }
    }];
    #pragma clang diagnostic pop
}

@end
