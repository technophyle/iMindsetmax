//
//  SettingsViewController.m
//  MindSetMax
//
//  Created by Kristian Borum on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "WebViewController.h"
#import "FontSettingsViewController.h"
#import "ThemeSettingsViewController.h"
#import "NewsletterViewController.h"
#import "DownloadManager.h"
#import "TableViewCell.h"

@interface SettingsViewController ()
@property (nonatomic,retain) NSArray* items;
@end


@implementation SettingsViewController

@synthesize backgroundView = backgroundView_;
@synthesize tableView      = tableView_;

- (id)init
{
  self = [super init];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)setupItems {
  NSMutableArray* a = [NSMutableArray array];
  self.items = a;
  [a addObject:@"FONTSIZE"];
  if ( [[ContentStore contentStore] booleanForPage:self.pageIndexPath property:@"showColorTheme" default:NO])
      [a addObject:@"COLORTHEME"];
  if ( [[ContentStore contentStore] booleanForPage:self.pageIndexPath property:@"showAutoPlay" default:NO])
    [a addObject:@"AUTOPLAY"];
  if ( [[ContentStore contentStore] booleanForPage:self.pageIndexPath property:@"showAutoDownload" default:NO])
    [a addObject:@"AUTODOWNLOAD"];
  if ( [MFMailComposeViewController canSendMail] )
    [a addObject:@"FEEDBACK"];
  [a addObject:@"NEWSLETTER"];
  [a addObject:@"ABOUT"];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[[ContentStore contentStore] backLabelForPage:self.pageIndexPath]
                                                                            style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  self.navigationItem.title = [[ContentStore contentStore] captionForPage:self.pageIndexPath];
  
  
  self.view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  
  self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  [self.tableView reloadData];
  [self.view addSubview:self.tableView];
  self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
  
  if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_list_background"]];
  else
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_list_background~ipad"]];
  self.view.opaque = YES;
  self.tableView.opaque = NO;
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  
  [self setupItems];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [self.tableView reloadData];
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (NSString*)fontSettingAsText {
  NSInteger selectedSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
  switch ( selectedSize ) {
    case 0:
      return NSLocalizedString(@"FontSizeSettingSmall",@"");
      break;
    case 2:
      return NSLocalizedString(@"FontSizeSettingLarge",@"");
      break;
    default:
      return NSLocalizedString(@"FontSizeSettingNormal",@"");
      break;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"SettingsCell";
  
  TableViewCell *cell = (TableViewCell*)([tableView dequeueReusableCellWithIdentifier:CellIdentifier]);
  if (cell == nil) {
    cell = [[[TableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  
  // Set the context.
  enum TableViewCellContext cellContext = TableViewCellContextSingle;
  NSInteger numberOfItemsInSection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
  if ( numberOfItemsInSection > 1 ) {
    if ( indexPath.row == 0 ) {
      cellContext = TableViewCellContextFirst;
    } else if ( indexPath.row+1 == numberOfItemsInSection ) {
      cellContext = TableViewCellContextLast;
    } else {
      cellContext = TableViewCellContextMiddle;
    }
  }
  cell.tableViewCellContext = cellContext;

  NSString* sectionType = nil;
  if ( self.items.count > indexPath.section ) {
    sectionType = [self.items objectAtIndex:indexPath.section];
  }
  
  cell.accessoryName = @"ui_table_arrow_29x29";
  if ( sectionType && [@"FONTSIZE" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    cell.textLabel.text = NSLocalizedString(@"FontSizeSetting",@"");
    cell.detailTextLabel.text = [self fontSettingAsText];
  } else if ( sectionType && [@"COLORTHEME" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    cell.textLabel.text = NSLocalizedString(@"ColorThemeSetting",@"");
  } else if ( sectionType && [@"AUTOPLAY" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    cell.textLabel.text = NSLocalizedString(@"AutoPlaySetting",@"");
    cell.accessoryName = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoPlay"] ? @"ui_table_check_29x29" : nil;
  } else if ( sectionType && [@"AUTODOWNLOAD" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    cell.textLabel.text = NSLocalizedString(@"DownloadSetting",@"");
    cell.accessoryName = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDownload"] ? @"ui_table_check_29x29" : nil;
  } else if ( sectionType && [@"FEEDBACK" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    cell.textLabel.text = NSLocalizedString(@"FeedbackSetting",@"");
  } else if ( sectionType && [@"NEWSLETTER" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    cell.textLabel.text = NSLocalizedString(@"NewsletterSignup",@"");
  } else {
    cell.textLabel.text = NSLocalizedString(@"AboutSetting",@"");
  }
  
  return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString* sectionType = nil;
  if ( self.items.count > indexPath.section ) {
    sectionType = [self.items objectAtIndex:indexPath.section];
  }

  if ( sectionType && [@"FONTSIZE" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    FontSettingsViewController *newViewController = [[FontSettingsViewController alloc] initWithNibName:@"FontSettingsViewController" bundle:nil];
    [newViewController autorelease];
    [self.navigationController pushViewController:newViewController animated:YES];
  } else if ( sectionType && [@"COLORTHEME" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
      ThemeSettingsViewController *newViewController = [[ThemeSettingsViewController alloc] initWithNibName:@"ThemeSettingsViewController" bundle:nil];
      [newViewController autorelease];
      [self.navigationController pushViewController:newViewController animated:YES];
  } else if ( sectionType && [@"AUTOPLAY" caseInsensitiveCompare:sectionType] == NSOrderedSame) {
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"AutoPlay"] forKey:@"AutoPlay"];
    [self.tableView reloadData];
  } else if ( sectionType && [@"AUTODOWNLOAD" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDownload"] forKey:@"AutoDownload"];
    [[DownloadManager sharedManager] setAutoDownload:[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoDownload"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTables" object:nil];
    [self.tableView reloadData];
  } else if ( sectionType && [@"FEEDBACK" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:FEEDBACK_EMAIL_ADDRESS]];
    [controller setSubject:NSLocalizedString(@"FeedbackEmailSubject",@"")];
    [controller setMessageBody:NSLocalizedString(@"FeedbackEmailText",@"") isHTML:NO];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
    [controller release];
  } else if ( sectionType && [@"NEWSLETTER" caseInsensitiveCompare:sectionType] == NSOrderedSame ) {
      NewsletterViewController *newViewController = [[NewsletterViewController alloc] initWithNibName:@"NewsletterViewController" bundle:nil];
      [newViewController autorelease];
      [self.navigationController pushViewController:newViewController animated:YES];
  } else {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mindsetmax.com"]];
    /*
     WebViewController *newViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
     newViewController.navigationItem.title = @"About";
     newViewController.content = ABOUT_HTML_FILE;
     newViewController.sandboxed = NO;
     [newViewController autorelease];
     [self.navigationController pushViewController:newViewController animated:YES];
     */
  }
}

#pragma mark - Mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
