#import "CatsController.h"
#import "CatsGalleryController.h"
#import "CatsTableController.h"
#import "CatInfoController.h"
#import "Cat.h"
#import "Breed.h"

#define UD_CURRENT_CAT_ID @"currentCatId"
#define UD_FIRST_RUN @"firstRun"

@interface CatsController () {
    NSFetchedResultsController *cats;
    NSManagedObjectID *currentCatId;
    
    CatsGalleryController *galleryController;
    CatsTableController *tableController;
    
    UIViewController *activeController;
    BOOL flipping;
    
    NSManagedObjectContext *context;
}

@end

@implementation CatsController

- (id)initWithContext:(NSManagedObjectContext *)ctx {
    if ((self = [super init])) {
        context = ctx;
        
        cats = [Cat catsControllerForSaleFromContext: context];
        
        galleryController = [[CatsGalleryController alloc] initWithContext:context];
        galleryController.delegate = self;
        tableController = [[CatsTableController alloc] initWithContext:context];
        tableController.delegate = self;    
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self addChildViewController:galleryController];
    [self.view addSubview:galleryController.view];
    activeController = galleryController;
    
	[self addChildViewController:tableController];
    
    [self handleNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    galleryController.view.frame = self.view.bounds;
    tableController.view.frame = self.view.bounds;
    
    NSError *err;
    if (![cats performFetch:&err]) {
        NSLog(@"Error while performing fetch: %@", err);
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (![ud objectForKey:UD_FIRST_RUN]) {
            //Bootstrap
            [Breed setBreedsInContext:context];
            [Cat setCatsInContext:context];
            
            [ud setObject:[NSNumber numberWithBool:YES] forKey:UD_FIRST_RUN];
            [ud synchronize];
        }
        
        NSURL *url = [ud URLForKey:UD_CURRENT_CAT_ID];
        currentCatId = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
    });
}

- (void)flip {
    if (flipping)
        return;
    
    flipping = YES;
    
    id from = activeController;
    id to = activeController == galleryController ? tableController : galleryController;
    
    activeController = to;
    
    [self transitionFromViewController:from 
                      toViewController:to 
                              duration:0.3 
                               options:UIViewAnimationOptionTransitionFlipFromRight 
                            animations:nil
                            completion:^(BOOL finished) {
                                flipping = NO;
                                [self handleNavigationItem];
                            }];
}

- (void)handleNavigationItem {
    if (activeController == galleryController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Таблица" style:UIBarButtonItemStylePlain target:self action:@selector(flip)];
        self.navigationItem.rightBarButtonItem = nil;
        
        self.navigationItem.title = @"Галлерея";
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Галлерея" style:UIBarButtonItemStylePlain target:self action:@selector(flip)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(changeTableControllerMode)];
        [self handleRightButtonTitle];
        
        self.navigationItem.title = @"Таблица";
    }
}

- (void)handleRightButtonTitle {
    NSString *title;
    if (tableController.editing) {
        title = @"Готово";
    } else {
        title = @"Править";
    }
    
    self.navigationItem.rightBarButtonItem.title = title;
}

- (void)changeTableControllerMode {
    tableController.editing = !tableController.editing;
    [self handleRightButtonTitle];
}

- (void)saveData {
    [context save:nil];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setURL:[currentCatId URIRepresentation] forKey:UD_CURRENT_CAT_ID];
    [ud synchronize];
}

#pragma mark - ChildListControllerDelegate

- (void)catsListController:(UIViewController<CatsListController> *)c openCatInfo:(Cat *)cat {
    CatInfoController *ic = [[CatInfoController alloc] initWithCat:cat];
    [self.navigationController pushViewController:ic animated:YES];
}

- (void)catsListController:(UIViewController<CatsListController> *)c movedToCatId:(NSManagedObjectID *)catId {
    currentCatId = catId;
}

- (NSManagedObjectID *)catsListControllerCurrentCatId:(UIViewController<CatsListController> *)c {
    return currentCatId;
}

- (void)catListControllerOpenEditor:(UIViewController<CatsListController> *)c {
    CatEditorController *ec = [[CatEditorController alloc] initWithContext:context andFutureOrderingIndex:cats.fetchedObjects.count];
    
    [self.navigationController pushViewController:ec animated:YES];
}

- (void)catsListController:(UIViewController<CatsListController> *)c editCat:(Cat *)cat {
    CatEditorController *ic = [[CatEditorController alloc] initForEditingCat:cat];
    [self.navigationController pushViewController:ic animated:YES];
}

@end
