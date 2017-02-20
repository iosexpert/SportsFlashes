 //
//  landingViewController.m
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "landingViewController.h"
#import "NVSlideMenuController.h"

#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "AsyncImageView.h"
#import "AppDelegate.h"


#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKSharingContent.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "MBProgressHUD.h"
#import <Google/Analytics.h>
#import "liveScoreListViewController.h"
#define SITEURL @"http://sportsflashes.com"
#import "liveScoreCategoryView.h"
#import "scoreDetailViewController.h"
#import "footballMatchScoreView.h"
#import "AppsFlyerTracker.h"

@interface landingViewController ()
{
    NSMutableArray *newsArr,*stripData;
    NSTimer *navHideTimer,*stripTimer;
    NSString *selectedLang;
    NSMutableArray *engNews,*hindiNews,*tableData;
    NSMutableDictionary *fullNews;
    SLComposeViewController *fbSLComposeViewController;
    int count,counterNewsSeen;
    NSString *cat_id,*selectedString,*selectedIdString;
    UIRefreshControl *refeshControl;
    UITableView *tableViewSelect;
    NSManagedObject *managedObject;
    NSManagedObjectContext *managedObjectContext;
    MBProgressHUD *HUD;
    UITapGestureRecognizer *hideShowNavigation;
    AsyncImageView *bigimg;
    SLComposeViewController *slComposer;
    
    int refreshView,readCount;
    
    NSTimer *newsSeenTimer;
    
    NSString *oldID;
    int limit,scrollPossition,tablePossition;
    
    UIView *survayTableView;
    
    BOOL iphone4,iphone5,iphone6,iphone6P,ipad,ipad2;
    
    
    UIView *updateView;
    UIButton *updateButton;
    
    NSString *trackId;
    AsyncImageView *addImage1;
    UIButton *addImageButton;
    
    NSTimer *counterTimer,*topStripTimer;
    int viewShow;
    int counter;
}
@end

@implementation landingViewController
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)refresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    counterNewsSeen=0;
    
    [self allNewsAcordingToCategoryServerHit];
    
}
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

