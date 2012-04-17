#import <CoreData/CoreData.h>

@interface Breed : NSManagedObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *firstLetter;

+ (NSFetchedResultsController *)breedsControllerFromContext:(NSManagedObjectContext *)ctx;

+ (void)setBreedsInContext:(NSManagedObjectContext *)ctx;

+ (NSEntityDescription *)entityFromContext:(NSManagedObjectContext *)ctx;

@end
