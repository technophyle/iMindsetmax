//
//  FontSettingsViewController.h
//  MindSetMax
//
//  Created by Kristian Borum on 9/14/11.
//  Copyright 2011 Borum Data. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontSettingsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) IBOutlet UIView* backgroundView;
@property (nonatomic,retain) IBOutlet UITableView* tableView;

@end