-(void)viewWillAppear:(BOOL)animated
{
    if([Utilities CheckInternetConnection])//0: internet working
        topStripTimer= [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getTopStripUpdate)userInfo:nil repeats:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
   
    

    
    
    
    
   
    
    
    
    
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"VRxCSFT9bSyT6T8zBHqaT6";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1126803446";
    [AppsFlyerTracker sharedTracker].delegate = self;
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    
    
    selectedIdString=@"";
    selectedString=@"";
    limit =10;
    viewShow=1;
    int height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480)
    {
        iphone4=YES;
    }
    else if (height == 568)
    {
        iphone5=YES;
    }
    else if (height == 667)
    {
        iphone6=YES;
    }
    else if (height == 736)
    {
        iphone6P=YES;
    }
    else if (height == 1024)
    {
        ipad=YES;
    }
    else
    {
        ipad2=YES;
    }
    
    
    [self restrictRotation:YES];
    
    oldID=0;
    loaderView.hidden=YES;
    
    //refeshControl = [[UIRefreshControl alloc] init];
    //[refeshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    //[mainTable addSubview:refeshControl];
    
    videoView.hidden=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchnews) name:@"search" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"langChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNewsAcordingToCategory:) name:@"catSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationApiCall) name:@"notification" object:nil];
    
    
    navigationBar.hidden=YES;
    unreadViewLbl.hidden=YES;
    
    
    
    
    
    hideShowNavigation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideShowNavigationAction:)];
    [self.view addGestureRecognizer:hideShowNavigation];
    
    self.navigationController.navigationBarHidden=YES;
    topStatusBar.backgroundColor=[UIColor colorWithRed:83.0/255.0 green:107.0/255.0 blue:119.0/255.0 alpha:1.0];
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    
    //[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(CheckForUpdateApp)userInfo:nil repeats:NO];
    
   counterTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autoCounter)userInfo:nil repeats:YES];


    [self getTopStripUpdate];
    

    if(appDelegate.notification)
    {
        [self notificationApiCall];
    }
    if(!appDelegate.notification)
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        selectedLang=[u objectForKey:@"lang"];
        NSMutableArray *arr=[[u objectForKey:@"oflineNews"]mutableCopy];
        if(arr.count==0 || arr == nil)
        {
            [self firstTimeCall];
        }
        else
        {
            engNews=[arr mutableCopy];
            
            
            
            NSArray *keyyy=[engNews valueForKey:@"id"];
            NSArray *uniquearray = [[NSSet setWithArray:keyyy] allObjects];
            NSMutableArray *t=[uniquearray mutableCopy];
            
            
            NSMutableArray *temp1=[NSMutableArray new];;
            for(int i=0;i<=engNews.count;i++)
            {
                if(t.count>0)
                {
                    if([t containsObject:[engNews[i] valueForKey:@"id"]])
                    {
                        [temp1 addObject:engNews[i]];
                        [t removeObjectAtIndex:[t indexOfObject:[engNews[i] valueForKey:@"id"]]];
                    }
                }
            }
            
            
            
            
            
            
            int n = (int)temp1.count;
            
            
            NSMutableArray *temp = [NSMutableArray new];
            for(int i=n-1; i >= 0; i--){
                for(int j=1; j <=i ; j++){
                    if([[temp1[j-1]valueForKey:@"id"]intValue]   < [[temp1[j]valueForKey:@"id"]intValue]){
                        [temp addObject:temp1[j-1]];
                        [temp1 replaceObjectAtIndex:j-1 withObject:temp1[j]];
                        [temp1 replaceObjectAtIndex:j withObject:[temp lastObject]];
                        [temp removeLastObject];
                    }
                    
                }
            }
            engNews=[temp1 mutableCopy];
            [temp1 removeAllObjects];
            
            
            if([Utilities CheckInternetConnection])//0: internet working
                [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getCategoriesAndNews:)userInfo:nil repeats:NO];
            [mainTable reloadData];
            
        }
    }
    
  
}
-(void)autoCounter
{
    counter=counter+1;
    if(counter>=180)
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        [self trackEvent:AFEventLevelAchieved withValues:@{@"Event_Name": @"3minute", @"UserID" : email}];

        
            id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
            [tracker set:kGAIEvent value:[NSString stringWithFormat:@"Event_Name-3minute, UserID-%@",email]];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
    }
    if(counter>=300)
    {
        [counterTimer invalidate];
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        [self trackEvent:AFEventLevelAchieved withValues:@{@"Event_Name": @"5minute", @"UserID" : email}];
        counter=0;
        
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        [tracker set:kGAIEvent value:[NSString stringWithFormat:@"Event_Name-5minute, UserID-%@",email]];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
    }
    
   
}
-(void)trackEvent:(NSString *)eventName withValues:(NSDictionary*)values
{
    [[AppsFlyerTracker sharedTracker] trackEvent: @"3MinuteUse" withValues:values ];// @{@"Event_Name": @30, @"UserID" : email}];
}
-(void)CheckForUpdateApp
{
    if([Utilities CheckInternetConnection]){
        BOOL up=[self needsUpdate];
        NSLog(@"%d",up);
        if(up){
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please Update" message:@"Please Update App To Get the Best Experience." preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Update Now" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self launchAppStore];
            }]];
            
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self closeAlertview];
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:alertController animated:YES completion:nil];
            });
            
            
        }
    }
    
}
-(void)closeAlertview
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)getTopStripUpdate
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request;
        request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/cric_live_mini_score?ln=%@",lang] parameters:nil];
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil)
            {
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    stripData=[JSON mutableCopy];
                    [self setDataOnTopStrip:JSON];
                }
                //NSLog(@"Network-Response: %@", JSON);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
    
}
-(void)stripeMove
{
    if(liveScrollView.contentOffset.x<liveScrollView.contentSize.width-self.view.frame.size.width)
        [liveScrollView setContentOffset:CGPointMake(liveScrollView.contentOffset.x+self.view.frame.size.width,0) animated:YES];
    else
        [liveScrollView setContentOffset:CGPointMake(0,0) animated:NO];
    
}
-(void)setDataOnTopStrip:(NSMutableDictionary*)dataArr
{
    
   // NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    //NSMutableArray *catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
    /// NSArray *labels=[[catArr valueForKey:@"labels"]mutableCopy];
    
    
    for(UIView *subview in [liveScrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    [stripTimer invalidate];
    stripTimer= [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(stripeMove)userInfo:nil repeats:YES];
    
    
    
    // NSLog(@"%@",dataArr);
    int x=0;
    //    NSString *st=@"";
    //    if([[labels valueForKey:@"livescore"][0] length]==0)
    //        st=@"Live Score";
    //    else
    //        st=[labels valueForKey:@"livescore"][0];
    
    
    int space=0;
    for(int i=0;i<[[dataArr valueForKey:@"cricket"] count];i++)
    {
        
        //        if([[dataArr valueForKey:@"add_status"]intValue]==1 && x!=0)
        //        {
        //            x=x+self.view.frame.size.width;
        //            space=1;
        //            AsyncImageView *addImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
        //            addImage.imageURL=[NSURL URLWithString:[dataArr valueForKey:@"add_img_path"]];
        //            addImage.tag=10000+i;
        //            addImage.contentMode=UIViewContentModeScaleToFill;
        //            addImage.clipsToBounds=YES;
        //            addImage.backgroundColor=[UIColor clearColor];
        //            [liveScrollView addSubview:addImage];
        //
        //
        //            UIButton *addImageButtonmn =  [UIButton buttonWithType:UIButtonTypeCustom];
        //            addImageButtonmn.tag=90000+i;
        //            [addImageButtonmn addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
        //            [addImageButtonmn setFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
        //            [addImageButtonmn setExclusiveTouch:YES];
        //            addImageButtonmn.backgroundColor=[UIColor clearColor];
        //            [liveScrollView addSubview:addImageButtonmn];
        //
        //
        //        }
        
        if(self.view.frame.size.width==320)
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame = CGRectMake (x+7, 0, 43, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            
            [label setText:[dataArr valueForKey:@"cricket_label"]];//@"Live Scores"];
            [liveScrollView addSubview:label];
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+53, 2, 40, 40)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_flag"]];
            leftImage.tag=30000+i;
            leftImage.layer.cornerRadius=20.0;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+233, 2, 40, 40)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_flag"]];
            rightImage.tag=30000+i;
            rightImage.layer.cornerRadius=20.0;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            
            
            
            
            UIFont * myFont11 = [UIFont fontWithName:@"GillSans-Bold" size:11];
            UILabel *downLbl1 = [[UILabel alloc] initWithFrame:CGRectMake (x+37, 40, 71, 15)];
            [downLbl1 setFont:myFont11];
            downLbl1.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl1.numberOfLines=2;
            downLbl1.textColor=[UIColor whiteColor];
            downLbl1.textAlignment=NSTextAlignmentCenter;
            downLbl1.backgroundColor=[UIColor clearColor];
            [downLbl1 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_name"]];
            [liveScrollView addSubview:downLbl1];
            
            
            UILabel *downLbl2 = [[UILabel alloc] initWithFrame:CGRectMake (x+220, 40, 70, 15)];
            [downLbl2 setFont:myFont11];
            downLbl2.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl2.numberOfLines=2;
            downLbl2.textColor=[UIColor whiteColor];
            downLbl2.textAlignment=NSTextAlignmentCenter;
            downLbl2.backgroundColor=[UIColor clearColor];
            [downLbl2 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_name"]];
            [liveScrollView addSubview:downLbl2];
            
            
            
            
            UIFont * myFont12 = [UIFont fontWithName:@"GillSans-Bold" size:9];
            CGRect labelFrame12 = CGRectMake (x+93, 0, 140, 15);
            UILabel *statusLbl = [[UILabel alloc] initWithFrame:labelFrame12];
            [statusLbl setFont:myFont12];
            statusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            statusLbl.numberOfLines=1;
            statusLbl.textColor=[UIColor whiteColor];
            statusLbl.textAlignment=NSTextAlignmentCenter;
            statusLbl.backgroundColor=[UIColor clearColor];
            [statusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"top_status"]];
            [liveScrollView addSubview:statusLbl];
            
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:10];
            CGRect labelFrame1 = CGRectMake (x+93, 15, 140, 20);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"title"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            UIFont * myFont123 = [UIFont fontWithName:@"GillSans-Bold" size:9];
            CGRect labelFrame123 = CGRectMake (x+105, 35, 115, 15);
            UILabel *downstatusLbl = [[UILabel alloc] initWithFrame:labelFrame123];
            [downstatusLbl setFont:myFont123];
            downstatusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            downstatusLbl.numberOfLines=1;
            downstatusLbl.textColor=[UIColor whiteColor];
            downstatusLbl.textAlignment=NSTextAlignmentCenter;
            downstatusLbl.backgroundColor=[UIColor clearColor];
            [downstatusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"m_status"]];
            [liveScrollView addSubview:downstatusLbl];
            
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=30000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+125, 0, 110, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        else if(self.view.frame.size.width==375)
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame = CGRectMake (x+7, 0, 48, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            
            [label setText:[dataArr valueForKey:@"cricket_label"]];//@"Live Scores"];
            [liveScrollView addSubview:label];
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+55, 2, 40, 40)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_flag"]];
            leftImage.tag=10000+i;
            leftImage.layer.cornerRadius=20.0;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+283, 2, 40, 40)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_flag"]];
            rightImage.tag=10000+i;
            rightImage.layer.cornerRadius=20.0;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            UIFont * myFont11 = [UIFont fontWithName:@"GillSans-Bold" size:10];
            UILabel *downLbl1 = [[UILabel alloc] initWithFrame:CGRectMake (x+40, 40, 70, 15)];
            [downLbl1 setFont:myFont11];
            downLbl1.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl1.numberOfLines=2;
            downLbl1.textColor=[UIColor whiteColor];
            downLbl1.textAlignment=NSTextAlignmentCenter;
            downLbl1.backgroundColor=[UIColor clearColor];
            [downLbl1 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_name"]];
            [liveScrollView addSubview:downLbl1];
            
            UILabel *downLbl2 = [[UILabel alloc] initWithFrame:CGRectMake (x+270, 40, 70, 15)];
            [downLbl2 setFont:myFont11];
            downLbl2.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl2.numberOfLines=2;
            downLbl2.textColor=[UIColor whiteColor];
            downLbl2.textAlignment=NSTextAlignmentCenter;
            downLbl2.backgroundColor=[UIColor clearColor];
            [downLbl2 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_name"]];
            [liveScrollView addSubview:downLbl2];
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:12];
            CGRect labelFrame1 = CGRectMake (x+105, 14, 170, 25);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"title"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            UIFont * myFont12 = [UIFont fontWithName:@"GillSans-Bold" size:10];
            CGRect labelFrame12 = CGRectMake (x+110,5, 160, 10);
            UILabel *statusLbl = [[UILabel alloc] initWithFrame:labelFrame12];
            [statusLbl setFont:myFont12];
            statusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            statusLbl.numberOfLines=1;
            statusLbl.textColor=[UIColor whiteColor];
            statusLbl.textAlignment=NSTextAlignmentCenter;
            statusLbl.backgroundColor=[UIColor clearColor];
            [statusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"top_status"]];
            [liveScrollView addSubview:statusLbl];
            
            
            UIFont * myFont123 = [UIFont fontWithName:@"GillSans-Bold" size: 10];
            CGRect labelFrame123 = CGRectMake (x+110, 35, 160, 15);
            UILabel *downstatusLbl = [[UILabel alloc] initWithFrame:labelFrame123];
            [downstatusLbl setFont:myFont123];
            downstatusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            downstatusLbl.numberOfLines=1;
            downstatusLbl.textColor=[UIColor whiteColor];
            downstatusLbl.textAlignment=NSTextAlignmentCenter;
            downstatusLbl.backgroundColor=[UIColor clearColor];
            [downstatusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"m_status"]];
            [liveScrollView addSubview:downstatusLbl];
            
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=30000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+125, 0, 160, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        else if(self.view.frame.size.width==414)
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame = CGRectMake (x+7, 0, 43, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            
            [label setText:[dataArr valueForKey:@"cricket_label"]];//@"Live Scores"];
            [liveScrollView addSubview:label];
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+65, 2, 40, 40)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_flag"]];
            leftImage.tag=10000+i;
            leftImage.layer.cornerRadius=20.0;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+313, 2, 40, 40)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_flag"]];
            rightImage.tag=10000+i;
            rightImage.layer.cornerRadius=20.0;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            UIFont * myFont11 = [UIFont fontWithName:@"GillSans-Bold" size:11];
            UILabel *downLbl1 = [[UILabel alloc] initWithFrame:CGRectMake (x+50, 40, 70, 15)];
            [downLbl1 setFont:myFont11];
            downLbl1.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl1.numberOfLines=2;
            downLbl1.textColor=[UIColor whiteColor];
            downLbl1.textAlignment=NSTextAlignmentCenter;
            downLbl1.backgroundColor=[UIColor clearColor];
            [downLbl1 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_name"]];
            [liveScrollView addSubview:downLbl1];
            
            UILabel *downLbl2 = [[UILabel alloc] initWithFrame:CGRectMake (x+300, 40, 70, 15)];
            [downLbl2 setFont:myFont11];
            downLbl2.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl2.numberOfLines=2;
            downLbl2.textColor=[UIColor whiteColor];
            downLbl2.textAlignment=NSTextAlignmentCenter;
            downLbl2.backgroundColor=[UIColor clearColor];
            [downLbl2 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_name"]];
            [liveScrollView addSubview:downLbl2];
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:15];
            CGRect labelFrame1 = CGRectMake (x+110, 12, 190, 28);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"title"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            UIFont * myFont12 = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame12 = CGRectMake (x+110,5, 190, 10);
            UILabel *statusLbl = [[UILabel alloc] initWithFrame:labelFrame12];
            [statusLbl setFont:myFont12];
            statusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            statusLbl.numberOfLines=1;
            statusLbl.textColor=[UIColor whiteColor];
            statusLbl.textAlignment=NSTextAlignmentCenter;
            statusLbl.backgroundColor=[UIColor clearColor];
            [statusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"top_status"]];
            [liveScrollView addSubview:statusLbl];
            
            
            UIFont * myFont123 = [UIFont fontWithName:@"GillSans-Bold" size: 11];
            CGRect labelFrame123 = CGRectMake (x+110, 35, 190, 15);
            UILabel *downstatusLbl = [[UILabel alloc] initWithFrame:labelFrame123];
            [downstatusLbl setFont:myFont123];
            downstatusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            downstatusLbl.numberOfLines=1;
            downstatusLbl.textColor=[UIColor whiteColor];
            downstatusLbl.textAlignment=NSTextAlignmentCenter;
            downstatusLbl.backgroundColor=[UIColor clearColor];
            [downstatusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"m_status"]];
            [liveScrollView addSubview:downstatusLbl];
            
            
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=30000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+125, 0, 160, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
            
        }
        else if(self.view.frame.size.width==768)
        {
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:15];
            CGRect labelFrame = CGRectMake (x+7, 0, 160, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            
            [label setText:[dataArr valueForKey:@"cricket_label"]];//@"Live Scores"];
            [liveScrollView addSubview:label];
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+164, 2, 40, 40)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_flag"]];
            leftImage.tag=10000+i;
            leftImage.layer.cornerRadius=20.0;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+614, 2, 40, 40)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_flag"]];
            rightImage.tag=10000+i;
            rightImage.layer.cornerRadius=20.0;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            UIFont * myFont11 = [UIFont fontWithName:@"GillSans-Bold" size:11];
            UILabel *downLbl1 = [[UILabel alloc] initWithFrame:CGRectMake (x+150, 40, 70, 15)];
            [downLbl1 setFont:myFont11];
            downLbl1.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl1.numberOfLines=2;
            downLbl1.textColor=[UIColor whiteColor];
            downLbl1.textAlignment=NSTextAlignmentCenter;
            downLbl1.backgroundColor=[UIColor clearColor];
            [downLbl1 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_name"]];
            [liveScrollView addSubview:downLbl1];
            
            UILabel *downLbl2 = [[UILabel alloc] initWithFrame:CGRectMake (x+600, 40, 70, 15)];
            [downLbl2 setFont:myFont11];
            downLbl2.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl2.numberOfLines=2;
            downLbl2.textColor=[UIColor whiteColor];
            downLbl2.textAlignment=NSTextAlignmentCenter;
            downLbl2.backgroundColor=[UIColor clearColor];
            [downLbl2 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_name"]];
            [liveScrollView addSubview:downLbl2];
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:19];
            CGRect labelFrame1 = CGRectMake (x+215, 12, 390, 28);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"title"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            UIFont * myFont12 = [UIFont fontWithName:@"GillSans-Bold" size:12];
            CGRect labelFrame12 = CGRectMake (x+215,2, 390, 10);
            UILabel *statusLbl = [[UILabel alloc] initWithFrame:labelFrame12];
            [statusLbl setFont:myFont12];
            statusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            statusLbl.numberOfLines=1;
            statusLbl.textColor=[UIColor whiteColor];
            statusLbl.textAlignment=NSTextAlignmentCenter;
            statusLbl.backgroundColor=[UIColor clearColor];
            [statusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"top_status"]];
            [liveScrollView addSubview:statusLbl];
            
            
            UIFont * myFont123 = [UIFont fontWithName:@"GillSans-Bold" size: 12];
            CGRect labelFrame123 = CGRectMake (x+215, 37, 390, 15);
            UILabel *downstatusLbl = [[UILabel alloc] initWithFrame:labelFrame123];
            [downstatusLbl setFont:myFont123];
            downstatusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            downstatusLbl.numberOfLines=1;
            downstatusLbl.textColor=[UIColor whiteColor];
            downstatusLbl.textAlignment=NSTextAlignmentCenter;
            downstatusLbl.backgroundColor=[UIColor clearColor];
            [downstatusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"m_status"]];
            [liveScrollView addSubview:downstatusLbl];
            
            
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=30000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+225, 0, 360, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        else
        {
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:16];
            CGRect labelFrame = CGRectMake (x+7, 0, 180, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            
            [label setText:[dataArr valueForKey:@"cricket_label"]];//@"Live Scores"];
            [liveScrollView addSubview:label];
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+264, 2, 40, 40)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_flag"]];
            leftImage.tag=10000+i;
            leftImage.layer.cornerRadius=20.0;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+814, 2, 40, 40)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_flag"]];
            rightImage.tag=10000+i;
            rightImage.layer.cornerRadius=20.0;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            UIFont * myFont11 = [UIFont fontWithName:@"GillSans-Bold" size:11];
            UILabel *downLbl1 = [[UILabel alloc] initWithFrame:CGRectMake (x+250, 40, 70, 15)];
            [downLbl1 setFont:myFont11];
            downLbl1.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl1.numberOfLines=2;
            downLbl1.textColor=[UIColor whiteColor];
            downLbl1.textAlignment=NSTextAlignmentCenter;
            downLbl1.backgroundColor=[UIColor clearColor];
            [downLbl1 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team1_name"]];
            [liveScrollView addSubview:downLbl1];
            
            UILabel *downLbl2 = [[UILabel alloc] initWithFrame:CGRectMake (x+800, 40, 70, 15)];
            [downLbl2 setFont:myFont11];
            downLbl2.lineBreakMode=NSLineBreakByWordWrapping;
            downLbl2.numberOfLines=2;
            downLbl2.textColor=[UIColor whiteColor];
            downLbl2.textAlignment=NSTextAlignmentCenter;
            downLbl2.backgroundColor=[UIColor clearColor];
            [downLbl2 setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"team2_name"]];
            [liveScrollView addSubview:downLbl2];
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:18];
            CGRect labelFrame1 = CGRectMake (x+315, 13,490, 28);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"title"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            UIFont * myFont12 = [UIFont fontWithName:@"GillSans-Bold" size:12];
            CGRect labelFrame12 = CGRectMake (x+315,2, 490, 10);
            UILabel *statusLbl = [[UILabel alloc] initWithFrame:labelFrame12];
            [statusLbl setFont:myFont12];
            statusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            statusLbl.numberOfLines=1;
            statusLbl.textColor=[UIColor whiteColor];
            statusLbl.textAlignment=NSTextAlignmentCenter;
            statusLbl.backgroundColor=[UIColor clearColor];
            [statusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"top_status"]];
            [liveScrollView addSubview:statusLbl];
            
            
            UIFont * myFont123 = [UIFont fontWithName:@"GillSans-Bold" size: 12];
            CGRect labelFrame123 = CGRectMake (x+315, 37, 490, 15);
            UILabel *downstatusLbl = [[UILabel alloc] initWithFrame:labelFrame123];
            [downstatusLbl setFont:myFont123];
            downstatusLbl.lineBreakMode=NSLineBreakByWordWrapping;
            downstatusLbl.numberOfLines=1;
            downstatusLbl.textColor=[UIColor whiteColor];
            downstatusLbl.textAlignment=NSTextAlignmentCenter;
            downstatusLbl.backgroundColor=[UIColor clearColor];
            [downstatusLbl setText:[[dataArr valueForKey:@"cricket"][i] valueForKey:@"m_status"]];
            [liveScrollView addSubview:downstatusLbl];
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=30000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+425, 0, 560, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        
        if(i<[[dataArr valueForKey:@"cricket"] count]-1)
        {
            UIButton *goToNext =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToNext.tag=30000+i;
            [goToNext setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
            [goToNext addTarget:self action:@selector(goToNextMatch:) forControlEvents:UIControlEventTouchUpInside];
            [goToNext setFrame:CGRectMake(x+(self.view.frame.size.width-35), 0, 35, 55)];
            [goToNext setExclusiveTouch:YES];
            goToNext.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToNext];
        }
        if(i==[[dataArr valueForKey:@"cricket"] count]-1  && [[dataArr valueForKey:@"football"] count]>0)
        {
            UIButton *goToNext =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToNext.tag=30000+i;
            [goToNext setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
            [goToNext addTarget:self action:@selector(goToNextMatch:) forControlEvents:UIControlEventTouchUpInside];
            [goToNext setFrame:CGRectMake(x+(self.view.frame.size.width-35), 0, 35, 55)];
            [goToNext setExclusiveTouch:YES];
            goToNext.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToNext];
        }
        
        if([[dataArr  valueForKey:@"add_status"]intValue]==1)
        {
            x=x+self.view.frame.size.width+self.view.frame.size.width;
            space=1;
            AsyncImageView *addImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
            addImage.imageURL=[NSURL URLWithString:[dataArr valueForKey:@"add_img_path"]];
            addImage.tag=10000+i;
            addImage.contentMode=UIViewContentModeScaleToFill;
            addImage.clipsToBounds=YES;
            addImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:addImage];
            
            
            UIButton *addImageButtonmn =  [UIButton buttonWithType:UIButtonTypeCustom];
            addImageButtonmn.tag=90000+i;
            [addImageButtonmn addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [addImageButtonmn setFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
            [addImageButtonmn setExclusiveTouch:YES];
            addImageButtonmn.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:addImageButtonmn];
            
        }
        else
        {
            if(space>0)
            {
                space++;
            }
            if(space>0 && space%2!=0 && [[dataArr  valueForKey:@"add_status"]intValue]==1)
            {
                x=x+self.view.frame.size.width+self.view.frame.size.width;
                AsyncImageView *addImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
                addImage.imageURL=[NSURL URLWithString:[dataArr valueForKey:@"add_img_path"]];
                addImage.tag=10000+i;
                addImage.contentMode=UIViewContentModeScaleToFill;
                addImage.clipsToBounds=YES;
                addImage.backgroundColor=[UIColor clearColor];
                [liveScrollView addSubview:addImage];
                
                
                UIButton *addImageButtonmn =  [UIButton buttonWithType:UIButtonTypeCustom];
                addImageButtonmn.tag=90000+i;
                [addImageButtonmn addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
                [addImageButtonmn setFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
                [addImageButtonmn setExclusiveTouch:YES];
                addImageButtonmn.backgroundColor=[UIColor clearColor];
                [liveScrollView addSubview:addImageButtonmn];
            }
            else
                x=x+self.view.frame.size.width;
            
            
        }
        
        
    }
    space=1;
    
    for(int i=0;i<[[dataArr valueForKey:@"football"] count];i++)
    {
        
        
        
        if(self.view.frame.size.width==320)
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame = CGRectMake (x+7, 0, 46, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            [label setText:[dataArr valueForKey:@"football_label"]];
            [liveScrollView addSubview:label];
            
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+66, 2, 50, 50)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_logo"]];
            leftImage.tag=60000+i;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+220, 2, 50, 50)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_logo"]];
            rightImage.tag=60000+i;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:18];
            CGRect labelFrame1 = CGRectMake (x+113, 0, 40, 55);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_goal"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            CGRect labelFrame2 = CGRectMake (x+173, 0, 40, 55);
            UILabel *scoreLabel1 = [[UILabel alloc] initWithFrame:labelFrame2];
            [scoreLabel1 setFont:myFont1];
            scoreLabel1.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel1.numberOfLines=2;
            scoreLabel1.textColor=[UIColor whiteColor];
            scoreLabel1.textAlignment=NSTextAlignmentCenter;
            scoreLabel1.backgroundColor=[UIColor clearColor];
            [scoreLabel1 setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_goal"]];
            [liveScrollView addSubview:scoreLabel1];
            
            
            CGRect labelFrame3 = CGRectMake (x+150, 4, 39, 16);
            UILabel *minLabel = [[UILabel alloc] initWithFrame:labelFrame3];
            [minLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:11]];
            minLabel.lineBreakMode=NSLineBreakByWordWrapping;
            minLabel.numberOfLines=2;
            minLabel.textColor=[UIColor whiteColor];
            minLabel.textAlignment=NSTextAlignmentCenter;
            minLabel.backgroundColor=[UIColor clearColor];
            [minLabel setText:[NSString stringWithFormat:@"%@'",[[dataArr valueForKey:@"football"][i] valueForKey:@"mins"]]];
            [liveScrollView addSubview:minLabel];
            
            
            
            UIView *v=[[UIView alloc]initWithFrame:CGRectMake(x+163, 28, 5, 2)];
            v.backgroundColor=[UIColor whiteColor];
            [liveScrollView addSubview:v];
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=60000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+130, 0, self.view.frame.size.width-120, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        
        else if(self.view.frame.size.width==375)
        {
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame = CGRectMake (x+7, 0, 46, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            [label setText:[dataArr valueForKey:@"football_label"]];
            [liveScrollView addSubview:label];
            
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+108, 2, 50, 50)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_logo"]];
            leftImage.tag=60000+i;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+270, 2, 50, 50)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_logo"]];
            rightImage.tag=60000+i;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:18];
            CGRect labelFrame1 = CGRectMake (x+163, 0, 40, 55);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_goal"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            CGRect labelFrame2 = CGRectMake (x+223, 0, 40, 55);
            UILabel *scoreLabel1 = [[UILabel alloc] initWithFrame:labelFrame2];
            [scoreLabel1 setFont:myFont1];
            scoreLabel1.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel1.numberOfLines=2;
            scoreLabel1.textColor=[UIColor whiteColor];
            scoreLabel1.textAlignment=NSTextAlignmentCenter;
            scoreLabel1.backgroundColor=[UIColor clearColor];
            [scoreLabel1 setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_goal"]];
            [liveScrollView addSubview:scoreLabel1];
            
            UIView *v=[[UIView alloc]initWithFrame:CGRectMake(x+213, 28, 5, 2)];
            v.backgroundColor=[UIColor whiteColor];
            [liveScrollView addSubview:v];
            
            
            CGRect labelFrame3 = CGRectMake (x+198, 4, 39, 16);
            UILabel *minLabel = [[UILabel alloc] initWithFrame:labelFrame3];
            [minLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:11]];
            minLabel.lineBreakMode=NSLineBreakByWordWrapping;
            minLabel.numberOfLines=2;
            minLabel.textColor=[UIColor whiteColor];
            minLabel.textAlignment=NSTextAlignmentCenter;
            minLabel.backgroundColor=[UIColor clearColor];
            [minLabel setText:[NSString stringWithFormat:@"%@'",[[dataArr valueForKey:@"football"][i] valueForKey:@"mins"]]];
            [liveScrollView addSubview:minLabel];
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=60000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+130, 0, self.view.frame.size.width-120, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        else if(self.view.frame.size.width==414)
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:11];
            CGRect labelFrame = CGRectMake (x+7, 0, 47, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=3;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            [label setText:[dataArr valueForKey:@"football_label"]];
            [liveScrollView addSubview:label];
            
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+100, 2, 50, 50)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_logo"]];
            leftImage.tag=60000+i;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+280, 2, 50, 50)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_logo"]];
            rightImage.tag=60000+i;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:15];
            CGRect labelFrame1 = CGRectMake (x+163, 0, 40, 55);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_goal"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            CGRect labelFrame2 = CGRectMake (x+221, 0, 40, 55);
            UILabel *scoreLabel1 = [[UILabel alloc] initWithFrame:labelFrame2];
            [scoreLabel1 setFont:myFont1];
            scoreLabel1.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel1.numberOfLines=2;
            scoreLabel1.textColor=[UIColor whiteColor];
            scoreLabel1.textAlignment=NSTextAlignmentCenter;
            scoreLabel1.backgroundColor=[UIColor clearColor];
            [scoreLabel1 setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_goal"]];
            [liveScrollView addSubview:scoreLabel1];
            
            UIView *v=[[UIView alloc]initWithFrame:CGRectMake(x+213, 28, 5, 2)];
            v.backgroundColor=[UIColor whiteColor];
            [liveScrollView addSubview:v];
            
            CGRect labelFrame3 = CGRectMake (x+198, 4, 39, 16);
            UILabel *minLabel = [[UILabel alloc] initWithFrame:labelFrame3];
            [minLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:11]];
            minLabel.lineBreakMode=NSLineBreakByWordWrapping;
            minLabel.numberOfLines=2;
            minLabel.textColor=[UIColor whiteColor];
            minLabel.textAlignment=NSTextAlignmentCenter;
            minLabel.backgroundColor=[UIColor clearColor];
            [minLabel setText:[NSString stringWithFormat:@"%@'",[[dataArr valueForKey:@"football"][i] valueForKey:@"mins"]]];
            [liveScrollView addSubview:minLabel];
            
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=60000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+130, 0, self.view.frame.size.width-120, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        else if(self.view.frame.size.width==768)
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:15];
            CGRect labelFrame = CGRectMake (x+7, 0, 165, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=2;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            [label setText:[dataArr valueForKey:@"football_label"]];
            [liveScrollView addSubview:label];
            
            
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+250, 2, 50, 50)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_logo"]];
            leftImage.tag=60000+i;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+500, 2, 50, 50)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_logo"]];
            rightImage.tag=60000+i;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:28];
            CGRect labelFrame1 = CGRectMake (x+343, 0, 40, 50);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_goal"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            CGRect labelFrame2 = CGRectMake (x+413, 0, 40, 50);
            UILabel *scoreLabel1 = [[UILabel alloc] initWithFrame:labelFrame2];
            [scoreLabel1 setFont:myFont1];
            scoreLabel1.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel1.numberOfLines=2;
            scoreLabel1.textColor=[UIColor whiteColor];
            scoreLabel1.textAlignment=NSTextAlignmentCenter;
            scoreLabel1.backgroundColor=[UIColor clearColor];
            [scoreLabel1 setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_goal"]];
            [liveScrollView addSubview:scoreLabel1];
            
            UIView *v=[[UIView alloc]initWithFrame:CGRectMake(x+397, 25, 5, 2)];
            v.backgroundColor=[UIColor whiteColor];
            [liveScrollView addSubview:v];
            
            CGRect labelFrame3 = CGRectMake (x+380, 2, 42, 16);
            UILabel *minLabel = [[UILabel alloc] initWithFrame:labelFrame3];
            [minLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:15]];
            minLabel.lineBreakMode=NSLineBreakByWordWrapping;
            minLabel.numberOfLines=2;
            minLabel.textColor=[UIColor whiteColor];
            minLabel.textAlignment=NSTextAlignmentCenter;
            minLabel.backgroundColor=[UIColor clearColor];
            [minLabel setText:[NSString stringWithFormat:@"%@'",[[dataArr valueForKey:@"football"][i] valueForKey:@"mins"]]];
            [liveScrollView addSubview:minLabel];
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=60000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+430, 0, self.view.frame.size.width-420, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        else
        {
            
            UIFont * myFont = [UIFont fontWithName:@"GillSans-Bold" size:16];
            CGRect labelFrame = CGRectMake (x+7, 0, 195, 55);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            [label setFont:myFont];
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.numberOfLines=2;
            label.textColor=[UIColor whiteColor];
            label.textAlignment=NSTextAlignmentLeft;
            label.backgroundColor=[UIColor clearColor];
            [label setText:[dataArr valueForKey:@"football_label"]];
            [liveScrollView addSubview:label];
            
            
            
            AsyncImageView *leftImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+400, 2, 50, 50)];
            leftImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_logo"]];
            leftImage.tag=60000+i;
            leftImage.contentMode=UIViewContentModeScaleAspectFill;
            leftImage.clipsToBounds=YES;
            leftImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:leftImage];
            
            
            AsyncImageView *rightImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x+650, 2, 50, 50)];
            rightImage.imageURL=[NSURL URLWithString:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_logo"]];
            rightImage.tag=60000+i;
            rightImage.contentMode=UIViewContentModeScaleAspectFill;
            rightImage.clipsToBounds=YES;
            rightImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:rightImage];
            
            
            UIFont * myFont1 = [UIFont fontWithName:@"GillSans-Bold" size:28];
            CGRect labelFrame1 = CGRectMake (x+493, 0, 40, 50);
            UILabel *scoreLabel = [[UILabel alloc] initWithFrame:labelFrame1];
            [scoreLabel setFont:myFont1];
            scoreLabel.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel.numberOfLines=2;
            scoreLabel.textColor=[UIColor whiteColor];
            scoreLabel.textAlignment=NSTextAlignmentCenter;
            scoreLabel.backgroundColor=[UIColor clearColor];
            [scoreLabel setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team1_goal"]];
            [liveScrollView addSubview:scoreLabel];
            
            
            
            CGRect labelFrame2 = CGRectMake (x+563, 0, 40, 50);
            UILabel *scoreLabel1 = [[UILabel alloc] initWithFrame:labelFrame2];
            [scoreLabel1 setFont:myFont1];
            scoreLabel1.lineBreakMode=NSLineBreakByWordWrapping;
            scoreLabel1.numberOfLines=2;
            scoreLabel1.textColor=[UIColor whiteColor];
            scoreLabel1.textAlignment=NSTextAlignmentCenter;
            scoreLabel1.backgroundColor=[UIColor clearColor];
            [scoreLabel1 setText:[[dataArr valueForKey:@"football"][i] valueForKey:@"team2_goal"]];
            [liveScrollView addSubview:scoreLabel1];
            
            UIView *v=[[UIView alloc]initWithFrame:CGRectMake(x+547, 25, 5, 2)];
            v.backgroundColor=[UIColor whiteColor];
            [liveScrollView addSubview:v];
            
            CGRect labelFrame3 = CGRectMake (x+530, 2, 42, 16);
            UILabel *minLabel = [[UILabel alloc] initWithFrame:labelFrame3];
            [minLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:15]];
            minLabel.lineBreakMode=NSLineBreakByWordWrapping;
            minLabel.numberOfLines=2;
            minLabel.textColor=[UIColor whiteColor];
            minLabel.textAlignment=NSTextAlignmentCenter;
            minLabel.backgroundColor=[UIColor clearColor];
            [minLabel setText:[NSString stringWithFormat:@"%@'",[[dataArr valueForKey:@"football"][i] valueForKey:@"mins"]]];
            [liveScrollView addSubview:minLabel];
            
            
            UIButton *goToMatchButton =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToMatchButton.tag=60000+i;
            [goToMatchButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [goToMatchButton setFrame:CGRectMake(x+580, 0, self.view.frame.size.width-620, 55)];
            [goToMatchButton setExclusiveTouch:YES];
            goToMatchButton.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToMatchButton];
        }
        
        
        
        if(i!=[[dataArr valueForKey:@"football"] count]-1)
        {
            UIButton *goToNext =  [UIButton buttonWithType:UIButtonTypeCustom];
            goToNext.tag=60000+i;
            [goToNext setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
            
            [goToNext addTarget:self action:@selector(goToNextMatch:) forControlEvents:UIControlEventTouchUpInside];
            [goToNext setFrame:CGRectMake(x+(self.view.frame.size.width-35), 0, 35, 54)];
            [goToNext setExclusiveTouch:YES];
            goToNext.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:goToNext];
            
        }
        if(space>0)
        {
            space++;
        }
        else
            x=x+self.view.frame.size.width;
        
        if(space>0 && space%2!=0 && [[dataArr  valueForKey:@"add_status"]intValue]==1)
        {
            x=x+self.view.frame.size.width+self.view.frame.size.width;
            AsyncImageView *addImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
            addImage.imageURL=[NSURL URLWithString:[dataArr valueForKey:@"add_img_path"]];
            addImage.tag=10000+i;
            addImage.contentMode=UIViewContentModeScaleToFill;
            addImage.clipsToBounds=YES;
            addImage.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:addImage];
            
            
            UIButton *addImageButtonmn =  [UIButton buttonWithType:UIButtonTypeCustom];
            addImageButtonmn.tag=90000+i;
            [addImageButtonmn addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
            [addImageButtonmn setFrame:CGRectMake(x-self.view.frame.size.width, 0, self.view.frame.size.width, 54)];
            [addImageButtonmn setExclusiveTouch:YES];
            addImageButtonmn.backgroundColor=[UIColor clearColor];
            [liveScrollView addSubview:addImageButtonmn];
        }
        else
            x=x+self.view.frame.size.width;
        
        
        
    }
    
    liveScrollView.contentSize=CGSizeMake(x, 20);
    liveScrollView.pagingEnabled=YES;
}
-(void)goToNextMatch:(UIButton*)btn
{
    
    [liveScrollView setContentOffset:CGPointMake(liveScrollView.contentOffset.x+self.view.frame.size.width,0) animated:YES];
    
    [stripTimer invalidate];
    stripTimer= [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(stripeMove)userInfo:nil repeats:YES];
    
    
}
-(void)goToMatchScreen:(UIButton*)btn
{
    if(btn.tag-90000>=0)
    {
        NSURL *url = [NSURL URLWithString:[stripData valueForKey:@"add_url"]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if(btn.tag-80000>=0)
    {
        //add_url
        NSURL *url = [NSURL URLWithString:[tableData[btn.tag-80000] valueForKey:@"add_url"]];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    else if(btn.tag-60000>=0)
    {
        //NSLog(@"%@", [[stripData valueForKey:@"football"][btn.tag-60000] valueForKey:@"match_id"]);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[[stripData valueForKey:@"football"][btn.tag-60000] valueForKey:@"fleage_id"] forKey:@"matchh_id"];
        [userDefaults setObject:[[stripData valueForKey:@"football"][btn.tag-60000] valueForKey:@"name"] forKey:@"matchh_name"];
        [userDefaults setObject:[[stripData valueForKey:@"football"][btn.tag-60000] valueForKey:@"logo"] forKey:@"matchh_flag"];
        [userDefaults synchronize];
        
        
        footballMatchScoreView *smvc;
        int height = [UIScreen mainScreen].bounds.size.height;
        if (height == 480) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"footballMatchScoreView"];
            
        }
        else if (height == 568) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"footballMatchScoreView"];
            
        }
        else if (height == 667) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"footballMatchScoreView"];
            
        }
        else if (height == 736) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"footballMatchScoreView"];
            
        }
        else if (height == 1024) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"footballMatchScoreView"];
            
        }
        else
        {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"footballMatchScoreView"];
            
        }
        
        [self.navigationController pushViewController:smvc animated:YES];
        
        
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        
        
        [userDefaults setObject:[[stripData valueForKey:@"cricket"][btn.tag-30000] valueForKey:@"top_status"] forKey:@"MatchName"];
        [userDefaults setObject:[[stripData valueForKey:@"cricket"][btn.tag-30000] valueForKey:@"match_id"] forKey:@"unique_id"];
        
        [userDefaults synchronize];
        
        
        scoreDetailViewController *smvc;
        int height = [UIScreen mainScreen].bounds.size.height;
        if (height == 480) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"scoreDetailViewController"];
            
        }
        else if (height == 568) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"scoreDetailViewController"];
            
        }
        else if (height == 667) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"scoreDetailViewController"];
            
        }
        else if (height == 736) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"scoreDetailViewController"];
            
        }
        else if (height == 1024) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"scoreDetailViewController"];
            
        }
        else
        {
            
            smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"scoreDetailViewController"];
            
        }
        
        [self.navigationController pushViewController:smvc animated:YES];
        //NSLog(@"%@,%d", [[stripData valueForKey:@"cricket"][btn.tag-30000] valueForKey:@"match_id"],btn.tag);
    }
}
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(closeFullView1) userInfo:nil repeats:NO];
    
    [UIView beginAnimations:@"animate" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationBeginsFromCurrentState: NO];
    [updateView setFrame:CGRectMake(0,0-updateView.frame.size.height, updateView.frame.size.width, updateView.frame.size.height)];
    //updateView.alpha=0.3;
    [UIView commitAnimations];
    
}
-(void)closeFullView1
{
    [updateView removeFromSuperview];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)launchAppStore
{
    NSString *iTunesString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", trackId];
    NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
    [[UIApplication sharedApplication] openURL:iTunesURL];
}
-(void)firstTimeCall
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request;
        request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/categories_email?email=%@&ln=%@",email,lang] parameters:nil];
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil)
            {
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"categoryArr"];
                    [userDefaults synchronize];
                }
                //NSLog(@"Network-Response: %@", JSON);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
    
    
    
    
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if((lang == (id)[NSNull null] || lang.length == 0 ))
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
        }
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if(appDelegate.notification)
        {
            limit =100;
        }
        
        
        
        
        if([lang isEqualToString:@"english"])
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
            
        }
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request;
        request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/landing_news?offset=0&email=%@&ln=%@&limit=10",email,lang] parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                    [userDefaults setObject:data forKey:@"news"];
                    [userDefaults synchronize];
                }
                
                NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
                NSData *data = [u objectForKey:@"news"];
                fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
                selectedLang=[u objectForKey:@"lang"];
                NSLog(@"%@,%@",selectedLang,fullNews);
                
                engNews=[[fullNews valueForKey:@"data"]mutableCopy];
                [mainTable reloadData];
                
                readCount=[[fullNews valueForKey:@"unread"]intValue];
                if(readCount>99)
                {
                    unreadViewLbl.text=[NSString stringWithFormat:@"%@ unread news",@"99+"];
                }
                else
                {
                    unreadViewLbl.text=[NSString stringWithFormat:@"%d unread news",readCount];
                }
                
                NSMutableArray *arr=[[u objectForKey:@"oflineNews"]mutableCopy];
                if(arr.count>0)
                {
                    for(int i=0;i<engNews.count;i++)
                    {
                        if (![arr containsObject: engNews[i]])
                            [arr addObject:engNews[i]];
                    }
                    [u setObject:arr forKey:@"oflineNews"];
                    [u synchronize];
                }
                else
                {
                    [u setObject:engNews forKey:@"oflineNews"];
                    [u synchronize];
                }
                
                
                
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        
        
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if([lang isEqualToString:@"english"])
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
            
            
        }
        
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/categories_feed?email=%@&ln=%@",email,lang]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"cat_myfeed"];
                    [userDefaults synchronize];
                }
                
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
-(void)notificationApiCall
{
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if((lang == (id)[NSNull null] || lang.length == 0 ))
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
        }
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if(appDelegate.notification)
        {
            limit =150;
        }
        
        
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request;
        request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/allnews_limit?ln=%@&limit=%d&offset=0&email=%@",lang,limit,email] parameters:nil];
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                    [userDefaults setObject:data forKey:@"news"];
                    [userDefaults synchronize];
                    
                    
                    
                    
                    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
                    fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
                    selectedLang=[u objectForKey:@"lang"];
                    NSLog(@"%@,%@",selectedLang,fullNews);
                    
                    engNews=[[fullNews valueForKey:@"data"]mutableCopy];
                    readCount=[[fullNews valueForKey:@"unread"]intValue];
                    if(readCount>99)
                    {
                        unreadViewLbl.text=[NSString stringWithFormat:@"%@ unread news",@"99+"];
                    }
                    else
                    {
                        unreadViewLbl.text=[NSString stringWithFormat:@"%d unread news",readCount];
                    }
                    
                    NSMutableArray *arr=[[u objectForKey:@"oflineNews"]mutableCopy];
                    if(arr.count>0)
                    {
                        for(int i=0;i<engNews.count;i++)
                        {
                            if (![arr containsObject: engNews[i]])
                                [arr addObject:engNews[i]];
                        }
                        [u setObject:arr forKey:@"oflineNews"];
                        [u synchronize];
                    }
                    else
                    {
                        [u setObject:engNews forKey:@"oflineNews"];
                        [u synchronize];
                    }
                    
                    scrollPossition=0;
                    
                    
                    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

                    for(int i=0;i<engNews.count;i++)
                    {
                        if([[engNews[i]valueForKey:@"id"]intValue]==appDelegate.notiNewsId)
                        {
                            scrollPossition=i;
                            break;
                        }
                        
                    }
                    
                    [mainTable reloadData];
                }
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }
    
    
    
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        
        
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if([lang isEqualToString:@"english"])
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
            
            
        }
        
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/categories_feed?email=%@&ln=%@",email,lang]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"cat_myfeed"];
                    [userDefaults synchronize];
                }
                
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request;
        request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/categories_email?email=%@&ln=%@",email,lang] parameters:nil];
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil)
            {
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"categoryArr"];
                    [userDefaults synchronize];
                }
                //NSLog(@"Network-Response: %@", JSON);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
