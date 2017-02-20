//
//  slideMenuViewController.h
//  MYScores
//
//  Created by Apple on 02/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface slideMenuViewController : UIViewController<UIActionSheetDelegate>
{
    IBOutlet UIView *topStatusBar;
    IBOutlet UIButton *languageBtn;
    IBOutlet UIButton *categoryBtn;
    IBOutlet UITableView *catTableView;
    IBOutlet UIButton *inviteButton;
    IBOutlet UIButton *rateButton;
    
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *changeMyFeedButton;
    
    IBOutlet UIScrollView *scrv;
    
    
    IBOutlet UIView *myFeedView;
    IBOutlet UITableView *myFeedTable;


IBOutlet UISearchBar *searchbar;
}


@end
