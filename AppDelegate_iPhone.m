#import "AppDelegate_iPhone.h"
#import "EventsViewController.h"
#import "Reachability.h"

@implementation AppDelegate_iPhone

@synthesize navigationController, eventsViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	self.lastImportDate = nil;
	[self setupUserDefaults];
	[self startReachabilityMonitor];
	
	if([self hasConnection]) {
		[self importData]; // Kick off event fetching.  See shared for source.
		
		self.lastImportDate = [NSDate date];		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" 
																												message:@"No internet connection available.  Older events are shown, but images and movies are unavailable." 
																											 delegate:self
																							cancelButtonTitle:@"OK" 
																							otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}

	// Override point for customization after application launch.
	
	eventsViewController.managedObjectContext = self.managedObjectContext;
	eventsViewController.managedObjectModel = self.managedObjectModel;
	
	[window addSubview:navigationController.view];
	[window addSubview:eventsViewController.view];
	[window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"Resigning active");
	[self stopReachabilityMonitor];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSLog(@"Entered background");
	[self stopReachabilityMonitor];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	[self startReachabilityMonitor];
	if([self hasConnection]) {
		[self importData]; // Kick off event fetching.  See shared for source.
		NSLog(@"Woke up with connection");
		self.lastImportDate = [NSDate date];		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" 
																												message:@"No internet connection available.  Older events are shown, but images and movies are unavailable." 
																											 delegate:self
																							cancelButtonTitle:@"OK" 
																							otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
		
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	[currentReach release];
	[eventsViewController release];
	[navigationController release];
	[super dealloc];
}

#pragma mark -
#pragma mark import management

- (void)cleanUpDatabase {
	NSFetchRequest *deleter = [[NSFetchRequest alloc] init];
	[deleter setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
	[deleter setPredicate:[NSPredicate predicateWithFormat:@"bookmarked == NO"]];
	[deleter setIncludesPropertyValues:NO];
	
	NSError *error = nil;
	NSArray *del = [self.managedObjectContext executeFetchRequest:deleter error:&error];
	[deleter release];
	//error handling goes here
	for (NSManagedObject * obj in del) {
		[self.managedObjectContext deleteObject:obj];
	}
}

- (IBAction)refresh:(id)sender {
	[self importData];
}

- (void)handleImportCompletion {
	[refreshButton setEnabled:YES];
	[super handleImportCompletion];
	[eventsViewController fetch];
}

- (void)importData {
	[super importData];
	[refreshButton setEnabled:NO];
}

#pragma mark -
#pragma mark Reachability

-(BOOL)hasConnection {
	return isReachable;
}

-(void)reachabilityChanged:(NSNotification *)note {
	Reachability *reach = [note object];
	NetworkStatus status = [reach currentReachabilityStatus];

	switch (status) 
	{
		case NotReachable:
			isReachable = NO;
			break;
		case ReachableViaWiFi:
			isReachable = YES;
			[refreshButton setEnabled:YES];
			break;
		case ReachableViaWWAN:
			isReachable = YES;
			[refreshButton setEnabled:YES];
			break;
	}
}

-(void)startReachabilityMonitor {
	currentReach = [[Reachability reachabilityForInternetConnection] retain];
	[currentReach startNotifier];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
	NetworkStatus status = [currentReach currentReachabilityStatus];

	switch (status) 
	{
		case NotReachable:
			isReachable = NO;
			[refreshButton setEnabled:NO];
			break;
		case ReachableViaWiFi:
			isReachable = YES;
			break;
		case ReachableViaWWAN:
			isReachable = YES;
			break;
	}
}

-(void)stopReachabilityMonitor {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
	[currentReach stopNotifier];
}


@end