-(void)getCategoriesAndNews:(NSTimer *)timer
{
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/categories_email?email=%@&ln=%@",email,lang] parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil)
            {
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"categoryArr"];
                    [userDefaults synchronize];
                }
                //NSLog(@"Network-Response: %@", JSON);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
    
    
    
    
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if(appDelegate.notification)
        {
            limit =100;
        }
        
        
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if([lang isEqualToString:@"english"])
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
            
        }
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/landing_news?offset=0&email=%@&ln=%@&limit=%d",email,lang,limit]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                    [userDefaults setObject:data forKey:@"news"];
                    [userDefaults synchronize];
                }
                
                
                NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
                NSData *data = [u objectForKey:@"news"];
                NSMutableArray *arr = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
                
                NSMutableArray *a=[[arr valueForKey:@"data"]mutableCopy];
                
                
                AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                if([[arr valueForKey:@"live_status"]intValue]==1)
                {
                    appDelegate.liveoFound=YES;
                }
                else
                {
                    appDelegate.liveoFound=false;
                    
                }
                
                
                if([[a[0]valueForKey:@"id"]intValue] != [[engNews[0]valueForKey:@"id"]intValue])
                {
                    updateButton= [UIButton buttonWithType:UIButtonTypeCustom];
                    UIFont * myFont = [UIFont fontWithName:@"Arial" size:12];
                    [updateButton addTarget:self action:@selector(loadNewDataAfterRefresh:) forControlEvents:UIControlEventTouchUpInside];
                    [updateButton setFrame:CGRectMake(self.view.frame.size.width/2-45, 76, 90, 25)];
                    [updateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [updateButton setTitle:@" New Stories" forState:UIControlStateNormal];
                    [updateButton setImage:[UIImage imageNamed:@"arrowup"] forState:UIControlStateNormal];
                    [updateButton setExclusiveTouch:YES];
                    updateButton.titleLabel.font=myFont;
                    updateButton.backgroundColor=[UIColor whiteColor];
                    updateButton.layer.cornerRadius=5.0;
                    updateButton.layer.borderColor=[UIColor orangeColor].CGColor;
                    updateButton.layer.borderWidth=1.0;
                    [self.view addSubview:updateButton];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        
        
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if([lang isEqualToString:@"english"])
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
            
            
        }
        
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/categories_feed?email=%@&ln=%@",email,lang]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"cat_myfeed"];
                    [userDefaults synchronize];
                }
                
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
-(void)loadNewDataAfterRefresh:(UIButton*)btn
{
    [updateButton removeFromSuperview];
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSData *data = [u objectForKey:@"news"];
    fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
    selectedLang=[u objectForKey:@"lang"];
    NSLog(@"%@,%@",selectedLang,fullNews);
    
    engNews=[[fullNews valueForKey:@"data"]mutableCopy];
    readCount=[[fullNews valueForKey:@"unread"]intValue];
    if(readCount>99)
    {
        unreadViewLbl.text=[NSString stringWithFormat:@"%@ unread news",@"99+"];
    }
    else
    {
        unreadViewLbl.text=[NSString stringWithFormat:@"%d unread news",readCount];
    }
    
    NSMutableArray *arr=[[u objectForKey:@"oflineNews"]mutableCopy];
    if(arr.count>0)
    {
        for(int i=0;i<engNews.count;i++)
        {
            if (![arr containsObject: engNews[i]])
                [arr addObject:engNews[i]];
        }
        [u setObject:arr forKey:@"oflineNews"];
        [u synchronize];
    }
    else
    {
        [u setObject:engNews forKey:@"oflineNews"];
        [u synchronize];
    }
    
    scrollPossition=0;
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    for(int i=0;i<engNews.count;i++)
    {
        if([[engNews[i]valueForKey:@"id"]intValue]==appDelegate.notiNewsId)
        {
            scrollPossition=i;
            break;
        }
        
    }
    
    [mainTable reloadData];
    [mainTable setContentOffset:CGPointZero animated:YES];
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
-(void)changeLanguage
{
    
    HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText=@"Please Wait";
    
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSString *email=[u objectForKey:@"deviceToken"];
    NSString *lang=[u objectForKey:@"lang"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:[NSString stringWithFormat:@"/api/v3/landing_news?offset=0&email=%@&ln=%@&limit=%d",email,lang,limit]
                                                      parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Print the response body in text
        //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        
        
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (JSONdata != nil) {
            
            NSError *e;
            NSMutableDictionary *JSON =
            [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                            options: NSJSONReadingMutableContainers
                                              error: &e];
            
            // [self loginresult:JSON];
            if([[JSON valueForKey:@"error"]integerValue] ==0)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                [userDefaults setObject:data forKey:@"news"];
                [userDefaults synchronize];
            }
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSData *data = [u objectForKey:@"news"];
            fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
            selectedLang=[u objectForKey:@"lang"];
            engNews=[[fullNews valueForKey:@"data"]mutableCopy];
            [u setObject:engNews forKey:@"oflineNews"];
            
        }
        [mainTable reloadData];
        HUD.hidden=YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        
    }];
    [operation start];
    
    
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
    
    
}
- (void)hideShowNavigationAction:(UITapGestureRecognizer*)sender {
    if(navigationBar.hidden)
    {
        if(readCount>99)
        {
            unreadViewLbl.text=[NSString stringWithFormat:@"%@ unread news",@"99+"];
        }
        else
        {
            unreadViewLbl.text=[NSString stringWithFormat:@"%d unread news",readCount];
        }
        unreadViewLbl.hidden=false;
        navHideTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideNavBar:)userInfo:nil repeats:NO];
        navigationBar.hidden=false;
    }
    else
    {
        unreadViewLbl.hidden=true;
        navigationBar.hidden=true;
        [navHideTimer invalidate];
    }
    
}
-(void)hideNavBar:(NSTimer *)timer {
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    if(!unreadViewLbl.hidden)
        unreadViewLbl.hidden=true;
}

