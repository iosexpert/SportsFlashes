//
//  footballMatchScoreView.m
//  SportsFlashes
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "footballMatchScoreView.h"
#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "AsyncImageView.h"

#import "footballScoreCardView.h"
#define SITEURL @"http://sportsflashes.com"

#import <Google/Analytics.h>

@interface footballMatchScoreView ()
{
    NSMutableArray *listArr;
    
    UIButton *liveButton,*resultButton,*fixtureButton;
    NSMutableArray *liveArr,*resultArr,*fixtureArr;
    
    int selectedButton;
    NSMutableArray *catArr,*labels;
}
@end

@implementation footballMatchScoreView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-15, 200, 27)];
    logo.image=[UIImage imageNamed:@"logo"];
    logo.alpha=0.3;
    [self.view addSubview:logo];
    
    
    
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
    labels=[[catArr valueForKey:@"labels"]mutableCopy];
    
    CGRect f = catTableView.frame;
    f.origin.y = catTableView.frame.origin.y+40;
    f.size.height= catTableView.frame.size.height-40;
    catTableView.frame =f;
    
    
    UIFont * myFont = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    liveButton.backgroundColor=[UIColor blackColor];
    liveButton.titleLabel.font=myFont;
    [liveButton addTarget:self action:@selector(liveMethod:) forControlEvents:UIControlEventTouchUpInside];
    [liveButton setTitle:[labels valueForKey:@"flive"][0] forState:UIControlStateNormal];
    liveButton.frame = CGRectMake(0+self.view.frame.size.width/3, catTableView.frame.origin.y-45, self.view.frame.size.width/3, 40.0);
    [self.view addSubview:liveButton];
    
    
    resultButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resultButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    resultButton.titleLabel.font=myFont;
    [resultButton addTarget:self action:@selector(recentMethod:) forControlEvents:UIControlEventTouchUpInside];
    [resultButton setTitle:[labels valueForKey:@"fresults"][0] forState:UIControlStateNormal];
    resultButton.frame = CGRectMake(0, catTableView.frame.origin.y-45, self.view.frame.size.width/3, 40.0);
    [self.view addSubview:resultButton];
    
    
    
    fixtureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fixtureButton.backgroundColor=[UIColor blackColor];
    fixtureButton.titleLabel.font=myFont;
    [fixtureButton addTarget:self action:@selector(upcommingMethod:) forControlEvents:UIControlEventTouchUpInside];
    [fixtureButton setTitle:[labels valueForKey:@"fupcomming"][0] forState:UIControlStateNormal];
    fixtureButton.frame = CGRectMake(self.view.frame.size.width/3+self.view.frame.size.width/3, catTableView.frame.origin.y-45, self.view.frame.size.width/3, 40.0);
    [self.view addSubview:fixtureButton];

    selectedButton=0;
    // Do any additional setup after loading the view.
}
-(void)liveMethod:(UIButton*)btn
{
    selectedButton=1;
    liveButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    resultButton.backgroundColor=[UIColor blackColor];
    fixtureButton.backgroundColor=[UIColor blackColor];
    [catTableView reloadData];
}
-(void)recentMethod:(UIButton*)btn
{
    selectedButton=0;
    resultButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    liveButton.backgroundColor=[UIColor blackColor];
    fixtureButton.backgroundColor=[UIColor blackColor];
    [catTableView reloadData];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    //[t invalidate];
}
-(void)upcommingMethod:(UIButton*)btn
{
    selectedButton=2;
    fixtureButton.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    liveButton.backgroundColor=[UIColor blackColor];
    resultButton.backgroundColor=[UIColor blackColor];
    [catTableView reloadData];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
       id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        [tracker set:kGAIScreenName value:@"FootballScoreLive"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/fleage_match_list?ln=%@&fleage_match_id=%@",lang,[u valueForKey:@"matchh_id"]]
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
                    listArr=[[JSON valueForKey:@"data"] mutableCopy];
                    liveArr=[NSMutableArray new];
                    resultArr=[NSMutableArray new];
                    fixtureArr=[NSMutableArray new];
                    
                    for(int i=0;i<listArr.count;i++)
                    {
                        if([[listArr[i] valueForKey:@"live_status"]integerValue]==1)
                            [liveArr addObject:listArr[i]];
                        if([[listArr[i] valueForKey:@"live_status"]integerValue]==2)
                            [resultArr addObject:listArr[i]];
                        if([[listArr[i] valueForKey:@"live_status"]integerValue]==3)
                            [fixtureArr addObject:listArr[i]];
                        
                        [catTableView reloadData];

                    }
                }
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
    }
    
}

-(IBAction)back_action:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)search_action:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
}- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

        return 30;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];

    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, tableView.frame.size.width, 30)];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    label.textColor=[UIColor blackColor];
    NSString *string;
    
    AsyncImageView *img=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 7, 25, 15)];
    img.imageURL=[NSURL URLWithString:[u objectForKey:@"matchh_flag"]];
    [view addSubview: img];

    
    if(section==0)
        string =[NSString stringWithFormat:@"%@",[u objectForKey:@"matchh_name"]];
    [label setText:string];
    [view addSubview:label];
            [view setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:204.0/255.0 alpha:1.0]]; //your background color...
    return view;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 135;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tempArr;
    if(selectedButton==0)
        tempArr=[resultArr mutableCopy];
    else if(selectedButton==1)
        tempArr=[liveArr mutableCopy];
    else
        tempArr=[fixtureArr mutableCopy];
    return tempArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
