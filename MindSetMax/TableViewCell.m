//
//  TableViewCell.m
//  MindSetMax
//
//  Created by Kristian Borum on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell() {
@private   
  enum TableViewCellContext _tableViewCellContext;
}
@end


@implementation TableViewCell

@synthesize titleString     = _titleString;
@synthesize subtitleString  = _subtitleString;
@synthesize iconName        = _iconName;
@synthesize accessoryName   = _accessoryName;

- (enum TableViewCellContext)tableViewCellContext {
  return _tableViewCellContext;
}

- (void)setTableViewCellContext:(enum TableViewCellContext)tableViewCellContext {
  _tableViewCellContext = tableViewCellContext;
  switch ( tableViewCellContext ) {
    default:
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ui_table_cell_single"] stretchableImageWithLeftCapWidth:100.0 topCapHeight:0.0]] autorelease];
      break;
    case TableViewCellContextFirst:
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ui_table_cell_top"] stretchableImageWithLeftCapWidth:100.0 topCapHeight:0.0]] autorelease];
      break;
    case TableViewCellContextMiddle:
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ui_table_cell_middle"] stretchableImageWithLeftCapWidth:100.0 topCapHeight:0.0]] autorelease];
      break;
    case TableViewCellContextLast:
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ui_table_cell_bottom"] stretchableImageWithLeftCapWidth:100.0 topCapHeight:0.0]] autorelease];
      break;      
  }
}

- (void)setTitleString:(NSString *)titleString {
  self.textLabel.text = titleString;
}

- (void)setSubTitleString:(NSString *)subTitleString {
  self.detailTextLabel.text = subTitleString;
}

- (void)setAccessoryName:(NSString *)accessoryName {
  if ( accessoryName != nil ) {
    self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryName]] autorelease];
  } else {
    self.accessoryView = [[[UIImageView alloc] init] autorelease];
  }
}

- (void)setIconName:(NSString *)iconName {
  self.imageView.image = [UIImage imageNamed:iconName]; 
}

- (void) layoutSubviews {
  [super layoutSubviews];  
  CGRect f = self.frame;
  self.textLabel.frame = CGRectMake(60, 2, f.size.width-138, 40);
  self.imageView.frame = CGRectMake(23, 7, 29, 29);
  CGRect accessoryFrame = self.accessoryView.frame;
  accessoryFrame.origin.x -= 16;
  self.accessoryView.frame = accessoryFrame;
  
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
      self.backgroundColor = [UIColor clearColor];
      self.contentView.backgroundColor = [UIColor clearColor];
      self.contentView.opaque = NO;
      self.opaque = NO;
      self.selectionStyle = UITableViewCellSelectionStyleNone;      
      self.textLabel.font = [UIFont fontWithName:@"Cabin-Bold" size:20.0];
      self.textLabel.textColor = [UIColor colorWithRed:.5 green:.8 blue:.1 alpha:1];
      self.textLabel.adjustsFontSizeToFitWidth = YES;
      self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
      self.textLabel.opaque = NO;
      self.textLabel.backgroundColor = [UIColor clearColor];
      self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui_table_arrow_29x29"]] autorelease];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
