//
//  FontSettingsViewController.m
//  MindSetMax
//
//  Created by Kristian Borum on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThemeSettingsViewController.h"
#import "TableViewCell.h"

@implementation ThemeSettingsViewController

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
  
  self.title = NSLocalizedString(@"ColorThemeSetting",@"");

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

#pragma mark - NEOColorPickerViewControllerDelegate
- (void) colorPickerViewController:(NEOColorPickerBaseViewController *) controller didSelectColor:(UIColor *)color {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"SelectedColor"];
}
- (void) colorPickerViewControllerDidCancel:(NEOColorPickerBaseViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
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
  static NSString *CellIdentifier = @"ThemeSettingsCell";
 
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
  
  NSInteger selectedTheme = [[NSUserDefaults standardUserDefaults] integerForKey:@"ColorTheme"];
  
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"ColorThemeSettingBright",@"");
        cell.accessoryName = selectedTheme == 0 ? @"ui_table_check_29x29" : nil;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"ColorThemeSettingDark",@"");
        cell.accessoryName = selectedTheme == 1 ? @"ui_table_check_29x29" : nil;
    } else {
        cell.textLabel.text = NSLocalizedString(@"ColorThemeSettingCustom",@"");
        cell.accessoryName = selectedTheme == 2 ? @"ui_table_check_29x29" : nil;
    }
    
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {               // WHEN CUSTOM COLOR IS SELECTED

        NEOColorPickerViewController *controller = [[NEOColorPickerViewController alloc] init];
        controller.delegate = self;
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedColor"];
        UIColor *selectedColor;
        @try {
            selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        }
        @catch (NSException *exception) {
            selectedColor = [UIColor redColor];
        }
        @finally {
            controller.selectedColor = selectedColor;
        }

        controller.title = @"Example";
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self presentViewController:navVC animated:YES completion:nil];
    }
  [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"ColorTheme"];
  [tableView reloadData];
}

@end
