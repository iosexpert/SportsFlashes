//
//  ScoreBoardViewController.h
//  SportsFlashes
//
//  Created by Apple on 02/11/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;


@interface ScoreBoardViewController : UIViewController
{
    IBOutlet UIScrollView *scrv;
    
    IBOutlet UILabel *headingLabel;
    IBOutlet UILabel *summaryLabel;
    
    
}
@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;

-(IBAction)sharingAction:(UIButton*)sender;
-(IBAction)backAction:(id)sender;
@end
