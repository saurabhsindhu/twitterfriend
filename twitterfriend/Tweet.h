//
//  Tweet.h
//  TwitterWorld
//
//  Created by Emmanuel Garnier on 15/04/13.
//  Copyright (c) 2013 Emmanuel Garnier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Tweet : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readonly) NSString *bigImageUrl;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithUser:(NSString *)user name:(NSString *)name text:(NSString *)text coordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image imageURL:(NSString *)imageURL;

@end
