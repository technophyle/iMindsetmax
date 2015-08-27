//
//  Test3ViewController.h
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/5/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Test3ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UILabel *questionLabel;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIProgressView *testProgressView;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;

@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) NSArray *answers;
@property (strong, nonatomic) NSDictionary *modalityArray;
@property (strong, nonatomic) NSMutableArray *scores;
@property (strong, nonatomic) NSMutableDictionary *sumsDictionary;
@property NSInteger totalQuestion;
@property NSInteger currentQuestion;
@property NSInteger currentProgress;

@end
