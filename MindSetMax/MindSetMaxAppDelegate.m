//
//  MindSetMaxAppDelegate.m
//  MindSetMax
//
//  Created by Kristian Borum on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MindSetMaxAppDelegate.h"
#import "RootViewController.h"
#import "WebViewController.h"
#import "BaseViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "DisclaimerViewController.h"
#import "NewsletterViewController.h"
#import "SearchEngine.h"
#import "Flurry.h"
#import "DownloadManager.h"

#import "UIColor+HexString.h"

#import <MediaPlayer/MPMoviePlayerViewController.h>

#import <Parse/Parse.h>
#import "ChimpKit.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <GooglePlus/GooglePlus.h>
#import <linkedin-sdk/LISDK.h>

@interface MindSetMaxAppDelegate ()

@end

@implementation MindSetMaxAppDelegate


/*
 TODO:
 
 - Setting skin skal ligne resten.
 - Audio playlist
 - User notes fri af træstrukturen
 - Oversigt over brugernoter
 - Share (Facebook, email & Twitter).
 - En 'accept disclaimer' knap.
 - Notifikation 64 meddelelser kan hentes fra fil og pushes til Home screen 1 ad gangen pr. dag
 */

void uncaughtExceptionHandler(NSException *exception) {
  [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

#pragma mark -
#pragma mark Application support

- (NSString*)pathToDocumentFolder
{
  static NSString *folder = nil;
  if ( folder == nil ) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    folder = ([paths count] > 0) ? [[paths objectAtIndex:0] retain] : nil;
  }
  return folder;
}


#pragma mark -
#pragma mark UNCAT

- (void)showDisclaimer {
  NSString* acceptedVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"TermsAccepted"];
  NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
  if ( acceptedVersion && [acceptedVersion compare:versionString] == NSOrderedSame ) return;
  DisclaimerViewController *disclaimerViewController = [[DisclaimerViewController alloc] initWithNibName:@"DisclaimerViewController" bundle:nil];
  [self.tabBarController presentViewController:disclaimerViewController animated:YES completion:nil];
  [disclaimerViewController release];
}

/**
 *
 *
 */
-(BaseViewController*)createViewControllerWithPageIndexPath:(NSIndexPath*)pageIndexPath parentViewController:(BaseViewController*)parentViewController {
  @try {
    
    ContentStore* contentStore = [ContentStore contentStore];
    
    // If the page has any groups, it is a new root view controller.
    if ( [contentStore numberOfGroupsForPage:pageIndexPath] > 0 ) {
      RootViewController *newVC = [[[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil] autorelease];
      newVC.pageIndexPath = pageIndexPath;
      [newVC updateTitleAndBackButton];
      return newVC;
      
    } else if ( [@"search" caseInsensitiveCompare:[contentStore typeOfPage:pageIndexPath]] == NSOrderedSame ) {
      SearchViewController *newVC = [[[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil] autorelease];
      newVC.pageIndexPath = pageIndexPath;
      return newVC;
      
    } else if ( [@"settings" caseInsensitiveCompare:[contentStore typeOfPage:pageIndexPath]] == NSOrderedSame ) {
      SettingsViewController *newVC = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] autorelease];
      newVC.pageIndexPath = pageIndexPath;
      return newVC;
      
    } else if ( [contentStore videoContentForPage:pageIndexPath].length>0 ) {
      NSString* video = [contentStore videoContentForPage:pageIndexPath];
      NSString* remoteURL = [contentStore remoteURLForPage:pageIndexPath];
      NSString *moviePath = [[NSBundle mainBundle] pathForResource:video ofType:@"mp4"];
      if ( remoteURL ) {
        moviePath = [[DownloadManager sharedManager] pathToLocalCopyOfRemoteResource:remoteURL];
      }
      MPMoviePlayerViewController *mp = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]] autorelease];
      [parentViewController presentMoviePlayerViewControllerAnimated:mp];
      return nil;
      
    } else if ( [contentStore audioContentForPage:pageIndexPath].length>0 ) {
      NSString* audio = [contentStore audioContentForPage:pageIndexPath];
      NSString* remoteURL = [contentStore remoteURLForPage:pageIndexPath];
      NSString *moviePath = [[NSBundle mainBundle] pathForResource:audio ofType:@"mp3"];
      if ( remoteURL ) {
        moviePath = [[DownloadManager sharedManager] pathToLocalCopyOfRemoteResource:remoteURL];
      }
      MPMoviePlayerViewController *mp = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]] autorelease];
      [parentViewController presentMoviePlayerViewControllerAnimated:mp];
      return nil;
      
    } else if ( [contentStore htmlContentForPage:pageIndexPath].length>0 ) {
      WebViewController *newVC = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
      newVC.pageIndexPath = pageIndexPath;
      newVC.sandboxed = NO;
      //newVC.canAnnotate = [self canAnnotateGroup:group item:item];
      return newVC;
      
    }
  }
  @catch(id error) {
    NSLog(@"createViewControllerWithPageIndexPath:%@ - %@",pageIndexPath,error);
  }
  return nil;
}



