//
//  TestResultViewController.h
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/6/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Test2ResultViewController : UIViewController

@property (nonatomic, strong) NSArray *scores;
@property (nonatomic, strong) NSArray *keys;

@property (weak, nonatomic) IBOutlet UIView *graphView;

@end
