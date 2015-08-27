//
//  RootViewController.h
//  NLP123
//
//  Created by Kristian Borum on 10/22/09.
//  Copyright Borum Data 2009-2010. All rights reserved.
//

//#import "WebViewController.h"
#import "BaseViewController.h"
#import "TableViewController.h"
#import "TableViewCell.h"
#import "BannerView.h"

#import "Social/Social.h"
#import "Accounts/Accounts.h"

@interface RootViewController : BaseViewController <UISearchBarDelegate>

@property (nonatomic,retain) IBOutlet TableViewController* tableViewController;
@property (nonatomic,retain) IBOutlet BannerView*          bannerView;
@property (nonatomic,retain) IBOutlet UIView*              tableViewContainer;

@property (nonatomic,retain)          NSIndexPath*         pageIndexPath;

- (void)updateTitleAndBackButton;

@end
