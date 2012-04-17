#import "Breed.h"

@implementation Breed

@dynamic title, firstLetter;

- (void)awakeFromFetch {
    self.firstLetter = [self.title substringToIndex:1];
}

+ (NSFetchedResultsController *)breedsControllerFromContext:(NSManagedObjectContext *)ctx {
    NSFetchRequest *r = [[NSFetchRequest alloc] init];
    r.entity = [Breed entityFromContext:ctx];
    NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    r.sortDescriptors = [NSArray arrayWithObject:d];
    
    NSFetchedResultsController *rc = [[NSFetchedResultsController alloc] initWithFetchRequest:r managedObjectContext:ctx sectionNameKeyPath:@"firstLetter" cacheName:nil];
    
    return rc;
}

+ (void)setBreedsInContext:(NSManagedObjectContext *)ctx {
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Breeds.plist" ofType:@""];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
        
    for (NSString *title in array) {
        Breed *b = [[Breed alloc] initWithEntity:[self entityFromContext:ctx] insertIntoManagedObjectContext:ctx];
        
        b.title = title;
    }
    
    NSError *err;
    err = nil;
    [ctx save:&err];
    if (err) {
        NSLog(@"Error while saving context after loaded breeds bootstrap: %@", err);
    }

    NSLog(@"Loaded breeds bootstrap.");
}

+ (NSEntityDescription *)entityFromContext:(NSManagedObjectContext *)ctx {
    return [NSEntityDescription entityForName:@"Breed" inManagedObjectContext:ctx];
}

@end
