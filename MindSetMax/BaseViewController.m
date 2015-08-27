//
//  BaseViewController.m
//  NLP123
//
//  Created by Kristian Borum on 2/18/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return [UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPhone||interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown;
}

- (NSUInteger)supportedInterfaceOrientations {
  if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  }
  return UIInterfaceOrientationMaskAll;
}

@end
