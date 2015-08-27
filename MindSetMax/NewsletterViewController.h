//
//  NewsletterViewController.h
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/17/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChimpKit.h"

@interface NewsletterViewController : UIViewController <UITextFieldDelegate, ChimpKitRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;

@end
