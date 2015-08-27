//
//  ContentStore.h
//  MindSetMax
//
//  Created by Kristian Borum on 9/21/12.
//  Copyright (c) 2012 Borum Data. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *
 * IndexPath use in content extraction:
 *
 * pos 0: Tab index
 *     1: Group index
 *     2: Page index in group
 *   n+1: Group index
 *   n+2: Page index.
 *
 * All odd indexPaths identifies a page, even identifies a group.
 *
 */
@interface ContentStore : NSObject

+ (ContentStore*)contentStore;

- (NSUInteger)numberOfTabs;
- (NSString*)iconForTabIndex:(NSUInteger)tabIndex;
- (NSString*)labelForTabIndex:(NSUInteger)tabIndex;

- (NSString*)backLabelForPage:(NSIndexPath*)indexPath;
- (NSString*)captionForPage:(NSIndexPath*)indexPath;
- (NSString*)titleForPage:(NSIndexPath*)indexPath;
- (NSString*)iconForPage:(NSIndexPath*)indexPath;
- (NSString*)typeOfPage:(NSIndexPath*)indexPath;
- (NSString*)remoteURLForPage:(NSIndexPath*)indexPath;
- (NSString*)audioContentForPage:(NSIndexPath*)indexPath;
- (NSString*)videoContentForPage:(NSIndexPath*)indexPath;
- (NSString*)htmlContentForPage:(NSIndexPath*)indexPath;
- (NSString*)viewControllerForPage:(NSIndexPath*)indexPath;
- (NSString*)annotationIdForPage:(NSIndexPath*)indexPath;
- (NSString*)shortcutIdForPage:(NSIndexPath*)indexPath;
- (NSUInteger)numberOfGroupsForPage:(NSIndexPath*)indexPath;

- (bool)exist:(NSIndexPath*)indexPath;

- (NSUInteger)numberOfPagesForGroup:(NSIndexPath*)indexPath;
- (NSString*)captionForGroup:(NSIndexPath*)indexPath;

- (bool)booleanForPage:(NSIndexPath*)indexPath property:(NSString*)property default:(bool)yesOrNo;

- (NSIndexPath*)pathIndexForShortcutId:(NSString*)shortcutId;

-(NSArray*)allIndexPaths;

- (NSInteger)messageOfTheDayAlertHour;
- (NSString*)navigationBarTint;
- (bool)askForAutoDownload;

- (NSString*)parseAppKey;
- (NSString*)parseClientId;

- (NSString*)mailchimpApiKey;
- (NSString*)mailchimpListId;

- (NSString*)shareMessage;
- (NSString*)shareLink;
- (NSString*)shareImageLink;

@end
