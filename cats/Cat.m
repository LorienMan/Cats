#import "Cat.h"

#define CAT_PHOTO_DIR @"photos"

@interface Cat ()

@end

@implementation Cat

@dynamic photoPath, thumbPath, name, gender, birthDate, breed, price, forSale, father, mother, order;

#define THUMB_DIMENSIONS CGSizeMake(50, 50)

#pragma mark - creators

+ (NSFetchedResultsController *)catsControllerForSaleFromContext:(NSManagedObjectContext *)ctx {
    NSFetchRequest *request = [NSFetchRequest new];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"forSale = YES"];
    NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.entity = [Cat entityFromContext:ctx];
    request.predicate = p;
    request.sortDescriptors = [NSArray arrayWithObject:d];
    
    NSFetchedResultsController *rc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    
    return rc;
}

+ (Cat *)catInContext:(NSManagedObjectContext *)ctx {
    return [[Cat alloc] initWithEntity:[self entityFromContext:ctx] insertIntoManagedObjectContext:ctx];
}

#pragma mark - instance methods

- (NSString *)genderString {
    return self.gender ? @"мальчик" : @"девочка";
}

- (NSString *)birthDateString {
    NSLocale *ruLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"LLL yyyy"];
    [dateFormatter setLocale:ruLocale];
    return [[dateFormatter stringFromDate:self.birthDate] lowercaseString];
}

- (void)setPhoto:(UIImage *)img {
    NSString *newPath;
    NSString *newThumbPath;
    
    if (self.photoPath) {
        newPath = self.photoPath;
        newThumbPath = self.thumbPath;
    } else {
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        NSString *filename = (__bridge NSString *)newUniqueIdString;
        filename = [filename stringByAppendingPathExtension: @"png"];
        
        NSString *thumbname = (__bridge NSString *)newUniqueIdString;
        thumbname = [thumbname stringByAppendingString:@"_thumb"];
        thumbname = [thumbname stringByAppendingPathExtension: @"png"];
        
        CFRelease(newUniqueId);
        CFRelease(newUniqueIdString);
        
        NSString *photoDir = [Cat catPhotoDir];
        
        newPath = [photoDir stringByAppendingPathComponent:filename];
        newThumbPath = [photoDir stringByAppendingPathComponent:thumbname];
        
        NSFileManager *fm = [NSFileManager defaultManager]; 
        NSError *err;
        if(![fm fileExistsAtPath:[Cat catPhotoDir]])
            if(![fm createDirectoryAtPath:photoDir withIntermediateDirectories:YES attributes:nil error:&err])
                NSLog(@"Error: Create folder failed - %@", err);
    }
    
    NSData *imgData = UIImagePNGRepresentation(img);
    [imgData writeToFile:newPath atomically:YES];
    
    CGSize orig = img.size;
    CGSize d = THUMB_DIMENSIONS;
    if (d.height / d.width > orig.height / orig.width) {
        d.width = d.height * orig.width / orig.height;
    }else {
        d.height = d.width * orig.height / orig.width;
    }
    
    CGRect r = CGRectMake(0, 0, d.width, d.height);
    
    UIGraphicsBeginImageContext(d);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, d.width, d.height);
    CGContextRotateCTM(context, -M_PI);
    
    CGContextDrawImage(context, r, img.CGImage);
    CGImageRef thumbCGImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    
                                
    UIImage *thumb = [UIImage imageWithCGImage:thumbCGImage scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(thumbCGImage);
    
    
    NSData *thumbData = UIImagePNGRepresentation(thumb);
    [thumbData writeToFile:newThumbPath atomically:YES];
    
    self.photoPath = newPath;
    self.thumbPath = newThumbPath;
}