-(IBAction)slideButton_action:(UIButton*)sender
{
    [navHideTimer invalidate];
    [self.slideMenuController toggleMenuAnimated:sender];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==100)
    {
        return 35;
    }
    else
    {
        if(viewShow==0)
        {
            return 237;
        }
        else
        {
            if(self.view.frame.size.width<375)
            {
                if([tableData[indexPath.row] objectForKey:@"extra_img"])
                {
                    return ((self.view.frame.size.height-76)*[[tableData[indexPath.row] objectForKey:@"extra_img"] count])+self.view.frame.size.height-76;
                }
                else
                    return self.view.frame.size.height-76;
            }
            if([tableData[indexPath.row] objectForKey:@"extra_img"])
            {
                return ((self.view.frame.size.height-75)*[[tableData[indexPath.row] objectForKey:@"extra_img"] count])+self.view.frame.size.height-75;
            }
            else
                return self.view.frame.size.height-75;
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag==100)
    {
        return [[tableData[tablePossition] objectForKey:@"survey_option"] count];
    }
    else
    {
        tableData=[NSMutableArray new];
        tableData=[NSMutableArray arrayWithArray:engNews];
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if(appDelegate.notification && engNews.count>0)
        {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scrollOnIndex)userInfo:nil repeats:NO];
            appDelegate.notification=false;
        }
        
        return tableData.count;
    }
}
-(void)scrollOnIndex
{
    
    //mainTable.contentOffset=CGPointMake(0, scrollPossition*(self.view.frame.size.height-76));
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:scrollPossition inSection:0];
    [mainTable  scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(tableView.tag==100)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        }
        
        UIFont * myFont = [UIFont fontWithName:@"Arial" size:12];
        CGRect labelFrame = CGRectMake (15, 2, 180, 30);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setFont:myFont];
        label.lineBreakMode=NSLineBreakByWordWrapping;
        label.numberOfLines=5;
        label.textColor=[UIColor blackColor];
        label.textAlignment=NSTextAlignmentCenter;
        label.backgroundColor=[UIColor clearColor];
        [label setText:[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row ]valueForKey:@"option_name"]];
        [cell addSubview:label];
        
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 25, 25)];
        if([[tableData[tablePossition] valueForKey:@"extra"]integerValue] ==1)
        {
            if ([selectedIdString rangeOfString:[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row]valueForKey:@"id"]].location == NSNotFound) {
                [btn setImage:[UIImage imageNamed:@"gr"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"sr"] forState:UIControlStateNormal];
            }
        }
        else
        {
            if ([selectedIdString rangeOfString:[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row]valueForKey:@"id"]].location == NSNotFound) {
                [btn setImage:[UIImage imageNamed:@"checkEmpty"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"checkFeild"] forState:UIControlStateNormal];
            }
        }
        [btn setTag:indexPath.row];
        btn.tag=indexPath.row;
        [btn addTarget:self action:@selector(checkSelect:) forControlEvents:UIControlEventTouchUpInside];
        [btn setUserInteractionEnabled:YES];
        cell.accessoryView =btn;
        
        
        
        //        cell.textLabel.text=[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row ]valueForKey:@"option_name"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        return cell;
    }
    else
    {
        if(viewShow==0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
            }
            
            AsyncImageView *mainImg=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, 0, 316, 236)];
            
            if([[tableData[indexPath.row] valueForKey:@"type"]integerValue]==2)
            {
                NSArray* foo = [[tableData[indexPath.row] valueForKey:@"img_path"] componentsSeparatedByString: @"="];
                if(foo.count>1)
                {
                    NSString* firstBit = [foo objectAtIndex: 1];
                    mainImg.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",firstBit]];
                    //                    cell.playButton.hidden=false;
                    //                    cell.playButton.tag=indexPath.row;
                    //                    [cell.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else
            {
                ;
                //                cell.playButton.tag=indexPath.row;
                //                [cell.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                //                cell.playButton.hidden=YES;
                mainImg.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
            }
            
            [cell addSubview:mainImg];
            tableView.pagingEnabled=false;
            return cell;
            
        }
        else
        {
            static NSString *CellIdentifier = @"newsTableViewCell";
            //static NSString *CellNib = @"newsTableViewCell";
            
            newsTableViewCell *cell = (newsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            [newsSeenTimer invalidate];
            cell.mainImage.image=nil;
            
            
            
            NSString *st1= [AppDelegate HourCalculation:[tableData[indexPath.row] objectForKey:@"datetime"]];
            
            
            
            if ([cell.contentView subviews]){
                for (AsyncImageView *subview in [cell.contentView subviews]) {
                    if(subview.tag>10000)
                        [subview removeFromSuperview];
                }
                for (UIButton *subview in [cell subviews]) {
                    if(subview.tag>=10000)
                        [subview removeFromSuperview];
                    if(subview.tag==10009)
                        [subview removeFromSuperview];
                    
                }
            }
            
            //NSLog(@"%@/n%d",tableData[indexPath.row],[[tableData[indexPath.row] valueForKey:@"type"]intValue]);
            
            
            
            if([[tableData[indexPath.row] objectForKey:@"news_read"] isEqualToString:@"no"])
            {
                if(readCount>0)
                {
                    readCount--;
                    [tableData[indexPath.row] setObject:@"yes" forKey:@"news_read"];
                }
                
                if(readCount>99)
                {
                    unreadViewLbl.text=[NSString stringWithFormat:@"%@ unread news",@"99+"];
                }
                else if(readCount>0 && readCount<=99)
                {
                    unreadViewLbl.text=[NSString stringWithFormat:@"%d unread news",readCount];
                }
                else if(readCount==0)
                {
                    unreadViewLbl.text=@"no unread news";
                }
                
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            cell.fbShareButton.tag=indexPath.row;
            [cell.fbShareButton addTarget:self action:@selector(fbShareAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.likeButton.tag=indexPath.row;
            [cell.likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            UIButton *bookmarkButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
            [bookmarkButton addTarget:self action:@selector(bookmarkAction:) forControlEvents:UIControlEventTouchUpInside];
            bookmarkButton.tag=indexPath.row;
            if([[tableData[indexPath.row]valueForKey:@"book_flag"]intValue]==0)
                [bookmarkButton setBackgroundImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
            else
                [bookmarkButton setBackgroundImage:[UIImage imageNamed:@"bookmark_f"] forState:UIControlStateNormal];
            bookmarkButton.frame = CGRectMake(20,cell.shareButton.frame.origin.y+10, 32, 32);
            [cell addSubview:bookmarkButton];
            if([[fullNews valueForKey:@"name"] isEqualToString:@"Bookmarks"])
            {
                [bookmarkButton setBackgroundImage:[UIImage imageNamed:@"bookmark_f"] forState:UIControlStateNormal];
            }
            
            
            
            [cell.likeButton setTitle:[NSString stringWithFormat:@"%d",[[tableData[indexPath.row]valueForKey:@"like_count"]intValue]] forState:UIControlStateNormal];
            
            if([[tableData[indexPath.row]valueForKey:@"like"]isEqualToString:@"no"])
            {
                [cell.likeButton setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
                [cell.likeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                
            }
            else
            {
                [cell.likeButton setTitleColor:[UIColor colorWithRed:55.0/255.0 green:90.0/255.0 blue:196.0/255.0 alpha:1.0]forState:UIControlStateNormal];
                [cell.likeButton setImage:[UIImage imageNamed:@"likeSelected"] forState:UIControlStateNormal];
            }
            
            cell.shareButton.tag=indexPath.row;
            [cell.shareButton addTarget:self action:@selector(shareOnSocialMedia:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cell.moreLinkButton setTitle:[tableData[indexPath.row] valueForKey:@"publisher"] forState:UIControlStateNormal];
            cell.moreLinkButton.tag=indexPath.row;
            [cell.moreLinkButton addTarget:self action:@selector(moreLinkAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            cell.newsByLable.text=[NSString stringWithFormat:@"by %@ / %@",[tableData[indexPath.row] valueForKey:@"editor_name"],[NSString stringWithFormat:@"%@ ago",st1]];
            
            cell.headingLable.text=[tableData[indexPath.row] valueForKey:@"title"];
            
            cell.desciptionLable.text=[tableData[indexPath.row] valueForKey:@"discription"];
            
            
            NSMutableDictionary *cb = [[NSMutableDictionary alloc] init];
            [cb setObject:[tableData[indexPath.row] valueForKey:@"id"] forKey:@"id"];
            newsSeenTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countUpdateForNewsSeen:)userInfo:cb repeats:YES];
            
            if([[tableData[indexPath.row] valueForKey:@"add_status"]integerValue]==1)
            {
                addImage1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height-54, self.view.frame.size.width, 54)];
                addImage1.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"add_img_path"]];
                addImage1.tag=10009;
                addImage1.contentMode=UIViewContentModeScaleToFill;
                addImage1.clipsToBounds=YES;
                addImage1.backgroundColor=[UIColor clearColor];
                [cell addSubview:addImage1];
                
                addImageButton =  [UIButton buttonWithType:UIButtonTypeCustom];
                addImageButton.tag=80000+indexPath.row;
                [addImageButton addTarget:self action:@selector(goToMatchScreen:) forControlEvents:UIControlEventTouchUpInside];
                [addImageButton setFrame:CGRectMake(0, cell.frame.size.height-54, self.view.frame.size.width, 54)];
                [addImageButton setExclusiveTouch:YES];
                addImageButton.backgroundColor=[UIColor clearColor];
                [cell addSubview:addImageButton];
            }
            else
            {
                [addImage1  removeFromSuperview];
                [addImageButton removeFromSuperview];
            }
            
            
            if(indexPath.row==tableData.count-8)
            {
                count++;
                [self loadMoreData];
            }
            
            NSString *st;
            st=[NSString stringWithFormat:@" #%@",[fullNews valueForKey:@"name"]];
            if([st isEqualToString:@" #(null)"])
                st=@" #All news";
            CGSize constraintSize;
            constraintSize.height = 20;
            constraintSize.width = MAXFLOAT;
            NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  cell.hashLable.font, NSFontAttributeName,
                                                  nil];
            
            CGRect frame = [st boundingRectWithSize:constraintSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributesDictionary
                                            context:nil];
            
            CGSize stringSize = frame.size;
            cell.hashLable.text=st;
            cell.hashLable.frame=CGRectMake(self.view.frame.size.width-stringSize.width-12, cell.hashLable.frame.origin.y, stringSize.width+10, 22.5);
            
            
            
            
            ////////////////////////////////////////////video player////////////////////////////////////////
            
            if([[tableData[indexPath.row] valueForKey:@"type"]integerValue]==2)
            {
                NSArray* foo = [[tableData[indexPath.row] valueForKey:@"img_path"] componentsSeparatedByString: @"="];
                if(foo.count>1)
                {
                    NSString* firstBit = [foo objectAtIndex: 1];
                    cell.mainImage.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",firstBit]];
                    cell.playButton.hidden=false;
                    cell.playButton.tag=indexPath.row;
                    [cell.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else
            {
                ;
                cell.playButton.tag=indexPath.row;
                [cell.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                cell.playButton.hidden=YES;
                cell.mainImage.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
            }
            
            /////////     //////////////////Survay Oprions////////////////////////////
            
            if([[tableData[indexPath.row] valueForKey:@"type"]integerValue]==4)
            {
                cell.survayView.hidden=false;
                cell.hashLable.hidden=YES;
                cell.submitButton.layer.cornerRadius=8.0;
                cell.submitButton.clipsToBounds=true;
                cell.survayTitle.text=[tableData[indexPath.row] valueForKey:@"title"];
                tablePossition=(int)indexPath.row;
                cell.selectFeild.delegate=self;
                cell.submitButton.tag=indexPath.row;
                
                
                
                if([[tableData[indexPath.row] valueForKey:@"extra"]integerValue] ==1)
                {
                    cell.selectFeild.text=@"Please Select Your Answer";
                }
                else
                {
                    cell.selectFeild.text=@"Please Select Multiple Answers";
                }
                
                
                [cell.submitButton addTarget:self action:@selector(survaySubmit:) forControlEvents:UIControlEventTouchUpInside];
                if([[tableData[indexPath.row] valueForKey:@"survey_view"] isEqualToString:@"yes"])
                {
                    cell.survaySelectedOptions.text=selectedString;
                    //
                }
                else
                {
                    cell.survaySelectedOptions.text=[NSString stringWithFormat:@"Your submited Answer: %@",[tableData[indexPath.row] valueForKey:@"survey_user_ans"]] ;
                    cell.submitButton.hidden=true;
                    cell.selectFeild.userInteractionEnabled=false;
                    
                }
                
                
                
                
                
            }
            else
            {
                selectedString=@"";
                cell.survayView.hidden=true;
                cell.hashLable.hidden=NO;
            }
            
            
            
            UIButton *button;
            AsyncImageView *bigimg1;
            
            
            /////////////////////For Image Post//////////////////////////////////////////
            if([[tableData[indexPath.row] valueForKey:@"type"]integerValue]==3)
            {
                cell.bigImagePost.hidden=YES;
                // cell.bigImagePost.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
                
                bigimg1=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, 1, self.view.frame.size.width-4, self.view.frame.size.height-75-2)];
                bigimg1.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
                bigimg1.tag=10000+indexPath.row;
                bigimg1.contentMode=UIViewContentModeScaleToFill;
                bigimg1.clipsToBounds=YES;
                bigimg1.backgroundColor=[UIColor whiteColor];
                [cell addSubview:bigimg1];
                
                
                button = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
                [button addTarget:self action:@selector(shareOnSocialMedia:) forControlEvents:UIControlEventTouchUpInside];
                // [button setTitle:@"Show View" forState:UIControlStateNormal];
                button.tag=10000+indexPath.row;
                [button setBackgroundImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
                button.frame = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height-75+2-60, 50, 50.0);
                [cell addSubview:button];
            }
            else
            {
                cell.bigImagePost.hidden=YES;
                [button removeFromSuperview];
                [bigimg1 removeFromSuperview];
            }
            
            
            ////////////////////////////////////////////For invite your Friend////////////////////////////////
            UIButton *button1;
            AsyncImageView *bigimg2;
            if([[tableData[indexPath.row] valueForKey:@"type"]integerValue]==7)
            {
                cell.bigImagePost.hidden=YES;
                // cell.bigImagePost.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
                
                bigimg2=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, 1, self.view.frame.size.width-4, self.view.frame.size.height-75-2)];
                bigimg2.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
                
                //bigimg2.image=[UIImage imageNamed:@"Invite"];
                bigimg2.tag=10000+indexPath.row;
                bigimg2.contentMode=UIViewContentModeScaleAspectFill;
                bigimg2.clipsToBounds=YES;
                bigimg2.backgroundColor=[UIColor whiteColor];
                [cell addSubview:bigimg2];
                
                
                button1 = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
                [button1 addTarget:self action:@selector(inviteYourFriend:) forControlEvents:UIControlEventTouchUpInside];
                // [button setTitle:@"Show View" forState:UIControlStateNormal];
                button1.tag=10000+indexPath.row;
                button1.frame = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height-75+2-190, 50, 150.0);
                [cell addSubview:button1];
            }
            else
            {
                cell.bigImagePost.hidden=YES;
                [button1 removeFromSuperview];
                [bigimg2 removeFromSuperview];
            }
            
            ////////////////////////////////////////////For Rate Us////////////////////////////////
            UIButton *button2;
            AsyncImageView *bigimg3;
            if([[tableData[indexPath.row] valueForKey:@"type"]integerValue]==6)
            {
                cell.bigImagePost.hidden=YES;
                // cell.bigImagePost.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
                
                bigimg3=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, 1, self.view.frame.size.width-4, self.view.frame.size.height-75-2)];
                bigimg3.imageURL=[NSURL URLWithString:[tableData[indexPath.row] valueForKey:@"img_path"]];
                
                //bigimg3.image=[UIImage imageNamed:@"thankyou"];
                bigimg3.tag=10000+indexPath.row;
                bigimg3.contentMode=UIViewContentModeScaleAspectFill;
                bigimg3.clipsToBounds=YES;
                bigimg3.backgroundColor=[UIColor whiteColor];
                [cell addSubview:bigimg3];
                
                
                button2 = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
                [button2 addTarget:self action:@selector(rateTheApp:) forControlEvents:UIControlEventTouchUpInside];
                button2.tag=10000+indexPath.row;
                button2.frame = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height-75+2-190, 50, 150.0);
                [cell addSubview:button2];
            }
            else
            {
                cell.bigImagePost.hidden=YES;
                [button2 removeFromSuperview];
                [bigimg3 removeFromSuperview];
            }
            
            
            
            
            
            
            
            
            
            
            
            
            if([tableData[indexPath.row] objectForKey:@"extra_img"])
            {
                for(int i=0;i<[[tableData[indexPath.row] objectForKey:@"extra_img"] count];i++)
                {
                    bigimg=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, ((self.view.frame.size.height-75)*i)+self.view.frame.size.height-75+2, self.view.frame.size.width-4, self.view.frame.size.height-75-4)];
                    bigimg.imageURL=[NSURL URLWithString:[[[tableData[indexPath.row]valueForKey:@"extra_img"] objectAtIndex:i] valueForKey:@"img_path"]];
                    bigimg.tag=1000+i;
                    bigimg.contentMode=UIViewContentModeScaleAspectFill;
                    bigimg.clipsToBounds=YES;
                    [cell addSubview:bigimg];
                    
                    
                    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
                    [button addTarget:self action:@selector(shareOnSocialMedia:) forControlEvents:UIControlEventTouchUpInside];
                    // [button setTitle:@"Show View" forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
                    button.frame = CGRectMake(self.view.frame.size.width/2-25, ((self.view.frame.size.height-75)*i)+self.view.frame.size.height-75+2-90+self.view.frame.size.height-75-4, 50, 50.0);
                    [cell addSubview:button];
                    
                    
                }
                
            }
            
            
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName value:[tableData[indexPath.row] valueForKey:@"title"]];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            // [self.playerView loadWithVideoId:@"M7lc1UVf-VE"];
            
            
            return cell;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==100)
    {
        
    }
}
-(void)inviteYourFriend:(UIButton*)btn
{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1165082423566165"];
    //[FBSDKAppInviteDialog showFromViewController:self withContent:content delegate:self];
    [FBSDKAppInviteDialog showWithContent:content delegate:nil];
}
-(void)rateTheApp:(UIButton*)btn
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1126803446&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]]];
}
-(void)bookmarkAction:(UIButton*)btn
{
    NSLog(@"%ld",(long)btn.tag);
    //    CABasicAnimation *theAnimation;
    //    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    //    theAnimation.duration=1.0;
    //
    //    theAnimation.repeatCount=1;
    //    theAnimation.autoreverses=NO;
    //    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    //    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    //    [btn.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    if([[tableData[btn.tag]valueForKey:@"book_flag"]intValue]==0)
    {
        [tableData[btn.tag] setValue:[NSNumber numberWithInt:1] forKey:@"book_flag"];
        [btn setBackgroundImage:[UIImage imageNamed:@"bookmark_f"] forState:UIControlStateNormal];
        
        if([Utilities CheckInternetConnection])//0: internet working
        {
            [newsSeenTimer invalidate];
            
            
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *email=[u objectForKey:@"deviceToken"];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                    path:[NSString stringWithFormat:@"/api/v3/bookmark_insert?news_id=%d&email=%@",[[tableData[btn.tag]valueForKey:@"id"]intValue],email]
                                                              parameters:nil];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // Print the response body in text
                //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                
                
                
                NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                
                if (JSONdata != nil) {
                    
                    NSError *e;
                    NSMutableDictionary *JSON =
                    [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &e];
                    
                    NSLog(@"bookmark result: %@", JSON);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [operation start];
            
            
            
            
            
        }
    }
    else
    {
        [tableData[btn.tag] setValue:[NSNumber numberWithInt:0] forKey:@"book_flag"];
        [btn setBackgroundImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
        
        if([Utilities CheckInternetConnection])//0: internet working
        {
            [newsSeenTimer invalidate];
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *email=[u objectForKey:@"deviceToken"];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                    path:[NSString stringWithFormat:@"/api/v3/bookmark_edit?news_id=%d&email=%@",[[tableData[btn.tag]valueForKey:@"id"]intValue],email]
                                                              parameters:nil];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                
                if (JSONdata != nil) {
                    
                    NSError *e;
                    NSMutableDictionary *JSON =
                    [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &e];
                    NSLog(@"bookmark result: %@", JSON);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [operation start];
        }
    }
}
-(void)checkSelect:(UIButton*)btn
{
    if([[tableData[tablePossition] valueForKey:@"extra"]integerValue] ==1)
    {
        if ([selectedString rangeOfString:[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]].location == NSNotFound) {
            
            
            
            selectedIdString=[NSString stringWithFormat:@"%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]];
            selectedString=[NSString stringWithFormat:@"Your selected option is: %@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]];
            
            
        }
        else
        {
            selectedString = [selectedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]] withString:@""];
            selectedIdString = [selectedIdString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]] withString:@""];
            
            
            selectedString = [selectedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]] withString:@""];
            selectedIdString = [selectedIdString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]] withString:@""];
            
            if([selectedString isEqualToString:@"Your selected option is:"])
            {
                selectedString=@"";
            }
            
        }
        // cell.selectFeild.text=@"Please Select Your Answer";
    }
    else
    {
        if ([selectedString rangeOfString:[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]].location == NSNotFound) {
            
            if([selectedString isEqualToString:@""]||[selectedString isEqualToString:@"Your selected options are: "])
            {
                selectedIdString=[NSString stringWithFormat:@"%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]];
                selectedString=[NSString stringWithFormat:@"Your selected options are: %@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]];
            }
            else
            {
                selectedIdString=[NSString stringWithFormat:@"%@,%@",selectedIdString,[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]];
                selectedString=[NSString stringWithFormat:@"%@,%@",selectedString,[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]];
            }
            
        }
        else
        {
            
            selectedString = [selectedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]] withString:@""];
            selectedIdString = [selectedIdString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]] withString:@""];
            
            
            selectedString = [selectedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"option_name"]] withString:@""];
            selectedIdString = [selectedIdString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:btn.tag ]valueForKey:@"id"]] withString:@""];
            
            if([selectedString isEqualToString:@"Your selected options are:"])
            {
                selectedString=@"";
            }
            
        }
        
    }
    
    
    [tableViewSelect reloadData];
    [mainTable reloadData];
}



