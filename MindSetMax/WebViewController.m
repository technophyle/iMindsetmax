//
//  WebViewController.m
//  NLP123
//
//  Created by Kristian Borum on 10/22/09.
//  Copyright Borum Data 2009-2010. All rights reserved.
//

#import "WebViewController.h"
#import "NoteViewController.h"


@implementation WebViewController

- (NSString*)insertString:(NSString*)string inData:(NSString*)data forKeyword:(NSString*)keyword {
  NSRange body = [data rangeOfString:keyword options:NSBackwardsSearch|NSCaseInsensitiveSearch];
  if ( body.location == NSNotFound ) return data;
  return [data stringByReplacingCharactersInRange:body withString:string];
}

- (NSString*)insertUserNotesInData:(NSString*)data {
  NSString* annotationId = [[ContentStore contentStore] annotationIdForPage:self.pageIndexPath];
  
  NSString *title = [[NoteStore noteStore] titleForId:annotationId];
  NSString *contents = [[NoteStore noteStore] noteForId:annotationId];
  if ( title == nil ) title = @"";
  if ( contents == nil ) contents = @"";
  
  NSString *string = [NSString stringWithFormat:@"<h2 class='user_note'>%@</h2><p class='user_note'>%@",title,contents];
  return [self insertString:string inData:data forKeyword:@"<NOTES/>"];
}

- (NSString*)insertFontSizeInData:(NSString*)data {
  NSInteger selectedSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
  int sizepx = 16;
  switch (selectedSize) {
    case 0:
      sizepx = 12;
      break;
    case 2:
      sizepx = 20;
      break;
    default:
      break;
  }
  NSString *string = [NSString stringWithFormat:@"<style type=\"text/css\">body {font-size: %dpx;}</style>",sizepx];
  return [self insertString:string inData:data forKeyword:@"<FONTSIZE/>"];
} 

- (NSString*)insertBlogFeedInData:(NSString*)data {
  if ( [data rangeOfString:@"<BLOGFEED/>"].location != NSNotFound ) {
    NSMutableString* string = [NSMutableString string];
    [string appendFormat:@"<div id='blog-feed'>.</div>"];
    return [self insertString:string inData:data forKeyword:@"<BLOGFEED/>"];
  }
  return data;
}

- (NSString*)insertUserNoteListInData:(NSString*)data {
  if ( [data rangeOfString:@"<NOTELIST/>"].location != NSNotFound ) {
    NSArray* allPaths = [[ContentStore contentStore] allIndexPaths];
    NSMutableString* string = [NSMutableString string];
    [string appendFormat:@"<ul class='notelist'>"];
    NSMutableDictionary* notes = [NSMutableDictionary dictionary];
    for (NSIndexPath* path in allPaths) {
      NSString* annotationId = [[ContentStore contentStore] annotationIdForPage:path];
      NSString* shortcutId   = [[ContentStore contentStore] shortcutIdForPage:path];
      if ( shortcutId.length > 0 && annotationId.length > 0 ) {
        NSString* pageCaption = [[ContentStore contentStore] titleForPage:path];
        NSString* noteCaption = [[NoteStore noteStore] titleForId:annotationId];
        NSString* noteContent = [[NoteStore noteStore] noteForId:annotationId];
        if ( !pageCaption ) pageCaption = @"";
        if ( !noteCaption ) noteCaption = @"";
        if ( !noteContent ) noteContent = @"";
        [notes setObject:[NSArray arrayWithObjects:shortcutId, pageCaption, noteCaption,noteContent, nil] forKey:pageCaption];
      }
    }
    for (NSString* key in [[notes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
      NSArray* items = [notes objectForKey:key];
      NSString* shortcutId = [items objectAtIndex:0];
      NSString* pageCaption = [items objectAtIndex:1];
      NSString* noteCaption = [items objectAtIndex:2];
      NSString* noteContent = [items objectAtIndex:3];
      [string appendFormat:@"<li><a class='notelist_notecaption' href='shortcut:%@'>%@</a><div class='notelist_notecaption'>%@</div><div class='notelist_note'>%@</div></li>", shortcutId, pageCaption, noteCaption,noteContent];
    }
    [string appendFormat:@"</ul>"];
    return [self insertString:string inData:data forKeyword:@"<NOTELIST/>"];
  }
  return data;
}


- (void)contentUpdated {
  if ( self.sandboxed ) {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.externalURL]]];
  } else {
    NSError*  error;
    NSString* content = [[ContentStore contentStore] htmlContentForPage:self.pageIndexPath];
    NSString* resourcePath = [[[[[NSBundle mainBundle] pathForResource:content ofType:@"html"] stringByDeletingLastPathComponent]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *contentData = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:content ofType:@"html"]
                                                      encoding:NSUTF8StringEncoding error:&error];
    contentData = [self insertUserNotesInData:contentData];
    contentData = [self insertFontSizeInData:contentData];
    contentData = [self insertUserNoteListInData:contentData];
    contentData = [self insertBlogFeedInData:contentData];
    
    [self.webView loadHTMLString:contentData baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//", resourcePath]]];
  }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
  [self.indicator stopAnimating];
  [self.curtains setHidden:YES];
  [self.curtains.layer removeAllAnimations];
}

