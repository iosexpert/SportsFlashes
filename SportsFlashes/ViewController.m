///////////
//  ViewController.m
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "ViewController.h"
#import "NVSlideMenuController.h"
#import "landingViewController.h"
#import "slideMenuViewController.h"
#import "AppDelegate.h"

#import "AFNetworking.h"
#import "Utilities.h"
#import "AFHTTPClient.h"

#define SITEURL @"http://sportsflashes.com"


@interface ViewController ()
{
    NSArray *animationImagesArray;
    int limit,selectedIndex;
    NSMutableArray *langArr,*infoImageArr;
    UIScrollView *scroll;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    langSelectorView.hidden=YES;
    ;
    limit=10;
    [self restrictRotation:YES];
    
    animationImagesArray=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"1.png"],[UIImage imageNamed:@"2.png"],[UIImage imageNamed:@"3.png"],[UIImage imageNamed:@"4.png"],[UIImage imageNamed:@"5.png"],[UIImage imageNamed:@"6.png"],[UIImage imageNamed:@"7.png"], nil];
    animationImageViw.animationImages=animationImagesArray;
    animationImageViw.animationDuration = 1.4;
    [animationImageViw startAnimating];
    
    infoImageArr=[[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"screen"],[UIImage imageNamed:@"screen1"],[UIImage imageNamed:@"screen2"], nil];
    
    NSString *temp;
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    temp = [u objectForKey:@"userid"];
    NSLog(@"%@",temp);
    if([Utilities CheckInternetConnection])//0: internet working
    {
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"http://sportsflashes.com/api/v3/findlang"] parameters:nil];
        
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
                
                // [self loginresult:JSON];
                if([[JSON valueForKey:@"error"]integerValue] ==0)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:[JSON valueForKey:@"data"] forKey:@"langarr"];
                    [userDefaults synchronize];
                    
                    
                    langArr=[[JSON valueForKey:@"data"]mutableCopy];
                    if((temp == (id)[NSNull null] || temp.length == 0 ))
                    {
                        langSelectorView.hidden=false;
                    }
                    else
                    {
                    }
                    [pickView reloadAllComponents];
                    
                }
                //NSLog(@"Network-Response: %@", JSON);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [operation start];
        
        self.navigationController.navigationBarHidden=YES;
        
        if((temp == (id)[NSNull null] || temp.length == 0 ))
        {
            scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            scroll.contentSize = CGSizeMake(self.view.frame.size.width*infoImageArr.count, 100);
            scroll.pagingEnabled=YES;
            scroll.backgroundColor=[UIColor whiteColor];
            [self.view addSubview:scroll];
            
            
            
            
            
            for(int i=0;i<infoImageArr.count;i++)
            {
                UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width*i), 0, self.view.frame.size.width, self.view.frame.size.height)];
                img.image=infoImageArr[i];
                [scroll addSubview:img];
                if(i==infoImageArr.count-1)
                {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    btn.tag = 102;
                    btn.frame = CGRectMake((self.view.frame.size.width*i)+self.view.frame.size.width/2-150,self.view.frame.size.height-90, 300, 45);
                    btn.layer.cornerRadius=10;
                    btn.backgroundColor=[UIColor orangeColor];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [btn setTitle:@"DONE" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(done_Action:) forControlEvents:UIControlEventTouchUpInside];
                    [scroll addSubview:btn];
                }
                
                UIButton *skip = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                skip.tag = 102;
                skip.frame = CGRectMake((self.view.frame.size.width*i)+self.view.frame.size.width-80,30, 60, 20);
                [skip setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                [skip setTitle:@"SKIP" forState:UIControlStateNormal];
                [skip addTarget:self action:@selector(skip_Action:) forControlEvents:UIControlEventTouchUpInside];
                [scroll addSubview:skip];
            }
            
            
        }
        else
        {
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arr=[[u objectForKey:@"oflineNews"]mutableCopy];
            if(arr.count!=0 || arr != nil)
                [self openMainScreen];
            else
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getNewsResult:)userInfo:nil repeats:NO];
            langSelectorView.hidden=YES;
        }
    }
    
    else
    {
        [self openMainScreen];
    }
    
    
    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)skip_Action:(id)sender
{
    [scroll removeFromSuperview];
}
-(void)done_Action:(id)sender
{
    [scroll removeFromSuperview];
}
-(IBAction)submitAction:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int row = (int)[pickView selectedRowInComponent:0];
    [userDefaults setObject:[[langArr objectAtIndex:row]valueForKey:@"id"] forKey:@"lang"];
    [userDefaults synchronize];
    langSelectorView.hidden=YES;
    [self webServiceCall:[[[langArr objectAtIndex:row]valueForKey:@"id"]intValue]];
    //[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getNewsResult:)userInfo:nil repeats:NO];
}
#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return langArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [langArr[row] valueForKey:@"name"];
}


