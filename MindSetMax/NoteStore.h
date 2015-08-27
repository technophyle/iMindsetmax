//
//  NoteStore.h
//  MindSetMax
//
//  Created by Kristian Borum on 9/21/12.
//  Copyright (c) 2012 Borum Data. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteStore : NSObject

- (NSString*)noteForId:(NSString*)noteId;
- (void)setNote:(NSString*)note forId:(NSString*)noteId;
- (NSString*)titleForId:(NSString*)noteId;
- (void)setTitle:(NSString*)title forId:(NSString*)noteId;

+ (NoteStore*)noteStore;

@end
