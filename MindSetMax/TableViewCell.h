//
//  TableViewCell.h
//  MindSetMax
//
//  Created by Kristian Borum on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum TableViewCellContext {
  TableViewCellContextSingle = 0,
  TableViewCellContextFirst,
  TableViewCellContextMiddle,
  TableViewCellContextLast,
  };

@interface TableViewCell : UITableViewCell

@property (nonatomic,retain) NSString *titleString;
@property (nonatomic,retain) NSString *subtitleString;
@property (nonatomic,retain) NSString *iconName;
@property (nonatomic,retain) NSString *accessoryName;
@property (nonatomic)        enum TableViewCellContext tableViewCellContext;

@end


/*

Normal:
 Headline 
 Subtitle
 
 Icon
 Action (disclosure, download, etc)
 
Editing:
 Reorder 
 Add / Remove

 
*/