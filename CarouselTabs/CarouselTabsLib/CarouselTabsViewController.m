//
//  CarouselTabsViewController.m
//  CarouselTabs
//
//  Created by Igor Lipovac on 01/07/14.
//  Copyright (c) 2014 Igor Lipovac. All rights reserved.
//

#import "CarouselTabsViewController.h"
#import "CarouselTabNavigationController.h"

// DEFINITIONS
#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE               !IS_IPAD
#define IS_IPHONE_5             ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define kTabPadding            15
#define kPageWidthIPad          570
#define kSmallTabScale         0.7
#define kScaleFactorInterval    (1.0 - kSmallTabScale)
#define kSpaceFromTop           (IS_IPAD ? 52 : (kTabPadding / 2))


@interface CarouselTabsViewController ()

//outlets
@property (weak, nonatomic) IBOutlet UIView             *tabButtonsContainer;
@property (weak, nonatomic) IBOutlet UIScrollView       *carouselScrollView;
@property (weak, nonatomic) IBOutlet UIView             *carouselCanvasView;
@property (weak, nonatomic) IBOutlet UIScrollView       *tabButtonScrollView;
//constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *canvasWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarWidth;

// properties
@property (nonatomic, strong) NSMutableArray            *carouselTabs;
@property (nonatomic, strong) NSMutableArray            *startViewControllers;
@property (nonatomic, strong) NSMutableArray            *tabButtonImages;
@property (nonatomic, strong) NSMutableArray            *tabButtonTitles;
@property (nonatomic, strong) NSMutableArray            *tabButtons;
@property (nonatomic, assign) CGPoint                   previousContentOffset;
@property (nonatomic, strong) UITapGestureRecognizer    *tapOnNextTab;
@property (nonatomic, strong) UITapGestureRecognizer    *tapOnPreviousTab;


@end

@implementation CarouselTabsViewController




- (id)initWithCarouselTabViewControllers:(NSArray*)tabViewControllers andTabButtonImages:(NSArray*)tabButtonImages
{
    self = [super init];
    if (self) {
        self.startViewControllers = tabViewControllers.mutableCopy;
        self.tabButtonImages = tabButtonImages.mutableCopy;
        self.tabButtons = [NSMutableArray array];
        self.carouselTabs = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCarouselTabViewControllers:(NSArray*)tabViewControllers andTabButtonTitles:(NSArray*)tabButtonTitles
{
    self = [super init];
    if (self) {
        self.startViewControllers = tabViewControllers.mutableCopy;
        self.tabButtonTitles = tabButtonTitles.mutableCopy;
        self.tabButtons = [NSMutableArray array];
        self.carouselTabs = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //create gesture recognizers
    self.tapOnNextTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnNext)];
    self.tapOnPreviousTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnPrevious)];
    [self prepareCarouselTabs];
     [self layoutTabButtons];
}

- (CGFloat)normalTabWidth
{
    return (IS_IPAD ? 540 : (self.carouselScrollView.frame.size.width - kTabPadding * 2));
}

- (CGFloat)normalTabHeight
{
    return(IS_IPAD ? 540 : (IS_IPHONE_5 ? (self.carouselScrollView.frame.size.height - kTabPadding) : 360));
}

- (CGFloat)pageWidth {
    return IS_IPAD ? kPageWidthIPad : self.canvasWidthConstraint.constant / [self numberOfTabs];
}

- (CGFloat)tabButtonWidth
{
    return IS_IPAD ? 80 : 60;
}

- (CGFloat) pagePadding {
    return (self.view.frame.size.width - [self normalTabWidth]) / 2;
}

- (NSInteger)numberOfTabs
{
    return self.startViewControllers.count;
}

- (CGFloat) canvasWidthForPositioning {
    CGFloat canvasWidthForPositioning = IS_IPAD ? (self.carouselCanvasView.frame.size.width - [self pagePadding] * 2) : (self.carouselCanvasView.frame.size.width );
    return canvasWidthForPositioning;
}

