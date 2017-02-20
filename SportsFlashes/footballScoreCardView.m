//
//  footballScoreCardView.m
//  SportsFlashes
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "footballScoreCardView.h"
#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "AsyncImageView.h"

#define SITEURL @"http://sportsflashes.com"

@interface footballScoreCardView ()
{
    NSMutableArray *listArr,*listArr2;
}
@end

@implementation footballScoreCardView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-15, 200, 27)];
    logo.image=[UIImage imageNamed:@"logo"];
    logo.alpha=0.1;
    [self.view addSubview:logo];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    if([Utilities CheckInternetConnection])
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/fleage_scorecard?ln=%@&fleage_match_id=%@",lang,[u valueForKey:@"matchhh_id"]]
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
                    listArr=[[JSON valueForKey:@"data1"] mutableCopy];
                    listArr2=[[JSON valueForKey:@"data2"] mutableCopy];
                    NSLog(@"%@",listArr2);
                    [catTableView reloadData];
                    
                    
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
    
    UIView *seprator1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    seprator1.backgroundColor=[UIColor grayColor];
    [view addSubview:seprator1];
    
    UIView *seprator=[[UIView alloc]initWithFrame:CGRectMake(0, 29, self.view.frame.size.width, 1)];
    seprator.backgroundColor=[UIColor grayColor];
    [view addSubview:seprator];
    
    AsyncImageView *img=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 7, 25, 15)];
    img.imageURL=[NSURL URLWithString:[u objectForKey:@"matchh_flag"]];
    
    UIView *v;
    if(section==0)
    {
        string =[NSString stringWithFormat:@"%@",[u objectForKey:@"matchh_name"]];
        [view addSubview: img];

    }
    else
    {
        v=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        v.backgroundColor=[UIColor darkGrayColor];
        string =[NSString stringWithFormat:@"%@",@"MIN"];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor orangeColor];
        label.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);

    }
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:.5]]; //your background color...
    return view;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    return 100;
    else
        return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    return listArr.count;
    else
        return listArr2.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //:@"matchh_name"];
    //:@"matchh_flag"];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    if(indexPath.section==0)
    {
    AsyncImageView *imgs=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 30, 20, 20)];
    imgs.image=[UIImage imageNamed:@"star"];
    [cell addSubview: imgs];
    
    AsyncImageView *imgsr=[[AsyncImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-25, 30, 20, 20)];
    imgsr.image=[UIImage imageNamed:@"star"];
    [cell addSubview: imgsr];
    
    
    
    
    AsyncImageView *img=[[AsyncImageView alloc]initWithFrame:CGRectMake(35, 10, 50, 60)];
    img.imageURL=[NSURL URLWithString:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team1_logo"]];
    img.layer.cornerRadius=5;
    img.clipsToBounds=YES;
    [cell addSubview: img];
    
    AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-85, 10, 50, 60)];
    img1.imageURL=[NSURL URLWithString:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_logo"]];
    img1.layer.cornerRadius=5;
    img1.clipsToBounds=YES;
    [cell addSubview: img1];
    
    
    
    UIFont * myFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGRect labelFrame = CGRectMake (25, 70, 70, 25);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:myFont];
    label.lineBreakMode=NSLineBreakByWordWrapping;
    label.numberOfLines=5;
    label.textColor=[UIColor blackColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.backgroundColor=[UIColor clearColor];
    [label setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team1_name"]];
    [cell addSubview:label];
    
    
    
  
    
    UIFont * myFont1 = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGRect labelFrame1 = CGRectMake (self.view.frame.size.width-95, 70, 70, 25);
    UILabel *label1 = [[UILabel alloc] initWithFrame:labelFrame1];
    [label1 setFont:myFont1];
    label1.lineBreakMode=NSLineBreakByWordWrapping;
    label1.numberOfLines=5;
    label1.textColor=[UIColor blackColor];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.backgroundColor=[UIColor clearColor];
    [label1 setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_name"]];
    [cell addSubview:label1];
    
    
    
    
    UIView *seprator=[[UIView alloc]initWithFrame:CGRectMake(0, 99, self.view.frame.size.width, 1)];
    seprator.backgroundColor=[UIColor grayColor];
    [cell addSubview:seprator];
    
    
    
    
    
    
    
    
    UIView *seprator2=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-7, 39, 10,3)];
    seprator2.backgroundColor=[UIColor grayColor];
    [cell addSubview:seprator2];
    
    
    UILabel *matchTime = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2-70, 0, 140, 30)];
    [matchTime setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    matchTime.lineBreakMode=NSLineBreakByWordWrapping;
    matchTime.numberOfLines=5;
    matchTime.textColor=[UIColor blackColor];
    matchTime.textAlignment=NSTextAlignmentCenter;
    matchTime.backgroundColor=[UIColor clearColor];
    [matchTime setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"match_time"]];
    [cell addSubview:matchTime];
    
    
    UILabel *matchStatus = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2-70, 50, 140, 30)];
    [matchStatus setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    matchStatus.lineBreakMode=NSLineBreakByWordWrapping;
    matchStatus.numberOfLines=5;
    matchStatus.textColor=[UIColor blackColor];
    matchStatus.textAlignment=NSTextAlignmentCenter;
    matchStatus.backgroundColor=[UIColor clearColor];
    [matchStatus setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"venue"]];
    //[cell addSubview:matchStatus];
    
    
    UIFont * myFont2 = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    UILabel *score1 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2-60, 25, 45, 30)];
    [score1 setFont:myFont2];
    score1.lineBreakMode=NSLineBreakByWordWrapping;
    score1.numberOfLines=5;
    score1.textColor=[UIColor blackColor];
    score1.textAlignment=NSTextAlignmentRight;
    score1.backgroundColor=[UIColor clearColor];
    [score1 setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team1_goal"]];
    [cell addSubview:score1];
    
    UILabel *score2 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2+10, 25, 45, 30)];
    [score2 setFont:myFont2];
    score2.lineBreakMode=NSLineBreakByWordWrapping;
    score2.numberOfLines=5;
    score2.textColor=[UIColor blackColor];
    score2.textAlignment=NSTextAlignmentLeft;
    score2.backgroundColor=[UIColor clearColor];
    [score2 setText:[[listArr objectAtIndex:indexPath.row] valueForKey:@"team2_goal"]];
    [cell addSubview:score2];
    }
    
    else
    {
        UIView *seprator1=[[UIView alloc]initWithFrame:CGRectMake(5, 0, 2, 40)];
        seprator1.backgroundColor=[UIColor grayColor];
        [cell addSubview:seprator1];
        
        UIView *seprator2=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-5, 0, 2, 40)];
        seprator2.backgroundColor=[UIColor grayColor];
        [cell addSubview:seprator2];
        
        UIView *seprator3=[[UIView alloc]initWithFrame:CGRectMake(5, 0, self.view.frame.size.width-10, 1)];
        seprator3.backgroundColor=[UIColor grayColor];
        [cell addSubview:seprator3];
        
