//
//  slideMenuViewController.m
//  MYScores
//
//  Created by Apple on 02/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "slideMenuViewController.h"
#import "NVSlideMenuController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "AFNetworking.h"
#import "AFHTTPClient.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#define SITEURL @"http://sportsflashes.com"


@interface slideMenuViewController ()
{
    NSMutableArray *catArr,*catTopArr,*catOtherArr,*catSettingArr ,*labels,*myFeedArr,*myFeedCatArr,*catTopMostArr,*catTopMostArrImg,*catTopMostArrImgSelect;
    int totalRows;
    MBProgressHUD *HUD;
    UIImageView *liveIcon;
    NSArray *liveArray;
    NSMutableArray *catArr1,*catTopArr1,*catOtherArr1;
    UIButton *submitbtn,*cancelBtn;
    
    
    int lastSelectedTag,currentSelectedTag;
}
@end

@implementation slideMenuViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(IBAction)slideButton_action:(UIButton*)sender
{
    searchbar.showsCancelButton=NO;
    [searchbar resignFirstResponder];
    searchbar.text=@"";
    [self.slideMenuController toggleMenuAnimated:sender];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGRect f1 = myFeedTable.frame;
    f1.size.height=myFeedTable.frame.size.height-50;
    myFeedTable.frame =f1;
    
    
    lastSelectedTag=0;
    
    /////////////////////Array for First 4 Options///////////////////////////////
    catTopMostArr=[[NSMutableArray alloc]initWithObjects:@"Change Language",@"Rate This App",@"Invite Your Friends",@"Change Feed", nil];
    catTopMostArrImg=[[NSMutableArray alloc]initWithObjects:@"c2",@"c4",@"c3",@"c1", nil];
    catTopMostArrImgSelect=[[NSMutableArray alloc]initWithObjects:@"cs1",@"cs2",@"cs3",@"cs4", nil];
    
    
    
   ////////////////////////table initilization for the slelection of my feed///////////////////////////
    
    myFeedTable.scrollEnabled=true;
    
    submitbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [submitbtn setFrame:CGRectMake(5, myFeedView.frame.size.height-35, myFeedView.frame.size.width/2-10, 30)];
    [submitbtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    submitbtn.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    [submitbtn setTitle:@"Submit" forState:UIControlStateNormal];
    [submitbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [myFeedView addSubview: submitbtn];
    
    cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(myFeedView.frame.size.width/2+5, myFeedView.frame.size.height-35, myFeedView.frame.size.width/2-10, 30)];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [myFeedView addSubview: cancelBtn];

    
    
    
    searchbar.placeholder=@"Search";
    
    //[inviteButton addTarget:self action:@selector(inviteFacebookUser) forControlEvents:UIControlEventTouchUpInside];
    //[rateButton addTarget:self action:@selector(rateOnAppStore) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    topStatusBar.backgroundColor=[UIColor colorWithRed:83.0/255.0 green:107.0/255.0 blue:119.0/255.0 alpha:1.0];
    self.navigationController.navigationBarHidden=YES;
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    ///////////////Fetch data from main array/////And put them in diffrent array to show the data of scrollview////////////
    myFeedCatArr=[NSMutableArray new];
    myFeedArr=[NSMutableArray new];
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    catArr=[[u objectForKey:@"categoryArr"]mutableCopy];
    catTopArr=[[catArr valueForKey:@"data_top"]mutableCopy];;
    labels=[[catArr valueForKey:@"labels"]mutableCopy];
    catOtherArr=[[catArr valueForKey:@"data"]mutableCopy];
    
    
    
    catArr1=[[u objectForKey:@"cat_myfeed"]mutableCopy];
    catTopArr1=[[catArr1 valueForKey:@"data_top"]mutableCopy];;
    catOtherArr1=[[catArr1 valueForKey:@"data"]mutableCopy];

    
    
    [cancelBtn setTitle:[labels valueForKey:@"cancel"][0] forState:UIControlStateNormal];
    [submitbtn setTitle:[labels valueForKey:@"submit"][0] forState:UIControlStateNormal];
    
   // [bookmarkButton setTitle:[labels valueForKey:@"bookmark"][0] forState:UIControlStateNormal];
   // [changeMyFeedButton setTitle:[labels valueForKey:@"feed"][0] forState:UIControlStateNormal];
   // [rateButton setTitle:[labels valueForKey:@"rate"][0] forState:UIControlStateNormal];
   // [inviteButton setTitle:[labels valueForKey:@"invite"][0] forState:UIControlStateNormal];
    
    //
    catTopMostArr=[[NSMutableArray alloc]initWithObjects:[labels valueForKey:@"language"][0],[labels valueForKey:@"rate"][0],[labels valueForKey:@"invite"][0],[labels valueForKey:@"feed"][0], nil];

    
    for (int i=0; i<catTopArr1.count;i++) {
        [myFeedCatArr addObject:catTopArr1[i]];
    }
    for (int i=0; i<catOtherArr1.count;i++) {
        [myFeedCatArr addObject:catOtherArr1[i]];
    }
    [myFeedTable reloadData];
    
    
    for(int i=0;i<[[catArr1 valueForKey:@"auto_feed"] count];i++)
    {
        if(![myFeedArr containsObject:[[[catArr1 valueForKey:@"auto_feed"] objectAtIndex:i]valueForKey:@"cateogory_id"]])
        [myFeedArr addObject:[[[catArr1 valueForKey:@"auto_feed"] objectAtIndex:i]valueForKey:@"cateogory_id"]];
    }
    catSettingArr=[[NSMutableArray alloc]initWithObjects:[labels valueForKey:@"privacy"][0],[labels valueForKey:@"terms"][0], nil];
    
    
    
    
    [self setDataOnScrolView];

    
    
}
-(void)setDataOnScrolView    /////////////second and third section on scroll view
{
    for (UIView *v in scrv.subviews) {
        if (![v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    
    int x=0,y=0;
    for (int i=0;i<catTopMostArr.count;i++)
    {
        
        
        
        UIButton *btnn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnn setFrame:CGRectMake(x, y, self.view.frame.size.width/4, self.view.frame.size.width/4)];
        
        UILabel *titleLabell = [[UILabel alloc] initWithFrame:CGRectMake(5, self.view.frame.size.width/4-30, self.view.frame.size.width/4-10, 35)];
        titleLabell.font = [UIFont fontWithName:@"Arial-BoldMT" size:10.0];
if(self.view.frame.size.width>414)
{
    titleLabell.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];

}
        titleLabell.text = catTopMostArr[i];
        titleLabell.numberOfLines = 3;
        titleLabell.userInteractionEnabled=false;
        titleLabell.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabell.textAlignment = NSTextAlignmentCenter;
        [btnn addSubview:titleLabell];
        btnn.tag=990000+i;

        if(i==0)
        [btnn addTarget:self action:@selector(changeLanguage:) forControlEvents:UIControlEventTouchUpInside];
        else if(i==1)
            [btnn addTarget:self action:@selector(rateOnAppStore:) forControlEvents:UIControlEventTouchUpInside];
        else if(i==2)
            [btnn addTarget:self action:@selector(inviteFacebookUser:) forControlEvents:UIControlEventTouchUpInside];
        else if(i==3)
            [btnn addTarget:self action:@selector(changeMyFeed:) forControlEvents:UIControlEventTouchUpInside];

        [scrv addSubview: btnn];

        UIImageView *logoImagee=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/4)/2-15,self.view.frame.size.width/4-60, 30, 30)];
        logoImagee.userInteractionEnabled=false;
        logoImagee.tag=900000+i;
        if(lastSelectedTag==990000+i)
        logoImagee.image=[UIImage imageNamed:catTopMostArrImgSelect[i]];
        else
            logoImagee.image=[UIImage imageNamed:catTopMostArrImg[i]];
        logoImagee.contentMode = UIViewContentModeScaleAspectFit;
        [btnn addSubview:logoImagee];
        
        
        
        x=x+self.view.frame.size.width/4;
        
        if(i%4==0 && i!=0)
        {
            x=0;
            y=y+self.view.frame.size.width/4;
        }
        
    }
    
    
    
    y=y+self.view.frame.size.width/4+20;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.view.frame.size.width, 25)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    label.textColor=categoryBtn.backgroundColor;
    NSString *string;
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, y+25, self.view.frame.size.width, 2)];
    v.backgroundColor=categoryBtn.backgroundColor;
    string = [labels valueForKey:@"category"][0];
    [label setText:string];
    [scrv addSubview:v];
    [scrv addSubview:label];
    
    catTableView.hidden=YES;
    
    x=0,y=y+20;
    for (int i=0;i<catTopArr.count;i++)
    {
        
        
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(x, y, self.view.frame.size.width/4, self.view.frame.size.width/4)];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.view.frame.size.width/4-30, self.view.frame.size.width/4-10, 30)];
        titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:10.0];
        if(self.view.frame.size.width>414)
        {
            titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            
        }// boldSystemFontOfSize:10.0];
        titleLabel.text = [catTopArr[i] valueForKey:@"name"];
        titleLabel.numberOfLines = 2;
        titleLabel.userInteractionEnabled=false;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:titleLabel];
        btn.tag=[[catTopArr[i] valueForKey:@"id"]intValue];
        [btn addTarget:self action:@selector(categorySelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrv addSubview: btn];
        
        
        if([[catTopArr[i] valueForKey:@"id"]intValue] == 52632 || [[catTopArr[i] valueForKey:@"id"]intValue] == 83 || [[catTopArr[i] valueForKey:@"id"]intValue] == 84 || [[catTopArr[i] valueForKey:@"id"]intValue] == 52675 || [[catTopArr[i] valueForKey:@"id"]intValue] == 52590)
        {
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

            if(appDelegate.liveoFound)
            {
                UIImageView *liveImage=[[AsyncImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/4)-20,self.view.frame.size.width/4-45, 15, 15)];
                liveImage.userInteractionEnabled=false;
                liveImage.image=[UIImage imageNamed:@"live"];
                [btn addSubview:liveImage];
 
            }
        }
        
        AsyncImageView *logoImage=[[AsyncImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/4)/2-15,self.view.frame.size.width/4-60, 30, 30)];
        logoImage.userInteractionEnabled=false;
        //logoImage.tag=800000+[[catTopArr[i] valueForKey:@"id"]intValue];
        if(lastSelectedTag==[[catTopArr[i] valueForKey:@"id"]intValue])
            logoImage.imageURL=[NSURL URLWithString:[catTopArr[i] valueForKey:@"select_icon"]];
        else
            logoImage.imageURL=[NSURL URLWithString:[catTopArr[i] valueForKey:@"non_select"]];        logoImage.contentMode = UIViewContentModeScaleAspectFit;
        [btn addSubview:logoImage];
        
        
        
        x=x+self.view.frame.size.width/4;
        
        if(i%4==0 && i!=0)
        {
            x=0;
            y=y+self.view.frame.size.width/4;
        }
        
        if(i==catTopArr.count-1 && i%2!=0)
        {
            y=y+self.view.frame.size.width/4;
        }
        if(i==catTopArr.count-1){
            if(i==6 || i==5)
            {
                y=y+self.view.frame.size.width/4;
            }
        }

    }
   
    y=y+15;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.view.frame.size.width, 25)];
    [label1 setFont:[UIFont boldSystemFontOfSize:14]];
    label1.textColor=categoryBtn.backgroundColor;
    NSString *string1;
    UIView *v1=[[UIView alloc]initWithFrame:CGRectMake(0, y+25-2, self.view.frame.size.width, 2)];
    v1.backgroundColor=categoryBtn.backgroundColor;
    string1=[labels valueForKey:@"sports"][0];
    [label1 setText:string1];
    [scrv addSubview:v1];
    [scrv addSubview:label1];
    
    
    x=0,y=y+20;
    for (int i=0;i<catOtherArr.count;i++)
    {
        
        
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(x, y, self.view.frame.size.width/4, self.view.frame.size.width/4)];        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.view.frame.size.width/4-30, self.view.frame.size.width/4-10, 30)];
        titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        if(self.view.frame.size.width>414)
        {
            titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            
        }
        titleLabel.text = [catOtherArr[i] valueForKey:@"name"];
        titleLabel.numberOfLines = 2;
        titleLabel.userInteractionEnabled=false;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:titleLabel];
        btn.tag=[[catOtherArr[i] valueForKey:@"id"]intValue];
        [btn addTarget:self action:@selector(categorySelectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrv addSubview: btn];
        
        
        
        if([[catOtherArr[i] valueForKey:@"id"]intValue] == 52632 || [[catOtherArr[i] valueForKey:@"id"]intValue] == 83 || [[catOtherArr[i] valueForKey:@"id"]intValue] == 84 || [[catOtherArr[i] valueForKey:@"id"]intValue] == 52675 || [[catOtherArr[i] valueForKey:@"id"]intValue] == 52590)
        {
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            if(appDelegate.liveoFound)
            {
                UIImageView *liveImage=[[AsyncImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/4)-20,self.view.frame.size.width/4-45, 15, 15)];
                liveImage.userInteractionEnabled=false;
                liveImage.image=[UIImage imageNamed:@"live"];
                [btn addSubview:liveImage];
                
            }
        }
        
        
        
        AsyncImageView *logoImage=[[AsyncImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/4)/2-15,self.view.frame.size.width/4-60, 30, 30)];
        logoImage.userInteractionEnabled=false;
        //logoImage.tag=800000+[[catTopArr[i] valueForKey:@"id"]intValue];
        if(lastSelectedTag==[[catOtherArr[i] valueForKey:@"id"]intValue])
        logoImage.imageURL=[NSURL URLWithString:[catOtherArr[i] valueForKey:@"select_icon"]];
        else
            logoImage.imageURL=[NSURL URLWithString:[catOtherArr[i] valueForKey:@"non_select"]];

        logoImage.contentMode = UIViewContentModeScaleAspectFit;
        [btn addSubview:logoImage];
        
        
        
        x=x+self.view.frame.size.width/4;
        
        if(i%4==0 && i!=0)
        {
            x=0;
            y=y+self.view.frame.size.width/4;
        }
        if(i==catOtherArr.count-1){
            if(i==6 || i==5 || i==10 || i== 12 || i==13 || i==23 || i==22 || i==21 || i==29 )
            {
                y=y+self.view.frame.size.width/4;
            }
        }
    }
    
    
    
    
    
    
    [scrv setContentSize:CGSizeMake(100, y+10)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)categorySelectButton:(UIButton*)btn
{
    
    lastSelectedTag=(int)btn.tag;
    [self setDataOnScrolView];
    
    NSDictionary *orientationData = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",(long)btn.tag] forKey:@"cat_id"];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"catSelected" object:nil userInfo:orientationData];
    [self.slideMenuController toggleMenuAnimated:0];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return myFeedCatArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        tableView.userInteractionEnabled=true;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        }
        
        cell.textLabel.text=[[myFeedCatArr objectAtIndex:indexPath.row]valueForKey:@"name"];
        
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 25, 25)];
        
        if (![myFeedArr containsObject:[[myFeedCatArr objectAtIndex:indexPath.row]valueForKey:@"id"]]) {
            [btn setImage:[UIImage imageNamed:@"checkEmpty"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"checkFeild"] forState:UIControlStateNormal];
        }
        
        btn.tag=[[[myFeedCatArr objectAtIndex:indexPath.row]valueForKey:@"id"]integerValue];
        [btn addTarget:self action:@selector(checkSelect:) forControlEvents:UIControlEventTouchUpInside];
        [btn setUserInteractionEnabled:YES];
        cell.accessoryView =btn;
        
        myFeedTable.scrollEnabled=true;
        
        //        cell.textLabel.text=[[[tableData[tablePossition] objectForKey:@"survey_option"]objectAtIndex:indexPath.row ]valueForKey:@"option_name"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        return cell;
   }
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==10)
    {
        
    }
    else
    {
        if(indexPath.section==0)
        {
            NSDictionary *orientationData = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",[[catTopArr objectAtIndex:indexPath.row]valueForKey:@"id"]] forKey:@"cat_id"];
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"catSelected" object:nil userInfo:orientationData];
            [self.slideMenuController toggleMenuAnimated:0];
            
        }
        else if(indexPath.section==1)
        {
            NSDictionary *orientationData = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",[[catOtherArr objectAtIndex:indexPath.row]valueForKey:@"id"]] forKey:@"cat_id"];
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"catSelected" object:nil userInfo:orientationData];
            [self.slideMenuController toggleMenuAnimated:0];
            
        }
        if(indexPath.section==2)
        {
            if(indexPath.row==0)
            {
                NSString *urlStr=[NSString stringWithFormat:@"http://sportsflashes.com/pdf/PrivacyPolicySportsFlashes.pdf"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            }
            else if(indexPath.row==1)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sportsflashes.com/pdf/TermsofUse-SportsFlashes.pdf"]];
                
            }
            else if(indexPath.row==2)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1126803446&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]]];
            }
            else if(indexPath.row==3)
            {
                FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
                content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1165082423566165"];
                //[FBSDKAppInviteDialog showFromViewController:self withContent:content delegate:self];
                
                [FBSDKAppInviteDialog showWithContent:content delegate:nil];
            }
        }
    }
}
-(void)rateOnAppStore:(UIButton*)btn
{
    if(lastSelectedTag!=0 && lastSelectedTag>=990000)
    {
    UIImageView *imageVieww=(UIImageView *)[self.view viewWithTag:900000+lastSelectedTag-990000];
    imageVieww.image=[UIImage imageNamed:catTopMostArrImg[lastSelectedTag-990000]];
    }
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:900000+btn.tag-990000];
    imageView.image=[UIImage imageNamed:catTopMostArrImgSelect[btn.tag-990000]];
    lastSelectedTag=(int)btn.tag;
    [self setDataOnScrolView];

    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1126803446&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]]];
}
-(IBAction)changeMyFeed:(UIButton*)sender
{
    if(lastSelectedTag!=0 && lastSelectedTag>=990000)
    {
    UIImageView *imageVieww=(UIImageView *)[self.view viewWithTag:900000+lastSelectedTag-990000];
    imageVieww.image=[UIImage imageNamed:catTopMostArrImg[lastSelectedTag-990000]];
    }
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:900000+sender.tag-990000];
    imageView.image=[UIImage imageNamed:catTopMostArrImgSelect[sender.tag-990000]];
    lastSelectedTag=(int)sender.tag;
    [self setDataOnScrolView];

    CGRect f = myFeedView.frame;
    f.origin.x = 0;
    myFeedView.frame =f;
    
    [myFeedTable reloadData];
    
}
-(void)inviteFacebookUser:(UIButton*)btn
{
    if(lastSelectedTag!=0 && lastSelectedTag>=990000)
    {
    UIImageView *imageVieww=(UIImageView *)[self.view viewWithTag:900000+lastSelectedTag-990000];
    imageVieww.image=[UIImage imageNamed:catTopMostArrImg[lastSelectedTag-990000]];
    }
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:900000+btn.tag-990000];
    imageView.image=[UIImage imageNamed:catTopMostArrImgSelect[btn.tag-990000]];
    lastSelectedTag=(int)btn.tag;
    [self setDataOnScrolView];

    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1165082423566165"];
    //[FBSDKAppInviteDialog showFromViewController:self withContent:content delegate:self];
    [FBSDKAppInviteDialog showWithContent:content delegate:nil];
}
-(IBAction)changeLanguage:(UIButton*)sender
{
    if(lastSelectedTag!=0 && lastSelectedTag>=990000)
    {
    UIImageView *imageVieww=(UIImageView *)[self.view viewWithTag:900000+lastSelectedTag-990000];
    imageVieww.image=[UIImage imageNamed:catTopMostArrImg[lastSelectedTag-990000]];
    }
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:900000+sender.tag-990000];
    imageView.image=[UIImage imageNamed:catTopMostArrImgSelect[sender.tag-990000]];
    lastSelectedTag=(int)sender.tag;
    [self setDataOnScrolView];

    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSMutableArray *languageArr=[u objectForKey:@"langarr"];
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Language option:"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        for (int j =0 ; j<languageArr.count; j++){
            NSString *titleString = [languageArr[j]valueForKey:@"name"];
            UIAlertAction *action = [UIAlertAction actionWithTitle:titleString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[languageArr[j]valueForKey:@"id"] forKey:@"lang"];
                [userDefaults synchronize];
                
                [self setLanguageOnServer:[[languageArr[j]valueForKey:@"id"]intValue]];
                [self.slideMenuController toggleMenuAnimated:0];
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"langChange" object:nil userInfo:nil];
                
            }];
            
            [alertController addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        [alertController addAction:cancelAction];
        if(self.view.frame.size.height>700)
        {
            CGRect rect = self.view.frame;
            rect.origin.x = self.view.frame.size.width / 20;
            rect.origin.y = self.view.frame.size.height / 20;
            [alertController.popoverPresentationController setPermittedArrowDirections:0];
            alertController.popoverPresentationController.sourceView = self.view;
            alertController.popoverPresentationController.sourceRect = rect;
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
//        UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"" message:@"No Internet Connection. Please Check Your Internet Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [al show];
//        al=nil;
    }
    
    
    
}