- (void)setCatPropsFromDictionary: (NSDictionary *)dic {
    #define iWD_GET_VALUE(name) \
    (\
        {\
        id value = [dic objectForKey:@#name];\
        NSAssert(value, @"Field %@ not found.\n", @#name);\
        value;\
        }\
    )
          
    NSString *p = [[NSBundle mainBundle] pathForResource:iWD_GET_VALUE(Photo) ofType:@""]; 
    UIImage *i = [UIImage imageWithContentsOfFile:p];
    [self setPhoto:i];
    
    self.name = iWD_GET_VALUE(Name);
    self.gender = [iWD_GET_VALUE(Gender) boolValue];
    self.birthDate = iWD_GET_VALUE(BirthDate);
    self.breed = iWD_GET_VALUE(Breed);
    self.price = iWD_GET_VALUE(Price);
    
    self.forSale = [iWD_GET_VALUE(ForSale) boolValue];
}

- (void)validate: (NSString **)e {
    NSString *errMsg = nil;
    
    if (!self.photoPath && !errMsg) {
        errMsg = @"Не выбрана фотография";
    }
    
    if (!self.name && !errMsg) {
        errMsg = @"Не заполнено имя";
    }
    
    if (!self.birthDate && !errMsg) {
        errMsg = @"Не установлена дата рождения";
    }
    
    if (!self.breed && !errMsg) {
        errMsg = @"Не выбрана порода";
    }
    
    if (!self.price && !errMsg) {
        errMsg = @"Не установлена цена";
    }
    
    *e = errMsg;
}

#pragma mark - NSManagedObject methods

- (void)prepareForDeletion {
    NSFileManager *fm = [NSFileManager defaultManager]; 
    NSError *err;
    if (![fm removeItemAtPath:self.photoPath error:&err]) {
        NSLog(@"Error while cleaning photo: %@", err);
    }
    if (![fm removeItemAtPath:self.thumbPath error:&err]) {
        NSLog(@"Error while cleaning thumb: %@", err);
    }
    
    [super prepareForDeletion];
}

#pragma mark - bootstrap

+ (void)setCatsInContext:(NSManagedObjectContext *)ctx {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Cats.plist" ofType:@""];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSData * data = [[NSFileManager defaultManager] contentsAtPath:path];
    NSDictionary *dic = (NSDictionary *)[NSPropertyListSerialization
                                         propertyListFromData:data
                                         mutabilityOption:NSPropertyListImmutable
                                         format:&format
                                         errorDescription:&errorDesc];
    
    if (!dic) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    } else {
        NSArray *rawCats = [NSArray arrayWithArray:[dic objectForKey:@"Cats"]];
        
        int idx = 0;
        for (NSDictionary* rawCat in rawCats) {
            Cat *cat = [Cat catInContext:ctx];
            [cat setCatPropsFromDictionary:rawCat];
            cat.order = idx;
            idx++;
        }
    }
    
    NSError *err;
    [ctx save:&err];
    if (err) {
        NSLog(@"Error while saving context after loaded cats bootstrap: %@", err);
    }
    
    NSLog(@"Loaded cats bootstrap.");
}

#pragma mark - helpers

+ (Cat*)catWithId:(NSManagedObjectID *)nid inController:(NSFetchedResultsController *)rc {
    __block Cat *result = nil;
    
    [rc.fetchedObjects enumerateObjectsUsingBlock:^(Cat *c, NSUInteger idx, BOOL *stop){
        if ([c.objectID isEqual:nid]) {
            result = c;
            *stop = YES;
        }
    }];
    
    return result;
}

+ (NSUInteger)indexOfCatWithId:(NSManagedObjectID*)sId inController:(NSFetchedResultsController *)rc {
    __block unsigned int index = NSNotFound;
    
    if (sId) {
        [rc.fetchedObjects enumerateObjectsUsingBlock:^(Cat* obj, NSUInteger idx, BOOL *stop) {
            if ([obj.objectID isEqual:sId]) {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

+ (void)moveCatFromIndex:(NSUInteger)idx1 toIndex:(NSUInteger)idx2 inController:(NSFetchedResultsController *)rc {  
    NSMutableArray *cats = [rc.fetchedObjects mutableCopy];
    
    if (idx1 < cats.count && idx2 < cats.count) {
        Cat *c = [cats objectAtIndex:idx1];
        [cats removeObjectAtIndex:idx1];
        [cats insertObject:c atIndex:idx2];
        
        for (int idx = 0; idx < cats.count; idx++) {
            if ((idx <= idx1 && idx >= idx2) ||
                (idx <= idx2 && idx >= idx1)) {
                c = [cats objectAtIndex:idx];
                c.order = idx;
            }
        }
        
        [rc.managedObjectContext save:nil];
    }
}

+ (NSString *)catPhotoDir {
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [dirs lastObject];
    return [path stringByAppendingPathComponent:CAT_PHOTO_DIR];
}

+ (NSEntityDescription *)entityFromContext:(NSManagedObjectContext *)ctx {
    return [NSEntityDescription entityForName:@"Cat" inManagedObjectContext:ctx];
}

@end
