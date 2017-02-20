//
//  ViewController.h
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
   IBOutlet UIImageView *animationImageViw;
    IBOutlet UISegmentedControl *sgmtCtrl;
    IBOutlet UIView *langSelectorView;
    IBOutlet UIButton *submitBtn;
    IBOutlet UIPickerView *pickView;
}
-(IBAction)submitAction:(id)sender;
@end

