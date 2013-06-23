//
//  ViewController.m
//  twitterfriend
//
//  Created by saurabh sindhu on 23/06/13.
//  Copyright (c) 2013 saurabh sindhu. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Tweet.h"
#import "TwitterConnection.h"

#define IMAGE_PREVIEW_TAG 11
#define NAME_LABEL_TAG 10

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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tweets = [[NSMutableArray alloc]init];
    fndname = [[NSMutableArray alloc]init];
      
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataIfNecessary) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshDataIfNecessary];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //NSLog(@"%@",tweets);

    
    UIImageView *imgEvent=[[UIImageView alloc]initWithFrame:CGRectMake(2, 0, 43, 43)];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[tweets objectAtIndex:indexPath.row]]];
      
    UIImage *img = [UIImage imageWithData:data];

    imgEvent.image=img;
      
    
   // NSLog(@"%@",imgEvent.image);
    
    [cell.contentView addSubview:imgEvent];
   
    UILabel *NameLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, 200, 30)];
    [NameLabel setTextColor:[UIColor blackColor]];
    [NameLabel setTextAlignment:NSTextAlignmentLeft];
    [NameLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [NameLabel setText:[fndname objectAtIndex:indexPath.row]];
    [cell addSubview:NameLabel];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && currentMaxDisplayedCell == 0){
        currentMaxDisplayedCell = -1;
    }
    
    if (indexPath.row > currentMaxDisplayedCell){
        
        cell.contentView.alpha = 0.7;
        
        CGAffineTransform transformScale = CGAffineTransformMakeScale(0.9, 0.9);
        
        cell.contentView.transform = transformScale;
        
        [table bringSubviewToFront:cell.contentView];
        [UIView animateWithDuration:0.5 animations:^{
            cell.contentView.alpha = 1;
            //clear the transform
            cell.contentView.transform = CGAffineTransformIdentity;
        } completion:nil];
        
    }
    currentMaxDisplayedCell = indexPath.row;
}
#pragma mark - Twitter server calls

- (void)loadProfilePictures
{
    for (int i = 0; i < tweets.count; i++)
    {
        Tweet *tweet = [tweets objectAtIndex:i];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tweet.imageURL]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                tweet.image = [UIImage imageWithData:data];
                
                NSArray *array = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]];
                [table reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
}

- (void)tweetRetrieved:(id)response
{
    if( [response isKindOfClass:[NSString class]] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:response
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [table reloadData];
        //[self loadProfilePictures];
        [self dismissLoadingAlertView];
        dataLoading = NO;
        return;
    }
    
    NSArray *jsonusers = [response objectForKey:@"users"];
    NSString *nextCursor = [response objectForKey:@"next_cursor_str"];
    
    for (NSDictionary *jsonTweet in jsonusers)
    {
        NSString *name = [jsonTweet objectForKey:@"name"];
        NSString *user = [jsonTweet objectForKey:@"screen_name"];
        NSString *text = @"";
        
        NSString *imageUrl = [jsonTweet objectForKey:@"profile_image_url"];
        UIImage *profilePic = nil;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 0;
        coordinate.longitude = 0;
        
        [tweets addObject:imageUrl];
        [fndname addObject:name];
        
        
        Tweet *tweet = [[Tweet alloc] initWithUser:user name:name text:text coordinate:coordinate image:profilePic imageURL:imageUrl];
        
        //[imagPic addObject:imageUrl];
        //[tweets addObject:tweet];
    }
    
    // If there's any other page, reload tableview data and download the profile pictures, otherwise make a new call
    if ([nextCursor isEqualToString:@"0"]) {
        [table reloadData];
       // [self loadProfilePictures];
        [self dismissLoadingAlertView];
        dataLoading = NO;
    }
    else {
        [self tweeterConnectionWithCursor:nextCursor];
    }
}

- (void)tweeterConnectionWithCursor:(NSString *)cursor
{
    NSDictionary *params = @{@"cursor" : cursor,
                             @"skip_status" : @"true",
                             @"include_user_entities" : @"true"};
    
    // NOTE: Im not using here twiter API 1.1, but 1, because of their crazy rate limit policy.. If you want to use API 1.1 please use TWITTER_FRIENDS_URL constant
    [TwitterConnection twitterConnectionWithApiUrl:TWITTER_FOLLOWINGS_URL params:params target:self selector:@selector(tweetRetrieved:)];
}

- (void)retriveCurrentTwitterAccount
{
    dataLoading = YES;
    tweets = [NSMutableArray new];
    [self tweeterConnectionWithCursor:@"-1"];
    [self showLoadingAlert];
}

- (void)refreshDataIfNecessary
{
    if ((tweets == nil || tweets.count == 0) && !dataLoading)
    {
        [self retriveCurrentTwitterAccount];
    }
}

- (void)showLoadingAlert
{
    loadingAlertView = [[UIAlertView alloc] initWithTitle:@"Loading" message:@"Please wait"
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(125, 75, 36, 36);
    [loadingAlertView addSubview:spinner];
    [spinner startAnimating];
    [loadingAlertView show];
}

- (void)dismissLoadingAlertView
{
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    loadingAlertView = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
