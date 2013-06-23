//
//  ViewController.h
//  twitterfriend
//
//  Created by saurabh sindhu on 23/06/13.
//  Copyright (c) 2013 saurabh sindhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
 
    IBOutlet UITableView *table;
    int currentMaxDisplayedCell;
    BOOL dataLoading;
    NSMutableArray *tweets;
    NSMutableArray *fndname;
    
    UIAlertView *loadingAlertView;
    
}

@end