/**
 * changePage:
 *
 * Manipulates the controller stack to display a specific page.
 * Parent controllers will be pushed onto the stack and old, unused ones will be removed.
 *
 */
- (void)changePage:(NSNotification*)notification {
  
  NSIndexPath* pathIndex = [[notification userInfo] objectForKey:@"ChangePage"];
  NSString*    shortcut  = [[notification userInfo] objectForKey:@"Shortcut"];
  bool         animate   = [[[notification userInfo] objectForKey:@"Animate"] boolValue];
  bool         sandbox   = [[[notification userInfo] objectForKey:@"Sandbox"] boolValue];
  //bool         remapped  = [[[notification userInfo] objectForKey:@"Remapped"] boolValue];
  NSString*    words     = [[notification userInfo] objectForKey:@"Words"];
  
 //NSLog(@"changePage: %@ animate=%d sandbox=%d ", pathIndex,animate,sandbox );
  
  if ( pathIndex.length==0 ) {
    pathIndex = [[ContentStore contentStore] pathIndexForShortcutId:shortcut];
    if ( pathIndex.length==0 ) {
      pathIndex = [NSIndexPath indexPathWithIndex:0];
    }
  }

  [Flurry logEvent:@"ChangePage" withParameters:[NSDictionary dictionaryWithObject:pathIndex forKey:@"Path"]];

  NSUInteger selectedTab = [pathIndex indexAtPosition:0];
  
  UINavigationController* nvc = nil;
  if ( self.tabBarController.viewControllers.count>selectedTab )
    nvc = [self.tabBarController.viewControllers objectAtIndex:selectedTab];
  if ( !nvc ) return; // Exit for non-existing tabs.
  
  NSMutableArray *stack =[NSMutableArray arrayWithArray:nvc.viewControllers];
  
  // Pop viewcontrollers until pathIndex has a partial match.
  while(true) {
    BaseViewController* last = [stack lastObject];
    if (!last) break;
    if ( pathIndex.length < last.pageIndexPath.length ) {
      [stack removeLastObject];
    } else {
      bool match = YES;
      for(NSUInteger position=0;position<last.pageIndexPath.length;position++) {
        if ( [pathIndex indexAtPosition:position] != [last.pageIndexPath indexAtPosition:position] ) {
          match = NO;
          break;
        }
      }
      if (match) {
        break;
      } else {
        [stack removeLastObject];
      }
    }
  }
  
  for(NSUInteger position=((BaseViewController*)[stack lastObject]).pageIndexPath.length;position+1<pathIndex.length;position+=2) {
    BaseViewController* last = [stack lastObject];
    NSIndexPath* newPageIndex = [[last.pageIndexPath indexPathByAddingIndex:[pathIndex indexAtPosition:position]] indexPathByAddingIndex:[pathIndex indexAtPosition:position+1]];
    BaseViewController* newVC = [self createViewControllerWithPageIndexPath:newPageIndex parentViewController:[stack lastObject]];
    if ( [newVC isKindOfClass:WebViewController.class] ) {
      [(WebViewController*)newVC setSandboxed:sandbox];
      [(WebViewController*)newVC setWords:words];
    }
    if ( !newVC ) break; // Fail in path, stop
    [stack addObject:newVC];
  }
  
  // Set the stack
  [nvc setViewControllers:stack animated:animate];
  
  [self.tabBarController setSelectedIndex:selectedTab];
  [self showDisclaimer];
}



