//
//  ScoreBoardViewController.m
//  SportsFlashes
//
//  Created by Apple on 02/11/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "ScoreBoardViewController.h"
#import "AsyncImageView.h"
#import "Utilities.h"
#import "AFNetworking.h"
#import <Google/Analytics.h>
#import "AppDelegate.h"

@interface ScoreBoardViewController ()
{
    NSTimer *t;
    UIView *v1,*v2,*v3,*v;
    
    int totalInning,selectedInning;
    NSMutableDictionary *matchData;
    
}
@end

@implementation ScoreBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"CricScoreBoard Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    scrv.contentSize=CGSizeMake(280, self.view.frame.size.height+30);
    self.view.backgroundColor=[UIColor whiteColor];
    self.bannerView.adUnitID = @"ca-app-pub-4237488103635443/8339330816";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    selectedInning=1;
    t=[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timerCalled)userInfo:nil repeats:YES];
    [self getDataFromServer];
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [t invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)timerCalled
{
    [self getDataFromServer];
    NSLog(@"Timer Called");
    // Your Code
}
-(void)getDataFromServer
{
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSString *score=[u objectForKey:@"unique_id"];//@"33";
    
    headingLabel.text=[u objectForKey:@"MatchName"];
    
    ///api/v3/scoreboard?ln=1&match_id=33
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://sportsflashes.com"]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/scoreboard?ln=%@&match_id=%@",[u objectForKey:@"lang"],score]
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
                    if([JSON objectForKey:@"batsman_4"])
                        totalInning=4;
                    else if([JSON objectForKey:@"batsman_3"])
                        totalInning=3;
                    else if([JSON objectForKey:@"batsman_2"])
                        totalInning=2;
                    else
                        totalInning=1;
                    matchData=[JSON mutableCopy];
                    [self setDataOnScroll];
                    
                }
                
            }
            
            
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
    
}
-(void)setDataOnScroll
{
    for (UIView *Sv in scrv.subviews) {
        [Sv removeFromSuperview];
    }
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if(appDelegate.batOrBowl)
        selectedInning=totalInning;
    else
        selectedInning=totalInning-1;
    
    if(selectedInning==0)
        selectedInning=1;
    
    
    int y=0;
    UIImageView *statusBackView=[[UIImageView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    statusBackView.image=[UIImage imageNamed:@"team-name-bg"];
    [scrv addSubview:statusBackView];
    
    UILabel *matchStatus = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, self.view.frame.size.width, 30)];
    [matchStatus setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
    matchStatus.textAlignment=NSTextAlignmentLeft;
    matchStatus.textColor=[UIColor whiteColor];
    matchStatus.backgroundColor=[UIColor clearColor];
    [matchStatus setText:[NSString stringWithFormat:@" %@",[matchData valueForKey:@"match_status"]]];
    [statusBackView addSubview:matchStatus];
    
    
    y=30;
    
    UIImageView *statusBackView1=[[UIImageView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    statusBackView1.image=[UIImage imageNamed:@"team-name-bg"];
    [scrv addSubview:statusBackView1];
    
    UIFont * myFont = [UIFont fontWithName:@"Arial-BoldMT" size:12];
    int x=totalInning;
    if(x==4)
    {
        int x1=self.view.frame.size.width/4;
        AsyncImageView *team1Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, y+4, 20, 15)];
        team1Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        // [scrv addSubview:team1Image];
        
        UIButton *team1Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team1Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team1Name setFrame:CGRectMake(2, y+4, x1, 15)];
        team1Name.tag=1;
        team1Name.titleLabel.font=myFont;
        [team1Name setTintColor:[UIColor whiteColor]];
        [team1Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team1Name];
        
        
        
        
        AsyncImageView *team2Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(x1+2, y+4, 20, 15)];
        team2Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        //[scrv addSubview:team2Image];
        
        
        UIButton *team2Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team2Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team2Name setFrame:CGRectMake(x1+2, y+4, x1, 15)];
        team2Name.tag=2;
        team2Name.titleLabel.font=myFont;
        [team2Name setTintColor:[UIColor whiteColor]];
        [team2Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team2Name];
        
        
        AsyncImageView *team3Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(x1+x1+2, y+4, 20, 15)];
        team3Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        // [scrv addSubview:team3Image];
        
        UIButton *team3Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team3Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team3Name setFrame:CGRectMake(x1+x1+2, y+4, x1, 15)];
        team3Name.tag=3;
        team3Name.titleLabel.font=myFont;
        [team3Name setTintColor:[UIColor whiteColor]];
        [team3Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra3"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team3Name];
        
        
        
        AsyncImageView *team4Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(x1+x1+x1+2, y+4, 20, 15)];
        team4Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        //[scrv addSubview:team4Image];
        
        UIButton *team4Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team4Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team4Name setFrame:CGRectMake(x1+x1+x1+2, y+4, x1, 15)];
        team4Name.tag=4;
        team4Name.titleLabel.font=myFont;
        [team4Name setTintColor:[UIColor whiteColor]];
        [team4Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra4"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team4Name];
        
        
        
        
        
        if(selectedInning==1)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 5)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 2)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            v3=[[UIView alloc]initWithFrame:CGRectMake(x1+x1+x1, y+20, x1-1, 2)];
            v3.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v3];
        }
        else if(selectedInning==2)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 5)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 2)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            v3=[[UIView alloc]initWithFrame:CGRectMake(x1+x1+x1, y+20, x1-1, 2)];
            v3.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v3];
        }
        else if(selectedInning==3)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 5)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            v3=[[UIView alloc]initWithFrame:CGRectMake(x1+x1+x1, y+20, x1-1, 2)];
            v3.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v3];
        }
        else
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 2)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            v3=[[UIView alloc]initWithFrame:CGRectMake(x1+x1+x1, y+20, x1-1, 5)];
            v3.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v3];
        }
        
        
    }
    else if(x==3)
    {
        int x1=self.view.frame.size.width/3;
        AsyncImageView *team1Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, y+4, 20, 15)];
        team1Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        // [scrv addSubview:team1Image];
        
        UIButton *team1Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team1Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team1Name setFrame:CGRectMake(2, y+4, x1, 15)];
        team1Name.tag=1;
        team1Name.titleLabel.font=myFont;
        [team1Name setTintColor:[UIColor whiteColor]];
        [team1Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team1Name];
        
        
        
        
        AsyncImageView *team2Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(x1+2, y+4, 20, 15)];
        team2Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        //[scrv addSubview:team2Image];
        
        
        UIButton *team2Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team2Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team2Name setFrame:CGRectMake(x1+2, y+4, x1, 15)];
        team2Name.tag=2;
        team2Name.titleLabel.font=myFont;
        [team2Name setTintColor:[UIColor whiteColor]];
        [team2Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team2Name];
        
        
        AsyncImageView *team3Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(x1+x1+2, y+4, 20, 15)];
        team3Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        // [scrv addSubview:team3Image];
        
        UIButton *team3Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team3Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team3Name setFrame:CGRectMake(x1+x1+2,y+4, x1, 15)];
        team3Name.tag=3;
        team3Name.titleLabel.font=myFont;
        [team3Name setTintColor:[UIColor whiteColor]];
        [team3Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra3"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team3Name];
        
        
        
        if(selectedInning==1)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 5)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 2)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            
        }
        else if(selectedInning==2)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 5)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 2)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            
        }
        else if(selectedInning==3)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 5)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            
        }
        else
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            v2=[[UIView alloc]initWithFrame:CGRectMake(x1+x1, y+20, x1-1, 2)];
            v2.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v2];
            
        }
        
        
        
    }
    else if(x==2)
    {
        int x1=self.view.frame.size.width/2;
        AsyncImageView *team1Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, y+4, 20, 15)];
        team1Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        //[scrv addSubview:team1Image];
        
        UIButton *team1Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team1Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team1Name setFrame:CGRectMake(2, y+4, x1, 15)];
        team1Name.tag=1;
        team1Name.titleLabel.font=myFont;
        [team1Name setTintColor:[UIColor whiteColor]];
        [team1Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team1Name];
        
        
        
        
        AsyncImageView *team2Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(x1+2,y+ 4, 20, 15)];
        team2Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        //[scrv addSubview:team2Image];
        
        
        UIButton *team2Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team2Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team2Name setFrame:CGRectMake(x1+2, y+4, x1, 15)];
        team2Name.tag=2;
        team2Name.titleLabel.font=myFont;
        [team2Name setTintColor:[UIColor whiteColor]];
        [team2Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team2Name];
        
        
        
        
        
        
        if(selectedInning==1)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 5)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            
        }
        else if(selectedInning==2)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1,y+ 20, x1-1, 5)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            
            
        }
        else if(selectedInning==3)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            
            
        }
        else
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            v1=[[UIView alloc]initWithFrame:CGRectMake(x1, y+20, x1-1, 2)];
            v1.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v1];
            
            
        }
        
        
        
        
    }
    else
    {
        int x1=self.view.frame.size.width/1;
        AsyncImageView *team1Image=[[AsyncImageView alloc]initWithFrame:CGRectMake(2, y+4, 20, 15)];
        team1Image.imageURL=[NSURL URLWithString:[NSString stringWithFormat:@""]];
        //[scrv addSubview:team1Image];
        
        UIButton *team1Name= [UIButton buttonWithType:UIButtonTypeCustom];
        [team1Name addTarget:self action:@selector(ininingView:) forControlEvents:UIControlEventTouchUpInside];
        [team1Name setFrame:CGRectMake(2, y+4, x1, 15)];
        team1Name.tag=1;
        team1Name.titleLabel.font=myFont;
        [team1Name setTintColor:[UIColor whiteColor]];
        [team1Name setTitle:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"shortname"]] forState:UIControlStateNormal];
        [scrv addSubview:team1Name];
        
        
        if(selectedInning==1)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 5)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            
            
        }
        else if(selectedInning==2)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            
            
        }
        else if(selectedInning==3)
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0, y+20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            
            
        }
        else
        {
            v=[[UIView alloc]initWithFrame:CGRectMake(0,y+ 20, x1-1, 2)];
            v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
            [scrv addSubview:v];
            
            
        }
        
        
        
        
    }
    
    UIImageView *headBackView=[[UIImageView alloc]initWithFrame:CGRectMake(0, y+26, self.view.frame.size.width, 30)];
    //headBackView.image=[UIImage imageNamed:@"team-name-bg"];
    headBackView.backgroundColor=[UIColor lightGrayColor];
    [scrv addSubview:headBackView];
    
    UILabel *teamStatus = [[UILabel alloc] initWithFrame:CGRectMake (0, 4, self.view.frame.size.width-125, 20)];
    [teamStatus setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    teamStatus.textAlignment=NSTextAlignmentLeft;
    teamStatus.textColor=[UIColor blackColor];//[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    teamStatus.backgroundColor=[UIColor clearColor];
    if(selectedInning==1)
        [teamStatus setText:[NSString stringWithFormat:@" %@ %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"inning_name"],[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"inning_run"]]];
    else if(selectedInning==2)
        [teamStatus setText:[NSString stringWithFormat:@" %@ %@",[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"inning_name"],[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"inning_run"]]];
    else if(selectedInning==3)
        [teamStatus setText:[NSString stringWithFormat:@" %@ %@",[[matchData valueForKey:@"team_extra3"][0] valueForKey:@"inning_name"],[[matchData valueForKey:@"team_extra3"][0] valueForKey:@"inning_run"]]];
    else
        [teamStatus setText:[NSString stringWithFormat:@" %@ %@",[[matchData valueForKey:@"team_extra4"][0] valueForKey:@"inning_name"],[[matchData valueForKey:@"team_extra4"][0] valueForKey:@"inning_run"]]];
    [headBackView addSubview:teamStatus];
    
    
    UILabel *r = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-110, 4, 15, 20)];
    [r setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    r.textAlignment=NSTextAlignmentRight;
    r.textColor=[UIColor blackColor];//[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    r.backgroundColor=[UIColor clearColor];
    [r setText:@"R"];
    [headBackView addSubview:r];
    
    UILabel *b = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-80, 4, 15, 20)];
    [b setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    b.textAlignment=NSTextAlignmentRight;
    b.textColor=[UIColor blackColor];//[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    b.backgroundColor=[UIColor clearColor];
    [b setText:@"B"];
    [headBackView addSubview:b];
    
    UILabel *s4 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-50, 4, 15, 20)];
    [s4 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    s4.textAlignment=NSTextAlignmentRight;
    s4.textColor=[UIColor blackColor];//[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    s4.backgroundColor=[UIColor clearColor];
    [s4 setText:@"4s"];
    [headBackView addSubview:s4];
    
    UILabel *s6 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-20, 4, 15, 20)];
    [s6 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    s6.textAlignment=NSTextAlignmentRight;
    s6.textColor=[UIColor blackColor];//[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    s6.backgroundColor=[UIColor clearColor];
    [s6 setText:@"6s"];
    [headBackView addSubview:s6];
    
    
    int z=0;
    if(selectedInning==1)
        z=(int)[[matchData objectForKey:@"batsman_1"] count];
    else if(selectedInning==2)
        z=(int)[[matchData objectForKey:@"batsman_2"] count];
    else if(selectedInning==3)
        z=(int)[[matchData objectForKey:@"batsman_3"] count];
    else
        z=(int)[[matchData objectForKey:@"batsman_4"] count];
    
    y=y+58;
    for(int i=0;i<z;i++)
    {
        
        UILabel *playerName = [[UILabel alloc] initWithFrame:CGRectMake (5, y, self.view.frame.size.width-125, 20)];
        [playerName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
        playerName.textAlignment=NSTextAlignmentLeft;
        playerName.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
        playerName.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [playerName setText:[[matchData valueForKey:@"batsman_1"][i] valueForKey:@"pname"]];
        else if(selectedInning==2)
            [playerName setText:[[matchData valueForKey:@"batsman_2"][i] valueForKey:@"pname"]];
        else if(selectedInning==3)
            [playerName setText:[[matchData valueForKey:@"batsman_3"][i] valueForKey:@"pname"]];
        else if(selectedInning==4)
            [playerName setText:[[matchData valueForKey:@"batsman_4"][i] valueForKey:@"pname"]];
        [scrv addSubview:playerName];
        
        
        
        UILabel *outBy = [[UILabel alloc] initWithFrame:CGRectMake (5, y+22, self.view.frame.size.width-100, 20)];
        [outBy setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
        outBy.textAlignment=NSTextAlignmentLeft;
        outBy.textColor=[UIColor blackColor];
        outBy.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [outBy setText:[[matchData valueForKey:@"batsman_1"][i] valueForKey:@"assist"]];
        else if(selectedInning==2)
            [outBy setText:[[matchData valueForKey:@"batsman_2"][i] valueForKey:@"assist"]];
        else if(selectedInning==3)
            [outBy setText:[[matchData valueForKey:@"batsman_3"][i] valueForKey:@"assist"]];
        else if(selectedInning==4)
            [outBy setText:[[matchData valueForKey:@"batsman_4"][i] valueForKey:@"assist"]];
        [scrv addSubview:outBy];
        
        
        UILabel *r = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-118, y+2, 20, 20)];
        [r setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        r.textAlignment=NSTextAlignmentRight;
        r.textColor=[UIColor blackColor];
        r.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [r setText:[[matchData valueForKey:@"batsman_1"][i] valueForKey:@"r"]];
        else if(selectedInning==2)
            [r setText:[[matchData valueForKey:@"batsman_2"][i] valueForKey:@"r"]];
        else if(selectedInning==3)
            [r setText:[[matchData valueForKey:@"batsman_3"][i] valueForKey:@"r"]];
        else if(selectedInning==4)
            [r setText:[[matchData valueForKey:@"batsman_4"][i] valueForKey:@"r"]];
        [scrv addSubview:r];
        
        UILabel *b = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-88, y+2, 20, 20)];
        [b setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        b.textAlignment=NSTextAlignmentRight;
        b.textColor=[UIColor blackColor];
        b.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [b setText:[[matchData valueForKey:@"batsman_1"][i] valueForKey:@"b"]];
        else if(selectedInning==2)
            [b setText:[[matchData valueForKey:@"batsman_2"][i] valueForKey:@"b"]];
        else if(selectedInning==3)
            [b setText:[[matchData valueForKey:@"batsman_3"][i] valueForKey:@"b"]];
        else if(selectedInning==4)
            [b setText:[[matchData valueForKey:@"batsman_4"][i] valueForKey:@"b"]];;
        [scrv addSubview:b];
        
        UILabel *s4 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-58, y+2, 20, 20)];
        [s4 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        s4.textAlignment=NSTextAlignmentRight;
        s4.textColor=[UIColor blackColor];
        s4.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [s4 setText:[[matchData valueForKey:@"batsman_1"][i] valueForKey:@"s4"]];
        else if(selectedInning==2)
            [s4 setText:[[matchData valueForKey:@"batsman_2"][i] valueForKey:@"s4"]];
        else if(selectedInning==3)
            [s4 setText:[[matchData valueForKey:@"batsman_3"][i] valueForKey:@"s4"]];
        else if(selectedInning==4)
            [s4 setText:[[matchData valueForKey:@"batsman_4"][i] valueForKey:@"s4"]];;
        [scrv addSubview:s4];
        
        UILabel *s6 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-28, y+2, 20, 20)];
        [s6 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        s6.textAlignment=NSTextAlignmentRight;
        s6.textColor=[UIColor blackColor];
        s6.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [s6 setText:[[matchData valueForKey:@"batsman_1"][i] valueForKey:@"s6"]];
        else if(selectedInning==2)
            [s6 setText:[[matchData valueForKey:@"batsman_2"][i] valueForKey:@"s6"]];
        else if(selectedInning==3)
            [s6 setText:[[matchData valueForKey:@"batsman_3"][i] valueForKey:@"s6"]];
        else if(selectedInning==4)
            [s6 setText:[[matchData valueForKey:@"batsman_4"][i] valueForKey:@"s6"]];;
        [scrv addSubview:s6];
        
        
        
        
        v=[[UIView alloc]initWithFrame:CGRectMake(0, y+44, self.view.frame.size.width, 1)];
        v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
        [scrv addSubview:v];
        
        y=y+45;
    }
    
    //////////////////////////////////////////////////////
    UILabel *extras = [[UILabel alloc] initWithFrame:CGRectMake (0, y+10, self.view.frame.size.width-130, 20)];
    [extras setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    extras.textAlignment=NSTextAlignmentLeft;
    extras.textColor=[UIColor blackColor];
    extras.backgroundColor=[UIColor clearColor];
    if(selectedInning==1)
        [extras setText:[NSString stringWithFormat:@" Extras: %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"extra"]]];
    if(selectedInning==2)
        [extras setText:[NSString stringWithFormat:@" Extras: %@",[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"extra"]]];
    if(selectedInning==3)
        [extras setText:[NSString stringWithFormat:@" Extras: %@",[[matchData valueForKey:@"team_extra3"][0] valueForKey:@"extra"]]];
    if(selectedInning==4)
        [extras setText:[NSString stringWithFormat:@" Extras: %@",[[matchData valueForKey:@"team_extra4"][0] valueForKey:@"extra"]]];
    [scrv addSubview:extras];
    
    
    UILabel *totalRun = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-120, y+2, 115, 35)];
    [totalRun setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    totalRun.textAlignment=NSTextAlignmentRight;
    totalRun.textColor=[UIColor blackColor];
    totalRun.lineBreakMode=NSLineBreakByWordWrapping;
    totalRun.numberOfLines=2;
    totalRun.backgroundColor=[UIColor clearColor];
    if(selectedInning==1)
        [totalRun setText:[NSString stringWithFormat:@" Total: %@",[[matchData valueForKey:@"team_extra1"][0] valueForKey:@"total"]]];
    if(selectedInning==2)
        [totalRun setText:[NSString stringWithFormat:@" Total: %@",[[matchData valueForKey:@"team_extra2"][0] valueForKey:@"total"]]];
    if(selectedInning==3)
        [totalRun setText:[NSString stringWithFormat:@" Total: %@",[[matchData valueForKey:@"team_extra3"][0] valueForKey:@"total"]]];
    if(selectedInning==4)
        [totalRun setText:[NSString stringWithFormat:@" Total: %@",[[matchData valueForKey:@"team_extra4"][0] valueForKey:@"total"]]];
    [scrv addSubview:totalRun];
    
    
    y=y+40;
    
    ///////////////////////////////////////////////////////
    UIImageView *bowlHeadBackView=[[UIImageView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    bowlHeadBackView.image=[UIImage imageNamed:@"team-name-bg"];
    [scrv addSubview:bowlHeadBackView];
    
    UILabel *bowlig = [[UILabel alloc] initWithFrame:CGRectMake (0, 4, self.view.frame.size.width-180, 20)];
    [bowlig setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
    bowlig.textAlignment=NSTextAlignmentLeft;
    bowlig.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    bowlig.backgroundColor=[UIColor clearColor];
    [bowlig setText:[NSString stringWithFormat:@" %@",@"Bowling"]];
    [bowlHeadBackView addSubview:bowlig];
    
    
    UILabel *o = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-180, 4, 25, 20)];
    [o setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    o.textAlignment=NSTextAlignmentRight;
    o.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    o.backgroundColor=[UIColor clearColor];
    [o setText:@"O"];
    [bowlHeadBackView addSubview:o];
    
    UILabel *m = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-155, 4, 20, 20)];
    [m setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    m.textAlignment=NSTextAlignmentRight;
    m.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    m.backgroundColor=[UIColor clearColor];
    [m setText:@"M"];
    [bowlHeadBackView addSubview:m];
    
    UILabel *rr = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-135, 4, 20, 20)];
    [rr setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    rr.textAlignment=NSTextAlignmentRight;
    rr.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    rr.backgroundColor=[UIColor clearColor];
    [rr setText:@"R"];
    [bowlHeadBackView addSubview:rr];
    
    UILabel *w = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-115, 4, 20, 20)];
    [w setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    w.textAlignment=NSTextAlignmentRight;
    w.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    w.backgroundColor=[UIColor clearColor];
    [w setText:@"W"];
    [bowlHeadBackView addSubview:w];
    
    UILabel *wd = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-90, 4, 25, 20)];
    [wd setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    wd.textAlignment=NSTextAlignmentRight;
    wd.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    wd.backgroundColor=[UIColor clearColor];
    [wd setText:@"WD"];
    [bowlHeadBackView addSubview:wd];
    
    UILabel *nb = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-65, 4, 25, 20)];
    [nb setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    nb.textAlignment=NSTextAlignmentRight;
    nb.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    nb.backgroundColor=[UIColor clearColor];
    [nb setText:@"NB"];
    [bowlHeadBackView addSubview:nb];
    
    UILabel *eco = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-40, 4, 35, 20)];
    [eco setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
    eco.textAlignment=NSTextAlignmentRight;
    eco.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    eco.backgroundColor=[UIColor clearColor];
    [eco setText:@"ECO"];
    [bowlHeadBackView addSubview:eco];
    
    
    y=y+35;
    
    if(selectedInning==1)
        z=(int)[[matchData objectForKey:@"bowler_1"] count];
    else if(selectedInning==2)
        z=(int)[[matchData objectForKey:@"bowler_2"] count];
    else if(selectedInning==3)
        z=(int)[[matchData objectForKey:@"bowler_3"] count];
    else
        z=(int)[[matchData objectForKey:@"bowler_4"] count];
    for(int i=0;i<z;i++)
    {
        UILabel *playerName = [[UILabel alloc] initWithFrame:CGRectMake (5, y+5, self.view.frame.size.width-175, 20)];
        [playerName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
        playerName.textAlignment=NSTextAlignmentLeft;
        playerName.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
        playerName.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [playerName setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"bname"]];
        else if(selectedInning==2)
            [playerName setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"bname"]];
        else if(selectedInning==3)
            [playerName setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"bname"]];
        else if(selectedInning==4)
            [playerName setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"bname"]];
        [scrv addSubview:playerName];
        
        
        
        UILabel *o = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-180, y+5, 25, 20)];
        [o setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        o.textAlignment=NSTextAlignmentRight;
        o.textColor=[UIColor blackColor];
        o.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [o setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"o"]];
        else if(selectedInning==2)
            [o setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"o"]];
        else if(selectedInning==3)
            [o setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"o"]];
        else if(selectedInning==4)
            [o setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"o"]];
        [scrv addSubview:o];
        
        UILabel *m = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-155, y+5, 20, 20)];
        [m setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        m.textAlignment=NSTextAlignmentRight;
        m.textColor=[UIColor blackColor];
        m.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [m setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"m"]];
        else if(selectedInning==2)
            [m setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"m"]];
        else if(selectedInning==3)
            [m setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"m"]];
        else if(selectedInning==4)
            [m setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"m"]];
        [scrv addSubview:m];
        
        UILabel *rr = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-135, y+5, 20, 20)];
        [rr setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        rr.textAlignment=NSTextAlignmentRight;
        rr.textColor=[UIColor blackColor];
        rr.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [rr setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"r"]];
        else if(selectedInning==2)
            [rr setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"r"]];
        else if(selectedInning==3)
            [rr setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"r"]];
        else if(selectedInning==4)
            [rr setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"r"]];
        [scrv addSubview:rr];
        
        UILabel *w = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-115, y+5, 20, 20)];
        [w setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        w.textAlignment=NSTextAlignmentRight;
        w.textColor=[UIColor blackColor];
        w.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [w setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"w"]];
        else if(selectedInning==2)
            [w setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"w"]];
        else if(selectedInning==3)
            [w setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"w"]];
        else if(selectedInning==4)
            [w setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"w"]];;
        [scrv addSubview:w];
        
        UILabel *wd = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-92, y+5, 25, 20)];
        [wd setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        wd.textAlignment=NSTextAlignmentRight;
        wd.textColor=[UIColor blackColor];
        wd.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [wd setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"wd"]];
        else if(selectedInning==2)
            [wd setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"wd"]];
        else if(selectedInning==3)
            [wd setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"wd"]];
        else if(selectedInning==4)
            [wd setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"wd"]];;
        [scrv addSubview:wd];
        
        UILabel *nb = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-65, y+5, 25, 20)];
        [nb setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        nb.textAlignment=NSTextAlignmentRight;
        nb.textColor=[UIColor blackColor];
        nb.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [nb setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"nb"]];
        else if(selectedInning==2)
            [nb setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"nb"]];
        else if(selectedInning==3)
            [nb setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"nb"]];
        else if(selectedInning==4)
            [nb setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"nb"]];;
        [scrv addSubview:nb];
        
        UILabel *eco = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-40, y+5, 35, 20)];
        [eco setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        eco.textAlignment=NSTextAlignmentRight;
        eco.textColor=[UIColor blackColor];
        eco.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [eco setText:[[matchData valueForKey:@"bowler_1"][i] valueForKey:@"eco"]];
        else if(selectedInning==2)
            [eco setText:[[matchData valueForKey:@"bowler_2"][i] valueForKey:@"eco"]];
        else if(selectedInning==3)
            [eco setText:[[matchData valueForKey:@"bowler_3"][i] valueForKey:@"eco"]];
        else if(selectedInning==4)
            [eco setText:[[matchData valueForKey:@"bowler_4"][i] valueForKey:@"eco"]];;
        [scrv addSubview:eco];
        
        
        
        
        v=[[UIView alloc]initWithFrame:CGRectMake(0, y+30, self.view.frame.size.width, 1)];
        v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
        [scrv addSubview:v];
        
        y=y+30;
    }
    
    ///////////////////////////////////////////////////////
    UIImageView *fallOfWicketBackView=[[UIImageView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    fallOfWicketBackView.image=[UIImage imageNamed:@"team-name-bg"];
    [scrv addSubview:fallOfWicketBackView];
    
    UILabel *fow = [[UILabel alloc] initWithFrame:CGRectMake (0, 2, self.view.frame.size.width, 25)];
    [fow setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    fow.textAlignment=NSTextAlignmentLeft;
    fow.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    fow.backgroundColor=[UIColor clearColor];
    [fow setText:[NSString stringWithFormat:@"  %@",@"Fall of Wicket"]];
    [fallOfWicketBackView addSubview:fow];
    
    y=y+30;
    if(selectedInning==1)
        z=(int)[[matchData objectForKey:@"fow_1"] count];
    else if(selectedInning==2)
        z=(int)[[matchData objectForKey:@"fow_2"] count];
    else if(selectedInning==3)
        z=(int)[[matchData objectForKey:@"fow_3"] count];
    else
        z=(int)[[matchData objectForKey:@"fow_4"] count];
    for(int i=0;i<z;i++)
    {
        UILabel *fow = [[UILabel alloc] initWithFrame:CGRectMake (0, y+5, 90, 25)];
        [fow setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        fow.textAlignment=NSTextAlignmentLeft;
        fow.textColor=[UIColor blackColor];
        fow.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [fow setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_1"][i] valueForKey:@"run"]]];
        else if(selectedInning==2)
            [fow setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_2"][i] valueForKey:@"run"]]];
        else if(selectedInning==3)
            [fow setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_3"][i] valueForKey:@"run"]]];
        else if(selectedInning==4)
            [fow setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_4"][i] valueForKey:@"run"]]];
        [scrv addSubview:fow];
        
        UILabel *fow1 = [[UILabel alloc] initWithFrame:CGRectMake (90, y+5, 160, 25)];
        [fow1 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        fow1.textAlignment=NSTextAlignmentLeft;
        fow1.textColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
        fow1.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [fow1 setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_1"][i] valueForKey:@"name"]]];
        else if(selectedInning==2)
            [fow1 setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_2"][i] valueForKey:@"name"]]];
        else if(selectedInning==3)
            [fow1 setText:[NSString stringWithFormat:@" %@",[[matchData valueForKey:@"fow_3"][i] valueForKey:@"name"]]];
        else if(selectedInning==4)
            [fow1 setText:[NSString stringWithFormat:@"  %@",[[matchData valueForKey:@"fow_4"][i] valueForKey:@"name"]]];        [scrv addSubview:fow1];
        
        UILabel *fow2 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-80, y+5, 80, 25)];
        [fow2 setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
        fow2.textAlignment=NSTextAlignmentLeft;
        fow2.textColor=[UIColor blackColor];
        fow2.backgroundColor=[UIColor clearColor];
        if(selectedInning==1)
            [fow2 setText:[NSString stringWithFormat:@"%@ ovs",[[matchData valueForKey:@"fow_1"][i] valueForKey:@"ovs"]]];
        else if(selectedInning==2)
            [fow2 setText:[NSString stringWithFormat:@"%@ ovs",[[matchData valueForKey:@"fow_2"][i] valueForKey:@"ovs"]]];
        else if(selectedInning==3)
            [fow2 setText:[NSString stringWithFormat:@"%@ ovs",[[matchData valueForKey:@"fow_3"][i] valueForKey:@"ovs"]]];
        else if(selectedInning==4)
            [fow2 setText:[NSString stringWithFormat:@"%@ ovs",[[matchData valueForKey:@"fow_4"][i] valueForKey:@"ovs"]]];        [scrv addSubview:fow2];
        
        v=[[UIView alloc]initWithFrame:CGRectMake(0, y+35, self.view.frame.size.width, 1)];
        v.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
        [scrv addSubview:v];
        y=y+35;
    }
    
    scrv.contentSize=CGSizeMake(280, y+40);
    
}
-(void)ininingView:(UIButton*)btn
{
    if(btn.tag==1)
    {
        selectedInning=1;
        CGRect newFrame = v.frame;
        newFrame.size.height = 5;
        v.frame=newFrame;
        
        CGRect newFrame1 = v1.frame;
        newFrame1.size.height = 2;
        v1.frame=newFrame1;
        
        CGRect newFrame2 = v2.frame;
        newFrame2.size.height = 2;
        v2.frame=newFrame2;
        
        CGRect newFrame3 = v3.frame;
        newFrame3.size.height = 2;
        v3.frame=newFrame3;
    }
    else if(btn.tag==2)
    {
        selectedInning=2;
        CGRect newFrame = v.frame;
        newFrame.size.height = 2;
        v.frame=newFrame;
        
        CGRect newFrame1 = v1.frame;
        newFrame1.size.height = 5;
        v1.frame=newFrame1;
        
        CGRect newFrame2 = v2.frame;
        newFrame2.size.height = 2;
        v2.frame=newFrame2;
        
        CGRect newFrame3 = v3.frame;
        newFrame3.size.height = 2;
        v3.frame=newFrame3;
    }
    else if(btn.tag==3)
    {
        selectedInning=3;
        CGRect newFrame = v.frame;
        newFrame.size.height = 2;
        v.frame=newFrame;
        
        CGRect newFrame1 = v1.frame;
        newFrame1.size.height = 2;
        v1.frame=newFrame1;
        
        CGRect newFrame2 = v2.frame;
        newFrame2.size.height = 5;
        v2.frame=newFrame2;
        
        CGRect newFrame3 = v3.frame;
        newFrame3.size.height = 2;
        v3.frame=newFrame3;
    }
    else
    {
        selectedInning=4;
        CGRect newFrame = v.frame;
        newFrame.size.height = 2;
        v.frame=newFrame;
        
        CGRect newFrame1 = v1.frame;
        newFrame1.size.height = 2;
        v1.frame=newFrame1;
        
        CGRect newFrame2 = v2.frame;
        newFrame2.size.height = 2;
        v2.frame=newFrame2;
        
        CGRect newFrame3 = v3.frame;
        newFrame3.size.height = 5;
        v3.frame=newFrame3;
    }
    [self setDataOnScroll];
}
-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)sharingAction:(UIButton*)sender
{
    CGRect rect =[self.view bounds];// [self.view bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer  renderInContext:context];
    UIImage *img1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    
    UIImage *shareImage = img1;
    NSURL *shareURL = [NSURL URLWithString:@""];
    NSArray *activityProviders = @[@"Download SpotsFlashes for Sports, News, Trivias, Predictions & Gosips For Iphone/Ipad https://goo.gl/jYrUfd & For Android https://goo.gl/L8H4iR", shareImage,shareURL];
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityProviders  applicationActivities:nil];
    if(self.view.frame.size.height>700)
    {
        activityVC.popoverPresentationController.sourceView = sender;
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else
    {
        activityVC.excludedActivityTypes = nil ;
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}
@end
