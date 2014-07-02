//
//  CarouselTabNavigationController.h
//  CarouselTabs
//
//  Created by Igor Lipovac on 01/07/14.
//  Copyright (c) 2014 Igor Lipovac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarouselTabNavigationController : UINavigationController

@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *xPositionConstraint;
@property (nonatomic, strong) NSLayoutConstraint *yPositionConstraint;

// topmost viewController
- (UIViewController*)tab;
// index of a tab button pointing to this specific tab
- (NSInteger)tabButtonIndex;

- (id)initWithRootViewController:(UIViewController *)rootViewController andTabButtonIndex:(NSInteger)tabButtonIndex;

@end
