//
//  SettingsViewController.h
//  MindSetMax
//
//  Created by Kristian Borum on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsViewController : BaseViewController <MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) IBOutlet UIView* backgroundView;
@property (nonatomic,retain) IBOutlet UITableView* tableView;

@end
