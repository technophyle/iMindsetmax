//
//  RootViewController.m
//  NLP123
//
//  Created by Kristian Borum on 10/22/09.
//  Copyright Borum Data 2009-2010. All rights reserved.
//

#import "RootViewController.h"
#import "NoteViewController.h"
#import "SearchViewController.h"
#import "SearchEngine.h"
#import "DownloadManager.h"
#import "TableViewCell.h"

#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <Pinterest/Pinterest.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <linkedin-sdk/LISDK.h>

// Forward decls.
@interface RootViewController () <UIActionSheetDelegate, GPPSignInDelegate>
{
  SLComposeViewController *mySLComposerSheet;
  Pinterest *pinterest;
}
@end

@implementation RootViewController

static NSString * const kClientId = @"861642394645-eculigo4amtm0m4e9fiob3516k5k17b4.apps.googleusercontent.com";

#pragma mark -

#pragma mark -
#pragma mark Rotation support

- (bool)isLandscape:(UIDeviceOrientation)interfaceOrientation {
  return interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight;
}

- (void)positionBannerAndTable {
  CGRect viewFrame = self.view.frame;
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  float tableWidth = appFrame.size.width;
  if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ) {
    self.bannerView.frame = CGRectMake(0,0,viewFrame.size.width,117);
    self.tableViewContainer.frame = CGRectMake(0,117,viewFrame.size.width,viewFrame.size.height-117);
    self.bannerView.vertical = NO;
  }
  if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
/*
    NSLog(@"viewFrame: %1f,%1f x %1f,%1f",viewFrame.origin.x,viewFrame.origin.y,viewFrame.size.width,viewFrame.size.height);
    NSLog(@"appFrame: %1f,%1f x %1f,%1f",appFrame.origin.x,appFrame.origin.y,appFrame.size.width,appFrame.size.height);
    NSLog(@"isLandscape   %1d",[self isLandscape:[[UIDevice currentDevice] orientation]] );
    */
    if ( [self isLandscape:[[UIDevice currentDevice] orientation]] ) {
      self.bannerView.frame = CGRectMake(0,0,viewFrame.size.width-tableWidth,viewFrame.size.height);
      self.tableViewContainer.frame = CGRectMake(viewFrame.size.width-tableWidth,0,tableWidth,viewFrame.size.height);
      self.bannerView.vertical = YES;
    } else {
      self.bannerView.frame = CGRectMake(0,0,viewFrame.size.width,117);
      self.tableViewContainer.frame = CGRectMake(0,117,viewFrame.size.width,viewFrame.size.height-117);
      self.bannerView.vertical = NO;
    }
  }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
  [self positionBannerAndTable];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
  [self positionBannerAndTable];
  [super viewDidLayoutSubviews];
}

#pragma mark Content


- (void)setTableViewController:(TableViewController *)tableViewController {
  [_tableViewController release];
  _tableViewController = [tableViewController retain];
  tableViewController.pageIndexPath = self.pageIndexPath;
}

#pragma mark -
#pragma mark Content Helpers

