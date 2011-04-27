//
//  AppDelegate_Shared.m
//  hv-retry
//
//  Created by Dave Lyon on 7/15/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "RecentEventsLoader.h"
#import "NSDateAdditions.h"

@implementation AppDelegate_Shared

@synthesize window;
@synthesize importer;
@synthesize lastImportDate;

#pragma mark -
#pragma mark Application lifecycle

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {

					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					abort();
        } 
    }
}

static NSString *apiRequestString = @"http://delphi.nascom.nasa.gov/api/index.php?action=getEvents&startDate=%@&eventType=ar,bp,ce,cd,cw,fi,fe,fl,lp,os,ss,ef&endDate=%@";

- (void)importData {
	if (importer != nil) return;
	
	self.importer = [[[RecentEventsLoader alloc] init] autorelease];
	importer.delegate = self;

	importer.persistentStoreCoordinator = self.persistentStoreCoordinator;
	
	NSString *start, *end;
	
//	if(lastImportDate == nil) {
		start = [[NSDate dateInPastForQuery] apiString];
//	} else {
//		start = [lastImportDate apiString];
//	}
	end = [[NSDate distantFuture] apiString];
	NSLog(@"Start: %@, End: %@", start, end);
	importer.requestURL = [NSURL URLWithString:
												 [NSString stringWithFormat:apiRequestString, start, end]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// add the importer to an operation queue for background processing (works on a separate thread)
	[self.operationQueue addOperation:importer];
	
}



- (NSOperationQueue *)operationQueue {
	if (operationQueue == nil) {
		operationQueue = [[NSOperationQueue alloc] init];
	}
	return operationQueue;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark RecentEventsLoader Delegate

- (void)importerDidSave:(NSNotification *)saveNotification{
	if([NSThread isMainThread]) {
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
	} else {
		[self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
	}
}

// Called by the importer when parsing is finished.
- (void)importerDidFinishParsingData:(RecentEventsLoader *)loader {
	[self performSelectorOnMainThread:@selector(handleImportCompletion) withObject:nil waitUntilDone:NO];
	self.importer = nil;
}
// Called by the importer in the case of an error.
- (void)importer:(RecentEventsLoader *)loader didFailWithError:(NSError *)error {
	[self performSelectorOnMainThread:@selector(handleImportError:) withObject:error waitUntilDone:NO];
}

- (void)handleImportCompletion { 
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.importer = nil;
}

- (void)handleImportError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.importer = nil;
	// handle errors as appropriate to your application...
	NSAssert3(NO, @"Unhandled error in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);	
	
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
		[operationQueue release];
		[importer release];
    
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Core Data stack

- (NSURL *)persistentStorePath {
	if (persistentStorePath == nil) {
		persistentStorePath = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"events.sqlite"]];
		
	}
	return persistentStorePath;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
	if (managedObjectContext_ != nil) {
		return managedObjectContext_;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext_ = [[NSManagedObjectContext alloc] init];
		[managedObjectContext_ setPersistentStoreCoordinator:coordinator];
	}
	return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
	if (managedObjectModel_ != nil) {
		return managedObjectModel_;
	}
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"events" ofType:@"momd"];
	NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
	managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]; 
  
	return managedObjectModel_;
}



/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
	if (persistentStoreCoordinator_ != nil) {
		return persistentStoreCoordinator_;
	}
	
	NSError *error = nil;
	persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.persistentStorePath options:nil error:&error]) {
		//TODO: Error Handling Here
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible;
		 * The schema for the persistent store is incompatible with current managed object model.
		 Check the error message to determine what the actual problem was.
		 
		 
		 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
		 
		 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
		 * Simply deleting the existing store:
		 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
		 
		 * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
		 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		 
		 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
		 
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}    
		
	return persistentStoreCoordinator_;
}

- (void)setupUserDefaults {
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	//Determine the path to our Settings.bundle.
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
	
	// Load paths to all .plist files from our Settings.bundle into an array.
	NSArray *allPlistFiles = [NSBundle pathsForResourcesOfType:@"plist" inDirectory:settingsBundlePath];
	
	// Put all of the keys and values into one dictionary,
	// which we then register with the defaults.
	NSMutableDictionary *preferencesDictionary = [NSMutableDictionary dictionary];
	
	// Copy the default values loaded from each plist
	// into the system's sharedUserDefaults database.
	NSString *plistFile;
	for (plistFile in allPlistFiles)
	{
		
		// Load our plist files to get our preferences.
		NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
		NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
		
		// Iterate through the specifiers, and copy the default
		// values into the DB.
		NSDictionary *item;
		for(item in preferencesArray)
		{
			// Obtain the specifier's key value.
			NSString *keyValue = [item objectForKey:@"Key"];
			
			// Using the key, return the DefaultValue if specified in the plist.
			// Note: We won't know the object type until after loading it.
			id defaultValue = [item objectForKey:@"DefaultValue"];
			
			// Some of the items, like groups, will not have a Key, let alone
			// a default value.  We want to safely ignore these.
			if (keyValue && defaultValue)
			{
				[preferencesDictionary setObject:defaultValue forKey:keyValue];
			}
			
		}
		
	}
	
	// Ensure the version number is up-to-date, too.
	// This is, incidentally, how you update the value in a Title element.
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *versionLabel = [NSString stringWithFormat:@"%@ (%d)", shortVersion, [version intValue]];
	[standardUserDefaults setObject:versionLabel forKey:@"app_version_number"];
	
	// Now synchronize the user defaults DB in memory
	// with the persistent copy on disk.
	[standardUserDefaults registerDefaults:preferencesDictionary];
	[standardUserDefaults synchronize];
	
}

@end

