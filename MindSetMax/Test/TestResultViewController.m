//
//  TestResultViewController.m
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/6/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import "TestResultViewController.h"

@interface TestResultViewController ()

@end

@implementation TestResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Result";
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld points.", self.score];
    
    NSString *resultString = @"";
    for (int i = 0; i < self.results.count; i++) {
        resultString = [resultString stringByAppendingString:self.results[i]];
        resultString = [resultString stringByAppendingString:@"\n\n"];
    }
    self.resultTextView.text = resultString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_scoreLabel release];
    [_resultTextView release];
    [_resultTextView release];
    [super dealloc];
}
@end
