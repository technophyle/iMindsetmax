//
//  TableViewController.h
//  NLP123
//
//  Created by Kristian Borum on 10/22/09.
//  Copyright Borum Data 2009-2010. All rights reserved.
//

#import "WebViewController.h"
#import "BaseViewController.h"
#import "TableViewCell.h"

@interface TableViewController : UITableViewController <UISearchBarDelegate> {
  
  bool            _isEditing;
}

@property (nonatomic, retain) NSIndexPath* pageIndexPath;
@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, strong) UIViewController* parentVC;

@end
