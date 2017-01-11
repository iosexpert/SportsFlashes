//
//  slideMenuViewController.m
//  MYScores
//
//  Created by Apple on 02/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "slideMenuViewController.h"

@interface slideMenuViewController ()

@end

@implementation slideMenuViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
