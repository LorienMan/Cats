#import "BreedPickerViewController.h"
#import "Breed.h"

@interface BreedPickerViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@end

@implementation BreedPickerViewController{
    Cat *cat;
    NSFetchedResultsController *breeds;
}
@synthesize breedsTableView;

- (id)initWithCat:(Cat *)c andContext:(NSManagedObjectContext *)ctx {
    if ((self = [super init])) {
        cat = c;
        breeds = [Breed breedsControllerFromContext:ctx];
        breeds.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Порода";
}

- (void)viewDidUnload {
    [self setBreedsTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    NSError *err;
    if (![breeds performFetch:&err]) {
        NSLog(@"Error while fething breeds: %@", err);
    }
    
    [self scrollToCurrentBreed];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)scrollToCurrentBreed {
    __block id objFound = nil;
    
    [breeds.fetchedObjects enumerateObjectsUsingBlock:^(Breed *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.title isEqualToString:cat.breed]) {
            objFound = obj;
            *stop = YES;
        }
    }];
    
    if (objFound) {
        [breedsTableView scrollToRowAtIndexPath:[breeds indexPathForObject:objFound] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return breeds.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[breeds sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"NewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    
    Breed *b = [breeds objectAtIndexPath:indexPath];
    cell.textLabel.text = b.title;
    if ([b.title isEqualToString:cat.breed]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id<NSFetchedResultsSectionInfo> sectionInfo = [[breeds sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [breeds sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [breeds sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    Breed *b = [breeds objectAtIndexPath:indexPath];
    cat.breed = b.title;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}

@end
