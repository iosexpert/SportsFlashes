//
//  loginViewController.m
//  SportsFlashes
//
//  Created by Apple on 18/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "loginViewController.h"


@interface loginViewController ()

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GIDSignIn sharedInstance].uiDelegate = self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)googleLogin:(UIButton*)sender{
    [[GIDSignIn sharedInstance] signIn];

}
-(IBAction)facebookLogin:(UIButton*)sender
{
    //[[GIDSignIn sharedInstance] signOut];
    
 
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email,gender" forKey:@"fields"];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile",@"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             
         } else if (result.isCancelled) {
             
             NSLog(@"Cancelled");
         } else {
             
             NSLog(@"Logged in%@",result.grantedPermissions);
             if ([result.grantedPermissions containsObject:@"email"]) {
                 // Do work
                 //[self getDetailsAndLogin];
                 if ([FBSDKAccessToken currentAccessToken]) {
                     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                          if (!error) {
                              NSLog(@"fetched user:%@", result);
                          }
                      }];
                 }
             }
         }
     }];
}
-(void)getDetailsAndLogin{


    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSString *userID = [[FBSDKAccessToken currentAccessToken] userID];
             NSString *userName = [result valueForKey:@"name"];
             NSString *email =  [result valueForKey:@"email"];
             NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[FBSDKAccessToken currentAccessToken] userID]];
             NSLog(@"Logged in%@,%@,%@,%@,%@",result,userID,userName,email,userImageURL);
            }
         else{
             NSLog(@"%@",error.localizedDescription);
         }
     }];
    
}
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    //[myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
