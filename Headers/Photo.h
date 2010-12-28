#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"


@interface Photo : NSObject <EGOPhoto>{
	
	NSURL *_URL;
	NSString *_caption;
	CGSize _size;
	UIImage *_image;
	
	BOOL _failed;
	
}

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage;
- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName;
- (id)initWithImageURL:(NSURL*)aURL;
- (id)initWithImage:(UIImage*)aImage;
@end