-(void)countUpdateForNewsSeen:(NSTimer *)timer {
    
    NSDictionary *dict = [timer userInfo];
    counterNewsSeen++;
    if(oldID==0)
    {
        oldID=[dict valueForKey:@"id"];
    }
    if([Utilities CheckInternetConnection] && ![oldID isEqualToString:[dict valueForKey:@"id"]])//0: internet working
    {
        //[newsSeenTimer invalidate];
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/setnews_viewtime?news_id=%@&email=%@&timec=%d",oldID,email,counterNewsSeen]
                                                          parameters:nil];
        oldID=[dict valueForKey:@"id"];
        counterNewsSeen=0;
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                NSLog(@"time Result: %@", JSON);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
        
        
        
        
    }
}
-(void)fbShareAction:(UIButton*)btn
{
    
    CGRect rect =[self.view bounds];// [self.view bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer  renderInContext:context];
    UIImage *img1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImage *image  = [self cropImage:img1];     //= [UIImage imageNamed:@"share320.jpg"];
    UIImage *im=[UIImage imageNamed:@"share320.jpg"];
    
    
    
    
    
    
    
    
    //foreground image
    CGSize newSize;
    if(self.view.frame.size.width==375)
        newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-100);
    else if(self.view.frame.size.width==320)
        newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-50);
    else if(self.view.frame.size.width==414)
        newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-100);
    else
        newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-200);
    
    
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    if(self.view.frame.size.width==375)
        [im drawInRect:CGRectMake(0,self.view.frame.size.height-135,self.view.frame.size.width,35) blendMode:kCGBlendModeNormal alpha:1.0];
    else if(self.view.frame.size.width==320)
        [im drawInRect:CGRectMake(0,self.view.frame.size.height-75,self.view.frame.size.width,25) blendMode:kCGBlendModeNormal alpha:1.0];
    else if(self.view.frame.size.width==414)
        [im drawInRect:CGRectMake(0,self.view.frame.size.height-135,self.view.frame.size.width,35) blendMode:kCGBlendModeNormal alpha:1.0];
    else
        [im drawInRect:CGRectMake(self.view.frame.size.width/2-160,self.view.frame.size.height-240,320,25) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    
    
    
    
    slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [slComposer addImage:newImage];
    
    //  [slComposer addImage:[UIImage imageWithContentsOfFile:[path_file objectAtIndex:number_to_be_shared]]];
    
    SLComposeViewControllerCompletionHandler handler = ^(SLComposeViewControllerResult result)
    {
        switch (result)
        {
            case SLComposeViewControllerResultDone:
                break;
            case SLComposeViewControllerResultCancelled:
                break;
            default:
                break;
        }
    };
    slComposer.completionHandler = handler;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:slComposer animated:YES completion:nil];
    
    
    
    
    //    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    //    content.contentURL = [NSURL URLWithString:[tableData[btn.tag]valueForKey:@"fb_url"]];
    //
    //
    //
    //    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    //    dialog.shareContent = content;
    //    dialog.fromViewController = self;
    //
    //    if (![dialog canShow]) {
    //        // fallback presentation when there is no FB app
    //        dialog.mode = FBSDKShareDialogModeFeedBrowser;
    //    }
    //    [dialog show];
    
    
    
    //    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    //    dialog.fromViewController = self;
    //    dialog.shareContent=content;
    //    //dialog.content = content;
    //    dialog.mode = FBSDKShareDialogModeShareSheet;
    //    [dialog show];
}

