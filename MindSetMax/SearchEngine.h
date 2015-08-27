//
//  SearchEngine.h
//  NLP123
//
//  Created by Kristian Borum on 11/29/10.
//  Copyright 2010 Krisb.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SearchEngine : NSObject <UITableViewDataSource,UISearchDisplayDelegate>

@property (nonatomic,retain) NSDictionary* searchDictionary;
@property (nonatomic,retain) NSDictionary *baseNameInfoMap; // Basename->page and Basename->title

@property (retain) NSString *currentSearchString;
@property (nonatomic, retain) NSString *activeSearchString;
@property (retain) NSMutableArray *activeResults;
@property (retain) UISearchDisplayController *searchController;

+ (id)sharedSearchEngine;

@end