/*
- (NSDictionary*)staticGroupForPath:(NSIndexPath*)indexPath {
  int sec = [indexPath indexAtPosition:0];
  if ( sec >= [self.content count] ) return nil;
  return [self.content objectAtIndex:sec];
}

- (NSMutableDictionary*)userGroupForPath:(NSIndexPath*)indexPath createAsNeeded:(bool)createAsNeeded {
  if ( indexPath.section >= [self.userContent count] ) {
    if ( createAsNeeded ) {      
      for ( int i=indexPath.section-[self.userContent count];i>=0;i--)
        [self.userContent addObject:[NSMutableDictionary dictionaryWithObject:[NSMutableArray array] forKey:@"Group"]];
    } else {
      return nil;
    }
  }
  return [self.userContent objectAtIndex:indexPath.section];
}

- (NSMutableDictionary*)userGroupForPath:(NSIndexPath*)indexPath {
  return [self userGroupForPath:indexPath createAsNeeded:NO];
}

- (NSInteger)translatedRowIndex:(NSIndexPath*)indexPath {
  NSDictionary *ug = [self userGroupForPath:indexPath];
  unsigned index = 0;
  for( NSDictionary *ud in [ug objectForKey:@"Group"] ) {
    if ( [[ud objectForKey:@"Index"] intValue] == indexPath.row )
      return index;
    index++;
  }
  return index;
}

- (NSDictionary*)staticItemForPath:(NSIndexPath*)indexPath originalPosition:(bool)yesOrNo {
  int idx = yesOrNo ? indexPath.row : [self translatedRowIndex:indexPath];
  NSArray *a = [[self staticGroupForPath:indexPath] objectForKey:@"Group"];
  if ( idx >= [a count] ) return nil;
  return [a objectAtIndex:idx];
}

- (void)makeDefaultUserContentForSection:(NSInteger)section {
  NSArray *as = [[self staticGroupForPath:[NSIndexPath indexPathForRow:0 inSection:section]] objectForKey:@"Group"];
  NSMutableDictionary *ug = [self userGroupForPath:[NSIndexPath indexPathForRow:0 inSection:section] createAsNeeded:YES];
  NSMutableArray *au = [ug objectForKey:@"Group"];
  if ( au == nil ) {
    au = [NSMutableArray array];
    [ug setObject:au forKey:@"Group"];
  }
  for (int i=[au count];i<[as count];i++) {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:@"Index"];
    [au addObject:d];
  }
}

- (NSMutableDictionary*)userItemForPath:(NSIndexPath*)indexPath originalPosition:(bool)yesOrNo  {
  int idx = yesOrNo ? indexPath.row : [self translatedRowIndex:indexPath];
  NSArray *a = [[self userGroupForPath:indexPath] objectForKey:@"Group"];
  if ( idx >= [a count] ) return nil;
  return [a objectAtIndex:idx];
}

- (NSMutableDictionary*)newUserItemForPath:(NSIndexPath*)indexPath  {
  NSMutableArray *a = [[self userGroupForPath:indexPath] objectForKey:@"Group"];
  NSMutableDictionary *ud = [[NSMutableDictionary dictionary] retain];
  [ud setObject:[NSNumber numberWithInt:[a count]] forKey:@"Index"];
  [ud setObject:[NSNumber numberWithBool:YES] forKey:@"Annotate"];
  [ud setObject:@"user_subject" forKey:@"Content"];
  [a addObject:ud];
  return ud;
}

- (bool)deleteUserItemForPath:(NSIndexPath*)indexPath  {
  NSMutableArray *a = [[self userGroupForPath:indexPath] objectForKey:@"Group"];
  if ( [a count] <= [indexPath row]) {
    NSLog(@"Internal error: Assertion triggered - tried to delete static content.");
    return NO;
  }
  NSDictionary *r = nil;
  for( NSMutableDictionary *d in a ) {
    int i=[[d objectForKey:@"Index"] intValue];
    if (i==[indexPath row])
      r = d;
    else if ( i > [indexPath row])
      [d setObject:[NSNumber numberWithInt:i-1] forKey:@"Index"];
  }
  if (r) {
    [a removeObject:r];
    return YES;
  }
  return NO;
}

- (NSMutableDictionary*)combinedItemForPath:(NSIndexPath*)indexPath originalPosition:(bool)yesOrNo {
  NSMutableDictionary *d  = [[[self staticItemForPath:indexPath originalPosition:yesOrNo] mutableCopy] autorelease];
  NSMutableDictionary *du = [[[self userItemForPath:indexPath originalPosition:yesOrNo] mutableCopy] autorelease];
  // [self makeDefaultUserContentForSection:indexPath.section];
  if ( d == nil ) {
    if ( du == nil ) return nil;
    d = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"_UserItem"]; 
  }
  [du addEntriesFromDictionary:d];
  return du;
}
*/

