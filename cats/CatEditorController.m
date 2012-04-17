#import "CatEditorController.h"
#import "Cat.h"
#import "DatePickerViewController.h"
#import "BreedPickerViewController.h"

@interface CatEditorController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@end

@implementation CatEditorController{
    NSArray *cells;
    Cat *cat;
    NSManagedObjectContext *context;
    
    NSIndexPath *selectedCellPath;
    NSIndexPath *selectedCellWithTextField;
}

@synthesize tableView;
@synthesize photoCell;
@synthesize genderCell;
@synthesize bdCell;
@synthesize breedCell;
@synthesize priceCell;
@synthesize nameCell;
@synthesize bdLabel;
@synthesize breedLabel;
@synthesize photoView;
@synthesize nameTextField;
@synthesize priceTextField;
@synthesize genderSegControl;

- (id)initWithContext:(NSManagedObjectContext *)ctx andFutureOrderingIndex:(int)order {
    if ((self = [super init])) {
        context = ctx;
        cat = [[Cat alloc] initWithEntity:[Cat entityFromContext:ctx] insertIntoManagedObjectContext:nil];
        cat.order = order;
    }
                 
    return  self;
}

- (id)initForEditingCat:(Cat *)c{
    if ((self = [super init])) {
        cat = c;
        context = cat.managedObjectContext;
        
        NSError *err;
        //save before editing to be able to rollback
        [context save:&err];
    }
    
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cells = [NSArray arrayWithObjects:
             photoCell,
             nameCell,
             genderCell,
             bdCell,
             breedCell,
             priceCell,
             nil];
    
    if (cat.managedObjectContext) {
        self.navigationItem.title = @"Правка";
    } else {
        self.navigationItem.title = @"Добавить";
    }
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
}

- (void)viewDidUnload {
    [self setPhotoCell:nil];
    [self setGenderCell:nil];
    [self setBdCell:nil];
    [self setBreedCell:nil];
    [self setPriceCell:nil];
    [self setTableView:nil];
    [self setBdLabel:nil];
    [self setPriceTextField:nil];
    [self setBreedLabel:nil];
    [self setPhotoView:nil];
    [self setNameTextField:nil];
    [self setNameCell:nil];
    [self setGenderSegControl:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerKeyboardNotifications];
    
    if (cat.birthDate)
        bdLabel.text = [cat birthDateString];
    
    if (cat.breed)
        breedLabel.text = cat.breed;
    
    if (cat.name) {
        nameTextField.text = cat.name;
    }
    
    if (cat.price) {
        priceTextField.text = [cat.price stringValue];
    }
    
    if (!photoView.image && cat.photoPath) {
        UIImage *i = [UIImage imageWithContentsOfFile:cat.photoPath];
        photoView.image = i;
    }
    
    genderSegControl.selectedSegmentIndex = cat.gender ? 0 : 1;
    
    if (selectedCellPath) {
        [tableView deselectRowAtIndexPath:selectedCellPath animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

- (void)unregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets i = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    tableView.contentInset = i;
    tableView.scrollIndicatorInsets = i;
    
    [tableView scrollToRowAtIndexPath:selectedCellWithTextField atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

- (void)save {
    NSString *errMsg = nil;
    
    [cat validate:&errMsg];
        
    if (!errMsg) {
        cat.forSale = YES;
        
        if (!cat.managedObjectContext) {
            [context insertObject:cat];
        }
        
        NSError *err;
        [context save:&err];
        if (err) {
            NSLog(@"Error while saving cat: %@", err);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:errMsg delegate:self cancelButtonTitle:@"Ок" otherButtonTitles:nil];
        [av show];
    }
}

- (void)back {
    if (cat.managedObjectContext) {
        [context rollback];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSNumber *)parcePriceString:(NSString *)price {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *n = [f numberFromString:price];
    if (n && [n doubleValue] < 0) {
        n = nil;
    }
    return n;
}

- (IBAction)selectedGender:(id)sender {
    cat.gender = !genderSegControl.selectedSegmentIndex;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    return [cells objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    selectedCellPath = indexPath;
    
    UITableViewCell *c = [cells objectAtIndex:indexPath.row];
    UIViewController *vc = nil;
    
    if (c == bdCell) {
        vc = [[DatePickerViewController alloc] initWithCat:cat];
    } else if (c == breedCell) {
        vc = [[BreedPickerViewController alloc] initWithCat:cat andContext:context];
    } else if (c == photoCell) {
        UIImagePickerController *ip = [[UIImagePickerController alloc] init];
        ip.delegate = self;
        [self presentModalViewController:ip animated:YES];
    }
    
    if (vc)
        [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[cells objectAtIndex:indexPath.row] frame].size.height;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    photoView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    cat.photo = photoView.image;
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == priceTextField) {
        NSNumber *n = [self parcePriceString:result];
        if (n || [result isEqualToString:@""]) {
            cat.price = [result isEqualToString:@""] ? nil : n;
            return YES;
        }
        return NO;
    }
    
    if (textField == nameTextField) {
        cat.name = [result isEqualToString:@""] ? nil : result;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    id cell;
    if (textField == nameTextField) {
        cell = nameCell;
    } else if (textField == priceTextField) {
        cell = priceCell;
    }
    selectedCellWithTextField = [NSIndexPath indexPathForRow:[cells indexOfObject:cell] inSection:0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    selectedCellWithTextField = nil;
}

@end
