//
//  ViewController.m
//  CarouselTabs
//
//  Created by Igor Lipovac on 02/07/14.
//  Copyright (c) 2014 Igor Lipovac. All rights reserved.
//

#import "StartViewController.h"
#import "CarouselTabsViewController.h"
#import "SimpleTabViewController.h"

@interface StartViewController ()
@property CarouselTabsViewController *carousel;
@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Carousel Tabs Example";
    NSMutableArray *arrayOfSimpleControllers = [NSMutableArray array];
    NSMutableArray *arrayOfTabTitles = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        SimpleTabViewController* stvc = [[SimpleTabViewController alloc] init];
        stvc.tabIndex = i;
        stvc.controllerLevel = 0;
        [arrayOfSimpleControllers addObject:stvc];
        [arrayOfTabTitles addObject:[NSString stringWithFormat:@"%d",i + 1]];
    }
    self.carousel = [[CarouselTabsViewController alloc] initWithCarouselTabViewControllers:arrayOfSimpleControllers andTabButtonTitles:arrayOfTabTitles];
    [self.view addSubview:self.carousel.view];
    [self.carousel.view setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