- (void)prepareCarouselTabs
{
    self.carouselCanvasView.translatesAutoresizingMaskIntoConstraints = NO;
    self.canvasWidthConstraint.constant =  IS_IPAD ? ([self numberOfTabs] * kPageWidthIPad + [self pagePadding] * 2) : ([self  numberOfTabs] * self.view.frame.size.width);
    // initialize tabs
    for (int i = 0; i < [self numberOfTabs]; i++ ){
        UIViewController *tab = [self.startViewControllers objectAtIndex:i];
        CarouselTabNavigationController *tabNavigationController = [[CarouselTabNavigationController alloc] initWithRootViewController:tab andTabButtonIndex:i];
        [self.carouselTabs addObject:tabNavigationController];
        [self addTab:tabNavigationController toCanvasViewOnNumber:i];
        if (i == 0) {
            tabNavigationController.heightConstraint.constant  = [self normalTabHeight];
            tabNavigationController.widthConstraint.constant  = [self normalTabWidth];
            tabNavigationController.xPositionConstraint.constant = (IS_IPAD ? [self pagePadding] : kTabPadding);
            tabNavigationController.yPositionConstraint.constant =  kSpaceFromTop;
            [tabNavigationController.view.layer setTransform:CATransform3DMakeScale(1 , 1, 1.0)];
        }
    }
    if (IS_IPAD && [self numberOfTabs] > 1) {
        [[[self.carouselTabs objectAtIndex:1] tab].view addGestureRecognizer:self.tapOnNextTab];
    }
}

