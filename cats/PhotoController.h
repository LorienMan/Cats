#import <UIKit/UIKit.h>

@class PhotoController;

@protocol PhotoControllerDelegate <NSObject>

- (void)photoControllerTappedPhoto:(id)c;

@end

@interface PhotoController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak) id<PhotoControllerDelegate> delegate;

- (id)initWithImage:(UIImage *)img;

- (IBAction)photoPush:(id)sender;

- (void)showImage:(UIImage *)img;

@end