//        UIView *seprator4=[[UIView alloc]initWithFrame:CGRectMake(100, 0, 2, 30)];
//        seprator4.backgroundColor=[UIColor grayColor];
//        [cell addSubview:seprator4];
        
        
        UIView *seprator4=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-15, 0, 2, 40)];
        seprator4.backgroundColor=[UIColor grayColor];
        [cell addSubview:seprator4];
        
        UIView *seprator5=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+15, 0, 2, 40)];
        seprator5.backgroundColor=[UIColor grayColor];
        [cell addSubview:seprator5];
        
        
//        UIView *seprator5=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, 0, 2, 30)];
//        seprator5.backgroundColor=[UIColor grayColor];
//        [cell addSubview:seprator5];

        
        UIView *seprator6=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, 0, 2, 40)];
        seprator6.backgroundColor=[UIColor grayColor];
       // [cell addSubview:seprator6];
        
        UIView *seprator7=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+40, 0, 2, 40)];
        seprator7.backgroundColor=[UIColor grayColor];
       // [cell addSubview:seprator7];
        
        
        
        UILabel *score2 = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width/2-15, 0, 30, 40)];
        [score2 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
        score2.lineBreakMode=NSLineBreakByWordWrapping;
        score2.numberOfLines=1;
        score2.textColor=[UIColor blackColor];
        score2.textAlignment=NSTextAlignmentCenter;
        score2.backgroundColor=[UIColor clearColor];
        [score2 setText:[NSString stringWithFormat:@"%@'",[[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"min"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        [cell addSubview:score2];

        
        if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_icon_status"]integerValue]==0)
        {
            if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"] length]>2 &&[[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_sub"] length]>2)
            {
                
                UIImageView *arowUp=[[UIImageView alloc]initWithFrame:CGRectMake(14, 5, 10, 10)];
                arowUp.image=[UIImage imageNamed:@"arrowUPp"];
                [cell addSubview:arowUp];
                
                
                UIImageView *arowDown=[[UIImageView alloc]initWithFrame:CGRectMake(14, 24, 10, 10)];
                arowDown.image=[UIImage imageNamed:@"arrowDown"];
                [cell addSubview:arowDown];

                
                UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (27, 2, 105, 18)];
                [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
                leftName.lineBreakMode=NSLineBreakByWordWrapping;
                leftName.numberOfLines=5;
                leftName.textColor=[UIColor blackColor];
                leftName.textAlignment=NSTextAlignmentLeft;
                leftName.backgroundColor=[UIColor clearColor];
                [leftName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"]]];
                [cell addSubview:leftName];
                
                
                UILabel *subtituteName = [[UILabel alloc] initWithFrame:CGRectMake (27, 20, 105, 18)];
                [subtituteName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
                subtituteName.lineBreakMode=NSLineBreakByWordWrapping;
                subtituteName.numberOfLines=5;
                subtituteName.textColor=[UIColor blackColor];
                subtituteName.textAlignment=NSTextAlignmentLeft;
                subtituteName.backgroundColor=[UIColor clearColor];
                [subtituteName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_sub"]]];
                [cell addSubview:subtituteName];
                
                
                          }
            else  if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"] length]>2 )
            {
                UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (12, 5, 105, 30)];
                [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
                leftName.lineBreakMode=NSLineBreakByWordWrapping;
                leftName.numberOfLines=5;
                leftName.textColor=[UIColor blackColor];
                leftName.textAlignment=NSTextAlignmentCenter;
                leftName.backgroundColor=[UIColor clearColor];
                [leftName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"]]];
                [cell addSubview:leftName];
            }
            //nothing
        }
        else if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_icon_status"]integerValue]==1)
        {
            UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (12, 5, 105, 30)];
            [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            leftName.lineBreakMode=NSLineBreakByWordWrapping;
            leftName.numberOfLines=5;
            leftName.textColor=[UIColor blackColor];
            leftName.textAlignment=NSTextAlignmentCenter;
            leftName.backgroundColor=[UIColor clearColor];
            [leftName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"]]];
            [cell addSubview:leftName];
            
            UIImageView *footballImage=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-38, 12, 17, 20)];
            footballImage.image=[UIImage imageNamed:@"Football"];
            [cell addSubview:footballImage];
         //football
        }
        else if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_icon_status"]integerValue]==2)
        {
            UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (12, 5, 105, 30)];
            [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            leftName.lineBreakMode=NSLineBreakByWordWrapping;
            leftName.numberOfLines=5;
            leftName.textColor=[UIColor blackColor];
            leftName.textAlignment=NSTextAlignmentCenter;
            leftName.backgroundColor=[UIColor clearColor];
            [leftName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"]]];
            [cell addSubview:leftName];
            
            UIImageView *footballImage=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-38, 10, 12, 20)];
            footballImage.image=[UIImage imageNamed:@"yellow"];
            [cell addSubview:footballImage];
            //yellow
        }
        else if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_icon_status"]integerValue]==3)
        {
            UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (12, 5, 105, 30)];
            [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            leftName.lineBreakMode=NSLineBreakByWordWrapping;
            leftName.numberOfLines=5;
            leftName.textColor=[UIColor blackColor];
            leftName.textAlignment=NSTextAlignmentCenter;
            leftName.backgroundColor=[UIColor clearColor];
            [leftName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"]]];
            [cell addSubview:leftName];
            
            UIImageView *footballImage=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-38, 10, 11, 20)];
            footballImage.image=[UIImage imageNamed:@"red"];
            [cell addSubview:footballImage];
            //red
        }
        else if([[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_icon_status"]integerValue]==4)
        {
            UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (12, 5, 105, 30)];
            [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            leftName.lineBreakMode=NSLineBreakByWordWrapping;
            leftName.numberOfLines=5;
            leftName.textColor=[UIColor blackColor];
            leftName.textAlignment=NSTextAlignmentCenter;
            leftName.backgroundColor=[UIColor clearColor];
            [leftName setText:[NSString stringWithFormat:@"%@",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"]]];
            [cell addSubview:leftName];
            
            UIImageView *footballImage=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-38, 10, 15, 20)];
            footballImage.image=[UIImage imageNamed:@"person"];
            [cell addSubview:footballImage];
            //person
        }
        UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake (20, 0, 80, 30)];
        [leftName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        leftName.lineBreakMode=NSLineBreakByWordWrapping;
        leftName.numberOfLines=5;
        leftName.textColor=[UIColor blackColor];
        leftName.textAlignment=NSTextAlignmentCenter;
        leftName.backgroundColor=[UIColor clearColor];
        [leftName setText:[NSString stringWithFormat:@"%@ (%@)",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer"],[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"fplayer_sub"]]];
        //[cell addSubview:leftName];
        
        
        UILabel *rightName = [[UILabel alloc] initWithFrame:CGRectMake (self.view.frame.size.width-100, 0, 80, 30)];
        [rightName setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        rightName.lineBreakMode=NSLineBreakByWordWrapping;
        rightName.numberOfLines=5;
        rightName.textColor=[UIColor blackColor];
        rightName.textAlignment=NSTextAlignmentLeft;
        rightName.backgroundColor=[UIColor clearColor];
        [rightName setText:[NSString stringWithFormat:@"%@ (%@)",[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"splayer"],[[listArr2 objectAtIndex:indexPath.row] valueForKey:@"spalyer_sub"]]];
        //[cell addSubview:rightName];
        if(indexPath.row==listArr2.count-1)
        {
            UIView *seprator3=[[UIView alloc]initWithFrame:CGRectMake(5, 39, self.view.frame.size.width-10, 1)];
            seprator3.backgroundColor=[UIColor grayColor];
            [cell addSubview:seprator3];
        }

        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

@end