//    AsyncImageView *imgs=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 18, 20, 20)];
//    imgs.image=[UIImage imageNamed:@"star"];
//    [cell addSubview: imgs];
//    
//    AsyncImageView *img=[[AsyncImageView alloc]initWithFrame:CGRectMake(35, 8, 15, 18)];
//    img.imageURL=[NSURL URLWithString:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team1_logo"]];
//    [cell addSubview: img];
//    
//    AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(35, 33, 15, 18)];
//    img1.imageURL=[NSURL URLWithString:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_logo"]];
//    [cell addSubview: img1];
//    
//    
//    UIFont * myFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];
//    CGRect labelFrame = CGRectMake (55, 5, self.view.frame.size.width-75-50, 25);
//    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
//    [label setFont:myFont];
//    label.lineBreakMode=NSLineBreakByWordWrapping;
//    label.numberOfLines=5;
//    label.textColor=[UIColor blackColor];
//    label.textAlignment=NSTextAlignmentLeft;
//    label.backgroundColor=[UIColor clearColor];
//    [label setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team1_name"]];
//    [cell addSubview:label];
//    
//    
//    
//    UIView *sideCount=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    sideCount.backgroundColor=[UIColor grayColor];
//    sideCount.layer.cornerRadius=5.0;
//    //cell.accessoryView=sideCount;// addSubview:sideCount];
//    
//    UIFont * myFont1 = [UIFont fontWithName:@"Helvetica" size:12];
//    CGRect labelFrame1 = CGRectMake (55, 30, self.view.frame.size.width-75-50, 25);
//    UILabel *label1 = [[UILabel alloc] initWithFrame:labelFrame1];
//    [label1 setFont:myFont1];
//    label1.lineBreakMode=NSLineBreakByWordWrapping;
//    label1.numberOfLines=5;
//    label1.textColor=[UIColor blackColor];
//    label1.textAlignment=NSTextAlignmentLeft;
//    label1.backgroundColor=[UIColor clearColor];
//    [label1 setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_name"]];
//    [cell addSubview:label1];
//    
//    
//    
//    
//    UIView *seprator=[[UIView alloc]initWithFrame:CGRectMake(0, 59, self.view.frame.size.width, 1)];
//    seprator.backgroundColor=[UIColor grayColor];
//    [cell addSubview:seprator];
//    
//    
//    
//    UIView *seprator1=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, 5, 1,50)];
//    seprator1.backgroundColor=[UIColor grayColor];
//    [cell addSubview:seprator1];
//    
//    
//    UIView *seprator2=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-55, 30, 50,1)];
//    seprator2.backgroundColor=[UIColor grayColor];
//    [cell addSubview:seprator2];
//    
//    
//    
//    
//    UIFont * myFont2 = [UIFont fontWithName:@"Helvetica-Bold" size:14];
//    UILabel *score1 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-50, 5, 45, 25)];
//    [score1 setFont:myFont2];
//    score1.lineBreakMode=NSLineBreakByWordWrapping;
//    score1.numberOfLines=5;
//    score1.textColor=[UIColor blackColor];
//    score1.textAlignment=NSTextAlignmentCenter;
//    score1.backgroundColor=[UIColor clearColor];
//    [score1 setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team1_goal"]];
//    [cell addSubview:score1];
//    
//    UILabel *score2 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-50, 30, 45, 25)];
//    [score2 setFont:myFont2];
//    score2.lineBreakMode=NSLineBreakByWordWrapping;
//    score2.numberOfLines=5;
//    score2.textColor=[UIColor blackColor];
//    score2.textAlignment=NSTextAlignmentCenter;
//    score2.backgroundColor=[UIColor clearColor];
//    [score2 setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_goal"]];
//    [cell addSubview:score2];
    NSArray *tempArr;
    if(selectedButton==0)
    tempArr=[resultArr mutableCopy];
    else if(selectedButton==1)
        tempArr=[liveArr mutableCopy];
    else
        tempArr=[fixtureArr mutableCopy];

    AsyncImageView *imgs=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 50, 20, 20)];
    imgs.image=[UIImage imageNamed:@"star"];
    [cell addSubview: imgs];
    
    AsyncImageView *imgsr=[[AsyncImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-25, 50, 20, 20)];
    imgsr.image=[UIImage imageNamed:@"star"];
    [cell addSubview: imgsr];
    
    
    
    
    AsyncImageView *img=[[AsyncImageView alloc]initWithFrame:CGRectMake(35, 30, 50, 60)];
    img.imageURL=[NSURL URLWithString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team1_logo"]];
    img.layer.cornerRadius=5;
    img.clipsToBounds=YES;
    [cell addSubview: img];
    
    AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-85, 30, 50, 60)];
    img1.imageURL=[NSURL URLWithString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team2_logo"]];
    img1.layer.cornerRadius=5;
    img1.clipsToBounds=YES;
    [cell addSubview: img1];
    
    
    
    UIFont * myFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGRect labelFrame = CGRectMake (25, 90, 70, 25);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:myFont];
    label.lineBreakMode=NSLineBreakByWordWrapping;
    label.numberOfLines=5;
    label.textColor=[UIColor blackColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.backgroundColor=[UIColor clearColor];
    [label setText:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team1_name"]];
    [cell addSubview:label];
    
    
    
    
    
    UIFont * myFont1 = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGRect labelFrame1 = CGRectMake (self.view.frame.size.width-95, 90, 70, 25);
    UILabel *label1 = [[UILabel alloc] initWithFrame:labelFrame1];
    [label1 setFont:myFont1];
    label1.lineBreakMode=NSLineBreakByWordWrapping;
    label1.numberOfLines=5;
    label1.textColor=[UIColor blackColor];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.backgroundColor=[UIColor clearColor];
    [label1 setText:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team2_name"]];
    [cell addSubview:label1];
    
    
    
    
    UIView *seprator=[[UIView alloc]initWithFrame:CGRectMake(0, 134, self.view.frame.size.width, 1)];
    seprator.backgroundColor=[UIColor grayColor];
    [cell addSubview:seprator];
    
    
    
    
    
    
    
    
    UIView *seprator2=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-7, 63, 10,3)];
    seprator2.backgroundColor=[UIColor grayColor];
    [cell addSubview:seprator2];
    
    
    UILabel *matchTime = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2-50,2,100,40)];
    [matchTime setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    matchTime.lineBreakMode=NSLineBreakByWordWrapping;
    matchTime.numberOfLines=5;
    matchTime.textColor=[UIColor blackColor];
    matchTime.textAlignment=NSTextAlignmentCenter;
    matchTime.backgroundColor=[UIColor clearColor];
    [matchTime setText:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"match_time"]];//[NSString stringWithFormat:@"%@ VS %@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team1_name"],[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_name"]]];//[[listArr objectAtIndex:indexPath.row] valueForKey:@"match_time"]];
    [cell addSubview:matchTime];
    
    
    UILabel *matchStatus = [[UILabel alloc] initWithFrame:CGRectMake (0, 105, self.view.frame.size.width, 30)];
    [matchStatus setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    matchStatus.lineBreakMode=NSLineBreakByWordWrapping;
    matchStatus.numberOfLines=5;
    matchStatus.textColor=[UIColor blackColor];
    matchStatus.textAlignment=NSTextAlignmentCenter;
    matchStatus.backgroundColor=[UIColor clearColor];
    [matchStatus setText:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"venue"]];
    [cell addSubview:matchStatus];
    
    
    UIFont * myFont2 = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    UILabel *score1 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2-60, 50, 45, 30)];
    [score1 setFont:myFont2];
    score1.lineBreakMode=NSLineBreakByWordWrapping;
    score1.numberOfLines=5;
    score1.textColor=[UIColor blackColor];
    score1.textAlignment=NSTextAlignmentRight;
    score1.backgroundColor=[UIColor clearColor];
    [score1 setText:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team1_goal"]];
    [cell addSubview:score1];
    
    

    UILabel *score2 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2+10, 50, 45, 30)];
    [score2 setFont:myFont2];
    score2.lineBreakMode=NSLineBreakByWordWrapping;
    score2.numberOfLines=5;
    score2.textColor=[UIColor blackColor];
    score2.textAlignment=NSTextAlignmentLeft;
    score2.backgroundColor=[UIColor clearColor];
    [score2 setText:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"team2_goal"]];
    [cell addSubview:score2];

    
    
    //        cell.textLabel.text=[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row ]valueForKey:@"option_name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray *tempArr;
//    if(selectedButton==0)
//        tempArr=[resultArr mutableCopy];
//    else if(selectedButton==1)
//        tempArr=[liveArr mutableCopy];
//    else
//        tempArr=[fixtureArr mutableCopy];
//
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"id"] forKey:@"matchhh_id"];
//    [userDefaults synchronize];
//
//
//            footballScoreCardView *smvc;
//            int height = [UIScreen mainScreen].bounds.size.height;
//            if (height == 480) {
//    
//    
//                smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"footballScoreCardView"];
//    
//            }
//            else if (height == 568) {
//    
//    
//                smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"footballScoreCardView"];
//    
//            }
//            else if (height == 667) {
//    
//    
//                smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"footballScoreCardView"];
//    
//            }
//            else if (height == 736) {
//    
//    
//                smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"footballScoreCardView"];
//    
//            }
//            else if (height == 1024) {
//    
//    
//                smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"footballScoreCardView"];
//    
//            }
//            else
//            {
//    
//    
//                smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"footballScoreCardView"];
//    
//            }
//    
//            [self.navigationController pushViewController:smvc animated:YES];
    
}


@end
