#import <UIKit/UIKit.h>
#import "Cat.h"

@interface DatePickerViewController : UIViewController

- (id)initWithCat:(Cat *)c;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end
