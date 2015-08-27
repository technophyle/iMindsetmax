//
//  DisclaimerViewController.h
//  NLP123
//
//  Created by Kristian Borum on 3/3/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DisclaimerViewController : UIViewController {

  UIWebView *webView;
  
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;

-(IBAction)accept:(id)sender;

@end
