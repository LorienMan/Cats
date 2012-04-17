#import "CatsGalleryController.h"
#import "CatsTableController.h"
#import "PhotoController.h"
#import "CatInfoController.h"
#import "Cat.h"

@interface CatsGalleryController ()<PhotoControllerDelegate, UIScrollViewDelegate> {
    NSFetchedResultsController *cats;
    int catIndex;
    
    int preloadCount;
    NSMutableDictionary *loadedPhotoControllers;
    NSMutableArray *freePhotoControllers;
}


@end

@implementation CatsGalleryController
@synthesize scrollView;
@synthesize delegate;

- (id)initWithContext:(NSManagedObjectContext *)ctx {
    if ((self = [super init])) {
        cats = [Cat catsControllerForSaleFromContext: ctx];
        
        preloadCount = 1;
        loadedPhotoControllers = [NSMutableDictionary dictionary];
        freePhotoControllers = [NSMutableArray array];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    
    for (id obj in loadedPhotoControllers) {
        [self removeChildController:obj];
    }
    loadedPhotoControllers = nil;
    freePhotoControllers = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSError *err;
    if (![cats performFetch:&err]) {
        NSLog(@"Error in Gallery Controller while fetching cats: %@", err);
    }

    CGSize svs = scrollView.bounds.size;
    scrollView.contentSize = CGSizeMake(svs.width*cats.fetchedObjects.count, svs.height);
    
    [self showCatWithId:[delegate catsListControllerCurrentCatId:self]];
}

- (void)showCatWithId:(NSManagedObjectID *)catId {
    unsigned int idx = [Cat indexOfCatWithId:catId inController:cats];
    
    if (idx == NSNotFound)
        idx = 0;
    
    CGSize s = scrollView.bounds.size;
    CGPoint p = CGPointMake(idx*s.width, 0);
    scrollView.contentOffset = p;
    
    [self movedToPage:idx]; 
}

- (void)movedToPage:(int)page {
    if (page < 0 || page >= cats.fetchedObjects.count)
        return;
    
    [self freeUsedPhotoControllers];
    
    int start = page - preloadCount, 
    end = page + preloadCount;
    
    for (int i=start; i<=end; i++) {
        [self loadPage:i];
    }
    
    catIndex = page;
    Cat *c = [cats.fetchedObjects objectAtIndex:catIndex];
    [delegate catsListController:self movedToCatId:c.objectID];
}

- (void)loadPage:(unsigned int)page {      
    if (page >= cats.fetchedObjects.count)
        return;

    Cat *cat = [cats.fetchedObjects objectAtIndex:page];

    PhotoController *pc = [loadedPhotoControllers objectForKey:cat.objectID];
    if (!pc) {
        //PhotoController is not loaded for this cat
        pc = [freePhotoControllers lastObject];
        
        if (pc) {
            [freePhotoControllers removeLastObject];
        } else {
            pc = [[PhotoController alloc] init];
            pc.view.bounds = self.view.bounds;
            pc.delegate = self;
            [self addChildViewController:pc];
            [pc didMoveToParentViewController:self];
        }
        
        [loadedPhotoControllers setObject:pc forKey:cat.objectID];
        
        UIImage *photo = [UIImage imageWithData:[NSData dataWithContentsOfFile:[cat photoPath]]];
        [pc showImage:photo];
        
        [scrollView insertSubview:pc.view atIndex:0];
    }
    
    CGRect oldFr = pc.view.frame;
    CGFloat newX = page * oldFr.size.width;
    CGRect newFr = CGRectMake(newX, 0, oldFr.size.width, oldFr.size.height);
    pc.view.frame = newFr;
}

- (void)freeUsedPhotoControllers {    
    NSSet *pcKeysToFree = [loadedPhotoControllers keysOfEntriesPassingTest:
        ^BOOL(id key, PhotoController* obj, BOOL* stop){
            int page = [Cat indexOfCatWithId:key inController:cats];
            if (page < catIndex - preloadCount ||
                page > catIndex + preloadCount)
                return YES;
            return NO;
        }];
    
    for (id key in pcKeysToFree) {
        PhotoController *pc = [loadedPhotoControllers objectForKey:key];
        [loadedPhotoControllers removeObjectForKey:key];
        [freePhotoControllers addObject:pc];
        [self removeChildController:pc];
    }
}

- (void)removeChildController:(PhotoController*)c {
    [c showImage:nil];
    [c viewWillDisappear:YES];
    [c.view removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sv {
    int currentShownCatIndex = round(sv.contentOffset.x / sv.frame.size.width);   
    
    if (currentShownCatIndex != catIndex) {        
        [self movedToPage:currentShownCatIndex];
    }
}

#pragma mark - PhotoControllerDelegate

- (void)photoControllerTappedPhoto:(PhotoController *)c {
    Cat *cat = [cats.fetchedObjects objectAtIndex:catIndex];
    
    [delegate catsListController:self openCatInfo:cat];
}

@end