-(void)likeAction:(UIButton*)btn
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        if(![[tableData[btn.tag]valueForKey:@"like"]isEqualToString:@"no"])
        {
            //            [btn setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
            //            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            NSLog(@"%@",[btn titleForState:UIControlStateNormal]);
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:tableData[btn.tag]];
            [dict setValue:@"yes" forKey:@"like"];
            [dict setValue:[NSString stringWithFormat:@"%d",[[btn titleForState:UIControlStateNormal]intValue]+1] forKey:@"like_count"];
            [tableData replaceObjectAtIndex:btn.tag withObject:dict];
            [btn setTitle:[NSString stringWithFormat:@"%d",[[btn titleForState:UIControlStateNormal]intValue]+1] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"likeSelected"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor purpleColor];
            
            [btn setTitleColor:[UIColor colorWithRed:55.0/255.0 green:90.0/255.0 blue:196.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            
            
            
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *email=[u objectForKey:@"deviceToken"];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                    path:[NSString stringWithFormat:@"/api/v3/news_like?news_id=%@&email=%@",[tableData[btn.tag]valueForKey:@"id"],email]
                                                              parameters:nil];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // Print the response body in text
                //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                
                
                
                NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                
                if (JSONdata != nil) {
                    
                    NSError *e;
                    NSMutableDictionary *JSON =
                    [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &e];
                    
                    NSLog(@"Like_Result: %@", JSON);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [operation start];
        }
    }
    else
    {
//        UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"" message:@"No Internet Connection. Please Check Your Internet Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [al show];
//        al=nil;
    }
    
}
//- (UIImage *)cropImage:(UIImage *)oldImage {
//
//    CGSize imageSize = oldImage.size;
//
//    UIGraphicsBeginImageContextWithOptions( CGSizeMake( imageSize.width, imageSize.height - 200),NO,  0.);
//    [oldImage drawAtPoint:CGPointMake( 0, -100)
//                blendMode:kCGBlendModeCopy
//                    alpha:1.];
//
//    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    return croppedImage;
//}
- (CGRect) TransformCGRectForUIImageOrientation: (CGRect) source: (UIImageOrientation) orientation: (CGSize) imageSize {
    
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI + M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            return source;
    }
    
}
- (UIImage *) cropImage: (UIImage *) originalImage
{
    
    CGRect cropRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
    
    CGRect transformedRect = [self TransformCGRectForUIImageOrientation:cropRect :originalImage.imageOrientation :originalImage.size];
    
    CGImageRef resultImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, transformedRect);
    
    UIImage *newImage = [[UIImage alloc] initWithCGImage:resultImageRef scale:1.0 orientation:originalImage.imageOrientation] ;
    
    return newImage;
}
-(void)shareOnSocialMedia:(UIButton*)btn
{
    
    CGRect rect =[self.view bounds];// [self.view bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer  renderInContext:context];
    UIImage *img1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImage *image  = [self cropImage:img1];     //= [UIImage imageNamed:@"share320.jpg"];
    UIImage *im=[UIImage imageNamed:@"share320.jpg"];
    
    
    
    
    
    
    
    
    //foreground image
    CGSize newSize;
    if(self.view.frame.size.width==375)
        newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-100);
    else if(self.view.frame.size.width==320)
        newSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-50);
    
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    if(self.view.frame.size.width==375)
        [im drawInRect:CGRectMake(0,self.view.frame.size.height-135,self.view.frame.size.width,35) blendMode:kCGBlendModeNormal alpha:1.0];
    else if(self.view.frame.size.width==320)
        [im drawInRect:CGRectMake(0,self.view.frame.size.height-75,self.view.frame.size.width,25) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    
    UIImage *shareImage = newImage;
    // NSURL *shareURL = [NSURL URLWithString:@""];
    NSMutableArray *activityItems = [NSMutableArray arrayWithObjects: shareImage, nil];
    
    
    //NSArray *activityProviders = @[@"Download SportsFlashes for Sports, News, Trivias, Predictions & Gosips For Iphone/Ipad https://goo.gl/jYrUfd & For Android https://goo.gl/L8H4iR", shareImage,shareURL];
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems  applicationActivities:nil];
    if(self.view.frame.size.height>700)
    {
        activityVC.popoverPresentationController.sourceView = btn;
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else
    {
        activityVC.excludedActivityTypes = nil ;
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}
-(void)moreLinkAction:(UIButton*)btn
{
    
    NSString *urlStr=[NSString stringWithFormat:@"%@",[tableData[btn.tag]valueForKey:@"newsurl"]];
    if ([urlStr rangeOfString:@"http"].location == NSNotFound) {
        urlStr=[NSString stringWithFormat:@"http://%@",urlStr];    }
    else {
    }
//    UIApplication *application = [UIApplication sharedApplication];
//    [application openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
//    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    
    
}
-(IBAction)scrollOnTop:(id)sender
{
    [mainTable setContentOffset:CGPointZero animated:YES];
    
}
-(IBAction)refreshAllData:(id)sender
{
    [self allNewsAcordingToCategoryServerHit];
}
-(void)allNewsAcordingToCategory:(NSNotification*)noty
{
    
    NSDictionary *dict = [noty userInfo];
    cat_id=[dict valueForKey:@"cat_id"];
    if([cat_id integerValue]==52680 || [cat_id integerValue]==52681 || [cat_id integerValue]==52682 || [cat_id integerValue]==52683 || [cat_id integerValue]==52684)
    {
        liveScoreCategoryView *smvc;
        int height = [UIScreen mainScreen].bounds.size.height;
        if (height == 480) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreCategoryView"];
            
        }
        else if (height == 568) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreCategoryView"];
            
        }
        else if (height == 667) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreCategoryView"];
            
        }
        else if (height == 736) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreCategoryView"];
            
        }
        else if (height == 1024) {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreCategoryView"];
            
        }
        else
        {
            
            
            smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreCategoryView"];
            
        }
        
        [self.navigationController pushViewController:smvc animated:YES];
    }
    else
    {
        [self allNewsAcordingToCategoryServerHit];
    }
    
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
    
}
-(void)allNewsAcordingToCategoryServerHit
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        count=0;
        if((cat_id == (id)[NSNull null] || cat_id.length == 0 ))
        {
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSMutableArray  *catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
            cat_id=[[[catArr valueForKey:@"data_top"]objectAtIndex:0]valueForKey:@"id"];
        }
        HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText=@"Please Wait";
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request ;
        if([cat_id isEqualToString:@"919191"])
        {
            //http://sportsflashes.com/api/v3/find_bookmarks?email=gopal@gmail.com&ln=1
            request = [httpClient requestWithMethod:@"GET"
                                               path:[NSString stringWithFormat:@"/api/v3/find_bookmarks?email=%@&ln=%@",email,selectedLang]
                                         parameters:nil];
            
        }
        else
        {
            request = [httpClient requestWithMethod:@"GET"
                                               path:[NSString stringWithFormat:@"/api/v3/allnews_cat?offset=%d&email=%@&cat_id=%@&ln=%@",count,email,cat_id,selectedLang]
                                         parameters:nil];
        }
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                    [userDefaults setObject:data forKey:@"news"];
                    [userDefaults synchronize];
                    
                    
                    
                    fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
                    engNews=[[fullNews valueForKey:@"data"]mutableCopy];
                    readCount=[[fullNews valueForKey:@"unread"]intValue];
                    [refeshControl endRefreshing];
                    loaderView.hidden=YES;
                    [mainTable reloadData];
                    [self scrollOnTop:0];
                    [HUD hide:YES];
                    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    if([[fullNews valueForKey:@"live_status"]intValue]==1)
                    {
                        appDelegate.liveoFound=YES;
                    }
                    else
                    {
                        appDelegate.liveoFound=false;
                        
                    }
                    
                }
            }
        }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Error: %@", error);
                                             [HUD hide:YES];
                                         }];
        [operation start];
        
    }
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        
        
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        if([lang isEqualToString:@"english"])
        {
            lang=[NSString stringWithFormat:@"%d",1];
            [u setObject:[NSString stringWithFormat:@"%d",1] forKey:@"lang"];
            [u synchronize];
            
            
        }
        
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/categories_feed?email=%@&ln=%@",email,lang]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:JSON forKey:@"cat_myfeed"];
                    [userDefaults synchronize];
                }
                
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
    }

    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