-(void)setLanguageOnServer:(int)x
{
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSString *email=[u objectForKey:@"deviceToken"];
    
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:[NSString stringWithFormat:@"/api/v3/lang_set?email=%@&ostype=1&ln=%d",email,x]
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
            
            NSLog(@"Langugage Update: %@", JSON);
            
            
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *email=[u objectForKey:@"deviceToken"];
            
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/api/v3/categories_email?email=%@&ln=%d",email,x] parameters:nil];
            
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
                    
                    
                    catArr=[JSON mutableCopy];
                    catTopArr=[[catArr valueForKey:@"data_top"]mutableCopy];;
                    labels=[[catArr valueForKey:@"labels"]mutableCopy];
                    catOtherArr=[[catArr valueForKey:@"data"]mutableCopy];
                    
                    
                    NSLog(@"%@",[labels valueForKey:@"category"][0]);
                    [categoryBtn setTitle:[labels valueForKey:@"category"][0] forState:UIControlStateNormal];
                    catSettingArr=[[NSMutableArray alloc]initWithObjects:[labels valueForKey:@"privacy"][0],[labels valueForKey:@"terms"][0], nil];//,[labels valueForKey:@"rate"][0],[labels valueForKey:@"invite"][0]
                    [rateButton setTitle:[labels valueForKey:@"rate"][0] forState:UIControlStateNormal];
                    [inviteButton setTitle:[labels valueForKey:@"invite"][0] forState:UIControlStateNormal];
                    [languageBtn setTitle:[labels valueForKey:@"language"][0] forState:UIControlStateNormal];                    [catTableView reloadData];
                    
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [operation start];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
    
    
    
    //
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if(searchBar.text.length>=3)
    {
        if([Utilities CheckInternetConnection])//0: internet working
        {
            
            HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText=@"Please Wait";
            
            
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *email=[u objectForKey:@"deviceToken"];
            NSString *lang=[u objectForKey:@"lang"];
            
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
            NSString *newCountryString =[[NSString stringWithFormat:@"/api/v3/allnews_serach?search=%@&ln=%@&offset=0&limit=100&email=%@",searchBar.text,lang,email] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:newCountryString parameters:nil];
            
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
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:JSON];
                        [userDefaults setObject:data forKey:@"news"];
                        [userDefaults synchronize];
                        HUD.hidden=YES;
                        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                        [notificationCenter postNotificationName:@"search" object:nil userInfo:nil];
                        [self.slideMenuController toggleMenuAnimated:0];
                        
                    }
                    //NSLog(@"Network-Response: %@", JSON);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [operation start];
            
            
        }
        else
        {
//            UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"" message:@"No Internet Connection. Please Check Your Internet Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [al show];
//            al=nil;
        }
    }
    searchbar.showsCancelButton=NO;
    searchbar.text=@"";
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchbar.showsCancelButton=NO;
    [searchBar resignFirstResponder];
    searchbar.text=@"";
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchbar.showsCancelButton=YES;
    searchbar.returnKeyType=UIReturnKeyDone;
    
    return YES;
}


