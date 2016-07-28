//
//  TableViewController.m
//  NLP123
//
//  Created by Kristian Borum on 10/22/09.
//  Copyright Borum Data 2009-2010. All rights reserved.
//

#import "TableViewController.h"
#import "NoteViewController.h"
#import "SearchEngine.h"
#import "DownloadManager.h"
#import "TableViewCell.h"
#import "TestViewController.h"

#import <MediaPlayer/MPMoviePlayerViewController.h>

// Forward decls.
@interface TableViewController ()
@end

@implementation TableViewController

@synthesize tableView = _tableView;

#pragma mark -

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;//(interfaceOrientation==UIInterfaceOrientationPortrait || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

#pragma mark -
#pragma mark Application support

- (void)reloadTable {
  [self.tableView reloadData];
}

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
  
  if ( SEARCH_ENABLED_FOR_TABLEVIEW ) {
    self.searchDisplayController.searchResultsDataSource = [SearchEngine sharedSearchEngine];
    self.searchDisplayController.delegate = [SearchEngine sharedSearchEngine];
    self.searchDisplayController.searchResultsDelegate = [SearchEngine sharedSearchEngine];
    self.searchDisplayController.searchBar.hidden = NO;
    self.searchDisplayController.searchBar.showsCancelButton = YES;
  } else {
    self.tableView.tableHeaderView = nil;
  }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ReloadTables" object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
  if ( SEARCH_ENABLED_FOR_TABLEVIEW ) {
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  
  //  NSLog(@"searchBarCancelButtonClicked");
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationItem.rightBarButtonItem = nil;
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[ContentStore contentStore] numberOfGroupsForPage:self.pageIndexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[ContentStore contentStore] numberOfPagesForGroup:[self.pageIndexPath indexPathByAddingIndex:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  float height = 1.0;
  if ( section == 0 ) height += 9.0;
  if ( [[[ContentStore contentStore] captionForGroup:[self.pageIndexPath indexPathByAddingIndex:section]] length] != 0 ) height += 30.0;
  return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0,0,100,40)] autorelease];
  header.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  header.backgroundColor = [UIColor clearColor];
  header.opaque = YES;
  NSString *text = [[ContentStore contentStore] captionForGroup:[self.pageIndexPath indexPathByAddingIndex:section]];
  if ( text.length != 0 ) {
    UILabel* textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30,5,30,30)] autorelease];
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"Cabin-Bold" size:20.0];
    textLabel.textColor = [UIColor colorWithRed:.5 green:.8 blue:.1 alpha:1];
    textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    textLabel.shadowOffset = CGSizeMake(0,-1);
    textLabel.adjustsFontSizeToFitWidth = YES;
    textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    textLabel.opaque = NO;
    textLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:textLabel];
  }
  return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 9.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  UIView* header = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  header.backgroundColor = [UIColor clearColor];
  header.opaque = NO;
  return header;
}

/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 //NSLog(@"tableView:titleForHeaderInSection:");
 return [self titleForSection:section];
 }
 */

/**
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 return [self canItemBeReordered:indexPath] || [self canItemBeDeleted:indexPath] || [self canItemBeAdded:indexPath];
 }
 
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 return [self canItemBeReordered:indexPath] && ![self canItemBeAdded:indexPath];
 }
 
 - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
 if ( [self canItemBeAdded:indexPath] ) return UITableViewCellEditingStyleInsert;
 if ( [self canItemBeDeleted:indexPath] ) return UITableViewCellEditingStyleDelete;
 return UITableViewCellEditingStyleNone;
 }
 
 - (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
 toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
 NSInteger maxIndex = [self tableView:tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
 if ( [self canSectionHaveNotes:sourceIndexPath.section] ) maxIndex--;
 
 if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
 NSInteger row = 0;
 if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
 row = maxIndex;
 }
 return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
 }
 if (proposedDestinationIndexPath.row > maxIndex )
 return [NSIndexPath indexPathForRow:maxIndex inSection:sourceIndexPath.section];
 return proposedDestinationIndexPath;
 }
 
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 [self makeDefaultUserContentForSection:fromIndexPath.section];
 [self moveItemFrom:fromIndexPath to:toIndexPath];
 [self requestSave];
 }
 
 - (void)setEditing:(BOOL)editing animated:(BOOL)animated {
 [super setEditing:editing animated:animated];
 [self.tableView beginUpdates];
 for(int section=0;section<[self numberOfSections];section++) {
 if ([self canSectionHaveNotes:section]) {
 int idx = [self numberOfItemsInSection:section];
 NSArray *tagInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:section]];
 UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
 if (editing) {
 if (animated) {
 animationStyle = UITableViewRowAnimationFade;
 }
 [self.tableView insertRowsAtIndexPaths:tagInsertIndexPath withRowAnimation:animationStyle];
 } else {
 [self.tableView deleteRowsAtIndexPaths:tagInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
 }
 }
 }
 _isEditing = editing;
 [self.tableView endUpdates];
 }
 */

