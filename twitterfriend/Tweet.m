//
//  Tweet.m
//  TwitterWorld
//
//  Created by Emmanuel Garnier on 15/04/13.
//  Copyright (c) 2013 Emmanuel Garnier. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithUser:(NSString *)user name:(NSString *)name text:(NSString *)text coordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image imageURL:(NSString *)imageURL
{
    if ((self = [super init])) {
        _user = user;
        _name = name;
        _coordinate = coordinate;
        _image = image;
        _text = text;
        _imageURL = imageURL;
    }
    return self;
}

- (NSString *)title
{
    return _name;
}

- (NSString *)subtitle
{
    return _text;
}

- (NSString *)bigImageUrl
{
    NSString *result = [self.imageURL stringByReplacingOccurrencesOfString:@"_normal." withString:@"."];
    return result;
}

@end
