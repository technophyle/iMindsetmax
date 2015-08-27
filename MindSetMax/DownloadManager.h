//
//  DownloadManager.h
//  MindSetMax
//
//  Created by Kristian Borum on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

/** 
 * Manages downloads
 *
 * Clients add things to _resources
 * The manager will download them one at a time.
 *
 * _resources are keyed using the remoteUrl, giving a dict.
 * 'Status' stores the status (Downloaded,Downloading,Waiting,Stopped). 
 * 'LocalPath' stores the path to the local file.
 * 
 */
@interface DownloadManager : NSObject <ASIHTTPRequestDelegate> {
  bool _autoDownload;
}

// Get the local URL or nil if file is not yet downloaded.
- (NSString*)pathToLocalCopyOfRemoteResource:(NSString*)remoteUrl;

// Register a remote resource. Should be done as soon as possible
- (void)registerRemoteResource:(NSString*)remoteUrl withLocalName:(NSString*)localName;

// Test if a remote resource has been downloaded. 
- (bool)isRemoteResourceDownloaded:(NSString*)remoteResource;

// Return a human readable string describing the status of a remote resource (not downloaded,waiting,downloading,downloaded) 
- (NSString*)getRemoteResourceDownloadStatus:(NSString*)remoteResource;

// Set the download state of a remote resource. Setting to NO will clear already loaded data.
- (void)markRemoteResource:(NSString*)remoteResource forDownload:(bool)yesOrNo;
- (bool)isRemoteResourceMarkedForDownload:(NSString*)remoteResource;

// Set true if automatic download should be enabled. Setting this to YES will disable markRemoteResource:forDownload:
@property (nonatomic) bool   autoDownload;
@property (nonatomic,retain) NSMutableDictionary* resources;

@property (nonatomic,retain) ASIHTTPRequest* request;
@property (nonatomic,retain) NSString*       current;

+ (DownloadManager*)sharedManager;

@end