-(void)webServiceCall:(int)lang
{
    if([Utilities CheckInternetConnection])//0: internet working
    {
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSString *email=[u objectForKey:@"deviceToken"];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SITEURL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:[NSString stringWithFormat:@"/api/v3/device_register?email=%@&uid=%@&ostype=1&ln=%d",email,email,lang ]
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
                    [userDefaults setObject:@"TRUE" forKey:@"userid"];
                    [userDefaults synchronize];
                    [self openMainScreen];
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

-(void)getNewsResult:(NSTimer *)timer {
    
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
                [self openMainScreen];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            
        }];
        [operation start];
        
        
    }
    
}

-(void)openMainScreen {
    
    landingViewController* hvm;
    slideMenuViewController* smvc;
    
    
    int height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480) {
        
        hvm =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"landingViewController"];
        smvc =[[UIStoryboard storyboardWithName:@"iphone4" bundle:nil] instantiateViewControllerWithIdentifier:@"slideMenuViewController"];
        
    }
    else if (height == 568) {
        
        hvm =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"landingViewController"];
        smvc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"slideMenuViewController"];
        
    }
    else if (height == 667) {
        
        hvm =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"landingViewController"];
        smvc =[[UIStoryboard storyboardWithName:@"iphone6" bundle:nil] instantiateViewControllerWithIdentifier:@"slideMenuViewController"];
        
    }
    else if (height == 736) {
        
        hvm =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"landingViewController"];
        smvc =[[UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil] instantiateViewControllerWithIdentifier:@"slideMenuViewController"];
        
    }
    else if (height == 1024) {
        
        hvm =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"landingViewController"];
        smvc =[[UIStoryboard storyboardWithName:@"ipad" bundle:nil] instantiateViewControllerWithIdentifier:@"slideMenuViewController"];
        
    }
    else
    {
        
        hvm =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"landingViewController"];
        smvc =[[UIStoryboard storyboardWithName:@"ipad2" bundle:nil] instantiateViewControllerWithIdentifier:@"slideMenuViewController"];
        
    }
    
    
    UINavigationController *mainNav=[[UINavigationController alloc]initWithRootViewController:hvm];
    mainNav.navigationBar.barStyle = UIBarStyleBlack;
    mainNav.navigationBarHidden=YES;
    
    UINavigationController *menuNav=[[UINavigationController alloc]initWithRootViewController:smvc];
    menuNav.navigationBar.barStyle = UIBarStyleBlack;
    menuNav.navigationBarHidden=YES;
    
    
    
    
    
    NVSlideMenuController *slideMenuVC = [[NVSlideMenuController alloc] initWithMenuViewController:menuNav andContentViewController:mainNav];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = slideMenuVC;
}
- (UIStoryboard *)grabStoryboard {
    
    UIStoryboard *storyboard;
    
    // detect the height of our screen
    int height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480) {
        storyboard = [UIStoryboard storyboardWithName:@"iphone4" bundle:nil];
    }
    else if (height == 568) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    else if (height == 667) {
        storyboard = [UIStoryboard storyboardWithName:@"iphone6" bundle:nil];
    }
    else if (height == 736) {
        storyboard = [UIStoryboard storyboardWithName:@"iphone6plus" bundle:nil];
    }
    else if (height == 1024) {
        storyboard = [UIStoryboard storyboardWithName:@"ipad" bundle:nil];
    }
    else
    {
        storyboard = [UIStoryboard storyboardWithName:@"ipad2" bundle:nil];
    }
    
    return storyboard;
}
-(void) restrictRotation:(BOOL) restriction
{
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [animationImageViw removeFromSuperview];
    animationImagesArray=nil;
}
@end