- (void)downloadButtonTapped:(id)sender {
  [[DownloadManager sharedManager] markRemoteResource:[sender titleForState:UIControlStateDisabled] forDownload:YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTables" object:nil];
}

/**
 * Build the cell.
 */
/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = nil;
 
 if ( [self canItemBeAdded:indexPath] ) {
 static NSString *CellIdentifier = @"AddCell";
 cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 if (cell == nil) {
 cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
 }
 cell.showsReorderControl = YES;
 cell.textLabel.text      = NSLocalizedString(@"NewNote",@"String to show in table view when adding a new row");
 } else {
 static NSString *CellIdentifier = @"Cell";
 cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 if (cell == nil) {
 cell = [[[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
 }
 NSDictionary *d = [self combinedItemForPath:indexPath originalPosition:NO];
 if ([d objectForKey:@"Title"]) {
 cell.textLabel.text = [d objectForKey:@"Title"];
 } else {
 cell.textLabel.text = [d objectForKey:@"NotesTitle"];
 }
 cell.imageView.image = [UIImage imageNamed:[d objectForKey:@"Icon"]];
 
 NSString *remoteUrl = [d objectForKey:@"RemoteContentURL"];
 DownloadManager *manager = [DownloadManager sharedManager];
 if ( remoteUrl && ![manager isRemoteResourceMarkedForDownload:remoteUrl] && ![manager isRemoteResourceDownloaded:remoteUrl] ) {
 //   NSString *downloadStatus = [[DownloadManager sharedManager] getRemoteResourceDownloadStatus:remoteUrl];
 
 UIImage *image = [UIImage imageNamed:@"ui_list_button_enabled.png"];
 
 UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
 CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
 button.frame = frame;
 [button setBackgroundImage:image forState:UIControlStateNormal];
 [button setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
 [[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
 [button setBackgroundImage:[UIImage imageNamed:@"ui_list_button_highlighted.png"] forState:UIControlStateHighlighted];
 [button setTitle:remoteUrl forState:UIControlStateDisabled]; // Ugly way to store a string in a button. Real ugly...
 
 [button addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
 button.backgroundColor = [UIColor clearColor];
 cell.accessoryView = button;
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 } else if (remoteUrl && ![manager isRemoteResourceDownloaded:remoteUrl]) {
 UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,4,60,24)];
 label.text = [manager getRemoteResourceDownloadStatus:remoteUrl];
 [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
 label.textColor = [UIColor lightGrayColor];
 label.backgroundColor = [UIColor clearColor];
 label.textAlignment = UITextAlignmentRight;
 cell.accessoryView = label;
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 } else {
 cell.accessoryView = nil;
 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 cell.selectionStyle = UITableViewCellSelectionStyleBlue;
 }
 }
 
 return cell;
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // Get a cell
  static NSString *CellIdentifier = @"TableViewCell";
  TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
  
  NSIndexPath* pagePath = [[self.pageIndexPath indexPathByAddingIndex:indexPath.section] indexPathByAddingIndex:indexPath.row];
  
  // Add decor
  cell.titleString = [[ContentStore contentStore] titleForPage:pagePath];
  cell.iconName = [[ContentStore contentStore] iconForPage:pagePath];
  
  NSString *remoteUrl = [[ContentStore contentStore] remoteURLForPage:pagePath];
  DownloadManager *manager = [DownloadManager sharedManager];
  if ( remoteUrl && ![manager isRemoteResourceDownloaded:remoteUrl] ) {
    if ( [manager isRemoteResourceMarkedForDownload:remoteUrl] ) {
      cell.accessoryName = @"ui_list_icon_downloadingremote_29x29";
    } else {
      cell.accessoryName = @"ui_list_icon_downloadremote_29x29";
    }
  } else {
    cell.accessoryName = @"ui_table_arrow_29x29";
  }
  
  return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSIndexPath* pagePath = [[self.pageIndexPath indexPathByAddingIndex:indexPath.section] indexPathByAddingIndex:indexPath.row];
  NSString *viewController = [[ContentStore contentStore] viewControllerForPage:pagePath];
    
  if (viewController) {
      NSString *title = [[ContentStore contentStore] titleForPage:pagePath];
      UIViewController *testVC = [[NSClassFromString(viewController) alloc] init];
//      TestViewController *testVC = (TestViewController *)[[TestViewController alloc] initWithNibName:viewController bundle:nil];
      testVC.navigationItem.title = title;
      NSLog(@"%@", self.parentVC.navigationController.viewControllers);
      [self.parentVC.navigationController pushViewController:testVC animated:YES];
  } else {
      NSString *remoteUrl = [[ContentStore contentStore] remoteURLForPage:pagePath];
      DownloadManager *manager = [DownloadManager sharedManager];
      if ( remoteUrl && ( ![manager isRemoteResourceMarkedForDownload:remoteUrl] || ![manager isRemoteResourceDownloaded:remoteUrl] ) ) {
          [[DownloadManager sharedManager] markRemoteResource:remoteUrl forDownload:YES];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTables" object:nil];
      } else {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangePage"
                                                              object:nil
                                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:pagePath,@"ChangePage",
                                                                      @"YES", @"Animate",@"YES",@"Remapped",@"NO",@"Sandbox",nil]];
      }
  }
}


@end

