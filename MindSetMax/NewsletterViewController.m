//
//  NewsletterViewController.m
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/17/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import "NewsletterViewController.h"
#import "ChimpKit.h"

@interface NewsletterViewController ()

@end

@implementation NewsletterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Newsletter";
    
//    [[ChimpKit sharedKit] setApiKey:@"803a4e8dd06f910ac4e872dd0ac36f2d-us6"];

//    [[ChimpKit sharedKit] callApiMethod:@"lists/list" withParams:nil
//                   andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                       NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                       NSLog(@"Here are my lists: %@", responseString);
//                   }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isModal]) {
        // being presented
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        
    }
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_nameTextField release];
    [_emailTextField release];
    [super dealloc];
}

- (void)subscribeMailchimp {
    NSString *listId = [ContentStore contentStore].mailchimpListId;
    NSString *email = self.emailTextField.text;
    NSString *fullName = self.nameTextField.text;
    NSString* firstName = [[fullName componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString* lastName = @"";
    
    if (listId == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mailchimp list id not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (fullName.length > firstName.length + 1) { // If the user has the last name
        lastName = [fullName substringFromIndex:firstName.length + 1];
    }
    NSDictionary *params = @{@"id": listId, @"email": @{@"email": email}, @"merge_vars": @{@"FNAME": firstName, @"LName":lastName}};
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withParams:params andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (kCKDebug) NSLog(@"Response String: %@", responseString);
        id parsedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (![parsedResponse isKindOfClass:[NSDictionary class]] || ![parsedResponse[@"email"] isKindOfClass:[NSString class]] || error) {
            if (parsedResponse[@"error"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:parsedResponse[@"error"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"An error occurred. Please try again later."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"You have successfully subscribed to the list."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"askForNewsletter"];
            });
        }
        [activityIndicator release];
    }];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - IBActions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)onSignup:(id)sender {
    [self subscribeMailchimp];
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
