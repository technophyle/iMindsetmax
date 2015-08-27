//
//  NoteStore.m
//  MindSetMax
//
//  Created by Kristian Borum on 9/21/12.
//  Copyright (c) 2012 Borum Data. All rights reserved.
//

#import "NoteStore.h"

@interface NoteStore ()
@property (atomic,retain) NSMutableDictionary* notes;
@end

@implementation NoteStore

- (NSString*)pathToNoteStore {
  @synchronized(self) {
    static NSString *folder = nil;
    if ( folder == nil ) {
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      folder = [[(([paths count] > 0) ? [paths objectAtIndex:0] : nil) stringByAppendingPathComponent:@"notes.plist"] retain];
    }
    return folder;
  }
}

- (void)save {
  [self.notes writeToFile:[self pathToNoteStore] atomically:YES];
}

- (NSMutableDictionary*)dictionaryForId:(NSString*)noteId {
  return [self.notes objectForKey:noteId];
}

- (NSString*)noteForId:(NSString*)noteId {
  return [[self dictionaryForId:noteId] objectForKey:@"content"];
}

- (void)setNote:(NSString*)note forId:(NSString*)noteId {
  if ( !noteId ) return;
  NSMutableDictionary* d = [self dictionaryForId:noteId];
  if ( !d ) {
    d = [NSMutableDictionary dictionary];
    [self.notes setObject:d forKey:noteId];
  }
  [d setObject:note forKey:@"content"];
  [self save];
}

- (NSString*)titleForId:(NSString*)noteId {
  return [[self dictionaryForId:noteId] objectForKey:@"title"];
}

- (void)setTitle:(NSString*)title forId:(NSString*)noteId {
  if ( !noteId ) return;
  NSMutableDictionary* d = [self dictionaryForId:noteId];
  if ( !d ) {
    d = [NSMutableDictionary dictionary];
    [self.notes setObject:d forKey:noteId];
  }
  [d setObject:title forKey:@"title"];
  [self save];
}

- (NoteStore*)init {
  self = [super init];
  if (self) {
    self.notes = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathToNoteStore]];
    if ( !self.notes )
      self.notes = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (NoteStore*)noteStore {
  @synchronized(self) {
    static NoteStore* sharedStore = nil;
    if (!sharedStore) {
      sharedStore = [[self alloc] init];
    }
    return sharedStore;
  }
}



@end
