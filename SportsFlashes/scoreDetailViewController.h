//
//  scoreDetailViewController.h
//  SportsFlashes
//
//  Created by Apple on 20/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "scoreTableViewCell.h"
@import GoogleMobileAds;

@interface scoreDetailViewController : UIViewController
{
    IBOutlet UILabel *batR;
    IBOutlet UILabel *batB;
    IBOutlet UILabel *bat4s;
    IBOutlet UILabel *bat6s;
    IBOutlet UILabel *batSR;
    
    IBOutlet UILabel *bat1name;
    IBOutlet UILabel *bat2name;
    
    
    IBOutlet UILabel *batR1;
    IBOutlet UILabel *batB1;
    IBOutlet UILabel *bat4s1;
    IBOutlet UILabel *bat6s1;
    IBOutlet UILabel *batSR1;
    
    IBOutlet UILabel *bowl1name;
    IBOutlet UILabel *bowl2name;
    
    
    
    IBOutlet UILabel *bowlO;
    IBOutlet UILabel *bowlM;
    IBOutlet UILabel *bowlR;
    IBOutlet UILabel *bowlW;
    IBOutlet UILabel *bowlECO;
    
    IBOutlet UILabel *bowlO1;
    IBOutlet UILabel *bowlM1;
    IBOutlet UILabel *bowlR1;
    IBOutlet UILabel *bowlW1;
    IBOutlet UILabel *bowlECO1;
    
    
    IBOutlet UILabel *headingLabel;
    IBOutlet UILabel *summaryLabel;
    IBOutlet UILabel *curentPlayingbat;
    IBOutlet UILabel *curentPlayingbowl;
    IBOutlet UILabel *curentRunRate;
    
    
    IBOutlet UILabel *recentOver;
    IBOutlet UILabel *manOfTheMatch;
    IBOutlet UILabel *partnership;
    IBOutlet UILabel *oversLeft;

    IBOutlet UIView *manOfMatchView;
    IBOutlet UIView *lastWicketView;
    
    IBOutlet UITextView *matchStartIn;
    IBOutlet UITextView *comentary;
    IBOutlet UITextView *error_summary;
    IBOutlet UITextView *error_previewLBL;
   IBOutlet UIView *errorView;
    
    
    IBOutlet UITableView *commentryTable;
    
    
    IBOutlet UILabel *battingLabel;
    IBOutlet UILabel *bowlingLabel;
    
    IBOutlet UIScrollView *scrv;
}
@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;

-(IBAction)backAction:(id)sender;
-(IBAction)sharingAction:(UIButton*)sender;

-(IBAction)batScoreBoardAction:(id)sender;
-(IBAction)bowlScoreBoardAction:(id)sender;
@end
