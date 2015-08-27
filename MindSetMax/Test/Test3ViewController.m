//
//  Test3ViewController.m
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/5/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import "Test3ViewController.h"
#import "Test3ResultViewController.h"
#import "SBJson.h"

@interface Test3ViewController ()

@property (nonatomic, retain) NSDictionary *content;
@property (nonatomic, strong) NSString *testName;

@end

@implementation Test3ViewController

@synthesize questions;
@synthesize answers;
@synthesize modalityArray;
@synthesize scores;
@synthesize sumsDictionary;
@synthesize totalQuestion;
@synthesize currentQuestion;
@synthesize currentProgress;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadJSON];
    self.testName = self.navigationItem.title;
    questions = [[self.content objectForKey:self.testName] objectForKey:@"questions"];
    answers = [[self.content objectForKey:self.testName] objectForKey:@"answers"];
    modalityArray = [[self.content objectForKey:self.testName] objectForKey:@"modality"];
    
    totalQuestion = questions.count;
    currentQuestion = 0;
    currentProgress = 0;
    
    self.progressLabel.text = [NSString stringWithFormat:@"1/%ld", (long)totalQuestion];
    
    [self initScore];
    
    // Scroll view content size
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = 519;
    self.scrollView.contentSize = contentSize;
    
    // UILabel borders & autoFit font sizes
    
    for (NSInteger tag = 1; tag < modalityArray.count + 1; tag++) {
        UILabel *answerLabel = (UILabel *)[self.view viewWithTag:tag];
        answerLabel.adjustsFontSizeToFitWidth = YES;
        
        UILabel *scoreLabel = (UILabel *)[self.view viewWithTag:tag + 10];
        scoreLabel.layer.cornerRadius = 5;
        scoreLabel.layer.borderWidth = 1;
        scoreLabel.layer.borderColor = [[UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:151.0f/255.0f alpha:1.0f] CGColor];
    }
    self.questionLabel.adjustsFontSizeToFitWidth = YES;
    
    // Tap Gesture
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [self refreshQuestion];
    [self refreshAnswer];
}

- (void)initScore {
    scores = [[NSMutableArray alloc] initWithCapacity:totalQuestion];
    for (int i = 0; i < totalQuestion; i++) {
        
        NSMutableArray *scoresForOneQuestion = [NSMutableArray new];
        for (NSInteger j = 0; j < modalityArray.count; j++) {
            [scoresForOneQuestion addObject:@0];
        }
        
        scores[i] = scoresForOneQuestion;
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
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        result = [parser objectWithString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
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
    
    if (currentQuestion == totalQuestion - 1) { // Reached the final
        self.nextButton.hidden = YES;
        self.submitButton.hidden = NO;
    } else {
        self.nextButton.hidden = NO;
        self.submitButton.hidden = YES;
    }
}

- (void)refreshAnswer {
    for (NSInteger i = 1; i < modalityArray.count + 1; i++) {
        // Update the answers
        UILabel *label = (UILabel *)[self.view viewWithTag:i];
        NSDictionary *answer = answers[currentQuestion][i - 1];
        label.text = answer.allValues[0]; // The first element (ONLY ONE ELEMENT)
        
        //Update the answer scores
        UILabel *scoreLabel = (UILabel *)[self.view viewWithTag:i + 10];
        NSInteger score = [self.scores[currentQuestion][i - 1] integerValue];
        if (score) {
            scoreLabel.text = @"✓";
        } else {
            scoreLabel.text = @"";
        }
    }
}

- (void)updateProgress {
    currentProgress = currentQuestion;
    self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld", currentProgress + 1, (long)totalQuestion];
    self.testProgressView.progress = (double)currentProgress / (double)totalQuestion;
}

- (void)calculateSum {
    sumsDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *modalityItem in modalityArray) {
        NSString *answerKey = modalityItem.allKeys[0];
        sumsDictionary[answerKey] = @0;
    }
    
    for (NSInteger i = 0; i < scores.count; i++) {
        for (NSInteger j = 0; j < modalityArray.count; j++) {
            NSNumber *score = scores[i][j];
            NSDictionary *answer = answers[i][j];
            NSString *answerKey = answer.allKeys[0];
            
            NSInteger sum = [sumsDictionary[answerKey] integerValue] + [score integerValue];
            sumsDictionary[answerKey] = [NSNumber numberWithInteger:sum];
        }
    }
}

#pragma mark - IBActions

- (IBAction)onPrev:(id)sender {
    if (currentQuestion > 0) {
        currentQuestion--;
        [self refreshQuestion];
        [self refreshAnswer];
    }
    [self updateProgress];
}

- (IBAction)onNext:(id)sender {
    if (currentQuestion < totalQuestion - 1) {
        currentQuestion++;
        [self refreshQuestion];
        [self refreshAnswer];
    }
    [self updateProgress];
}

- (IBAction)onSubmit:(id)sender {
    [self calculateSum];
    
    Test3ResultViewController *testResultVC = (Test3ResultViewController *)[[Test3ResultViewController alloc] initWithNibName:@"Test3ResultViewController" bundle:nil];
    
    NSMutableArray *theScores = [NSMutableArray new];
    NSMutableArray *theKeys = [NSMutableArray new];
    
    for (NSDictionary *keyItem in modalityArray) {
        NSString *theKey = keyItem.allKeys[0];
        
        [theKeys addObject:keyItem.allValues[0]]; // Add "Velocity", "3", etc
        [theScores addObject:sumsDictionary[theKey]];
    }
    
    testResultVC.scores = theScores;
    testResultVC.keys = theKeys;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.80f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [self.navigationController pushViewController:testResultVC animated:YES];
    [UIView commitAnimations];
    
    self.testProgressView.progress = 1;
}

#pragma mark - Getsures

- (void)viewTapped:(UITapGestureRecognizer *)sender {
    UIView* view = sender.view;
    CGPoint loc = [sender locationInView:view];
    UIView* subview = [view hitTest:loc withEvent:nil];
    
    if (subview.tag > 0) { // If answer or score label touched
        NSInteger tag = subview.tag;
        if (subview.tag <= modalityArray.count) { // If answer
            tag += 10; // Score label tag
        }
        
        for (NSInteger i = 0; i < modalityArray.count; i++) {
            UILabel *scoreLabel = (UILabel *)[self.view viewWithTag:i+1+10];
            scoreLabel.text = @"";
            scores[currentQuestion][i] = @0;
        }
        
        UILabel *scoreLabel = (UILabel *)[self.view viewWithTag:tag];
        scoreLabel.text = @"✓";

        scores[currentQuestion][tag - 10 - 1] = @1;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
