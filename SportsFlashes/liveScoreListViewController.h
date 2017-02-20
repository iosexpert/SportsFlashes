//
//  liveScoreListViewController.h
//  SportsFlashes
//
//  Created by Apple on 20/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;

@interface liveScoreListViewController : UIViewController
{
    IBOutlet UITableView *liveTable;
    IBOutlet UILabel *headingLable;
    
}

@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;

-(IBAction)backAction:(id)sender;
-(IBAction)refreshAction:(id)sender;
@end
