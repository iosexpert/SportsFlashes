//
//  liveScoreListViewController.m
//  SportsFlashes
//
//  Created by Apple on 20/10/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "liveScoreListViewController.h"
#import "AFNetworking.h"
#import "Utilities.h"
#import "scoreDetailViewController.h"
#import "AsyncImageView.h"
#import "NVSlideMenuController.h"
#import <Google/Analytics.h>


@interface liveScoreListViewController ()
{
    NSMutableArray *listArray;
    NSTimer *t;
    UIButton *liveButton,*recentButton,*upcomingButton;
    NSMutableArray *liveArr,*recentArr,*upcommingArr;
    int selectedButton;
    NSMutableArray *catArr,*labels;
    

}
@end

@implementation liveScoreListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
   

    
    
    selectedButton=0;
    self.bannerView.adUnitID = @"ca-app-pub-4237488103635443/8339330816";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    t=[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerCalled)userInfo:nil repeats:YES];
    [self getDataFromServer];
    
    
    
    
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
    labels=[[catArr valueForKey:@"labels"]mutableCopy];
    
    
    CGRect f = liveTable.frame;
    f.origin.y = liveTable.frame.origin.y+40;
    f.size.height= liveTable.frame.size.height-40;
    liveTable.frame =f;
    
    
    UIFont * myFont = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    liveButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    liveButton.titleLabel.font=myFont;
    [liveButton addTarget:self action:@selector(liveMethod:) forControlEvents:UIControlEventTouchUpInside];
    [liveButton setTitle:[labels valueForKey:@"live"][0] forState:UIControlStateNormal];
    liveButton.frame = CGRectMake(0, liveTable.frame.origin.y-45, self.view.frame.size.width/3, 40.0);
    [self.view addSubview:liveButton];
    
    
    recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recentButton.backgroundColor=[UIColor blackColor];
    recentButton.titleLabel.font=myFont;
    [recentButton addTarget:self action:@selector(recentMethod:) forControlEvents:UIControlEventTouchUpInside];
    [recentButton setTitle:[labels valueForKey:@"recent"][0] forState:UIControlStateNormal];
    recentButton.frame = CGRectMake(0+self.view.frame.size.width/3, liveTable.frame.origin.y-45, self.view.frame.size.width/3, 40.0);
    [self.view addSubview:recentButton];
    
    upcomingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    upcomingButton.backgroundColor=[UIColor blackColor];
    upcomingButton.titleLabel.font=myFont;

    [upcomingButton addTarget:self action:@selector(upcommingMethod:) forControlEvents:UIControlEventTouchUpInside];
    [upcomingButton setTitle:[labels valueForKey:@"upcomming"][0] forState:UIControlStateNormal];
    upcomingButton.frame = CGRectMake(self.view.frame.size.width/3+self.view.frame.size.width/3, liveTable.frame.origin.y-45, self.view.frame.size.width/3, 40.0);
    [self.view addSubview:upcomingButton];
    
    // Do any additional setup after loading the view.
}
-(void)liveMethod:(UIButton*)btn
{
    selectedButton=0;
    liveButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    recentButton.backgroundColor=[UIColor blackColor];
    upcomingButton.backgroundColor=[UIColor blackColor];
    [liveTable reloadData];
}
-(void)recentMethod:(UIButton*)btn
{
    selectedButton=1;
    recentButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    liveButton.backgroundColor=[UIColor blackColor];
    upcomingButton.backgroundColor=[UIColor blackColor];
    [liveTable reloadData];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [t invalidate];
}
-(void)upcommingMethod:(UIButton*)btn
{
    selectedButton=2;
    upcomingButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    liveButton.backgroundColor=[UIColor blackColor];
    recentButton.backgroundColor=[UIColor blackColor];
    [liveTable reloadData];

 
}

