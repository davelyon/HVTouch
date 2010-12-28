//
//  AppDelegate_iPhone.h
//  hv-retry
//
//  Created by Dave Lyon on 7/15/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"
#import "RecentEventsLoader.h"

@class EventsViewController, Reachability;

@interface AppDelegate_iPhone : AppDelegate_Shared <RecentEventsLoaderDelegate> {
	UINavigationController *navigationController;	
	EventsViewController *eventsViewController;
	
	IBOutlet UIBarButtonItem *refreshButton; //TODO: Move this to viewcontroller

	Reachability *currentReach;
	BOOL isReachable;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet EventsViewController *eventsViewController;

- (void)cleanUpDatabase;
- (IBAction)refresh:(id)sender;
- (BOOL)hasConnection;
- (void)startReachabilityMonitor;
- (void)stopReachabilityMonitor;
@end

