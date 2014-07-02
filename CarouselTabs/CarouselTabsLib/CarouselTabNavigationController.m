//
//  CarouselTabNavigationController.m
//  CarouselTabs
//
//  Created by Igor Lipovac on 01/07/14.
//  Copyright (c) 2014 Igor Lipovac. All rights reserved.
//

#import "CarouselTabNavigationController.h"

@interface CarouselTabNavigationController ()

@property (nonatomic, assign) NSInteger tabButtonIndex;

@end

@implementation CarouselTabNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController andTabButtonIndex:(NSInteger) tabButtonIndex
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.tabButtonIndex = tabButtonIndex;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tabButtonIndex {
    return _tabButtonIndex;
}

- (UIViewController *)tab {
    return self.topViewController;
}

@end
