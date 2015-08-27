//
//  DisclaimerViewController.m
//  NLP123
//
//  Created by Kristian Borum on 3/3/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import "DisclaimerViewController.h"


@implementation DisclaimerViewController

@synthesize webView;

-(IBAction)accept:(id)sender {
  NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
  [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:@"TermsAccepted"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
//  NSString *contentPath = [[NSBundle mainBundle] resourcePath];
//  contentPath = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"disclaimer" ofType:@"html"]];
  NSError *error;
  
  NSString *resourcePath = [[[[[NSBundle mainBundle] pathForResource:@"disclaimer" ofType:@"html"] stringByDeletingLastPathComponent]
                             stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                            stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  
  NSString *contentData = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"disclaimer" ofType:@"html"]
                                                    encoding:NSUTF8StringEncoding error:&error];
  [self.webView loadHTMLString:contentData baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//", resourcePath]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
}


@end