- (void)layoutTabButtons
{
    // initialize tab buttons
    CGFloat fullWidthOfTabBar = [self numberOfTabs] * [self tabButtonWidth];
    CGFloat horizontalOffsetFromStart = 0;
    if (fullWidthOfTabBar > self.tabButtonScrollView.frame.size.width) {
        self.tabBarWidth.constant = fullWidthOfTabBar;
    } else {
        horizontalOffsetFromStart = (self.tabButtonScrollView.frame.size.width - fullWidthOfTabBar) / 2;
    }
    for (int i = 0; i < [self numberOfTabs]; i++) {
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tabButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [tabButton setFrame:CGRectMake(0, 0, [self tabButtonWidth], self.tabButtonsContainer.frame.size.height)];
        if (self.tabButtonTitles) {
            [tabButton setTitle:[self.tabButtonTitles objectAtIndex:i] forState:UIControlStateNormal];
            tabButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [tabButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [tabButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            
        }
        else if (self.tabButtonImages) {
            [tabButton setImage:[self.tabButtonImages objectAtIndex:i] forState:UIControlStateNormal];
        }
        [self.tabButtonsContainer addSubview:tabButton];
        [self.tabButtons addObject:tabButton];
        [tabButton addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [tabButton setFrame:CGRectMake(i * [self tabButtonWidth] + horizontalOffsetFromStart, 0, tabButton.frame.size.width, tabButton.frame.size.height)];
        if (index == 0) {
            [tabButton setEnabled:NO]; // disabling the first tab button (selecting it
        }
    }
    [self.tabButtonScrollView layoutIfNeeded];
}

- (void)addTab:(CarouselTabNavigationController*)tab toCanvasViewOnNumber:(NSInteger)tabNumber
{
    UIView *tabView = tab.view;
    [tabView setClipsToBounds:NO];
    tabView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.carouselCanvasView addSubview:tabView];

    CGFloat pageWidth = [self pageWidth];
    CGFloat tabPositionX = tabNumber * pageWidth + [self pagePadding];
    // set width / height / position
    tab.xPositionConstraint =[NSLayoutConstraint constraintWithItem:tabView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationLessThanOrEqual
                                                             toItem:self.carouselCanvasView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:tabPositionX  + (kScaleFactorInterval/2) * [self normalTabWidth]];

    tab.yPositionConstraint = [NSLayoutConstraint constraintWithItem:tabView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationLessThanOrEqual
                                                              toItem:self.carouselCanvasView
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0
                                                            constant:kSpaceFromTop + (kScaleFactorInterval/2) * [self normalTabHeight]];

    tab.heightConstraint = [NSLayoutConstraint constraintWithItem:tabView attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:0
                                                         constant:[self normalTabHeight]];

    tab.widthConstraint = [NSLayoutConstraint constraintWithItem:tabView
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0
                                                        constant:[self normalTabWidth]];

    [self.carouselCanvasView addConstraints:@[tab.xPositionConstraint,tab.yPositionConstraint]];
    [tabView addConstraints: @[tab.heightConstraint,tab.widthConstraint]];
    [tabView.layer setTransform:CATransform3DMakeScale(kSmallTabScale , kSmallTabScale, 1.0)];
}

- (void)resetCardConstraints
{
    float pageWidth = [self pageWidth];
    for (int page = 0; page < [self numberOfTabs]; page++) {
        float cardXCenterPosition = page * pageWidth  + [self pagePadding];
        CarouselTabNavigationController *tab = [self.carouselTabs objectAtIndex:page];
        tab.xPositionConstraint.constant = cardXCenterPosition  + (kScaleFactorInterval/2) * [self normalTabWidth];
        tab.yPositionConstraint.constant = kSpaceFromTop + (kScaleFactorInterval/2) * [self normalTabHeight];
    }
}

#pragma mark - scrollView methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = [self pageWidth];
    int previousPage = scrollView.contentOffset.x / pageWidth;
    int nextPageInFocus = (scrollView.contentOffset.x + pageWidth / 2)  / pageWidth;
    int nextPageForAnimationFocus = (scrollView.contentOffset.x + pageWidth)  / pageWidth;
    CGFloat currentXOffset = scrollView.contentOffset.x;
    
    if (nextPageForAnimationFocus > previousPage) {
        // INFINITE CAROUSEL SCROLL
if (nextPageInFocus > previousPage && [self numberOfTabs] >= 3){
    CGPoint offsetPoint = scrollView.contentOffset;
    if (nextPageInFocus == self.carouselTabs.count - 1 && self.previousContentOffset.x < currentXOffset){
        CarouselTabNavigationController *firstTab = [self.carouselTabs firstObject];
        [self.carouselTabs removeObjectAtIndex:0];
        [self.carouselTabs addObject:firstTab];
        [firstTab.view.layer setTransform:CATransform3DMakeScale(kSmallTabScale , kSmallTabScale, 1.0)];
        previousPage -= 1;
        nextPageInFocus -= 1;
        nextPageForAnimationFocus -= 1;
        offsetPoint = CGPointMake(currentXOffset - pageWidth, scrollView.contentOffset.y);
        
    } else if ( nextPageInFocus == 1 && self.previousContentOffset.x > currentXOffset){
        CarouselTabNavigationController *lastTab = [self.carouselTabs lastObject];
        [self.carouselTabs removeLastObject];
        [self.carouselTabs insertObject:lastTab atIndex:0];
        [lastTab.view.layer setTransform:CATransform3DMakeScale(kSmallTabScale , kSmallTabScale, 1.0)];
        previousPage += 1;
        nextPageInFocus += 1;
        nextPageForAnimationFocus += 1;
        offsetPoint = CGPointMake(currentXOffset + pageWidth, scrollView.contentOffset.y);

    }
    CGRect scrollBounds = scrollView.bounds;
    scrollBounds.origin = offsetPoint;
    scrollView.bounds = scrollBounds;
    [self resetCardConstraints];

}
        // ANIMATION
        self.previousContentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
        CGFloat previousCardCenter = (previousPage * pageWidth);
        CGFloat nextCardCenter = (nextPageForAnimationFocus * pageWidth) + pageWidth;
        CGFloat contentOffsetx = scrollView.contentOffset.x + pageWidth;
        CGFloat scaleFactor = [self calculateScaleFactorForContentOffset:contentOffsetx previousCardPosition:previousCardCenter andNextCardPosition:nextCardCenter];
        
        CarouselTabNavigationController* tab = [self.carouselTabs objectAtIndex:previousPage];
        CGFloat tabXPosition = previousPage * pageWidth  + [self pagePadding];
        tab.xPositionConstraint.constant  = tabXPosition  + ((kScaleFactorInterval - scaleFactor)/2) * [self normalTabWidth];
        tab.yPositionConstraint.constant  = kSpaceFromTop + ((kScaleFactorInterval - scaleFactor)/2) * [self normalTabHeight];
        [tab.view.layer setTransform:CATransform3DMakeScale((kSmallTabScale + scaleFactor), (kSmallTabScale + scaleFactor), 1.0)];
        
        if (nextPageForAnimationFocus < self.carouselTabs.count ){
            CarouselTabNavigationController* nextTab = [self.carouselTabs objectAtIndex:nextPageForAnimationFocus];
            CGFloat nextTabXPosition = nextPageForAnimationFocus * pageWidth  + [self pagePadding];
            nextTab.xPositionConstraint.constant  = nextTabXPosition  + (scaleFactor/2) * [self normalTabWidth];
            nextTab.yPositionConstraint.constant  = kSpaceFromTop + (scaleFactor/2) * [self normalTabHeight];
            [nextTab.view.layer setTransform:CATransform3DMakeScale(kSmallTabScale +(kScaleFactorInterval - scaleFactor), kSmallTabScale + (kScaleFactorInterval - scaleFactor), 1.0)];
        }
    }  
}



// CUSTOM PAGING FOR IPAD
- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (IS_IPAD) {
        float pageWidth = [self pageWidth];
        int page = targetContentOffset->x / pageWidth;
        if (targetContentOffset->x > self.previousContentOffset.x){
            page = (targetContentOffset->x + pageWidth * 3 / 4)  / pageWidth; // RIGHT SWIPE
        } else {
            page = (targetContentOffset->x + pageWidth / 4)  / pageWidth; // LEFT SWIPE
        }
        targetContentOffset->x = [self canvasWidthForPositioning] * page / [self numberOfTabs];
        [self.carouselScrollView setContentOffset:CGPointMake(targetContentOffset->x , 0) animated:YES]; // forcing it to start scrolling after dragging
    }
}


