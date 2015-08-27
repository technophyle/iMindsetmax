//
//  SearchEngine.m
//  NLP123
//
//  Created by Kristian Borum on 11/29/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import "SearchEngine.h"
//#import "RegexKitLite.h"
#import "Flurry.h"

@interface SearchEngine ()
- (void)buildDatabase;
@end

@implementation SearchEngine

+ (id)sharedSearchEngine {
  static SearchEngine *shared = nil;
  if ( !shared ) {
    shared = [[SearchEngine alloc] init];
  }
  return shared;
}

void recurseContentParse(NSMutableDictionary *dict,NSArray *array,NSString *path,int tab) {
  for(int g=0;g<[array count];g++) {
    NSArray *items = [[array objectAtIndex:g] objectForKey:@"Group"];
    if( items != nil ) {
      for(int i=0;i<[items count];i++) {
        NSArray *subitems = [[items objectAtIndex:i] objectForKey:@"Subitems"];
        if (subitems) {
          recurseContentParse(dict,subitems,[NSString stringWithFormat:@"%@.%d-%d",path,g,i],tab);
        } else {
          NSString *baseName = [[items objectAtIndex:i] objectForKey:@"Content"];
          NSString *title = [[items objectAtIndex:i] objectForKey:@"Title"];
          NSMutableDictionary *t = [NSMutableDictionary dictionary];
          [dict setObject:t forKey:baseName];
          [t setObject:[NSString stringWithFormat:@"%@.%d-%d",path,g,i] forKey:@"Page"];
          [t setObject:[NSNumber numberWithInt:tab] forKey:@"Tab"];
          [t setObject:title forKey:@"Title"];
        }
      }
    }
  }
}

- (void)buildDatabase {
  
  
  
  
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (NSString*)currentSearchDictFilePath {
  NSArray *l = [NSBundle preferredLocalizationsFromArray:[NSArray arrayWithObjects:SUPPORTED_LANGUAGES,nil]];
  return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"search_%@.dict",(NSString*)[l objectAtIndex:0]]];
}

- (NSString *)flattenHTML:(NSString *)html {
  NSScanner *theScanner;
  NSString *text;
  theScanner = [NSScanner scannerWithString:html];
  while ([theScanner isAtEnd] == NO) {
    //remove html tags
    [theScanner scanUpToString:@"<" intoString:NULL];
    if ( [theScanner scanUpToString:@">" intoString:&text] )
      html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
  }
  return html;
}


/**
 * Add the page at indexPath to the dictionary, along wth the sub-pages.
 *
 * If indexPath is empty, the child pages will be processed.
 */
