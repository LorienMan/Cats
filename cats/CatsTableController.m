#import "CatsTableController.h"
#import "CatInfoController.h"
#import "Cat.h"
#import "CatCell.h"

#define EDIT_SECTION 0
#define CATS_SECTION 1 

@interface CatsTableController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation CatsTableController {
    NSFetchedResultsController *cats;
    BOOL editing;
}
@synthesize catsTableView;
@synthesize delegate;

- (id)initWithContext:(NSManagedObjectContext *)ctx {
    if ((self = [super init])) {
        cats = [Cat catsControllerForSaleFromContext: ctx];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setCatsTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    NSError *err;
    if (![cats performFetch:&err]) {
        NSLog(@"Error in Table Controller while fetching cats: %@", err);
    }
    
    [catsTableView reloadData];
    
    cats.delegate = self;

    [self showCatWithId:[delegate catsListControllerCurrentCatId:self] scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)viewWillDisappear:(BOOL)animated {
    cats.delegate = nil;
}

- (void)showCatWithId:(NSManagedObjectID *)catId scrollPosition:(UITableViewScrollPosition)sPos {
    if (!catId)
        return;
    
    int idx = [Cat indexOfCatWithId:catId inController:cats];
    
    if (idx == NSNotFound)
        return;
    
    [catsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:CATS_SECTION] animated:NO scrollPosition:sPos];
}

- (BOOL)editing {
    return editing;
}

- (void)setEditing:(BOOL)ed {   
    editing = ed;
    [catsTableView setEditing:ed animated:YES];
    
    if (!ed) {
        [self showCatWithId:[delegate catsListControllerCurrentCatId:self] scrollPosition:UITableViewScrollPositionNone];
    }
    
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:EDIT_SECTION];
    [catsTableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade]; 
}

- (void)configureCell:(UITableViewCell *)c atIndexPath:(NSIndexPath *)indexPath {
    unsigned int catIndex = indexPath.row;
    CatCell *cell = (CatCell *)c;
    Cat *cat = [cats.fetchedObjects objectAtIndex:catIndex];
    
    UIImage *img = [UIImage imageWithContentsOfFile:cat.thumbPath];
    cell.imageView.image = img;
    cell.nameLabel.text = cat.name;
    cell.priceLabel.text = [NSString stringWithFormat:@"$ %@", [cat.price stringValue]];
    cell.tag = catIndex;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number;
    switch (section) {
        case EDIT_SECTION:
            number = self.editing ? 0 : 1;
            break;
            
        case CATS_SECTION:
            number = cats.fetchedObjects.count;
            break;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell;
    
    switch (indexPath.section) {
        case EDIT_SECTION: {
            static NSString *cellId = @"NewCell";
            
            UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!c)
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
            c.textLabel.text = @"Добавить";
            
            cell = c;
            break;
        } 
        
        case CATS_SECTION: {
            static NSString *cellId = @"CatCell";
            
            CatCell *c = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!c)
                c = [[[NSBundle mainBundle] loadNibNamed:@"CatCell" owner:nil options:nil] lastObject];
            
            [self configureCell:c atIndexPath:indexPath];
            
            cell = c;
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == CATS_SECTION) {
        [Cat moveCatFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row inController:cats];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL can;
    switch (indexPath.section) {
        case EDIT_SECTION:
            can = NO;
            break;
            
        case CATS_SECTION:
            can = YES;
            break;
    }
    return can;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        unsigned int catIndex = indexPath.row;
        Cat *c = [cats.fetchedObjects objectAtIndex:catIndex];
        [cats.managedObjectContext deleteObject:c];
        
        NSError *err;
        if (![cats.managedObjectContext save:nil]) {
            NSLog(@"Error while saving context after deleting cat: %@", err);
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    switch (indexPath.section) {
        case EDIT_SECTION:
            [delegate catListControllerOpenEditor:self];
            break;
            
        case CATS_SECTION: {
            unsigned int catIndex = indexPath.row;
            Cat *c = [cats.fetchedObjects objectAtIndex:catIndex];
            [delegate catsListController:self movedToCatId:c.objectID];
            
            if ([self editing]) {
                [delegate catsListController:self editCat:c];
            } else {
                [delegate catsListController:self openCatInfo:c];
            }
            break;
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCellEditingStyle style;
    
    switch (indexPath.section) {
        case EDIT_SECTION:
            style = UITableViewCellEditingStyleNone;
            break;
            
        case CATS_SECTION: {
            style = UITableViewCellEditingStyleDelete;
            break;
        }
    }
    return style;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *result = nil;
    
    switch (proposedDestinationIndexPath.section) {
        case EDIT_SECTION:
            result = sourceIndexPath;
            break;
            
        case CATS_SECTION:
            result = proposedDestinationIndexPath;
            break;
    }
    
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat fh;
    switch (section) {
        case EDIT_SECTION:
            fh = self.editing ? 1 : tableView.sectionFooterHeight;
            break;
            
        case CATS_SECTION:
            fh = tableView.sectionFooterHeight;
            break;
    }
    
    return fh;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat hh;
    switch (section) {
        case EDIT_SECTION:
            hh = self.editing ? 1 : tableView.sectionHeaderHeight;
            break;
            
        case CATS_SECTION:
            hh = self.editing ? tableView.sectionHeaderHeight - 2 : tableView.sectionHeaderHeight;
            break;
    }
    
    return hh;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (!editing) {
        [self.catsTableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!editing) {
        UITableView *tableView = self.catsTableView;
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:CATS_SECTION];
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:CATS_SECTION];
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                        atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!editing) {
        [self.catsTableView endUpdates];
    }
}

@end
