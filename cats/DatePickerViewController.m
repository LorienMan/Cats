#import "DatePickerViewController.h"

@interface DatePickerViewController () <UITableViewDataSource>

@end

@implementation DatePickerViewController{
    Cat *cat;
}
@synthesize datePicker;

- (id)initWithCat:(Cat *)c {
    if ((self = [super init])) {
        cat = c;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title = @"Дата рождения";
    UIFont *f = [UIFont boldSystemFontOfSize:16.0];
    CGSize s = [title sizeWithFont:f];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, s.width, s.height)];
    
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = f;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.titleView = titleLabel;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*30*6];
    datePicker.maximumDate = [NSDate date];
    if (cat.birthDate) {
        datePicker.date = cat.birthDate;
    }
    
}

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [super viewDidUnload];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)save {
    cat.birthDate = datePicker.date;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    return nil;
}

@end
