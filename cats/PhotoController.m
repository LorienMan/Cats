#import "PhotoController.h"


@interface PhotoController ()

@property (strong) UIImage *image;

@end

@implementation PhotoController
@synthesize photo;
@synthesize delegate;
@synthesize image;

- (id)initWithImage:(UIImage *)img {
    if ((self = [super init])) {
        self.image = img;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photo.image = self.image;
}

- (void)viewDidUnload {
    [self setPhoto:nil];
    
    [super viewDidUnload];
}

- (IBAction)photoPush:(id)sender {
    [delegate photoControllerTappedPhoto:self];
}

- (void)showImage:(UIImage *)img {
    self.image = img;
    self.photo.image = img;
}

@end
