//
//  footbalMatchListView.m
//  SportsFlashes
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "footbalMatchListView.h"
#define SITEURL @"http://sportsflashes.com"

#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "AsyncImageView.h"

#import "footballMatchScoreView.h"

@interface footbalMatchListView ()
{
    NSMutableArray *listArr;
    
    
}
@end

@implementation footbalMatchListView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-15, 200, 27)];
    logo.image=[UIImage imageNamed:@"logo"];
    logo.alpha=0.3;
    [self.view addSubview:logo];
    
   
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/fleage_list?ln=%@",lang]
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
                    NSLog(@"%@",listArr[0]);
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
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40;;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    AsyncImageView *img=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 6, 35, 25)];
    img.imageURL=[NSURL URLWithString:[[listArr objectAtIndex:indexPath.row] valueForKey:@"logo"]];
    [cell addSubview: img];
    
    
    UIFont * myFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    CGRect labelFrame = CGRectMake (45, 4, 180, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:myFont];
    label.lineBreakMode=NSLineBreakByWordWrapping;
    label.numberOfLines=5;
    label.textColor=[UIColor blackColor];
    label.textAlignment=NSTextAlignmentLeft;
    label.backgroundColor=[UIColor clearColor];
    [label setText:[[[listArr objectAtIndex:indexPath.row] valueForKey:@"name"] uppercaseString]];
    [cell addSubview:label];
    
    
    
    UIView *sideCount=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
    sideCount.backgroundColor=[UIColor grayColor];
    sideCount.layer.cornerRadius=4.0;
    cell.accessoryView=sideCount;// addSubview:sideCount];
    
    UIFont * myFont1 = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGRect labelFrame1 = CGRectMake (5, 0, 20, 20);
    UILabel *label1 = [[UILabel alloc] initWithFrame:labelFrame1];
    [label1 setFont:myFont1];
    label1.lineBreakMode=NSLineBreakByWordWrapping;
    label1.numberOfLines=5;
    label1.textColor=[UIColor whiteColor];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.backgroundColor=[UIColor clearColor];
    [label1 setText:[[[listArr objectAtIndex:indexPath.row] valueForKey:@"ccount"] uppercaseString]];
    [sideCount addSubview:label1];
    
    
    
    
    UIView *seprator=[[UIView alloc]initWithFrame:CGRectMake(0, 39, self.view.frame.size.width, 1)];
    seprator.backgroundColor=[UIColor blackColor];
    [cell addSubview:seprator];
    
    //        cell.textLabel.text=[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row ]valueForKey:@"option_name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] forKey:@"matchh_id"];
    [userDefaults setObject:[[listArr objectAtIndex:indexPath.row] valueForKey:@"name"] forKey:@"matchh_name"];
    [userDefaults setObject:[[listArr objectAtIndex:indexPath.row] valueForKey:@"logo"] forKey:@"matchh_flag"];
    [userDefaults synchronize];
    
//    if([[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==1 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==2 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==3 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==4 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==5)
//    {
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
//    }
//    if([[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==6 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==7 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==8 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==9 || [[[listArr objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]==10)
//    {
//        liveScoreListViewController *smvc;
//        int height = [UIScreen mainScreen].bounds.size.height;
//        if (height == 480) {
//            
//            
//            smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreListViewController"];
//            
//        }
//        else if (height == 568) {
//            
//            
//            smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreListViewController"];
//            
//        }
//        else if (height == 667) {
//            
//            
//            smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreListViewController"];
//            
//        }
//        else if (height == 736) {
//            
//            
//            smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreListViewController"];
//            
//        }
//        else if (height == 1024) {
//            
//            
//            smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreListViewController"];
//            
//        }
//        else
//        {
//            
//            
//            smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"liveScoreListViewController"];
//            
//        }
//        
//        [self.navigationController pushViewController:smvc animated:YES];
//    }
//    if(tableView.tag==100)
//    {
//        
//    }
}


@end
