//
//  scoreDetailViewController.m
//  SportsFlashes
//
//  Created by Apple on 20/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "scoreDetailViewController.h"
#import "AFNetworking.h"
#import "Utilities.h"
#import "ScoreBoardViewController.h"
#import <Google/Analytics.h>

#import "AppDelegate.h"
@interface scoreDetailViewController ()
{
    NSString *score;
    NSMutableArray *tableData;
    NSMutableDictionary *mainArr;
    NSTimer *t;
    NSMutableArray *catArr,*labels;
    UILabel *rrLabel,*lastWicket;
    
}
@end

@implementation scoreDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSString *st=[u objectForKey:@"MatchName"];
    
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:st];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    scrv.contentSize=CGSizeMake(280, self.view.frame.size.height+30);
    
    self.bannerView.adUnitID = @"ca-app-pub-4237488103635443/8339330816";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    
    CGRect f = commentryTable.frame;
    f.origin.y = commentryTable.frame.origin.y+20;
    f.size.height= commentryTable.frame.size.height-20;
    commentryTable.frame =f;
    
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
    labels=[[catArr valueForKey:@"labels"]mutableCopy];
    
    battingLabel.text=[NSString stringWithFormat:@"%@",[labels valueForKey:@"batting"][0]];
    bowlingLabel.text=[NSString stringWithFormat:@"%@",[labels valueForKey:@"bowling"][0]];
    
    
    [self getDataFromServer];
    
}
-(void)timerCalled
{
    [self getDataFromServer];
    // NSLog(@"Timer Called");
    // Your Code
}
-(void)getDataFromServer
{
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    score=[u objectForKey:@"unique_id"];
    
    headingLabel.text=[u objectForKey:@"MatchName"];
    
    //http://cricapi.com/api/cricketScore/?unique_id=
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://sportsflashes.com"]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/match_summary?ln=%@&match_id=%@",[u objectForKey:@"lang"],score] parameters:nil];//
        
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
                    [NSTimer scheduledTimerWithTimeInterval:[[JSON objectForKey:@"ref"]intValue] target:self selector:@selector(timerCalled)userInfo:nil repeats:NO];
                    
                    mainArr=[JSON mutableCopy];
                    if ([JSON objectForKey:@"batting"] != [NSNull null]) {
                        
                        batR.text=[[JSON valueForKey:@"batting"][0]valueForKey:@"r"];
                        batB.text=[[JSON valueForKey:@"batting"][0]valueForKey:@"b"];
                        bat4s.text=[[JSON valueForKey:@"batting"][0]valueForKey:@"s4"];
                        bat6s.text=[[JSON valueForKey:@"batting"][0]valueForKey:@"s6"];
                        batSR.text=[[JSON valueForKey:@"batting"][0]valueForKey:@"sr"];
                        
                        bat1name.text=[[JSON valueForKey:@"batting"][0]valueForKey:@"name"];
                        
                        
                        if([[JSON valueForKey:@"batting"] count]>1)
                        {
                            bat2name.text=[[JSON valueForKey:@"batting"][1]valueForKey:@"name"];
                            
                            batR1.text=[[JSON valueForKey:@"batting"][1]valueForKey:@"r"];
                            batB1.text=[[JSON valueForKey:@"batting"][1]valueForKey:@"b"];
                            bat4s1.text=[[JSON valueForKey:@"batting"][1]valueForKey:@"s4"];
                            bat6s1.text=[[JSON valueForKey:@"batting"][1]valueForKey:@"s6"];
                            batSR1.text=[[JSON valueForKey:@"batting"][1]valueForKey:@"sr"];
                            
                            
                        }
                        
                        
                    }
                    
                    if ([JSON objectForKey:@"bowling"] != [NSNull null]) {
                        
                        bowl1name.text=[[JSON valueForKey:@"bowling"][0]valueForKey:@"name"];
                        
                        bowlO.text=[[JSON valueForKey:@"bowling"][0]valueForKey:@"o"];
                        bowlM.text=[[JSON valueForKey:@"bowling"][0]valueForKey:@"m"];
                        bowlR.text=[[JSON valueForKey:@"bowling"][0]valueForKey:@"r"];
                        bowlW.text=[[JSON valueForKey:@"bowling"][0]valueForKey:@"w"];
                        bowlECO.text=[[JSON valueForKey:@"bowling"][0]valueForKey:@"eco"];
                        
                        if([[JSON valueForKey:@"bowling"] count]>1)
                        {
                            bowl2name.text=[[JSON valueForKey:@"bowling"][1]valueForKey:@"name"];
                            
                            bowlO1.text=[[JSON valueForKey:@"bowling"][1]valueForKey:@"o"];
                            bowlM1.text=[[JSON valueForKey:@"bowling"][1]valueForKey:@"m"];
                            bowlR1.text=[[JSON valueForKey:@"bowling"][1]valueForKey:@"r"];
                            bowlW1.text=[[JSON valueForKey:@"bowling"][1]valueForKey:@"w"];
                            bowlECO1.text=[[JSON valueForKey:@"bowling"][1]valueForKey:@"eco"];
                        }
                        
                    }
                    curentPlayingbat.text=[JSON valueForKey:@"batting_team_name"];
                    curentPlayingbowl.text=[JSON valueForKey:@"bowling_team_name"];
                    curentRunRate.text=[NSString stringWithFormat:@"CRR : %@",[JSON valueForKey:@"run_rate"]];
                    curentRunRate.textAlignment=NSTextAlignmentRight;
                    summaryLabel.text=[JSON valueForKey:@"match_status"];
                    
                    recentOver.text=[NSString stringWithFormat:@"Recent Over : %@",[JSON valueForKey:@"recent_overs"]];
                    tableData= [[JSON valueForKey:@"comm"]mutableCopy];// comentary.text=[NSString stringWithFormat:@"Commentry :  %@",];
                    [commentryTable reloadData];
                    
                    
                    if ([JSON valueForKey:@"mom"] != nil)
                        manOfTheMatch.text=[JSON valueForKey:@"mom"];
                    else
                        manOfMatchView.hidden=YES;
                    
                    if([JSON valueForKey:@"partnership"]!=[NSNull null])
                        partnership.text=[JSON valueForKey:@"partnership"];
                    else
                        partnership.text=@"-";
                    
                    
                    if([JSON valueForKey:@"rrr"]!=[NSNull null])
                    {
                    [rrLabel removeFromSuperview];
                    CGRect rrLabelRect = CGRectMake (self.view.frame.size.width-110, partnership.frame.origin.y, 100, recentOver.frame.size.height);
                    rrLabel = [[UILabel alloc] initWithFrame:rrLabelRect];
                    [rrLabel setFont:[UIFont fontWithName:recentOver.font.fontName size:recentOver.font.pointSize]];
                    rrLabel.lineBreakMode=NSLineBreakByWordWrapping;
                    rrLabel.numberOfLines=1;
                    rrLabel.textColor=[UIColor blackColor];
                    rrLabel.textAlignment=NSTextAlignmentRight;
                    rrLabel.backgroundColor=[UIColor clearColor];
                    [rrLabel setText:[NSString stringWithFormat:@"Req.RR: %@",[JSON valueForKey:@"rrr"]]];
                    if([[JSON valueForKey:@"rrr"]integerValue]!=0)
                        [lastWicketView addSubview:rrLabel];
                    }
                    errorView.hidden=YES;
                    
                    
                    
                    [lastWicket removeFromSuperview];
                    CGRect lastWicketLabelRect = CGRectMake (10, commentryTable.frame.origin.y-20, 300, 20);
                    lastWicket = [[UILabel alloc] initWithFrame:lastWicketLabelRect];
                    [lastWicket setFont:[UIFont fontWithName:recentOver.font.fontName size:recentOver.font.pointSize]];
                    lastWicket.lineBreakMode=NSLineBreakByWordWrapping;
                    lastWicket.numberOfLines=1;
                    lastWicket.textColor=[UIColor blackColor];
                    lastWicket.textAlignment=NSTextAlignmentLeft;
                    lastWicket.backgroundColor=[UIColor clearColor];
                    [lastWicket setText:[NSString stringWithFormat:@"Last Wicket: %@",[JSON valueForKey:@"lastwkt"]]];
                    [scrv addSubview:lastWicket];
                    
                    
                    //oversLeft.text=[JSON valueForKey:@"batting_team_name"];
                }
                else
                {
                    errorView.hidden=NO;
                    matchStartIn.text=[JSON valueForKey:@"message"];
                    error_summary.text=[JSON valueForKey:@"summary"];
                    error_previewLBL.text=[JSON valueForKey:@"preview_label"];
                }
                
                
                
            }
            
            
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return tableData.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,20)];
    [view setBackgroundColor:[UIColor clearColor]]; //your background color...
    
    UIFont * myFont =[UIFont fontWithName:@"Arial-BoldMT" size:15];
    CGRect labelFrame = CGRectMake (10, 5, tableView.frame.size.width, 20);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:myFont];
    label.lineBreakMode=NSLineBreakByWordWrapping;
    label.numberOfLines=10;
    label.textColor=[UIColor blackColor];
    label.textAlignment=NSTextAlignmentLeft;
    label.backgroundColor=[UIColor clearColor];
    [label setText:[NSString stringWithFormat:@"%@ : ",[labels valueForKey:@"commentry"][0]]];
    [view addSubview:label];
    
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section==0)
        return 30;
    else
        return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,20)];
    [view setBackgroundColor:[UIColor clearColor]]; //your background color...
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=[tableData[indexPath.section] mutableCopy];
    
    if([[dict valueForKey:@"over_status"] intValue]==1)
    {
        return 120;
    }
    else
    {
        CGRect labelRect = [[dict valueForKey:@"commentry"] boundingRectWithSize:self.view.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }context:nil];
        return labelRect.size.height+35;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    //[tableView setBackgroundColor:[UIColor colorWithRed:42.0/255.0 green:58.0/255.0 blue:68.0/255.0 alpha:1.0]];
    
    NSDictionary *dict=[tableData[indexPath.section] mutableCopy];
    
    if([[dict valueForKey:@"over_status"] intValue]==1)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, tableView.frame.size.width-4,120)];
        [view setBackgroundColor:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]];
        [cell addSubview:view];
        
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width,30)];
        [view1 setBackgroundColor:[UIColor colorWithRed:83.0/255.0 green:107.0/255.0 blue:119.0/255.0 alpha:1.0]];
        [view addSubview:view1];
        
        
        UIFont * myFont = [UIFont systemFontOfSize:12];
        CGRect labelFrame1 = CGRectMake (5, 0, 90, 30);
        UILabel *totalRuns = [[UILabel alloc] initWithFrame:labelFrame1];
        [totalRuns setFont:myFont];
        totalRuns.lineBreakMode=NSLineBreakByWordWrapping;
        totalRuns.numberOfLines=1;
        totalRuns.textColor=[UIColor whiteColor];
        totalRuns.textAlignment=NSTextAlignmentLeft;
        totalRuns.backgroundColor=[UIColor clearColor];
        NSString *newStr = [NSString stringWithFormat:@"Runs %@",[dict valueForKey:@"overrun"]];
        [totalRuns setText:newStr];
        [view1 addSubview:totalRuns];
        
    
        
        
        CGRect labelFrame = CGRectMake (self.view.frame.size.width-210, 0, 200, 30);
        UILabel *recentOverLbl = [[UILabel alloc] initWithFrame:labelFrame];
        [recentOverLbl setFont:myFont];
        recentOverLbl.lineBreakMode=NSLineBreakByWordWrapping;
        recentOverLbl.numberOfLines=1;
        recentOverLbl.textColor=[UIColor whiteColor];
        recentOverLbl.textAlignment=NSTextAlignmentRight;
        recentOverLbl.backgroundColor=[UIColor clearColor];
        [recentOverLbl setText:[NSString stringWithFormat:@"Recent Score: %@",[dict valueForKey:@"overrecentover"]]];
        [view1 addSubview:recentOverLbl];
        
        
        CGRect runsTotallabelFrame = CGRectMake (5, 30, 70, 30);
        UILabel *runsTotal = [[UILabel alloc] initWithFrame:runsTotallabelFrame];
        [runsTotal setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
        runsTotal.lineBreakMode=NSLineBreakByWordWrapping;
        runsTotal.numberOfLines=1;
        runsTotal.textColor=[UIColor whiteColor];
        runsTotal.textAlignment=NSTextAlignmentCenter;
        runsTotal.backgroundColor=[UIColor clearColor];
        NSArray* foo = [[dict valueForKey:@"score"] componentsSeparatedByString: @" "];
        if(foo.count>1)
            [runsTotal setText:[NSString stringWithFormat:@"%@",foo[1]]];
        else
            [runsTotal setText:[NSString stringWithFormat:@"%@",foo[0]]];
        [view addSubview:runsTotal];
        
        
        
        CGRect overNolabelFrame = CGRectMake (5, 60, 70, 30);
        UILabel *overNo = [[UILabel alloc] initWithFrame:overNolabelFrame];
        [overNo setFont:myFont];
        overNo.lineBreakMode=NSLineBreakByWordWrapping;
        overNo.numberOfLines=1;
        overNo.textColor=[UIColor whiteColor];
        overNo.textAlignment=NSTextAlignmentCenter;
        overNo.backgroundColor=[UIColor clearColor];
        [overNo setText:[NSString stringWithFormat:@"Ov No.%@",[dict valueForKey:@"ovno"]]];
        [view1 addSubview:overNo];
        
        
        CGRect overNolabelFrame1 = CGRectMake (2, 90, 74, 20);
        UILabel *requiredRunRate = [[UILabel alloc] initWithFrame:overNolabelFrame1];
        [requiredRunRate setFont:myFont];
        requiredRunRate.lineBreakMode=NSLineBreakByWordWrapping;
        requiredRunRate.numberOfLines=1;
        requiredRunRate.textColor=[UIColor whiteColor];
        requiredRunRate.textAlignment=NSTextAlignmentCenter;
        requiredRunRate.backgroundColor=[UIColor clearColor];
        [requiredRunRate setText:[NSString stringWithFormat:@"Req.RR:%@",[mainArr valueForKey:@"rrr"]]];
        if([[mainArr valueForKey:@"rrr"]integerValue]!=0)
            [view1 addSubview:requiredRunRate];
        
        
        
        UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(80, 40, 1,70)];
        [view3 setBackgroundColor:[UIColor whiteColor]];
        [view addSubview:view3];
        
        
        CGRect batman1labelFrame = CGRectMake (85, 40, 100, 20);
        UILabel *batman1 = [[UILabel alloc] initWithFrame:batman1labelFrame];
        [batman1 setFont:myFont];
        batman1.lineBreakMode=NSLineBreakByWordWrapping;
        batman1.numberOfLines=1;
        batman1.textColor=[UIColor whiteColor];
        batman1.textAlignment=NSTextAlignmentLeft;
        batman1.backgroundColor=[UIColor clearColor];
        [batman1 setText:[NSString stringWithFormat:@"%@",[[[dict valueForKey:@"ovbatsman"]objectAtIndex:0]valueForKey:@"name"]]];
        [view1 addSubview:batman1];
        
        CGRect batman1ScorelabelFrame = CGRectMake (self.view.frame.size.width-60, 40, 50, 20);
        UILabel *batman1Score = [[UILabel alloc] initWithFrame:batman1ScorelabelFrame];
        [batman1Score setFont:myFont];
        batman1Score.lineBreakMode=NSLineBreakByWordWrapping;
        batman1Score.numberOfLines=1;
        batman1Score.textColor=[UIColor whiteColor];
        batman1Score.textAlignment=NSTextAlignmentRight;
        batman1Score.backgroundColor=[UIColor clearColor];
        [batman1Score setText:[NSString stringWithFormat:@"%@ (%@)",[[[dict valueForKey:@"ovbatsman"]objectAtIndex:0]valueForKey:@"r"],[[[dict valueForKey:@"ovbatsman"]objectAtIndex:0]valueForKey:@"b"]]];
        [view1 addSubview:batman1Score];
        
        
        
        CGRect bowlerlabelFrame = CGRectMake (85, 90, 100, 20);
        UILabel *bowlerScore = [[UILabel alloc] initWithFrame:bowlerlabelFrame];
        [bowlerScore setFont:myFont];
        bowlerScore.lineBreakMode=NSLineBreakByWordWrapping;
        bowlerScore.numberOfLines=1;
        bowlerScore.textColor=[UIColor whiteColor];
        bowlerScore.textAlignment=NSTextAlignmentLeft;
        bowlerScore.backgroundColor=[UIColor clearColor];
        [bowlerScore setText:[NSString stringWithFormat:@"%@",[[[dict valueForKey:@"ovbowler"]objectAtIndex:0]valueForKey:@"name"]]];
        [view1 addSubview:bowlerScore];
        
        
        
        CGRect bowlerStatlabelFrame = CGRectMake (self.view.frame.size.width-100, 90, 90, 20);
        UILabel *bowlerStatScore = [[UILabel alloc] initWithFrame:bowlerStatlabelFrame];
        [bowlerStatScore setFont:myFont];
        bowlerStatScore.lineBreakMode=NSLineBreakByWordWrapping;
        bowlerStatScore.numberOfLines=1;
        bowlerStatScore.textColor=[UIColor whiteColor];
        bowlerStatScore.textAlignment=NSTextAlignmentRight;
        bowlerStatScore.backgroundColor=[UIColor clearColor];
        [bowlerStatScore setText:[NSString stringWithFormat:@"%@-%@-%@-%@",[[[dict valueForKey:@"ovbowler"]objectAtIndex:0]valueForKey:@"o"],[[[dict valueForKey:@"ovbowler"]objectAtIndex:0]valueForKey:@"m"],[[[dict valueForKey:@"ovbowler"]objectAtIndex:0]valueForKey:@"r"],[[[dict valueForKey:@"ovbowler"]objectAtIndex:0]valueForKey:@"w"]]];
        [view1 addSubview:bowlerStatScore];
        
        
        
        if([[dict valueForKey:@"ovbatsman"] count]==2)
        {
            CGRect batman2labelFrame = CGRectMake (85, 60, 100, 20);
            UILabel *batman2 = [[UILabel alloc] initWithFrame:batman2labelFrame];
            [batman2 setFont:myFont];
            batman2.lineBreakMode=NSLineBreakByWordWrapping;
            batman2.numberOfLines=1;
            batman2.textColor=[UIColor whiteColor];
            batman2.textAlignment=NSTextAlignmentLeft;
            batman2.backgroundColor=[UIColor clearColor];
            [batman2 setText:[NSString stringWithFormat:@"%@",[[[dict valueForKey:@"ovbatsman"]objectAtIndex:1]valueForKey:@"name"]]];
            [view1 addSubview:batman2];
            
            
            CGRect batman2ScorelabelFrame = CGRectMake (self.view.frame.size.width-60, 60, 50, 20);
            UILabel *batman2Score = [[UILabel alloc] initWithFrame:batman2ScorelabelFrame];
            [batman2Score setFont:myFont];
            batman2Score.lineBreakMode=NSLineBreakByWordWrapping;
            batman2Score.numberOfLines=1;
            batman2Score.textColor=[UIColor whiteColor];
            batman2Score.textAlignment=NSTextAlignmentRight;
            batman2Score.backgroundColor=[UIColor clearColor];
            [batman2Score setText:[NSString stringWithFormat:@"%@ (%@)",[[[dict valueForKey:@"ovbatsman"]objectAtIndex:1]valueForKey:@"r"],[[[dict valueForKey:@"ovbatsman"]objectAtIndex:1]valueForKey:@"b"]]];
            [view1 addSubview:batman2Score];
            
        }
        
        
        
    }
    else
    {
        CGRect labelRect = [[dict valueForKey:@"commentry"] boundingRectWithSize:self.view.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }context:nil];
        
        CGRect frame = commentryTable.frame;
        frame.size.height = tableView.contentSize.height+120;
        commentryTable.frame = frame;
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(3, 3, tableView.frame.size.width-6,labelRect.size.height+34)];
        [view1 setBackgroundColor:[UIColor orangeColor]];
        view1.layer.cornerRadius=10.0;
        [cell addSubview:view1];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(4, 4, tableView.frame.size.width-9,labelRect.size.height+31)];
        [view setBackgroundColor:[UIColor whiteColor]];
        view.layer.cornerRadius=10.0;
        [cell addSubview:view];
        
        
        
        //NSLog(@"%@",tableData[indexPath.section]);
        
        
        if(352+tableView.contentSize.height>self.view.frame.size.height)
            scrv.contentSize=CGSizeMake(10, 342+tableView.contentSize.height);
        else
            scrv.contentSize=CGSizeMake(10,self.view.frame.size.height-30);
        
        UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 36,36)];
        img.image=[UIImage imageNamed:@"ball"];
        img.layer.cornerRadius=18.0;
        img.clipsToBounds=YES;
        [cell addSubview:img];
        
        UIFont * myFont = [UIFont systemFontOfSize:12];
        CGRect labelFrame = CGRectMake (50, 9, self.view.frame.size.width-60, labelRect.size.height+15);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setFont:myFont];
        label.lineBreakMode=NSLineBreakByWordWrapping;
        label.numberOfLines=15;
        label.textColor=[UIColor blackColor];
        label.textAlignment=NSTextAlignmentLeft;
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
        
        
        NSArray* foo = [[dict valueForKey:@"commentry"] componentsSeparatedByString: @" "];
        float firstBit = [[foo objectAtIndex: 0]floatValue];
        NSString *st;
        if(firstBit ==0)
        {
            img.image=[UIImage imageNamed:@"40.png"];
            [label setText:[dict valueForKey:@"commentry"]];
        }
        else
        {
            st=[NSString stringWithFormat:@"%0.1f",firstBit];
            //NSLog(@"%@",st);
            CGRect labelFrame1 = CGRectMake (1, 2, 33, 30);
            UILabel *label1 = [[UILabel alloc] initWithFrame:labelFrame1];
            [label1 setFont:myFont];
            label1.lineBreakMode=NSLineBreakByWordWrapping;
            label1.numberOfLines=15;
            label1.textColor=[UIColor whiteColor];
            label1.textAlignment=NSTextAlignmentCenter;
            label1.backgroundColor=[UIColor clearColor];
            [label1 setText:st];
            NSString *newStr = [[dict valueForKey:@"commentry"] substringFromIndex:st.length+1];
            [label setText:newStr];
            [img addSubview:label1];
            
        }
        
        cell.backgroundColor=[UIColor clearColor];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    tableView.scrollEnabled=false;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}
-(IBAction)batScoreBoardAction:(id)sender
{
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.batOrBowl=1;
    ScoreBoardViewController *smvc;
    int height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 568) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 667) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 736) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 1024) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else
    {
        
        smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    
    [self.navigationController pushViewController:smvc animated:YES];
    
    
}
-(IBAction)bowlScoreBoardAction:(id)sender
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.batOrBowl=0;

    ScoreBoardViewController *smvc;
    int height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 568) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 667) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 736) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else if (height == 1024) {
        
        
        smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    else
    {
        
        smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"ScoreBoardViewController"];
        
    }
    
    [self.navigationController pushViewController:smvc animated:YES];
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [t invalidate];
}
-(IBAction)sharingAction:(UIButton*)sender
{
    
    CGRect rect =[self.view bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer  renderInContext:context];
    UIImage *img1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImage *shareImage = img1;
    NSURL *shareURL = [NSURL URLWithString:@""];
    NSArray *activityProviders = @[@"Download SpotsFlashes for Sports, News, Trivias, Predictions & Gosips For Iphone/Ipad https://goo.gl/jYrUfd & For Android https://goo.gl/L8H4iR",shareImage,shareURL];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityProviders  applicationActivities:nil];
    
    
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