/*
- (NSInteger)numberOfSections {
  return [self.content count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
  return [[[self userGroupForPath:[NSIndexPath indexPathForRow:0 inSection:section] createAsNeeded:YES] objectForKey:@"Group"] count];
}

- (NSString*)titleForSection:(NSInteger)section {
  return [[self staticGroupForPath:[NSIndexPath indexPathForRow:0 inSection:section]] objectForKey:@"Title"];
}

- (bool)canItemBeReordered:(NSIndexPath*)indexPath {
  return [[[self staticGroupForPath:indexPath] objectForKey:@"Reorder"] boolValue];
}

- (bool)canItemBeDeleted:(NSIndexPath*)indexPath {
  return [[[self combinedItemForPath:indexPath originalPosition:NO] objectForKey:@"_UserItem"] boolValue];
}

- (bool)canItemBeAdded:(NSIndexPath*)indexPath {
  return [self combinedItemForPath:indexPath originalPosition:NO] == nil;
}

- (bool)canSectionHaveNotes:(NSInteger)section {
  NSString* noteId = [[[self staticGroupForPath:[NSIndexPath indexPathForRow:0 inSection:section]] objectForKey:@"NotesId"] stringValue];
  return noteId != nil && ![noteId isEqualToString:@""];
}

- (bool)canReorder {
  bool reorder = NO;
  for( NSDictionary *g in self.content ) {
    if ( [[g objectForKey:@"Reorder"] boolValue])
      reorder = YES;
  }
  return reorder;
}

- (bool)canAnnotate {
  bool ann = NO;
  for( NSDictionary *g in self.content ) {
    if ( [[g objectForKey:@"Notes"] boolValue])
      ann = YES;
  }
  return ann;
}

- (bool)canAnnotateGroup:(int)group item:(int)item {
  NSDictionary * i = [self combinedItemForPath:[NSIndexPath indexPathForRow:item inSection:group] originalPosition:NO];  
  if ( [i objectForKey:@"Annotate"] == nil || [[i objectForKey:@"Annotate"] boolValue] )
    return YES;
  return NO;
}

- (void)moveItemFrom:(NSIndexPath*)fromIndexPath to:(NSIndexPath*)toIndexPath {
  NSMutableArray *au = [[self userGroupForPath:fromIndexPath] objectForKey:@"Group"];
  for ( NSMutableDictionary *d in au ) {
    int index = [[d objectForKey:@"Index"] intValue];
    if ( index == fromIndexPath.row )
      index = toIndexPath.row;
    else if ( index == toIndexPath.row ) 
      index += fromIndexPath.row < toIndexPath.row ? -1: 1; 
    else
      index += ( ( index > toIndexPath.row ) ? 1 : 0 ) - ( ( index > fromIndexPath.row ) ? 1 : 0 );
    [d setObject:[NSNumber numberWithInt:index] forKey:@"Index"];
  }
}

- (void)requestSave {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestSave" object:nil userInfo:nil];
}

*/


#pragma mark -
#pragma mark Application support

- (void)updateTitleAndBackButton {
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[[ContentStore contentStore] backLabelForPage:self.pageIndexPath]
                                                                            style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  self.navigationItem.title = [[ContentStore contentStore] captionForPage:self.pageIndexPath];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.parentViewController.view.backgroundColor = [UIColor blackColor];
  
  [self updateTitleAndBackButton];
  
  // Add table VC
  self.tableViewController = [[[TableViewController alloc] initWithNibName:nil bundle:nil] autorelease];
  self.tableViewController.parentVC = self;
  [self.tableViewContainer addSubview:self.tableViewController.view];
  /*
   CGRect frame = self.view.frame;
   CGRect bounds = self.view.bounds;
   CGPoint center = self.view.center;
   
   NSLog(@"RootVC frame %f,%f %f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
   NSLog(@"RootVC bounds %f,%f %f,%f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
   NSLog(@"RootVC center %f,%f",center.x,center.y);
   if ( frame.origin.y != 0 ) {
   frame.origin.y = 137;
   frame.size.height -= 137;
   }
   if ( frame.origin.x != 0 ) {
   frame.origin.x = 137;
   frame.size.width -= 137;
   }
   */
  self.tableViewController.view.frame = self.tableViewContainer.bounds; //frame = frame;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  /* Search & Share buttons on the nav bar */
  
  UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)];
  UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonClicked:)];
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareButtonItem, searchButtonItem, nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
//  self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
  self.searchDisplayController.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}


/** 
 *
 */
