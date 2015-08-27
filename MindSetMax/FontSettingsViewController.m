//
//  FontSettingsViewController.m
//  MindSetMax
//
//  Created by Kristian Borum on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FontSettingsViewController.h"
#import "TableViewCell.h"

@implementation FontSettingsViewController

@synthesize backgroundView = backgroundView_;
@synthesize tableView      = tableView_;

- (id)init {
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

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  
  self.title = NSLocalizedString(@"FontSizeSetting",@"");

}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"FontSettingsCell";
 
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
  
  NSInteger selectedSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
  
  switch ( indexPath.row ) {
    case 0:
      cell.textLabel.text = NSLocalizedString(@"FontSizeSettingSmall",@"");
      cell.accessoryName = selectedSize == 0 ? @"ui_table_check_29x29" : nil;
      break;
    case 2:
      cell.textLabel.text = NSLocalizedString(@"FontSizeSettingLarge",@"");;
      cell.accessoryName = selectedSize == 2 ? @"ui_table_check_29x29" : nil;
      break;
    default:
      cell.textLabel.text = NSLocalizedString(@"FontSizeSettingNormal",@"");;
      cell.accessoryName = selectedSize == 1 ? @"ui_table_check_29x29" : nil;
      break;
  }
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"FontSize"];
  [tableView reloadData];
}

@end
