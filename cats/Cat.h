#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Cat : NSManagedObject

+ (Cat *)catInContext:(NSManagedObjectContext *)ctx;


@property (strong, nonatomic)  NSString *photoPath;
@property (strong, nonatomic)  NSString *thumbPath;
@property (strong, nonatomic)  NSString *name;
@property BOOL gender;
@property (strong, nonatomic)  NSDate *birthDate;
@property (strong, nonatomic)  NSString *breed;
@property (strong, nonatomic)  NSNumber *price;
@property BOOL forSale;
@property (strong, nonatomic)  Cat *father;
@property (strong, nonatomic)  Cat *mother;
@property int order;

- (NSString *)genderString;
- (NSString *)birthDateString;

- (void)setPhoto:(UIImage *)img;

- (void)setCatPropsFromDictionary: (NSDictionary *)dic;

- (void)validate: (NSString **)e;

+ (void)setCatsInContext:(NSManagedObjectContext *)ctx;

+ (NSFetchedResultsController *)catsControllerForSaleFromContext:(NSManagedObjectContext *)ctx;

+ (Cat*)catWithId:(NSManagedObjectID *)nid inController:(NSFetchedResultsController *)rc;

+ (NSUInteger)indexOfCatWithId:(NSManagedObjectID*)catId inController:(NSFetchedResultsController *)rc;

+ (void)moveCatFromIndex:(NSUInteger)idx1 toIndex:(NSUInteger)idx2 inController:(NSFetchedResultsController *)rc;

+ (NSEntityDescription *)entityFromContext:(NSManagedObjectContext *)ctx;

@end
