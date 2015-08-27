//
//  WebViewController.h
//  NLP123
//
//  Created by Kristian Borum on 10/22/09.
//  Copyright Borum Data 2009-2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface WebViewController : BaseViewController <UIWebViewDelegate>

@property (nonatomic,retain) IBOutlet UIWebView   *webView;
@property (nonatomic,retain) IBOutlet UIImageView *curtains;

@property (nonatomic,retain)          NSString    *externalURL;
@property (nonatomic,retain)          UIActivityIndicatorView *indicator;

@property (nonatomic)                 bool         sandboxed;
@property (nonatomic,retain)          NSString    *words;

@property (nonatomic,retain)          NSIndexPath* pageIndexPath;

@end