-(void)editNotes:(id)sender {
  NoteViewController *noteViewController = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
  noteViewController.pageIndexPath = self.pageIndexPath;
  [self.navigationController presentViewController:noteViewController animated:YES completion:nil];
  [noteViewController release];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if ( !self.sandboxed ) {
    if ( [[ContentStore contentStore] annotationIdForPage:self.pageIndexPath] )
      self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Notes",@"") style:UIBarButtonItemStylePlain target:self action:@selector(editNotes:)] autorelease];
  } else {
    self.indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    self.indicator.center = CGPointMake(160.0, self.view.frame.size.height/2);
    self.indicator.hidesWhenStopped = YES;
    [self.indicator startAnimating];
    [self.view addSubview:self.indicator];
  }
  [self contentUpdated];
}


- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationItem.rightBarButtonItem = nil;
}


- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
  if (self.words == nil)
    self.words = @"";
  NSString *call = [NSString stringWithFormat:@"var words = '%@';",self.words];
  [self.webView stringByEvaluatingJavaScriptFromString:call];
  [self.webView stringByEvaluatingJavaScriptFromString:@"highlight();"];
  CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.toValue   = [NSNumber numberWithFloat:0.0f];
	opacityAnimation.duration            = .2f;
  opacityAnimation.repeatCount         = 1;
  opacityAnimation.removedOnCompletion = NO;
  opacityAnimation.fillMode            = kCAFillModeForwards;
  opacityAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  opacityAnimation.delegate            = self;
  [self.curtains.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog( @"webView:didFailLoadWithError:%@", error );
}

- (NSIndexPath*)indexPathFromPath:(NSString*)pathString {
  NSUInteger parts[256];
  int size = 0;
  NSArray *listItems = [pathString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".-"]];
  for (NSString* part in listItems) {
    if ( [part caseInsensitiveCompare:@""] != NSOrderedSame) {
      parts[size++] = [part intValue];
    }
  }
  return [NSIndexPath indexPathWithIndexes:parts length:size];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *url = [request.URL absoluteString];
  if ( [[url uppercaseString] rangeOfString:@"SHORTCUT:"].location != NSNotFound ) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangePage"
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[url substringFromIndex:9],@"Shortcut",@"YES",@"Animate",@"NO",@"Sandbox",nil]];
  } else if ( [[url uppercaseString] rangeOfString:@"EXTERNAL:"].location != NSNotFound ) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url substringFromIndex:9]]];
  } else if (self.sandboxed) {
    return YES;
  } else {
    if ( navigationType != UIWebViewNavigationTypeOther ) {
      WebViewController *newViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
      NSString *caption = @"External Page";
      newViewController.navigationItem.title = caption;
      newViewController.sandboxed = YES;
      newViewController.externalURL = url;
      [self.navigationController pushViewController:newViewController animated:YES];
      [newViewController autorelease];
    } else {
      return YES;
    }
  }
  return NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  self.webView.delegate = self;
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[[ContentStore contentStore] backLabelForPage:self.pageIndexPath]
                                                                            style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  self.navigationItem.title = [[ContentStore contentStore] captionForPage:self.pageIndexPath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  self.webView.delegate = nil;
  self.webView = nil;
  [super dealloc];
}


@end
