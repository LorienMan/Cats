#import <UIKit/UIKit.h>
#import "CatsController.h"
#import "CatsListController.h"
#import "Cat.h"

@protocol CatsTableControllerDelegate <NSObject>

- (void)catsTableController:(id)c returnsToCatId:(NSManagedObjectID *)catId;

@end

@interface CatsTableController : UIViewController <CatsListController>

@property (weak, nonatomic) IBOutlet UITableView *catsTableView;
@property BOOL editing;

@end