- (int) pageNumberInFocus
{
    int page = (self.carouselScrollView.contentOffset.x + [self pageWidth]/2)  / [self pageWidth];
    return page;
}


- (void) adjustButtonImages
{
    CarouselTabNavigationController *tab = [self.carouselTabs objectAtIndex:[self pageNumberInFocus]];
    for (UIButton *tabButton in self.tabButtons) {
        [tabButton setEnabled:YES];
    }
    [[self.tabButtons objectAtIndex:tab.tabButtonIndex] setEnabled:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!IS_IPAD) {
        [self adjustButtonImages];
    }
    float offsetX = [self canvasWidthForPositioning] * [self pageNumberInFocus] / [self numberOfTabs];
    [self.carouselScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

// TAP GESTURES FOR IPAD DASH
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self adjustButtonImages];
    [self.view setUserInteractionEnabled:YES];
    if (IS_IPAD) {
        int page = [self pageNumberInFocus];
        UIViewController *currentTab = [[self.carouselTabs objectAtIndex:page] tab];
        [currentTab.view removeGestureRecognizer:self.tapOnNextTab];
        [currentTab.view removeGestureRecognizer:self.tapOnPreviousTab];
        
        if (page + 1 < self.carouselTabs.count) {
            UIViewController *nextTab = [[self.carouselTabs objectAtIndex:page + 1] tab];
            [nextTab.view addGestureRecognizer:self.tapOnNextTab];
        }
        if (page - 1 >= 0) {
            UIViewController *previous = [[self.carouselTabs objectAtIndex:page - 1] tab];
            [previous.view addGestureRecognizer:self.tapOnPreviousTab];
        }
    }
}


- (void)tappedOnNext
{
    [self.view setUserInteractionEnabled:NO];
    int page = [self pageNumberInFocus] + 1;
    float offsetX = [self canvasWidthForPositioning] * page / [self numberOfTabs];
    [self.carouselScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)tappedOnPrevious
{
    [self.view setUserInteractionEnabled:NO];
    int page = [self pageNumberInFocus] - 1;
    float offsetX = [self canvasWidthForPositioning] * page / [self numberOfTabs];
    [self.carouselScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}



- (IBAction)tabButtonTapped:(id)sender
{
    UIButton *tapped = (UIButton*)sender;
    float offsetX = self.carouselScrollView.contentOffset.x;
    int buttonIndex = [self.tabButtons indexOfObject:tapped];
    for (int index = 0; index < self.carouselTabs.count; index++){
        if (buttonIndex == [[self.carouselTabs objectAtIndex:index] tabButtonIndex]){
            offsetX = ([self canvasWidthForPositioning] * index) / [self numberOfTabs];
            break;
        }
    }
    [self.carouselScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

#pragma mark - animation helper
// non linear scaling function
- (CGFloat)calculateScaleFactorForContentOffset:(CGFloat) offset previousCardPosition: (CGFloat)previousCenter andNextCardPosition:(CGFloat) nextCenter
{
    CGFloat xValue =  (offset - previousCenter) / (nextCenter - previousCenter + 0.000001);
    CGFloat scale =  xValue * xValue * (xValue - 1) * (xValue - 1) * 4.8 ;
    return scale;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
