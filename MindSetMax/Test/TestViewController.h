//
//  TestViewController.h
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/5/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TestViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *questionLabel;
@property (retain, nonatomic) IBOutlet UIPickerView *answerPickerView;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIProgressView *testProgressView;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;

@property (strong) NSArray *questions;
@property (strong) NSArray *answers;
@property (strong) NSMutableArray *scores;
@property NSInteger totalQuestion;
@property NSInteger currentQuestion;
@property NSInteger currentProgress;
@property NSInteger totalScore;

@end
