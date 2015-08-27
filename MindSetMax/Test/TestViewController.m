//
//  TestViewController.m
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/5/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import "TestViewController.h"
#import "TestResultViewController.h"
#import "SBJson.h"

@interface TestViewController ()

@property (nonatomic, retain) NSDictionary *content;
@property (nonatomic, strong) NSString *testName;

@end

@implementation TestViewController

@synthesize questions;
@synthesize answers;
@synthesize scores;
@synthesize totalQuestion;
@synthesize currentQuestion;
@synthesize currentProgress;
@synthesize totalScore;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadJSON];
    self.testName = self.navigationItem.title;
    questions = [[self.content objectForKey:self.testName] objectForKey:@"questions"];
    answers = [[self.content objectForKey:self.testName] objectForKey:@"answers"];
    
    totalQuestion = questions.count;
    currentQuestion = 0;
    currentProgress = 0;
    
    self.progressLabel.text = [NSString stringWithFormat:@"1/%ld", (long)totalQuestion];
    
    [self initScore];
}

- (void)viewDidAppear:(BOOL)animated {
    [self refreshQuestion];
    [self refreshAnswer];
}

- (void)initScore {
    scores = [[NSMutableArray alloc] initWithCapacity:totalQuestion];
    for (int i = 0; i < totalQuestion; i++) {
        scores[i] = [NSNumber numberWithInteger:0];
    }
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait);
}

#pragma mark - JSON

- (void)loadJSON {
    NSArray *l = [NSBundle preferredLocalizationsFromArray:[NSArray arrayWithObjects:SUPPORTED_LANGUAGES,nil]];
    NSString *contentPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj",(NSString*)[l objectAtIndex:0]]];
    self.content = [self parseJSON:[NSData dataWithContentsOfFile:[contentPath stringByAppendingPathComponent:@"test.json"]]];
}

- (id)parseJSON:(NSData*)jsonData {
    if ( !jsonData ) return nil;
    id result = nil;
    NSError* error;
    if ( NSClassFromString(@"NSJSONSerialization") ) {
        result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        result = [parser objectWithString:[[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease]];
    }
    if ( !result ) {
        NSLog(@"Malformed JSON: %@",error);
    }
    return result;
}

#pragma mark - Q&A methods

- (void)refreshQuestion {
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.2;
    [self.questionLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];

    // This will fade:
    self.questionLabel.text = [NSString stringWithFormat:@"%ld. %@", (long)currentQuestion + 1, questions[currentQuestion]];

    [self.answerPickerView selectRow:[scores[currentQuestion] integerValue] inComponent:0 animated:YES];
    if (currentQuestion == totalQuestion - 1) { // Reached the final
        self.nextButton.hidden = YES;
        self.submitButton.hidden = NO;
    } else {
        self.nextButton.hidden = NO;
        self.submitButton.hidden = YES;
    }
}

- (void)refreshAnswer {
//    self.answerPickerView
}

- (void)updateScore {
    scores[currentQuestion] = [NSNumber numberWithInteger:[self.answerPickerView selectedRowInComponent:0]];
}

- (void)updateProgress {
    if (currentProgress < currentQuestion) {
        currentProgress = currentQuestion;
        self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld", currentProgress + 1, (long)totalQuestion];
        self.testProgressView.progress = (double)currentProgress / (double)totalQuestion;
    }
}

- (void)calculateSum {
    totalScore = 0;
    for (int i = 0; i < scores.count; i++) {
        totalScore += [scores[i] integerValue];
    }
}

#pragma mark - IBActions

- (IBAction)onPrev:(id)sender {
    [self updateScore];
    if (currentQuestion > 0) {
        currentQuestion--;
        [self refreshQuestion];
    }
}

- (IBAction)onNext:(id)sender {
    [self updateScore];
    if (currentQuestion < totalQuestion - 1) {
        currentQuestion++;
        [self refreshQuestion];
    }
    [self updateProgress];
}

- (IBAction)onSubmit:(id)sender {
    [self updateScore];
    [self calculateSum];
    
    TestResultViewController *testResultVC = (TestResultViewController *)[[TestResultViewController alloc] initWithNibName:@"TestResultViewController" bundle:nil];
    testResultVC.score = totalScore;
    testResultVC.results = [[self.content objectForKey:self.testName] objectForKey:@"results"];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [self.navigationController pushViewController:testResultVC animated:YES];
    [UIView commitAnimations];
    
    self.testProgressView.progress = 1;
}

#pragma mark - UIPickerView

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
//    NSLog(@"abc");
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return answers.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = answers[row];
    return title;
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
    [_questionLabel release];
    [_answerPickerView release];
    [_nextButton release];
    [_submitButton release];
    [answers release];
    [questions release];
    [_testProgressView release];
    [_progressLabel release];
    [super dealloc];
}
@end