/*
-(id<BaseViewController>)createChildWithSegment:(NSString*)segment remapped:(bool)yesOrNo {
  
  NSLog( @"createChildWithSegment: %@", segment);
  NSRange range=[segment rangeOfString:@"-"];
  if ( range.location == NSNotFound ) return nil;
  int group = [[segment substringToIndex:range.location] integerValue];
  int item = [[segment substringFromIndex:range.location+1] integerValue];
  
  NSDictionary *i = [self combinedItemForPath:[NSIndexPath indexPathForRow:item inSection:group] originalPosition:!yesOrNo];
  NSMutableDictionary *ue = [self userItemForPath:[NSIndexPath indexPathForRow:item inSection:group] originalPosition:!yesOrNo]; 
  
  NSArray *subitems = [i objectForKey:@"Subitems"];
  NSMutableArray *usubitems = [ue objectForKey:@"Subitems"];
  NSString *htmlcontent = [i objectForKey:@"Content"];
  NSString *videocontent = [i objectForKey:@"Video"];
  NSString *audiocontent = [i objectForKey:@"Audio"];
  NSString *remotecontent = [i objectForKey:@"RemoteContentURL"];
  
  // If not downloaded, we just ignore selections.
  if ( remotecontent && ![[DownloadManager sharedManager] isRemoteResourceDownloaded:remotecontent] ) {
    return nil;
  }
  
  if ( subitems ) {
    RootViewController *newViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    NSString *caption = [i objectForKey:@"Caption"];
    newViewController.navigationItem.title = caption != nil ? caption : [i objectForKey:@"Title"];
    
    newViewController.content = subitems;
    newViewController.userContent = usubitems;
    newViewController.tab = self.tab;
    //    [self.navigationController pushViewController:newViewController animated:YES];
    [newViewController autorelease];
    return newViewController;
  } else if ( [videocontent compare:@""] != NSOrderedSame ) {
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:videocontent ofType:@"mp4"];
    if ( remotecontent ) { 
      moviePath = [[DownloadManager sharedManager] pathToLocalCopyOfRemoteResource:remotecontent];
    }
    MPMoviePlayerViewController *mp = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]] autorelease];
    [self presentMoviePlayerViewControllerAnimated:mp];
    return nil;
  } else if ( [audiocontent compare:@""] != NSOrderedSame ) {
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:audiocontent ofType:@"mp3"];
    if ( remotecontent ) { 
      moviePath = [[DownloadManager sharedManager] pathToLocalCopyOfRemoteResource:remotecontent];
    }
    MPMoviePlayerViewController *mp = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]] autorelease];
    [self presentMoviePlayerViewControllerAnimated:mp];
    return nil;
  } else {
    WebViewController *newViewController = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
    NSString *caption = [i objectForKey:@"Caption"];
    newViewController.navigationItem.title = caption != nil ? caption : [i objectForKey:@"Title"];
    newViewController.content = htmlcontent;
    newViewController.sandboxed = NO;
    newViewController.userEntry = ue;
    newViewController.canAnnotate = [self canAnnotateGroup:group item:item];
    return newViewController;
  }
}
*/
 
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  [super setEditing:editing animated:animated];
  [self.tableViewController setEditing:editing animated:animated];
}

#pragma mark - Search button event handler

- (void)searchButtonClicked:(id)sender {
  SearchViewController *newVC = [[[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil] autorelease];
  newVC.pageIndexPath = [NSIndexPath indexPathWithIndex:10];  // Just put a number that is bigger than the number of tabs;
                                                              // for reference, check createViewControllerWithPageIndexPath inside app delegate
                                                              // after checking out the initial commit
  [self.navigationController pushViewController:newVC animated:YES];
//  [self presentViewController:newVC animated:YES completion:nil];
}

#pragma mark - Share button event handler

- (void)shareButtonClicked:(id)sender {
/*  NSString *textToShare = [ContentStore contentStore].shareMessage;
  
  NSArray *objectsToShare = @[textToShare];
  
  UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
  
  NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                 UIActivityTypePrint,
                                 UIActivityTypeAssignToContact,
                                 UIActivityTypeSaveToCameraRoll,
                                 UIActivityTypeAddToReadingList,
                                 UIActivityTypeCopyToPasteboard];
//                                 UIActivityTypePostToFlickr,
//                                 UIActivityTypePostToVimeo];
  
  activityVC.excludedActivityTypes = excludeActivities;
  
  [self presentViewController:activityVC animated:YES completion:nil];*/
  UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                          @"Share on Facebook",
                          @"Share on Twitter",
                          @"Share on Google+",
                          @"Share on Linkedin",
                          @"Share on Pinterest",
                          nil];
  popup.tag = 1;
  [popup showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (popup.tag) {
    case 1: {
      switch (buttonIndex) {
        case 0:
          [self FBShare];
          break;
        case 1:
          [self TwitterShare];
          break;
        case 2:
          [self GoogleShare];
          break;
        case 3:
          [self LinkedinShare];
          break;
        case 4:
          [self PinterestShare];
          break;
        default:
          break;
      }
      break;
    }
    default:
      break;
  }
}

#pragma mark - Share methods

- (void)FBShare {
  NSString *textToShare = [ContentStore contentStore].shareMessage;
  
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
  {
    mySLComposerSheet = [[[SLComposeViewController alloc] init] autorelease]; //initiate the Social Controller
    mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [mySLComposerSheet setInitialText:[NSString stringWithFormat:textToShare, mySLComposerSheet.serviceType]]; //the message you want to post
    
    //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
    [self presentViewController:mySLComposerSheet animated:YES completion:nil];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please set up your Facebook account in the device settings first!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;
  }
  [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
    NSString *output;
    switch (result) {
      case SLComposeViewControllerResultCancelled:
        output = @"Action cancelled due to an error!";
        break;
      case SLComposeViewControllerResultDone:
        output = @"Thanks for sharing!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];

        break;
      default:
        break;
    } //check if everything worked properly. Give out a message on the state.
  }];
}

