#import "CatInfoController.h"
#import "PhotoController.h"
#import "Cat.h"
#import "CatEditorController.h"

@interface CatInfoController () <PhotoControllerDelegate>

@property Cat *cat;

@end

@implementation CatInfoController
@synthesize motherButton;
@synthesize fatherButton;
@synthesize gender;
@synthesize birthdate;
@synthesize breed;
@synthesize price;
@synthesize priceLabel;
@synthesize photo;
@synthesize cat;

- (id)initWithCat:(Cat *)c {    
    if ((self = [super init])) {
        self.cat = c;
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Править" style:UIBarButtonItemStyleDone target:self action:@selector(edit)];
}

- (void)viewDidUnload {
    [self setPhoto:nil];
    [self setGender:nil];
    [self setBirthdate:nil];
    [self setBreed:nil];
    [self setPrice:nil];
    [self setMotherButton:nil];
    [self setFatherButton:nil];
    [self setPriceLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showCat:self.cat];
}

- (void)showCat:(Cat *)c {
    photo.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[c photoPath]]];
    gender.text = [c genderString];    
    birthdate.text = [c birthDateString];
    breed.text = [c breed];
    
    if (c.forSale) {
        price.text = [NSString stringWithFormat:@"$ %@", [[c price] stringValue]];
        priceLabel.hidden = NO;
    }
    self.navigationItem.title = [c name];    
    
    [self updateParent:c.mother forButton:self.motherButton];
    [self updateParent:c.father forButton:self.fatherButton];
}

- (void)updateParent:(Cat *)c forButton:(UIButton *)b {
    if (c) {
        NSString *heading;
        
        if (c.gender) 
            heading = @"Папа";
        else 
            heading = @"Мама";
        
        [b setTitle:[NSString stringWithFormat:@"%@: %@", heading, c.name]
                forState:UIControlStateNormal];
        b.hidden = NO;
    } else {
        b.hidden = YES;
    }
}

- (IBAction)photoClick:(id)sender {
    PhotoController *pc = [[PhotoController alloc] initWithImage: self.photo.image];
    pc.delegate = self;
    [self presentViewController:pc animated:YES completion:nil];
}

- (IBAction)showMother:(id)sender {
    [self showInfoForCat:cat.mother];
}


- (IBAction)showFather:(id)sender {
    [self showInfoForCat:cat.father];
}

- (void)showInfoForCat:(Cat *)c {
    if(!c)
        return;
    
    CatInfoController *ic = [[CatInfoController alloc] initWithCat:c];
    [self.navigationController pushViewController:ic animated:YES];
}

- (void)edit {
    CatEditorController *ic = [[CatEditorController alloc] initForEditingCat:cat];
    [self.navigationController pushViewController:ic animated:YES];
}

#pragma mark - PhotoControllerDelegate

- (void)photoControllerTappedPhoto:(id)c {
    [c dismissModalViewControllerAnimated:YES];
}

@end
