//
//  BannerView.h
//  MindSetMax
//
//  Created by Kristian Borum on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerView : UIView

@property (nonatomic) bool vertical;

@property (nonatomic,retain) UIImageView* iconView;
@property (nonatomic,retain) UILabel*     headerLabel;
@property (nonatomic,retain) UILabel*     detailLabel;


@end
