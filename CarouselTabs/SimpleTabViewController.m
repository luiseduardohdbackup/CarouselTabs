//
//  SimpleTabViewController.m
//  CarouselTabs
//
//  Created by Igor Lipovac on 02/07/14.
//  Copyright (c) 2014 Igor Lipovac. All rights reserved.
//

#import "SimpleTabViewController.h"

@interface SimpleTabViewController ()
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIButton *pushButton;
@end

@implementation SimpleTabViewController

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
    self.title = [NSString stringWithFormat:@"This is tab %d", self.tabIndex + 1];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Pop" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    if (self.controllerLevel == 3) {
        self.view.backgroundColor = [UIColor redColor];
        self.pushButton.hidden = YES;
    } else if (self.controllerLevel == 2) {
        self.view.backgroundColor = [UIColor yellowColor];
    } else if (self.controllerLevel == 1) {
        self.view.backgroundColor = [UIColor greenColor];
    } else if (self.controllerLevel == 0) {
        self.view.backgroundColor = [UIColor blueColor];
    }
    self.levelLabel.text = [NSString stringWithFormat:@"This controller is on level %d",self.controllerLevel];
}

- (IBAction)pushAnotherController:(id)sender {
    SimpleTabViewController *newViewController = [[SimpleTabViewController alloc] init];
    newViewController.tabIndex = self.tabIndex;
    newViewController.controllerLevel = self.controllerLevel + 1;
    [self.navigationController pushViewController:newViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
