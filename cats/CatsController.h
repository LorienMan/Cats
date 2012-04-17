#import <UIKit/UIKit.h>
#import "CatsListController.h"
#import "CatEditorController.h"
#import "Cat.h"

@interface CatsController : UIViewController <CatsListControllerDelegate>

- (id)initWithContext:(NSManagedObjectContext *)ctx;

- (void)saveData;

@end
