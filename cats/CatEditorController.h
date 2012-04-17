#import <UIKit/UIKit.h>
#import "Cat.h"

@interface CatEditorController : UIViewController

- (id)initWithContext:(NSManagedObjectContext *)ctx andFutureOrderingIndex:(int)order;
- (id)initForEditingCat:(Cat *)c;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *photoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *genderCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *bdCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *breedCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *nameCell;

@property (weak, nonatomic) IBOutlet UILabel *bdLabel;
@property (weak, nonatomic) IBOutlet UILabel *breedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegControl;

- (IBAction)selectedGender:(id)sender;

@end
