//
//  TestResultViewController.h
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/6/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestResultViewController : UIViewController

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSArray *results;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UITextView *resultTextView;

@end
