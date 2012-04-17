#import <UIKit/UIKit.h>
#import "Cat.h"

@interface BreedPickerViewController : UIViewController

- (id)initWithCat:(Cat *)c andContext:(NSManagedObjectContext *)ctx;

@property (weak, nonatomic) IBOutlet UITableView *breedsTableView;

@end