#pragma mark -
#pragma mark Application lifecycle

void recurseRegisterRemoteFiles(NSArray *array) {
  for(int g=0;g<[array count];g++) {
    NSArray *items = [[array objectAtIndex:g] objectForKey:@"Group"];
    if( items != nil ) {
      for(int i=0;i<[items count];i++) {
        NSArray *subitems = [[items objectAtIndex:i] objectForKey:@"Subitems"];
        if (subitems) {
          recurseRegisterRemoteFiles(subitems);
        } else {
          NSString *localName = [[items objectAtIndex:i] objectForKey:@"Video"];
          if ( !localName || [localName length] == 0 ) {
            localName = [[[items objectAtIndex:i] objectForKey:@"Audio"] stringByAppendingString:@".mp3"];
          } else {
            localName = [localName stringByAppendingString:@".mp4"];
          }
          NSString *remoteUrl = [[items objectAtIndex:i] objectForKey:@"RemoteContentURL"];
          if ( remoteUrl && [remoteUrl length] > 0 )
            [[DownloadManager sharedManager] registerRemoteResource:remoteUrl withLocalName:localName];
        }
      }
    }
  }
}

-(void)registerRemoteFiles:(NSArray*)content {
  for( int i=0; i<3; i++ )
    recurseRegisterRemoteFiles([content objectAtIndex:i]);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [Fabric with:@[CrashlyticsKit]];

  NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
  [Flurry startSession:FLURRY_KEY];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@"1"   forKey:@"FontSize"]];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@"0"   forKey:@"ColorTheme"]];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"AutoDownload"]];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"AutoPlay"]];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@"YES" forKey:@"AskForAutoDownload"]];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@""    forKey:@"CurrentPage"]];
  [defaults registerDefaults:[NSDictionary dictionaryWithObject:@""    forKey:@"TermsAccepted"]];
  
  
//  [Parse setApplicationId:@"VynG9mlCMocYKPn1O28PRhufhCUZwJZbtsDCId0c" clientKey:@"7odjmgfJNUbOHs6vhLQQeI1w1IpSabYOXINwJqoU"];

  [Parse setApplicationId:[ContentStore contentStore].parseAppKey
                clientKey:[ContentStore contentStore].parseClientId];
  
  [[ChimpKit sharedKit] setApiKey:[ContentStore contentStore].mailchimpApiKey];

  ContentStore* contentStore = [ContentStore contentStore];

  // Set tabs
  NSMutableArray* tabViewControllers = [NSMutableArray array];
  NSUInteger numberOfTabs = [contentStore numberOfTabs];
  for(NSUInteger tabIndex=0;tabIndex<numberOfTabs;tabIndex++) {
    BaseViewController* vc = [self createViewControllerWithPageIndexPath:[NSIndexPath indexPathWithIndex:tabIndex] parentViewController:nil];
    UINavigationController* nvc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    UIColor* tintColor = [UIColor colorFromHexString:[contentStore navigationBarTint]];
    if ( tintColor ) {
      nvc.navigationBar.tintColor = tintColor;
      if ( [nvc.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        nvc.navigationBar.barTintColor = tintColor;
        nvc.navigationBar.tintColor = [UIColor whiteColor];
        nvc.navigationBar.translucent = NO;
        [nvc.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
      }
    }
    
//    /* Search button on the nav bar */
//    UIImage *image = [[UIImage imageNamed:@"ui_tabbar_search.png"] autorelease];
//    nvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonClicked:)];

    
    [tabViewControllers addObject:nvc];
    nvc.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[contentStore labelForTabIndex:tabIndex] image:[UIImage imageNamed:[contentStore iconForTabIndex:tabIndex]] tag:0] autorelease];
  }
  [self.tabBarController setViewControllers:tabViewControllers animated:NO];
  
  
  
  // Override point for customization after app launch
  NSArray        *static_content = nil;//[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"plist"]];
  
  [SearchEngine sharedSearchEngine];
  [self registerRemoteFiles:static_content];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"ChangePage" object:nil];
  
  //	[self.window addSubview:[navigationController view]];
  
  NSIndexPath *pageIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPage"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangePage"
                                                      object:nil
                                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:pageIndex,@"ChangePage",@"YES",@"Remapped",@"NO",@"Animate",nil]];
  [self.window makeKeyAndVisible];
  
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        [application setStatusBarStyle:UIStatusBarStyleLightContent];
//        self.window.clipsToBounds =YES;
//        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
//    }
    
  return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  UIApplicationState state = [application applicationState];
  NSLog(@"STATE %ld",state);
  if (state == UIApplicationStateActive) {
    if (notification) {
      NSLog(@"application:didReceiveLocalNotification:%@",notification);
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                          message:notification.alertBody
                                                         delegate:self cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
      
      
      [alertView show];
      [alertView autorelease];
    }
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSIndexPath* path = ((BaseViewController*)((UINavigationController*)self.tabBarController.selectedViewController).viewControllers.lastObject).pageIndexPath;
  [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"CurrentPage"];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (NSInteger)dayOfTheYear {
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSUInteger dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit
                                              inUnit:NSYearCalendarUnit forDate:[NSDate date]];
  [gregorian release];
  return dayOfYear;
}