- (void)createDictionaryForIndexPath:(NSIndexPath*)indexPath {
  
  ContentStore* contentStore = [ContentStore contentStore];
  
  if ( indexPath.length > 0 ) {
    // Parse page (or group).
    
    NSString* htmlPath = [contentStore htmlContentForPage:indexPath];
    if (htmlPath) {
      
      
      NSArray *l = [NSBundle preferredLocalizationsFromArray:[NSArray arrayWithObjects:SUPPORTED_LANGUAGES,nil]];
      NSString *contentPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj",(NSString*)[l objectAtIndex:0]]];
      
      NSString *html = [NSString stringWithContentsOfFile:[[contentPath stringByAppendingPathComponent:htmlPath] stringByAppendingPathExtension:@"html"] encoding:NSUTF8StringEncoding error:nil];
      if (html) {
        NSString *flat = [self flattenHTML:html];
        flat = [flat stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        flat = [flat stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        flat = [flat stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
        for (NSString *s = @"";
             [flat compare:s] != NSOrderedSame ;
             flat = [flat stringByReplacingOccurrencesOfString:@"  " withString:@" "])
          s = flat;
        
        
        
        // flat = [flat stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
        NSRange range = NSMakeRange(0, [flat length]);
        void (^enumerateSubstring)(NSString *, NSRange, NSRange, BOOL *) = ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
          NSMutableDictionary *pages = [[self.searchDictionary objectForKey:@"WORDS"] objectForKey:[substring uppercaseString]];
          if (!pages) {
            pages = [NSMutableDictionary dictionary];
            [[self.searchDictionary objectForKey:@"WORDS"] setObject:pages forKey:[substring uppercaseString]];
          }
          NSUInteger count = 1+[[pages objectForKey:indexPath] integerValue];
          [pages setObject:[NSNumber numberWithInt:count] forKey:indexPath];
        };
        [flat enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:enumerateSubstring];
      }
    }
  }
  
  // Process the children
  for(NSUInteger index=0;[contentStore exist:[indexPath indexPathByAddingIndex:index]];index++) {
    [self createDictionaryForIndexPath:[indexPath indexPathByAddingIndex:index]];
  }
  
}

/**
 * Create a dictionary of all words in the html content files.
 *
 * Search algorithm:
 *  Walk through list of dict keys, match all dict words that starts with any words in the search string.
 *  Order results by adding the number of hits in the files.
 *
 * Dictionary structure:
 * - VERSION: BundleVersion for creator.
 * - WORDS: Mapping of all words to dict of NSIndexPaths and counts.
 */
- (void)createDictionary {
  //NSLog(@"createDictionary");
  
  // Empty structure
  NSMutableDictionary *d = [NSMutableDictionary dictionary];
  NSMutableDictionary *w = [NSMutableDictionary dictionary];
  [d setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"VERSION"];
  [d setObject:w forKey:@"WORDS"];
  self.searchDictionary = d;
  
  [self createDictionaryForIndexPath:[[[NSIndexPath alloc] init] autorelease]];
  //
  
  return;
  /*
   NSArray *l = [NSBundle preferredLocalizationsFromArray:[NSArray arrayWithObjects:SUPPORTED_LANGUAGES,nil]];
   NSString *contentPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj",(NSString*)[l objectAtIndex:0]]];
   NSFileManager *fileManager = [NSFileManager defaultManager];
   if ([fileManager fileExistsAtPath:contentPath]) {
   NSArray *contents;
   contents = [fileManager contentsOfDirectoryAtPath:contentPath error:nil];
   int idx = 0;
   for (NSString *entity in contents) {
   if ( [[entity pathExtension] compare:@"html"] == NSOrderedSame ) {
   NSString *baseName = [entity stringByDeletingPathExtension];
   NSMutableDictionary *r = [NSMutableDictionary dictionary];
   [r setObject:baseName forKey:@"BASENAME"];
   //    [f setObject:r forKey:[NSNumber numberWithInt:idx]];
   // NSLog(@"%@ is type %@", entity, [entity pathExtension]);
   
   // Parse file
   NSString *html = [NSString stringWithContentsOfFile:[contentPath stringByAppendingPathComponent:entity] encoding:NSUTF8StringEncoding error:nil];
   NSString *flat = [self flattenHTML:html];
   flat = [flat stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
   flat = [flat stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
   flat = [flat stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
   for (NSString *s = @"";
   [flat compare:s] != NSOrderedSame ;
   flat = [flat stringByReplacingOccurrencesOfString:@"  " withString:@" "])
   s = flat;
   
   
   
   // flat = [flat stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
   int len = [flat length];
   len = len > 256 ? 256 : len;
   [r setObject:[flat substringToIndex:len] forKey:@"SUBTITLE"];
   NSRange range = NSMakeRange(0, [flat length]);
   void (^enumerateSubstring)(NSString *, NSRange, NSRange, BOOL *) = ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
   NSMutableDictionary *tup = [w objectForKey:[substring uppercaseString]];
   if (tup==nil) {
   tup = [NSMutableDictionary dictionary];
   [w setObject:tup forKey:[substring uppercaseString]];
   [tup setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:idx]];
   }
   int cur = 1+[[tup objectForKey:[NSNumber numberWithInt:idx]] integerValue];
   [tup setObject:[NSNumber numberWithInt:cur] forKey:[NSNumber numberWithInt:idx]];
   };
   [flat enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:enumerateSubstring];
   
   idx++;
   }
   }
   }
   */
  //[d writeToFile:[self currentSearchDictFilePath] atomically:YES];
}

- (void)loadDictionary {
  [self createDictionary];
  NSLog(@"Search dictionary loaded: %d words", [[self.searchDictionary objectForKey:@"WORDS"] count]);
}

- (id)init {
  self = [super init];
  if (self ) {
    self.searchDictionary = nil;
    self.activeResults = [NSMutableArray array];
    [self loadDictionary];
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.activeResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //NSLog(@"tableView:cellForRowAtIndexPath:%d (row)",indexPath.row);
  
  UITableViewCell *cell = nil;
  
  static NSString *CellIdentifier = @"SearchCell";
  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  @synchronized(self) {
    if ( indexPath.row < [self.activeResults count]) {
      cell.textLabel.text      = [[self.activeResults objectAtIndex:indexPath.row] objectForKey:@"TITLE"];
      cell.detailTextLabel.text = [[self.activeResults objectAtIndex:indexPath.row] objectForKey:@"SUBTITLE"];
    }
  }
  return cell;
}

- (void)postChangePage:(NSDictionary*)userInfo {
  [Flurry logEvent:@"Searched" withParameters:[NSDictionary dictionaryWithObject:self.currentSearchString forKey:@"String"]];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangePage"
                                                      object:nil
                                                    userInfo:userInfo];
  [userInfo release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPathForSelection {
  //  NSLog(@"tableView:%p didSelectRowAtIndexPath:%d    tv super:%@",tableView,indexPath.row,self.searchController.searchResultsTableView.superview);
  [self.searchController setActive:NO animated:NO];
  //self.searchController = nil;
  NSIndexPath* indexPath = [[self.activeResults objectAtIndex:indexPathForSelection.row] objectForKey:@"INDEXPATH"];
//#ifndef __clang_analyzer__
  NSDictionary *userInfo = [[NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"ChangePage",@"YES",@"Remapped",@"NO",@"Animate",
                             self.activeSearchString,@"Words",nil] retain];
//#endif
  
  // Delay page change slightly to allow search controller to deactivate. Workaround to iOS issue.
  [self performSelector:@selector(postChangePage:) withObject:userInfo afterDelay:.1];
  
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  self.searchController = controller;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
  // self.searchController = nil;
}

/**
 * Use currentSearchString to generate dictionary of hits.
 */
- (void)setSearchString:(UISearchDisplayController *)controller {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  @try {
    if ( self.currentSearchString != self.activeSearchString ) {
      
   //   NSLog(@"setSearchString:%@",self.currentSearchString);
      @synchronized(self) {
        self.activeSearchString = self.currentSearchString;
      }
      [self.activeResults removeAllObjects];
      
      NSMutableDictionary *tally = [NSMutableDictionary dictionary]; // Score -> NSIndexPath
      NSRange range = NSMakeRange(0, [self.activeSearchString length]);
      void (^enumerateSubstring)(NSString *, NSRange, NSRange, BOOL *) = ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        bool isPartial = NSEqualRanges(substringRange,enclosingRange);
        if ( isPartial ) {
          NSArray *words = [[self.searchDictionary objectForKey:@"WORDS"] allKeys];
          NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring];
          NSArray *beginWithWord = [words filteredArrayUsingPredicate:bPredicate];
          for (NSString *matchedWord in beginWithWord) {
            NSDictionary *word = [[self.searchDictionary objectForKey:@"WORDS"] objectForKey:matchedWord];
            for (NSIndexPath *indexPath in [word allKeys]) {
              NSNumber *score = [tally objectForKey:indexPath];
              if (!score) {
                score = [NSNumber numberWithDouble:0.0];
              }
              double gain = 1.0 + [[word objectForKey:indexPath] floatValue] / 1e6;
              score = [NSNumber numberWithDouble:[score doubleValue]+gain];
              [tally setObject:score forKey:indexPath];
            }
          }
        } else {
          NSDictionary *word = [[self.searchDictionary objectForKey:@"WORDS"] objectForKey:substring];
          for (NSIndexPath *indexPath in [word allKeys]) {
            NSNumber *score = [tally objectForKey:indexPath];
            if (!score) {
              score = [NSNumber numberWithDouble:0.0];
            }
            double gain = 1.0 + [[word objectForKey:indexPath] floatValue] / 1e6;
            score = [NSNumber numberWithDouble:[score doubleValue]+gain];
            [tally setObject:score forKey:indexPath];
          }
        }
      };
      [self.activeSearchString enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:enumerateSubstring];
      
      NSArray *ordered = [[[tally keysSortedByValueUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
      
      @synchronized(self) {
        [self.activeResults removeAllObjects];
        for (NSIndexPath* indexPath in ordered) {
          NSMutableDictionary *entry = [NSMutableDictionary dictionary];
          //NSString *baseName = [[[self.searchDictionary objectForKey:@"FILES"] objectForKey:fileidx] objectForKey:@"BASENAME"];
          NSString *title = [[ContentStore contentStore] titleForPage:indexPath];
          if ( title == nil ) {
            continue;
          }
          [self.activeResults addObject:entry];
          [entry setObject:title forKey:@"TITLE"];
          [entry setObject:indexPath forKey:@"INDEXPATH"];
          [entry setObject:title forKey:@"SUBTITLE"];
        }
      }
      [controller.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
  }
  @finally {
    [pool release];
  }
}


/**
 * Async search
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  @synchronized(self) {
    self.currentSearchString = [searchString uppercaseString];
  }
  [self performSelectorInBackground:@selector(setSearchString:) withObject:controller];
  return NO;
}


@end
