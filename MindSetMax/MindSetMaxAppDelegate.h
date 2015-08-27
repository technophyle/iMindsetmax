//
//  MindSetMaxAppDelegate.h
//  MindSetMax
//
//  Created by Kristian Borum on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"
#import "BaseViewController.h"

@interface MindSetMaxAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationControllerVideo;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationControllerAudio;
@property (nonatomic, retain) IBOutlet RootViewController     *rootViewController;
@property (nonatomic, retain) IBOutlet RootViewController     *rootViewControllerVideo;
@property (nonatomic, retain) IBOutlet RootViewController     *rootViewControllerAudio;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
