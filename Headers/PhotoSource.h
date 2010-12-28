#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"

@interface PhotoSource : NSObject <EGOPhotoSource> {
	
	NSArray *_photos;
	NSInteger _numberOfPhotos;
	
}

- (id)initWithPhotos:(NSArray*)photos;

@end