#import <UIKit/UIKit.h>
#import "CatsController.h"
#import "CatsListController.h"
#import "Cat.h"

@interface CatsGalleryController : UIViewController <CatsListController>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