-(void)timerCalled
{
    [self getDataFromServer];
    NSLog(@"Timer Called");
    // Your Code
}
-(void)getDataFromServer
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://sportsflashes.com"]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/match_list?ln=%@",[u objectForKey:@"lang"]]
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
                    listArray=[[JSON valueForKey:@"data"]mutableCopy];
                    liveArr=[NSMutableArray new];
                    recentArr=[NSMutableArray new];
                    upcommingArr=[NSMutableArray new];
                    for(int i=0;i<listArray.count;i++)
                    {
                        if([[listArray[i] valueForKey:@"show_status"]integerValue]==1)
                           [liveArr addObject:listArray[i]];
                        if([[listArray[i] valueForKey:@"show_status"]integerValue]==2)
                            [recentArr addObject:listArray[i]];
                        if([[listArray[i] valueForKey:@"show_status"]integerValue]==3)
                            [upcommingArr addObject:listArray[i]];
                    }
                    
                    
                    [liveTable reloadData];
                }
                //NSLog(@"Network-Response: %@", JSON);
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
 //   [self.slideMenuController toggleMenuAnimated:sender];
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)refreshAction:(id)sender
{
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   if(selectedButton==0)
    return liveArr.count;
    else if(selectedButton==1)
        return recentArr.count;
    else
        return upcommingArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 115;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,30)];
    
 
        UIFont * myFont = [UIFont fontWithName:@"Arial-BoldMT" size:12];
        CGRect labelFrame = CGRectMake (10, 5,tableView.frame.size.width-10, 20);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setFont:myFont];
        label.lineBreakMode=NSLineBreakByWordWrapping;
        label.numberOfLines=5;
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor blackColor];
        label.backgroundColor=[UIColor clearColor];
    if(selectedButton==0)
        [label setText:[NSString stringWithFormat:@"%@",[liveArr[section] valueForKey:@"tname"]]];
    else if(selectedButton==1)
        [label setText:[NSString stringWithFormat:@"%@",[recentArr[section] valueForKey:@"tname"]]];
    else
        [label setText:[NSString stringWithFormat:@"%@",[upcommingArr[section] valueForKey:@"tname"]]];
        [view addSubview:label];
        
        
    //42,58,68
    view.backgroundColor=[UIColor whiteColor];//[UIColor colorWithRed:42/255.0 green:58/255.0 blue:68/255.0 alpha:1.0];
    
    return view;
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
   //
    //250,150,20
    UIImageView *borderImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 113, self.view.frame.size.width, 2)];
    borderImg.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    [cell addSubview:borderImg];
    
    
    UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 113)];
    //img.image=[UIImage imageNamed:@"team-name-bg"];
    img.backgroundColor=[UIColor whiteColor];
    [cell addSubview:img];
    
    
    AsyncImageView *imgLeft=[[AsyncImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
    if(selectedButton==0)
        imgLeft.imageURL=[NSURL URLWithString:[liveArr[indexPath.section] valueForKey:@"team1_flag"]];
    else if(selectedButton==1)
        imgLeft.imageURL=[NSURL URLWithString:[recentArr[indexPath.section] valueForKey:@"team1_flag"]];
    else
        imgLeft.imageURL=[NSURL URLWithString:[upcommingArr[indexPath.section] valueForKey:@"team1_flag"]];
    
    imgLeft.layer.cornerRadius=30.0;
    imgLeft.layer.masksToBounds=YES;
    [cell addSubview:imgLeft];
    
    AsyncImageView *imgRight=[[AsyncImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 10, 60,60)];
    if(selectedButton==0)
        imgRight.imageURL=[NSURL URLWithString:[liveArr[indexPath.section] valueForKey:@"team2_flag"]];
    else if(selectedButton==1)
        imgRight.imageURL=[NSURL URLWithString:[recentArr[indexPath.section] valueForKey:@"team2_flag"]];
    else
        imgRight.imageURL=[NSURL URLWithString:[upcommingArr[indexPath.section] valueForKey:@"team2_flag"]];
    imgRight.layer.cornerRadius=30.0;
    imgRight.layer.masksToBounds=YES;
    [cell addSubview:imgRight];
    
    
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 5, self.view.frame.size.width-180, 45)];
    NSString *stringWithoutHTML = @"";
    
    
    if(selectedButton==0)
        stringWithoutHTML = [[[liveArr objectAtIndex:indexPath.section]valueForKey:@"title"] stringByReplacingOccurrencesOfString:@"*" withString:@""];
    else if(selectedButton==1)
        stringWithoutHTML = [[[recentArr objectAtIndex:indexPath.section]valueForKey:@"title"] stringByReplacingOccurrencesOfString:@"*" withString:@""];
    else
        stringWithoutHTML = [[[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"title"] stringByReplacingOccurrencesOfString:@"*" withString:@""];

    
    
//    stringWithoutHTML = [stringWithoutHTML stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    stringWithoutHTML = [stringWithoutHTML stringByReplacingOccurrencesOfString:@">" withString:@""];
//    stringWithoutHTML = [stringWithoutHTML stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
//    stringWithoutHTML = [stringWithoutHTML stringByReplacingOccurrencesOfString:@"&" withString:@""];
//    stringWithoutHTML = [stringWithoutHTML stringByReplacingOccurrencesOfString:@";" withString:@""];

    fromLabel.text = stringWithoutHTML;
    fromLabel.numberOfLines = 2;
    fromLabel.clipsToBounds = YES;
    fromLabel.font=[UIFont fontWithName:@"Arial-BoldMT" size:17.0f];
    fromLabel.backgroundColor = [UIColor clearColor];
    fromLabel.textColor = [UIColor blackColor];
    fromLabel.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:fromLabel];
    
    
    UILabel *fromLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(75, 40, self.view.frame.size.width-160, 60)];
    if(selectedButton==0)
    fromLabel1.text = [[liveArr objectAtIndex:indexPath.section]valueForKey:@"m_status"];
    else if(selectedButton==1)
        fromLabel1.text = [[recentArr objectAtIndex:indexPath.section]valueForKey:@"m_status"];
    else
    fromLabel1.text = [[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"m_status"];

    fromLabel1.numberOfLines = 3;
    fromLabel1.clipsToBounds = YES;
    fromLabel1.font=[UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
    fromLabel1.backgroundColor = [UIColor clearColor];
    fromLabel1.textColor = [UIColor blackColor];
    fromLabel1.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:fromLabel1];
    
    
    
    

    
    
    UILabel *team1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 65, 60, 30)];
    if(selectedButton==0)
        team1.text = [[liveArr objectAtIndex:indexPath.section]valueForKey:@"team1_name"];
    else if(selectedButton==1)
        team1.text = [[recentArr objectAtIndex:indexPath.section]valueForKey:@"team1_name"];
    else
        team1.text = [[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"team1_name"];
    //team1.text = [[listArray objectAtIndex:indexPath.section]valueForKey:@"team1_name"];
    team1.numberOfLines = 2;
    team1.clipsToBounds = YES;
    team1.font=[UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
    team1.backgroundColor = [UIColor clearColor];
    team1.textColor = [UIColor blackColor];
    team1.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:team1];

    
    
    UILabel *team2 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 65, 60, 30)];
    if(selectedButton==0)
        team2.text = [[liveArr objectAtIndex:indexPath.section]valueForKey:@"team2_name"];
        else if(selectedButton==1)
            team2.text = [[recentArr objectAtIndex:indexPath.section]valueForKey:@"team2_name"];
            else
                team2.text = [[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"team2_name"];

    team2.numberOfLines = 2;
    team2.clipsToBounds = YES;
    team2.font=[UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
    team2.backgroundColor = [UIColor clearColor];
    team2.textColor = [UIColor blackColor];
    team2.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:team2];

    
    cell.backgroundColor=[UIColor clearColor];
       //cell.textLabel.text=[[listArray objectAtIndex:indexPath.row]valueForKey:@"title"];
       cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  @"unique_id"
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[[listArray objectAtIndex:indexPath.section]valueForKey:@"tname"]);
    
    
    if(selectedButton==0)
    {
        if ([[liveArr objectAtIndex:indexPath.section]valueForKey:@"tname"] == nil || [[[liveArr objectAtIndex:indexPath.section]valueForKey:@"tname"] isKindOfClass:[NSNull class]])
            [userDefaults setObject:@"-" forKey:@"MatchName"];
        else
            [userDefaults setObject:[[liveArr objectAtIndex:indexPath.section]valueForKey:@"tname"] forKey:@"MatchName"];
        [userDefaults setObject:[[liveArr objectAtIndex:indexPath.section]valueForKey:@"match_id"] forKey:@"unique_id"];
        
    }
    else if(selectedButton==1)
    {
        if ([[recentArr objectAtIndex:indexPath.section]valueForKey:@"tname"] == nil || [[[recentArr objectAtIndex:indexPath.section]valueForKey:@"tname"] isKindOfClass:[NSNull class]])
            [userDefaults setObject:@"-" forKey:@"MatchName"];
        else
            [userDefaults setObject:[[recentArr objectAtIndex:indexPath.section]valueForKey:@"tname"] forKey:@"MatchName"];
        [userDefaults setObject:[[recentArr objectAtIndex:indexPath.section]valueForKey:@"match_id"] forKey:@"unique_id"];
    }
    else
    {
        if ([[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"tname"] == nil || [[[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"tname"] isKindOfClass:[NSNull class]])
            [userDefaults setObject:@"-" forKey:@"MatchName"];
        else
            [userDefaults setObject:[[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"tname"] forKey:@"MatchName"];
        [userDefaults setObject:[[upcommingArr objectAtIndex:indexPath.section]valueForKey:@"match_id"] forKey:@"unique_id"];
    }

    
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

    
}

@end
