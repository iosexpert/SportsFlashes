//
//  landingViewController.h
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "newsTableViewCell.h"
#import "YTPlayerView.h"
#import "AppsFlyerTracker.h"


@interface landingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,YTPlayerViewDelegate,AppsFlyerTrackerDelegate>
{
    IBOutlet UIView *topStatusBar;
    IBOutlet UIActivityIndicatorView *loaderView;
    IBOutlet UIView *navigationBar;
    IBOutlet UITableView *mainTable;
    IBOutlet UILabel *unreadViewLbl;

    IBOutlet UIView *videoView;
    
    IBOutlet UIScrollView *liveScrollView;
    
    IBOutlet UIButton *closeVideoButton;
    IBOutlet UIWebView *webv;
}
@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@end