- (void)TwitterShare {
  NSString *textToShare = [ContentStore contentStore].shareMessage;
  
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) //check if Facebook Account is linked
  {
    mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [mySLComposerSheet setInitialText:[NSString stringWithFormat:textToShare, mySLComposerSheet.serviceType]]; //the message you want to post
    
    //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
    [self presentViewController:mySLComposerSheet animated:YES completion:nil];
  } else {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please set up your Twitter account in the device settings first!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert show];
    return;
  }
  [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
    NSString *output;
    switch (result) {
      case SLComposeViewControllerResultCancelled:
        output = @"Action Cancelled";
        break;
      case SLComposeViewControllerResultDone:
        output = @"Thanks for sharing!";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
        break;
      default:
        break;
    } //check if everything worked properly. Give out a message on the state.
  }];
}

- (void)GoogleShare {
  [self GoogleSignIn]; // Once signed in, it will call the callback "finishedWithAuth" and we're putting the posting code there
}

- (void)GoogleSignIn {
  GPPSignIn *signIn = [GPPSignIn sharedInstance];
//  [signIn signOut];
  signIn.shouldFetchGooglePlusUser = YES;
  signIn.clientID = kClientId;
  signIn.scopes = @[ kGTLAuthScopePlusLogin ];
  signIn.delegate = self;
  [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
  NSLog(@"Error:%@ Auth:%@", error, auth);
  [self postOnGooglePlus];
}

- (void)postOnGooglePlus {
  NSString *textToShare = [ContentStore contentStore].shareMessage;
  NSString *shareLink = [ContentStore contentStore].shareLink;
  
  id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
  
  [shareBuilder setPrefillText:textToShare];
  [shareBuilder setURLToShare:[NSURL URLWithString:shareLink]];
  // [shareBuilder setURLToShare:[NSURL URLWithString:@"https://www.shinnxstudios.com"]];
  // [shareBuilder setTitle:@"Title" description:@"Descp" thumbnailURL:[NSURL URLWithString:@"https://www.fbo.com/imageurl"]];
  
  [shareBuilder open];
}

- (void)LinkedinShare {
  if ([LISDKSessionManager hasValidSession]) {
    [self postOnLinkedin];
  } else {
    [LISDKSessionManager
     createSessionWithAuth:[NSArray arrayWithObjects:LISDK_BASIC_PROFILE_PERMISSION, LISDK_W_SHARE_PERMISSION, nil]
     state:nil
     showGoToAppStoreDialog:YES
     successBlock:^(NSString *returnState) {
       NSLog(@"%s","success called!");
       [self postOnLinkedin];
     }
     errorBlock:^(NSError *error) {
       NSLog(@"%s","error called!");
     }
     ];
  }
}

- (void)postOnLinkedin {
  NSString *txtToShare = [ContentStore contentStore].shareMessage;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share on Linkedin" message:@"Please type the message you would like to share on Linkedin" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField *alertTextField = [alert textFieldAtIndex:0];
  alertTextField.text = txtToShare;
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) return;
  NSString *message = [alertView textFieldAtIndex:0].text;
  NSString *url = @"https://api.linkedin.com/v1/people/~/shares";
  NSString *payload = [NSString stringWithFormat:@"{\"comment\":\"%@\", \"visibility\":{ \"code\":\"anyone\" }}", message];
  [[LISDKAPIHelper sharedInstance]
   postRequest:url
   stringBody:payload
   success:^(LISDKAPIResponse *response) {
     // do something with response
     NSString *output = @"Thanks for sharing!";
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Linkedin" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
     [alert show];
   }
   error:^(LISDKAPIError *apiError) {
     NSString *output = @"Action cancelled due to an error!";
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Linkedin" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
     [alert show];
   }
   ];
}

- (void)PinterestShare {
  NSString *textToShare = [ContentStore contentStore].shareMessage;
  NSString *shareLink = [ContentStore contentStore].shareLink;
  NSString *shareImageLink = [ContentStore contentStore].shareImageLink;
  
  pinterest = [[Pinterest alloc]initWithClientId:@"1446115"];
  NSURL *imageURL     = [NSURL URLWithString:shareImageLink];
  NSURL *sourceURL    = [NSURL URLWithString:shareLink];
  
  [pinterest createPinWithImageURL:imageURL
                         sourceURL:sourceURL
                       description:textToShare];
}

@end

