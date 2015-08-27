//
//  ContentStore.m
//  MindSetMax
//
//  Created by Kristian Borum on 9/21/12.
//  Copyright (c) 2012 Borum Data. All rights reserved.
//

#import "ContentStore.h"

#import "SBJson.h"

@interface ContentStore ()
@property (nonatomic,retain) NSDictionary* content;
- (void)collectIndexPaths:(NSMutableArray*)working current:(NSIndexPath*)current;
@end

// Check json files using: http://jsonlint.com



@implementation ContentStore

- (id)parseJSON:(NSData*)jsonData {
  if ( !jsonData ) return nil;
  id result = nil;
  NSError* error;
  if ( NSClassFromString(@"NSJSONSerialization") ) {
    result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
  } else {
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    result = [parser objectWithString:[[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease]];
  }
  if ( !result ) {
    NSLog(@"Malformed JSON: %@",error);
  }
  return result;
}

- (ContentStore*)init {
  self = [super init];
  if (self) {
    NSArray *l = [NSBundle preferredLocalizationsFromArray:[NSArray arrayWithObjects:SUPPORTED_LANGUAGES,nil]];
    NSString *contentPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj",(NSString*)[l objectAtIndex:0]]];
//    self.content = [self parseJSON:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"]]];
    self.content = [self parseJSON:[NSData dataWithContentsOfFile:[contentPath stringByAppendingPathComponent:@"content.json"]]];
  }
  return self;
}

+ (ContentStore*)contentStore {
  @synchronized(self) {
    static ContentStore* sharedStore = nil;
    if (!sharedStore) {
      sharedStore = [[self alloc] init];
    }
    return sharedStore;
  }
}

#pragma mark - Data extraction.

- (NSDictionary*)dictionaryForTabIndex:(NSUInteger)tabIndex {
  NSArray* tabs = [self.content objectForKey:@"tabs"];
  if ( tabIndex >= tabs.count ) return nil;
  return [tabs objectAtIndex:tabIndex];
}

- (NSDictionary*)pageForTabIndex:(NSUInteger)tabIndex {
  return [[self dictionaryForTabIndex:tabIndex] objectForKey:@"tabPage"];
}

- (NSDictionary*)dictionaryForGroupOrPage:(NSIndexPath*)indexPath {
  NSUInteger position=0;
  NSDictionary* pageDictionary = [self pageForTabIndex:[indexPath indexAtPosition:position++]];
  
  while ( position < indexPath.length ) {
    NSArray* groups = [pageDictionary objectForKey:@"groups"];
    if ( [indexPath indexAtPosition:position] >= groups.count ) return nil; // Group does not exist.
    NSDictionary* groupDictionary = [groups objectAtIndex:[indexPath indexAtPosition:position++]];
    if ( position >= indexPath.length ) return groupDictionary;
    NSArray* pages = [groupDictionary objectForKey:@"groupPages"];
    if ( [indexPath indexAtPosition:position] >= pages.count ) return nil; // Page does not exist.
    pageDictionary = [pages objectAtIndex:[indexPath indexAtPosition:position++]];
  }
  return pageDictionary;
}

- (void)collectIndexPaths:(NSMutableArray*)working current:(NSIndexPath*)current {
  for( int i=0;;i++) {
    NSIndexPath* path = [current indexPathByAddingIndex:i];
    if ( [self exist:path] ) {
      [working addObject:path];
      [self collectIndexPaths:working current:path];
    } else {
      break;
    }
  }
}

-(NSArray*)allIndexPaths {
  NSMutableArray* working = [NSMutableArray array];
  [self collectIndexPaths:working current:[[[NSIndexPath alloc] init] autorelease]];
  return working;
}

- (bool)exist:(NSIndexPath*)indexPath {
  return [self dictionaryForGroupOrPage:indexPath] != nil;
}



- (NSDictionary*)dictionaryForPage:(NSIndexPath*)indexPath {
  if (indexPath.length % 2 != 1 ) return nil;
  return [self dictionaryForGroupOrPage:indexPath];
}

- (NSDictionary*)dictionaryForGroup:(NSIndexPath*)indexPath {
  if (indexPath.length % 2 != 0 ) return nil;
  return [self dictionaryForGroupOrPage:indexPath];
}

- (NSUInteger)numberOfTabs {
  return ((NSArray*)[self.content objectForKey:@"tabs"]).count;
}


- (NSString*)iconForTabIndex:(NSUInteger)tabIndex {
  return [[self dictionaryForTabIndex:tabIndex] objectForKey:@"tabIcon"];
}

- (NSString*)labelForTabIndex:(NSUInteger)tabIndex {
  return [[self dictionaryForTabIndex:tabIndex] objectForKey:@"tabName"];
}

- (NSString*)backLabelForPage:(NSIndexPath*)indexPath {
  NSDictionary* pageDict = [self dictionaryForPage:indexPath];
  NSString* label = [pageDict objectForKey:@"backLabel"];
  if (!label)
    label = [pageDict objectForKey:@"caption"];
  return label;
}

- (NSString*)captionForPage:(NSIndexPath*)indexPath {
  NSDictionary* pageDict = [self dictionaryForPage:indexPath];
  return [pageDict objectForKey:@"caption"];
}

- (NSString*)titleForPage:(NSIndexPath*)indexPath {
  NSDictionary* pageDict = [self dictionaryForPage:indexPath];
  return [pageDict objectForKey:@"title"];
}

- (NSString*)iconForPage:(NSIndexPath*)indexPath {
  NSDictionary* pageDict = [self dictionaryForPage:indexPath];
  return [pageDict objectForKey:@"icon"];
}

- (NSString*)remoteURLForPage:(NSIndexPath*)indexPath {
  NSDictionary* pageDict = [self dictionaryForPage:indexPath];
  return [pageDict objectForKey:@"remoteURL"];
}

- (NSString*)typeOfPage:(NSIndexPath*)indexPath {
  return [[self dictionaryForPage:indexPath] objectForKey:@"type"];
}

- (NSString*)audioContentForPage:(NSIndexPath*)indexPath {
  return [[self dictionaryForPage:indexPath] objectForKey:@"audio"];
}

- (NSString*)videoContentForPage:(NSIndexPath*)indexPath {
  return [[self dictionaryForPage:indexPath] objectForKey:@"video"];
}

- (NSString*)viewControllerForPage:(NSIndexPath*)indexPath {
    return [[self dictionaryForPage:indexPath] objectForKey:@"view_controller"];
}

- (NSString*)htmlContentForPage:(NSIndexPath*)indexPath {
  return [[self dictionaryForPage:indexPath] objectForKey:@"html"];
}

- (NSString*)annotationIdForPage:(NSIndexPath*)indexPath {
  return [[self dictionaryForPage:indexPath] objectForKey:@"annotationId"];
}

- (NSString*)shortcutIdForPage:(NSIndexPath*)indexPath {
  return [[self dictionaryForPage:indexPath] objectForKey:@"shortcutId"];
}

- (NSUInteger)numberOfGroupsForPage:(NSIndexPath*)indexPath {
  NSDictionary* pageDict = [self dictionaryForPage:indexPath];
  NSArray* groups = [pageDict objectForKey:@"groups"];
  if ( groups ) {
    return groups.count;
  }
  return 0;
}

- (NSUInteger)numberOfPagesForGroup:(NSIndexPath*)indexPath {
  NSDictionary* groupDict = [self dictionaryForGroup:indexPath];
  NSArray* pages = [groupDict objectForKey:@"groupPages"];
  if ( pages ) {
    return pages.count;
  }
  return 0;
}

- (NSString*)captionForGroup:(NSIndexPath*)indexPath {
  return [[self dictionaryForGroup:indexPath] objectForKey:@"groupCaption"];
}

- (bool)booleanForPage:(NSIndexPath*)indexPath property:(NSString*)property default:(bool)yesOrNo {
  NSString* val =[[self dictionaryForPage:indexPath] objectForKey:property];
  if (!val) return yesOrNo;
  return [val boolValue];
}

- (bool)askForAutoDownload {
  NSString* val = [[self.content objectForKey:@"appSettings" ] objectForKey:@"askForAutoDownload"];
  if (!val) return YES;
  return [val boolValue];
}

- (NSString*)parseAppKey {
  return [[self.content objectForKey:@"appSettings" ] objectForKey:@"parseApplicationKey"];
}

- (NSString*)parseClientId {
  return [[self.content objectForKey:@"appSettings" ] objectForKey:@"parseClientId"];
}

- (NSString*)mailchimpApiKey {
    return [[self.content objectForKey:@"appSettings" ] objectForKey:@"mailchimpApiKey"];
}

- (NSString*)mailchimpListId {
    return [[self.content objectForKey:@"appSettings" ] objectForKey:@"mailchimpListId"];
}

- (NSString*)shareMessage {
    return [[self.content objectForKey:@"appSettings" ] objectForKey:@"shareMessage"];
}

- (NSString*)shareLink {
    return [[self.content objectForKey:@"appSettings" ] objectForKey:@"shareLink"];
}

- (NSString*)shareImageLink {
    return [[self.content objectForKey:@"appSettings" ] objectForKey:@"shareImageLink"];
}

- (NSInteger)messageOfTheDayAlertHour {
  return ((NSString*)[[self.content objectForKey:@"appSettings" ] objectForKey:@"messageOfTheDayAlertHour"]).intValue;
}

- (NSString*)navigationBarTint {
  return [[self.content objectForKey:@"appSettings" ] objectForKey:@"navigationBarTint"];
}

- (NSIndexPath*)pathIndexForShortcutId:(NSString*)shortcutId {
  for (NSIndexPath* indexPath in [self allIndexPaths]) {
    if ( [shortcutId caseInsensitiveCompare:[self shortcutIdForPage:indexPath]] == NSOrderedSame )
      return indexPath;
  }
  return nil;
}

@end
