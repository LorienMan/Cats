#import <UIKit/UIKit.h>
#import "Cat.h"

@interface CatInfoController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *birthdate;
@property (weak, nonatomic) IBOutlet UILabel *breed;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *motherButton;
@property (weak, nonatomic) IBOutlet UIButton *fatherButton;

- (id)initWithCat:(Cat*)c;

- (IBAction)showMother:(id)sender;
- (IBAction)showFather:(id)sender;

@end
