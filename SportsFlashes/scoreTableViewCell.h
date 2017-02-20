//
//  scoreTableViewCell.h
//  SportsFlashes
//
//  Created by Apple on 20/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface scoreTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel    *overs;
@property(weak, nonatomic) IBOutlet UILabel    *bowledTo;
@property(weak, nonatomic) IBOutlet UILabel    *runs;
@property(weak, nonatomic) IBOutlet UILabel    *ballSpeed;
@property(weak, nonatomic) IBOutlet UITextView *platedTo;


@end