-(void)loadMoreData
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        if((cat_id == (id)[NSNull null] || cat_id.length == 0 ))
        {
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSMutableArray  *catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
            cat_id=[[[catArr valueForKey:@"data_top"]objectAtIndex:0]valueForKey:@"id"];
        }
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/allnews_cat?offset=%d&email=%@&cat_id=%@&ln=%@",10*count,email,cat_id,selectedLang]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    
                    
                    fullNews = [JSON mutableCopy];
                    if([[fullNews valueForKey:@"data"] count]==0)
                    {
                        refreshView=1;
                    }
                    for(int i=0;i<[[fullNews valueForKey:@"data"] count];i++)
                    {
                        if (![engNews containsObject: [fullNews valueForKey:@"data"][i]])
                            [engNews addObject:[fullNews valueForKey:@"data"][i]];
                        
                    }
                    
                    NSMutableArray *arr=[[u objectForKey:@"oflineNews"]mutableCopy];
                    for(int i=0;i<[[fullNews valueForKey:@"data"] count];i++)
                    {
                        if (![arr containsObject: [fullNews valueForKey:@"data"][i]])
                        {
                            [arr addObject:[fullNews valueForKey:@"data"][i]];
                        }
                        
                    }
                    [u setObject:arr forKey:@"oflineNews"];
                    [u synchronize];
                    [arr removeAllObjects];
                    // [engNews addObjectsFromArray:[fullNews valueForKey:@"data_en"]];;
                    // [hindiNews addObjectsFromArray:[fullNews valueForKey:@"data_hn"]];;
                    
                    [refeshControl endRefreshing];
                    loaderView.hidden=YES;
                    [mainTable reloadData];
                    
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            loaderView.hidden=YES;
        }];
        [operation start];
    }
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
-(void)saveDataInUserDefault:(NSMutableDictionary*)dict
{
    /*
     AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
     managedObjectContext = [appDel managedObjectContext];
     NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"NewsTable" inManagedObjectContext:managedObjectContext];
     [newDevice setValue:@"" forKey:@"name"];
     [newDevice setValue:@"" forKey:@"city"];
     NSError *error = nil;
     if ([managedObjectContext save:&error]) {
     NSLog(@"data saved");
     }
     else{
     NSLog(@"Error occured while saving");
     }
     */
    
    
}
-(void)playVideo:(UIButton*)btn
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        [self restrictRotation:NO];
        videoView.hidden=false;
        closeVideoButton.hidden=false;
        
        [closeVideoButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        NSArray* foo = [[tableData[btn.tag] valueForKey:@"img_path"] componentsSeparatedByString: @"="];
        if(foo.count>1)
        {
            
//             static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
//            
//            
//            NSString *html = [NSString stringWithFormat:youTubeVideoHTML, self.view.frame.size.width, self.view.frame.size.height, [foo objectAtIndex: 1]];
//            
//            [webv loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
            
            
            
            
//            NSString *youTubeVideoHTML = @"<html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = 'http://www.youtube.com/player_api'; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'320', height:'300', videoId:'sLVGweQU7rQ', events: { 'onReady': onPlayerReady } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
//            
//            NSString *html = [NSString stringWithFormat:youTubeVideoHTML, [foo objectAtIndex: 1]];
//            
//            UIWebView *videoVieww = [[UIWebView alloc] initWithFrame:CGRectMake(0, 300, 320, 300)];
//            videoVieww.backgroundColor = [UIColor clearColor];
//            videoVieww.opaque = NO;
//            //videoView.delegate = self;
//            [self.view addSubview:videoVieww];
//            
//            videoVieww.mediaPlaybackRequiresUserAction = NO;
//            
//            [videoVieww loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
            
            
            
            
            
            
            NSString* firstBit = [foo objectAtIndex: 1];
            if(foo.count==3)
                firstBit = [NSString stringWithFormat:@"%@=%@",[foo objectAtIndex: 1],[foo objectAtIndex: 2]];
            NSDictionary *playerVars = @{
                                         @"controls" : @"1",
                                         @"playsinline" : @"1",
                                         @"autohide" : @"1",
                                         @"showinfo" : @"1",
                                         @"autoplay" : @"1",
                                         @"fs" : @"0",
                                         @"rel" : @"0",
                                         @"loop" : @"0",
                                         @"enablejsapi" : @"1",
                                         @"modestbranding" : @"0",
                                         };
            
            [self.playerView loadWithVideoId:firstBit playerVars:playerVars];
            // [self.playerView loadWithVideoId:firstBit];
            self.playerView.delegate=self;
        }
    }
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //        //=============Portrait===============
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if(iphone5)
        {
            videoView.frame=CGRectMake(0, 0, 320,568);
            _playerView.frame=CGRectMake(0, 90, 320,219);
            topStatusBar.hidden=false;
        }
        else if(iphone4)
        {
            videoView.frame=CGRectMake(0, 0, 320,480);
            _playerView.frame=CGRectMake(0, 38,320, 219);
            topStatusBar.hidden=false;
        }
        else if(iphone6)
        {
            videoView.frame=CGRectMake(0, 0, 375,667);
            _playerView.frame=CGRectMake(0, 90, 375,255);
            topStatusBar.hidden=false;
        }
        else if(iphone6P)
        {
            videoView.frame=CGRectMake(0, 0, 414,736);
            _playerView.frame=CGRectMake(0, 90, 414,255);
            topStatusBar.hidden=false;
        }
        else if(ipad)
        {
            videoView.frame=CGRectMake(0, 0,768,1024);
            _playerView.frame=CGRectMake(0,131, 768,413);
            topStatusBar.hidden=false;
        }
        else
        {
            videoView.frame=CGRectMake(0, 0,1024, 1366);
            _playerView.frame=CGRectMake(0, 241, 1024,547);
            topStatusBar.hidden=false;
        }
        
    }
    else
    {
        if(iphone5)
        {
            videoView.frame=CGRectMake(0, 0,self.view.frame.size.height, self.view.frame.size.width);
            topStatusBar.hidden=YES;
            videoView.frame=CGRectMake(0, 0, 568,320);
            _playerView.frame=CGRectMake(0, 0, 568,320);
        }
        else if(iphone4)
        {
            videoView.frame=CGRectMake(0, 0,self.view.frame.size.height, self.view.frame.size.width);
            topStatusBar.hidden=YES;
            videoView.frame=CGRectMake(0, 0, 420,320);
            _playerView.frame=CGRectMake(0, 0, 420,320);
        }
        else if(iphone6)
        {
            videoView.frame=CGRectMake(0, 0,self.view.frame.size.height, self.view.frame.size.width);
            topStatusBar.hidden=YES;
            videoView.frame=CGRectMake(0, 0, 667,375);
            _playerView.frame=CGRectMake(0, 0, 667,375);
            
        }
        else if(iphone6P)
        {
            videoView.frame=CGRectMake(0, 0,self.view.frame.size.height, self.view.frame.size.width);
            topStatusBar.hidden=YES;
            videoView.frame=CGRectMake(0, 0, 736,414);
            _playerView.frame=CGRectMake(0, 0, 736,414);
        }
        else if(ipad)
        {
            videoView.frame=CGRectMake(0, 0,self.view.frame.size.height, self.view.frame.size.width);
            topStatusBar.hidden=YES;
            videoView.frame=CGRectMake(0, 0, 1024,768);
            _playerView.frame=CGRectMake(0, 0, 1024,768);
            
        }
        else
        {
            videoView.frame=CGRectMake(0, 0,self.view.frame.size.height, self.view.frame.size.width);
            topStatusBar.hidden=YES;
            videoView.frame=CGRectMake(0, 0, 1366,1024);
            _playerView.frame=CGRectMake(0, 0, 1366,1024);
        }
        
        
        
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [topStripTimer invalidate];
    [navHideTimer invalidate];
}
-(IBAction)closeFullScreenMode:(UIButton*)sender
{
    [self restrictRotation:YES];
    videoView.hidden=true;
    [self.playerView stopVideo];
    
}
-(void) restrictRotation:(BOOL) restriction
{
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}
-(void)callServiceForNotification
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        count=0;
        if((cat_id == (id)[NSNull null] || cat_id.length == 0 ))
        {
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSMutableArray  *catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
            cat_id=[[[catArr valueForKey:@"data_top"]objectAtIndex:0]valueForKey:@"id"];
        }
        HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText=@"Please Wait";
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/allnews_cat?offset=%d&email=%@&cat_id=%@&limit=100",count,email,cat_id]
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Print the response body in text
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            
            
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (JSONdata != nil) {
                
                NSError *e;
                NSMutableDictionary *JSON =
                [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                options: NSJSONReadingMutableContainers
                                                  error: &e];
                
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                    [userDefaults setObject:data forKey:@"news"];
                    [userDefaults synchronize];
                    
                    
                    
                    fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
                    engNews=[[fullNews valueForKey:@"data_en"]mutableCopy];
                    hindiNews=[[fullNews valueForKey:@"data_hn"]mutableCopy];
                    [refeshControl endRefreshing];
                    scrollPossition=0;
                    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    for(int i=0;i<engNews.count;i++)
                    {
                        if([[engNews[i]valueForKey:@"id"]intValue]==appDelegate.notiNewsId)
                        {
                            scrollPossition=i;
                            break;
                        }
                        
                    }
                    
                    loaderView.hidden=YES;
                    [mainTable reloadData];
                    [HUD hide:YES];
                }
            }
        }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Error: %@", error);
                                             [HUD hide:YES];
                                         }];
        [operation start];
        
    }
    if(!navigationBar.hidden)
        navigationBar.hidden=true;
    unreadViewLbl.hidden=true;
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField

