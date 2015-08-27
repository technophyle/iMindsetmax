//
//  DownloadManager.m
//  MindSetMax
//
//  Created by Kristian Borum on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager

@dynamic autoDownload;
@synthesize resources    = _resources;
@synthesize request      = _request;
@synthesize current      = _current;

- (bool)autoDownload {
  return _autoDownload;
}


- (void)initiateDownload:(NSString*)remoteUrl {
  self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:remoteUrl]];
  self.request.delegate = self;
  self.request.shouldContinueWhenAppEntersBackground = YES;
  self.current = remoteUrl;
  [self.request setDownloadDestinationPath:[[_resources objectForKey:remoteUrl] objectForKey:@"LocalPath"]];
  [self.request startAsynchronous];
  [[_resources objectForKey:self.current] setObject:@"Downloading" forKey:@"Status"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTables" object:nil];
}


/**
 * If any unfetched remoteUrls exists, download.
 *
 */
- (void)process {
  if ( _request ) return; // Exit if operation is in progress.
  for (NSString* remoteUrl in _resources) {
    NSString* status = [self getRemoteResourceDownloadStatus:remoteUrl];
    if ( ( [status compare:@"Waiting"] == NSOrderedSame ) ) {
      [self initiateDownload:remoteUrl];
      return;
    }
  }
}

- (void)setAutoDownload:(bool)yesOrNo {
  _autoDownload = yesOrNo;
  [self process];
}

- (id)init
{
    self = [super init];
    if (self) {
      self.resources = [NSMutableDictionary dictionary];
      self.autoDownload = NO;
    }
    
    return self;
}



- (void)requestFinished:(ASIHTTPRequest *)request {
  [[_resources objectForKey:self.current] setObject:@"Downloaded" forKey:@"Status"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTables" object:nil];
  self.request = nil;
  self.current = nil;
  [self process];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
  self.request = nil;
  self.current = nil;
  [self process];
}


// Test if a remote resource has been downloaded. 
- (bool)isRemoteResourceDownloaded:(NSString*)remoteResource {
  return [[self getRemoteResourceDownloadStatus:remoteResource] compare:@"Downloaded"] == NSOrderedSame;
}

// Get the local URL or nil if file is not yet downloaded.
- (NSString*)pathToLocalCopyOfRemoteResource:(NSString*)remoteResource {
  if ( ![self isRemoteResourceDownloaded:remoteResource] ) return nil;
  return [[_resources objectForKey:remoteResource] objectForKey:@"LocalPath"];
}

- (NSString*)pathToDocumentFolder 
{
  static NSString *folder = nil;
  if ( folder == nil ) {
    NSArray *folders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    folder = [[folders objectAtIndex:0] retain];
  }
  return folder;
}

// Register a remote resource. Should be done as soon as possible
- (void)registerRemoteResource:(NSString*)remoteUrl withLocalName:(NSString*)localName {
  if ( !remoteUrl ) return;
  NSMutableDictionary* s= [_resources objectForKey:remoteUrl];
  if ( !s ) {
    s = [NSMutableDictionary dictionary];
    [_resources setObject:s forKey:remoteUrl];
    [s setObject:@"Stopped" forKey:@"Status"];    
  }
  NSString *localPath = [[self pathToDocumentFolder] stringByAppendingPathComponent:localName];
  [s setObject:localPath forKey:@"LocalPath"];
  if ( [[NSFileManager defaultManager] fileExistsAtPath:localPath] ) {
    [s setObject:@"Downloaded" forKey:@"Status"];  
  }
  [self process];
 // NSLog(@"DownloadManager: Added %@",localPath);
}


// Return a human readable string describing the status of a remote resource (not downloaded,waiting,downloading,downloaded) 
- (NSString*)getRemoteResourceDownloadStatus:(NSString*)remoteResource {
  if ( !remoteResource ) return @"Unknown";
  NSDictionary* s= [_resources objectForKey:remoteResource];
  NSString *status = [s objectForKey:@"Status"];
  if ( !s ) return @"Unknown";
  if ( _autoDownload && [status compare:@"Stopped"] == NSOrderedSame )
    status = @"Waiting";
    return status;
}

// Set the download state of a remote resource. Setting to NO will clear already loaded data.
- (void)markRemoteResource:(NSString*)remoteResource forDownload:(bool)yesOrNo {
  if ( [self isRemoteResourceMarkedForDownload:remoteResource] == yesOrNo ) return; // No change
  NSMutableDictionary* s= [_resources objectForKey:remoteResource];
  if ( yesOrNo ) {
    [s setObject:@"Waiting" forKey:@"Status"];
    //NSLog(@"DownloadManager: Started %@",remoteResource);
  } else {
    [s setObject:@"Stopped" forKey:@"Status"];
  }
  [self process];
}

- (bool)isRemoteResourceMarkedForDownload:(NSString*)remoteResource {
  NSString *status = [self getRemoteResourceDownloadStatus:remoteResource];
  return (( [status compare:@"Downloaded"] == NSOrderedSame ) ||
          ( [status compare:@"Waiting"] == NSOrderedSame ) ||
          ( [status compare:@"Downloading"] == NSOrderedSame ));
  
}

+ (DownloadManager*)sharedManager {
  static DownloadManager* manager = nil;
  if ( manager == nil ) {
    manager = [[DownloadManager alloc] init];
  }
  return manager;
}

@end
