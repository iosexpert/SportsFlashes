//
//  loginViewController.h
//  SportsFlashes
//
//  Created by Apple on 18/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/SignIn.h>

@interface loginViewController : UIViewController<GIDSignInUIDelegate>


@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;

-(IBAction)facebookLogin:(UIButton*)sender;
-(IBAction)googleLogin:(UIButton*)sender;
@end