-(void)cancelAction:(UIButton*)btn
{
    CGRect f = myFeedView.frame;
    f.origin.x = 0-myFeedView.frame.size.width;
    myFeedView.frame =f;
  
}
-(void)submitAction:(UIButton*)btn
{
    NSString *st=@"";
    for(int i=0;i<myFeedArr.count;i++)
    {
        st=[NSString stringWithFormat:@"%@,%@",st,myFeedArr[i]];
    }
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        HUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText=@"Please Wait";
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        NSString *lang=[u objectForKey:@"lang"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSString *newCountryString =[[NSString stringWithFormat:@"/api/v3/myfeed_insert?cat_id=%@&email=%@&ln=%@",st,email,lang] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:newCountryString parameters:nil];
        
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
                    
                                    
                                    NSDictionary *orientationData = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",[[catTopArr objectAtIndex:0]valueForKey:@"id"]] forKey:@"cat_id"];
                                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                                    [notificationCenter postNotificationName:@"catSelected" object:nil userInfo:orientationData];
                                    HUD.hidden=YES;
                                    [self cancelAction:0];
                                    [self.slideMenuController toggleMenuAnimated:0];

                              
                    
                }
                //NSLog(@"Network-Response: %@", JSON);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            HUD.hidden=YES;
        }];
        [operation start];
        
        
    }
    else
    {
//        UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"" message:@"No Internet Connection. Please Check Your Internet Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [al show];
//        al=nil;
    }

}
-(void)checkSelect:(UIButton*)btn
{
    if([myFeedArr containsObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]])
    {
        [myFeedArr removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    }
    else
        [myFeedArr addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    [myFeedTable reloadData];
}
-(IBAction)bookmark:(UIButton*)sender
{
    NSDictionary *orientationData = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",@"919191"] forKey:@"cat_id"];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"catSelected" object:nil userInfo:orientationData];
    [self.slideMenuController toggleMenuAnimated:0];
}
@end
