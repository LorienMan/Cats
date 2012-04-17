#import <Foundation/Foundation.h>
#import "Cat.h"

@protocol CatsListControllerDelegate;


#pragma mark - CatsListController protocol

@protocol CatsListController <NSObject>

- (id)initWithContext:(NSManagedObjectContext *)c;

@property (weak) id<CatsListControllerDelegate> delegate;

@end


#pragma mark - CatsListControllerDelegate protocol

@protocol CatsListControllerDelegate <NSObject>

- (void)catsListController:(UIViewController<CatsListController> *)c openCatInfo:(Cat *)cat;
- (void)catsListController:(UIViewController<CatsListController> *)c movedToCatId:(NSManagedObjectID *)catId;
- (NSManagedObjectID *)catsListControllerCurrentCatId:(UIViewController<CatsListController> *)c;
- (void)catListControllerOpenEditor:(UIViewController<CatsListController> *)c;

- (void)catsListController:(UIViewController<CatsListController> *)c editCat:(Cat *)cat;
@end