//
//  TwitterConnection.h
//  TwitterWorld
//
//  Created by Emmanuel Garnier on 16/04/13.
//  Copyright (c) 2013 Emmanuel Garnier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterConnection : NSObject

+ (void)twitterConnectionWithApiUrl:(NSString *)url params:(NSDictionary *)params target:(NSObject *)target selector:(SEL)responseSelector;

@end