NSInteger max(NSInteger a,NSInteger b) {
  return a>b?a:b;
}


#define MOTD_FRONT_LOAD 60


- (void)reloadMOTD {
  PFQuery *query = [PFQuery queryWithClassName:@"MessageOfTheDay"];
  query.cachePolicy = kPFCachePolicyNetworkElseCache;
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      NSMutableDictionary *messagesByDay = [NSMutableDictionary dictionary];
      for (PFObject *object in objects) {
        NSString* day = [object objectForKey:@"day"];
        NSString* message = [object objectForKey:@"message"];
        if ( message && day )
          [messagesByDay setObject:message forKey:day];
      }
      [[UIApplication sharedApplication] cancelAllLocalNotifications];
      
      
      NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
      NSDate* date = [NSDate date];
      NSInteger todayOfTheYear = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
      
      NSUInteger alert_hour = [[ContentStore contentStore] messageOfTheDayAlertHour];
      
      for (NSString* day in messagesByDay) {
        NSInteger messageDayOfTheYear = [day integerValue];
        if (( messageDayOfTheYear >= todayOfTheYear && messageDayOfTheYear<todayOfTheYear+MOTD_FRONT_LOAD ) ||
            ( messageDayOfTheYear+366 >= todayOfTheYear && messageDayOfTheYear+366<todayOfTheYear+MOTD_FRONT_LOAD ) ) {
          NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
          [components setYear:[[calendar components:NSYearCalendarUnit fromDate:date] year]];
          [components setMonth:1];
          [components setDay:1];
          NSDate* d = [[calendar dateFromComponents:components] dateByAddingTimeInterval:3600*24*(messageDayOfTheYear-1)+3600*alert_hour];
          if ( [d timeIntervalSinceNow] > 0 ) {
            UILocalNotification* localNotification = [[[UILocalNotification alloc] init] autorelease];
            localNotification.alertBody = [messagesByDay objectForKey:day];
            localNotification.alertAction = @"Open";
            localNotification.timeZone = [NSTimeZone localTimeZone];
            localNotification.fireDate = d;
            localNotification.repeatInterval = 0;
            //NSLog(@"Added: %@ at %@    %d %d   at %@",[messagesByDay objectForKey:day],day,todayOfTheYear,messageDayOfTheYear,d);
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
          }
        }
      }
    }
  }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [self reloadMOTD];

  if ( [defaults boolForKey:@"AskForAutoDownload"] && [[ContentStore contentStore] askForAutoDownload]) {
    [[[[UIAlertView alloc] initWithTitle:@"Downloads"
                                 message:@"Enable automatic download of content? You can change this at any time in the settings."
                                delegate:self
                       cancelButtonTitle:@"No"
                       otherButtonTitles:@"Yes", nil] autorelease] show];
    [defaults setBool:NO forKey:@"AskForAutoDownload"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return;
  }
  
  
  if (! [defaults objectForKey:@"lastRatePrompt"]) {
    [defaults setObject:[NSDate date] forKey:@"lastRatePrompt"];
    [defaults setBool:YES forKey:@"askForRating"];
  }
  
  NSInteger daysSinceInstall = [[NSDate date] timeIntervalSinceDate:[defaults objectForKey:@"lastRatePrompt"]] / 86400;
  if (daysSinceInstall >= APPSTORE_RATE_PROMPT_INTERVAL && [defaults boolForKey:@"askedForRating"] == NO && [defaults boolForKey:@"askForRating"] != NO ) {
    [[[[UIAlertView alloc] initWithTitle:@"Like This App?" message:@"Please rate it in the App Store!" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate It!",@"Ask Later", nil] autorelease] show];
    [defaults setObject:[NSDate date] forKey:@"lastRatePrompt"];
  }
  
  // Newsletter prompt
  if (! [defaults objectForKey:@"lastNewsletterPrompt"]) {
    [defaults setObject:[NSDate date] forKey:@"lastNewsletterPrompt"];
    [defaults setBool:YES forKey:@"askForNewsletter"];
  }
  
  NSInteger daysSinceLastPrompt = [[NSDate date] timeIntervalSinceDate:[defaults objectForKey:@"lastNewsletterPrompt"]] / 86400;
  if (daysSinceLastPrompt >= NEWSLETTER_PROMPT_INTERVAL && [defaults boolForKey:@"askForNewsletter"] != NO ) {
    [[[[UIAlertView alloc] initWithTitle:@"Newsletter" message:@"Would you like to subscribe to our newsletter?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Yes!",@"Remind Me Later", nil] autorelease] show];
    [defaults setObject:[NSDate date] forKey:@"lastNewsletterPrompt"];
  }
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ( [alertView.title compare:@"Downloads"] == NSOrderedSame ) {
    if (buttonIndex == 1) {
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AutoDownload"];
    } else if (buttonIndex == 0) {
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoDownload"];
    }
    [[DownloadManager sharedManager] setAutoDownload:[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDownload"]];
  } else if ( [alertView.title compare:@"Newsletter"] == NSOrderedSame ) {
    if (buttonIndex == 1) {
      [defaults setBool:NO forKey:@"askForNewsletter"];
      NSLog(@"Signup to newsletter..");
    } else if (buttonIndex == 0) {
      [defaults setBool:NO forKey:@"askForNewsletter"];
    }
  } else {
    if (buttonIndex == 1) {
      [defaults setBool:NO forKey:@"askForRating"];
      NSURL *url = [NSURL URLWithString:APPSTORE_RATE_URL];
      [[UIApplication sharedApplication] openURL:url];
    } else if (buttonIndex == 0) {
      [defaults setBool:NO forKey:@"askForRating"];
    }
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  
  if ([alertView.title compare:@"Newsletter"] == NSOrderedSame && buttonIndex == 1) {
    // Present Newsletter Signup VC
    NewsletterViewController *newsletterVC = [[NewsletterViewController alloc] initWithNibName:@"NewsletterViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:newsletterVC];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:controller animated:YES completion:nil];
  }
}


- (void)dealloc
{
  [_window release];
  [super dealloc];
}

#pragma mark - URL handler of the app delegate

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
  
  if ([LISDKCallbackHandler shouldHandleUrl:url]) {
    return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
  }
  
  return [GPPURLHandler handleURL:url
                sourceApplication:sourceApplication
                       annotation:annotation];
}

@end