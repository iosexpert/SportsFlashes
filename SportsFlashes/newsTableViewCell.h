//
//  newsTableViewCell.h
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface newsTableViewCell : UITableViewCell

@property(nonatomic,retain)IBOutlet AsyncImageView *mainImage1;
@property(nonatomic,retain)IBOutlet AsyncImageView *mainImage;
@property(nonatomic,retain)IBOutlet AsyncImageView *bigImagePost;
@property(nonatomic,retain)IBOutlet UIButton *shareButton;
@property(nonatomic,retain)IBOutlet UIButton *fbShareButton;
@property(nonatomic,retain)IBOutlet UIButton *likeButton;
@property(nonatomic,retain)IBOutlet UIButton *moreLinkButton;
@property(nonatomic,retain)IBOutlet UIButton *playButton;

@property(nonatomic,retain)IBOutlet UILabel *hashLable;
@property(nonatomic,retain)IBOutlet UILabel *headingLable;
@property(nonatomic,retain)IBOutlet UITextView *desciptionLable;
@property(nonatomic,retain)IBOutlet UILabel *newsByLable;



@property(nonatomic,retain)IBOutlet UIView *survayView;
@property(nonatomic,retain)IBOutlet UILabel *survayTitle;
@property(nonatomic,retain)IBOutlet UITextView *survaySelectedOptions;
@property(nonatomic,retain)IBOutlet UITextField *selectFeild;
@property(nonatomic,retain)IBOutlet UIButton *submitButton;
@end
