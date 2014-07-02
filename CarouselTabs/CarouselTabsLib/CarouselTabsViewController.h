//
//  CarouselTabsViewController.h
//  CarouselTabs
//
//  Created by Igor Lipovac on 01/07/14.
//  Copyright (c) 2014 Igor Lipovac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarouselTabsViewController : UIViewController <UIScrollViewDelegate>

- (id)initWithCarouselTabViewControllers:(NSArray*)tabViewControllers andTabButtonImages:(NSArray*)tabButtonImages;

- (id)initWithCarouselTabViewControllers:(NSArray*)tabViewControllers andTabButtonTitles:(NSArray*)tabButtonTitles;

@end
