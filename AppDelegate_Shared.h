//
//  AppDelegate_Shared.h
//  hv-retry
//
//  Created by Dave Lyon on 7/15/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RecentEventsLoader.h"

@class RecentEventsLoader;

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate, RecentEventsLoaderDelegate> {
	
	UIWindow *window;
	RecentEventsLoader *importer;
	NSOperationQueue *operationQueue;
	NSDate *lastImportDate;

@private
	NSManagedObjectContext *managedObjectContext_;
	NSManagedObjectModel *managedObjectModel_;
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	NSURL *persistentStorePath;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSURL *persistentStorePath;

@property (nonatomic, retain) RecentEventsLoader *importer;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

@property (nonatomic,retain) NSDate *lastImportDate;

- (NSString *)applicationDocumentsDirectory;
- (void)handleImportCompletion;
- (void)importData;
@end