{
    survayTableView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    survayTableView.backgroundColor=[UIColor clearColor];
    survayTableView.tag=90;
    
    [self.view removeGestureRecognizer:hideShowNavigation];
    tableViewSelect = [[UITableView alloc] initWithFrame:CGRectMake(40, survayTableView.frame.size.height/2-200, survayTableView.frame.size.width-80, 250) style:UITableViewStylePlain];
    tableViewSelect.delegate = self;
    tableViewSelect.dataSource = self;
    tableViewSelect.tag=100;
    tableViewSelect.backgroundColor = [UIColor whiteColor];
    [survayTableView addSubview:tableViewSelect];
    
    [self.view addSubview:survayTableView];
    
    return false;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    return false;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    //CGPoint touchLocation = [touch locationInView:touch.view];
    
    if(touch.view.tag==90)
    {
        [survayTableView removeFromSuperview];
        hideShowNavigation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideShowNavigationAction:)];
        [self.view addGestureRecognizer:hideShowNavigation];
        
    }
}
-(void)survaySubmit:(UIButton*)btn
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        if([selectedIdString isEqualToString:@""])
        {
            
        }
        else
        {
            HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText=@"Please Wait";
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *email=[u objectForKey:@"deviceToken"];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                    path:[NSString stringWithFormat:@"/api/v3/survey_answer?survey_id=%@&email=%@&opt_id=%@",[tableData[btn.tag] valueForKey:@"id"],email,selectedIdString]
                                                              parameters:nil];
            selectedIdString=@"";
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
                
                NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                
                if (JSONdata != nil) {
                    
                    NSError *e;
                    NSMutableDictionary *JSON =
                    [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &e];
                    
                    if([[JSON valueForKey:@"error"]integerValue] ==0)
                    {
                        
                        [HUD hide:YES];
                    }
                }
            }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Error: %@", error);
                                                 [HUD hide:YES];
                                             }];
            [operation start];
        }
    }
}
-(void)searchnews
{
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSData *data = [u objectForKey:@"news"];
    fullNews = [[NSKeyedUnarchiver unarchiveObjectWithData:data]mutableCopy];
    selectedLang=[u objectForKey:@"lang"];
    engNews=[[fullNews valueForKey:@"data"]mutableCopy];
    [mainTable reloadData];
}
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStatePlaying:
            NSLog(@"Started playback");
            break;
        case kYTPlayerStatePaused:
            NSLog(@"Paused playback");
            break;
        default:
            break;
    }
}
-(void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
    [self.playerView playVideo];
}
-(BOOL) needsUpdate{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    if(data)
    {
        NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        trackId=[NSString stringWithFormat:@"%d",[[[lookup valueForKey:@"results" ] valueForKey:@"trackId"][0]intValue]];
        if ([lookup[@"resultCount"] integerValue] == 1){
            NSString* appStoreVersion = lookup[@"results"][0][@"version"];
            NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
            if (![appStoreVersion isEqualToString:currentVersion]){
                NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
                return YES;
            }
        }
    }
    return NO;
}
-(void)onConversionDataReceived:(NSDictionary*) installData {
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        NSLog(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        NSLog(@"This is an organic install.");
    }
}
-(void)onConversionDataRequestFailure:(NSError *) error {
    NSLog(@"%@",error);
}
- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    NSLog(@"attribution data: %@", attributionData);
}
- (void) onAppOpenAttributionFailure:(NSError *)error {
    NSLog(@"%@",error);
}
@end
