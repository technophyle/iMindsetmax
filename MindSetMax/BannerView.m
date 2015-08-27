//
//  BannerView.m
//  MindSetMax
//
//  Created by Kristian Borum on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BannerView.h"

@implementation BannerView

@synthesize vertical    = _vertical;
@synthesize iconView    = _iconView;
@synthesize headerLabel = _headerLabel;
@synthesize detailLabel = _detailLabel;

- (void)layoutSubviews {
  CGRect frame = self.frame;
  float w = frame.size.width;
  float h = frame.size.height;
  if ( self.vertical ) {
    self.iconView.frame = CGRectMake((w-80)/2,(h-234)/2,80,117);
    self.headerLabel.frame = CGRectMake((w-220)/2,(h-234)/2+117,220,22);
    self.detailLabel.frame = CGRectMake((w-220)/2,(h-234)/2+137,220,77);
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
  } else {
    self.iconView.frame = CGRectMake((w-310)/2,20,80,117);
    self.headerLabel.frame = CGRectMake((w-310)/2+90,20,220,22);
    self.detailLabel.frame = CGRectMake((w-310)/2+90,40,220,77);
    self.headerLabel.textAlignment = NSTextAlignmentLeft;
  }
}

- (void)setup {
  
  self.iconView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui_table_banner_icon.png"]] autorelease];
  self.headerLabel = [[[UILabel alloc] init] autorelease];
  self.detailLabel = [[[UILabel alloc] init] autorelease];
  
  self.headerLabel.backgroundColor = [UIColor clearColor];
  self.headerLabel.font = [UIFont fontWithName:@"Cabin-Bold" size:18.0];
  self.headerLabel.textColor = [UIColor colorWithRed:.5 green:.8 blue:.1 alpha:1];
  self.headerLabel.numberOfLines = 1;
  self.headerLabel.text = NSLocalizedString(@"BannerHeader",@"");
  self.detailLabel.backgroundColor = [UIColor clearColor];
  self.detailLabel.font = [UIFont fontWithName:@"Cabin-Regular" size:8.0];
  self.detailLabel.textColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
  self.detailLabel.numberOfLines = 4;
  self.detailLabel.text = NSLocalizedString(@"BannerText",@"");
  
  [self addSubview:self.iconView];
  [self addSubview:self.headerLabel];
  [self addSubview:self.detailLabel];
}

- (void)awakeFromNib {
  [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setup];
    }
    return self;
}

- (void)dealloc {
  [self.iconView removeFromSuperview];
  [self.headerLabel removeFromSuperview];
  [self.detailLabel removeFromSuperview];
  self.iconView = nil;
  self.headerLabel = nil;
  self.detailLabel = nil;
  [super dealloc];
}

@end
