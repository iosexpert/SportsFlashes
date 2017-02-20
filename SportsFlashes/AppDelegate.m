//
//  AppDelegate.m
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/Analytics.h>
#import "Harpy.h"
#import "AppsFlyerTracker.h"


#import "AFNetworking.h"
@import GoogleMobileAds;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()<HarpyDelegate , UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
   
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"VRxCSFT9bSyT6T8zBHqaT6";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1126803446";

    
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];  
    }
    else
    {
        if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
        {
            // iOS 8 Notifications
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            
            [application registerForRemoteNotifications];
        }
        else
        {
            // iOS < 8 Notifications
            //        [application registerForRemoteNotificationTypes:
            //         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        }  
    }
    
    
    
    
    
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:@"rohitmahajan120@gmail.com" forKey:@"deviceToken"];
//    [userDefaults synchronize];

    if (!launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
       
     }
    else {
        NSDictionary *info = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        self.notification=true;
        self.notiNewsId=[[[[info valueForKey:@"aps"]valueForKey:@"alert"]valueForKey:@"news_id"]intValue];
        
        
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            [userDefaults setObject:[[[info valueForKey:@"aps"]valueForKey:@"alert"]valueForKey:@"news_id"] forKey:@"newsId"];
//            [userDefaults synchronize];
        
    }
    
    
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[NSString stringWithFormat:@"%f",[UIScreen mainScreen].bounds.size.width] forKey:@"size"];
            [userDefaults synchronize];
    
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-4237488103635443~8758133212"];

    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    [GIDSignIn sharedInstance].delegate = self;

    
    //id tracker = [[GAI sharedInstance] defaultTracker];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    UIStoryboard *storyboard = [self grabStoryboard];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    
    
    
    
//    
//    // Set the UIViewController that will present an instance of UIAlertController
//    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
//    
//    // (Optional) Set the Delegate to track what a user clicked on, or to use a custom UI to present your message.
//    [[Harpy sharedInstance] setDelegate:self];
//    
//    // (Optional) The tintColor for the alertController
//    //    [[Harpy sharedInstance] setAlertControllerTintColor:[UIColor purpleColor]];
//    
//    // (Optional) Set the App Name for your app
//    [[Harpy sharedInstance] setAppName:@"SportsFlashes"];
//    
//    /* (Optional) Set the Alert Type for your app
//     By default, Harpy is configured to use HarpyAlertTypeOption */
//    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeOption];
//    
//    /* (Optional) If your application is not available in the U.S. App Store, you must specify the two-letter
//     country code for the region in which your applicaiton is available. */
//    //    [[Harpy sharedInstance] setCountryCode:@"en-US"];
//    
//    /* (Optional) Overrides system language to predefined language.
//     Please use the HarpyLanguage constants defined in Harpy.h. */
//    //    [[Harpy sharedInstance] setForceLanguageLocalization:HarpyLanguageRussian];
//    
//    // Turn on Debug statements
//    [[Harpy sharedInstance] setDebugEnabled:true];
//    
//    // Perform check for new version of your app
//    [[Harpy sharedInstance] checkVersion];
    
        [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [FBSDKAppEvents activateApp];
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}

/*
 #pragma mark - Core Data stack
 
 @synthesize persistentContainer = _persistentContainer;
 
 - (NSPersistentContainer *)persistentContainer {
 // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
 @synchronized (self) {
 if (_persistentContainer == nil) {
 _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"SportsFlashes"];
 [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
 if (error != nil) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 

 Typical reasons for an error here include:
 * The parent directory does not exist, cannot be created, or disallows writing.
 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
 * The device is out of space.
 * The store could not be migrated to the current model version.
 Check the error message to determine what the actual problem was.
 */
/*
 NSLog(@"Unresolved error %@, %@", error, error.userInfo);
 abort();
 }
 }];
 }
 }
 
 return _persistentContainer;
 }
 
 #pragma mark - Core Data Saving support
 
 - (void)saveContext {
 NSManagedObjectContext *context = self.persistentContainer.viewContext;
 NSError *error = nil;
 if ([context hasChanges] && ![context save:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 NSLog(@"Unresolved error %@, %@", error, error.userInfo);
 abort();
 }
 }
 - (NSManagedObjectContext *) managedObjectContext {
 if (managedObjectContext != nil) {
 return managedObjectContext;
 }
 NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
 if (coordinator != nil) {
 managedObjectContext = [[NSManagedObjectContext alloc] init];
 [managedObjectContext setPersistentStoreCoordinator: coordinator];
 }
 
 return managedObjectContext;
 }
 
 - (NSManagedObjectModel *)managedObjectModel {
 if (managedObjectModel != nil) {
 return managedObjectModel;
 }
 managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil] ;
 
 return managedObjectModel;
 }
 - (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
 if (persistentStoreCoordinator != nil) {
 return persistentStoreCoordinator;
 }
 
 NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"SportsFlashes.sqlite"]];
 
 NSError *error = nil;
 NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
 persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
 if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
 // Handle error
 }
 
 return persistentStoreCoordinator;}
 
 - (NSString *)applicationDocumentsDirectory {
 
 return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
 }
 */
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
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *dt=[NSString stringWithFormat:@"%@",deviceToken];
    NSString *stringWithoutSpaces = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringWithoutSpaces = [stringWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
    stringWithoutSpaces = [stringWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", stringWithoutSpaces);
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:stringWithoutSpaces forKey:@"deviceToken"];
    [userDefaults synchronize];
    
    
    
    // custom stuff we do to register the device with our AWS middleman
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
    
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    self.notification=true;
    self.notiNewsId=[[[[userInfo valueForKey:@"aps"]valueForKey:@"alert"]valueForKey:@"news_id"]intValue];
    
    NSLog(@"%@",[[[userInfo valueForKey:@"aps"]valueForKey:@"alert"]valueForKey:@"news_id"]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userInfo.plist"];
    
    [userInfo writeToFile:filePath atomically:YES];
    
    
    
    if(application.applicationState == UIApplicationStateActive) {
        
        //app is currently active, can update badges count here
        
    }else if(application.applicationState == UIApplicationStateBackground){
        
        [notificationCenter postNotificationName:@"notification" object:nil userInfo:nil];
        
    }else if(application.applicationState == UIApplicationStateInactive){
        
        [notificationCenter postNotificationName:@"notification" object:nil userInfo:nil];
        
    }
    
    

  }



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSString *st=url.absoluteString;
    if(![st containsString:@"fb1728521094074890://"])
    {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
    }
    else
    {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    }
}
//- (void)signIn:(GIDSignIn *)signIn
//didSignInForUser:(GIDGoogleUser *)user
//     withError:(NSError *)error {
//    // Perform any operations on signed in user here.
//    NSString *userId = user.userID;                  // For client-side use only!
//    NSString *idToken = user.authentication.accessToken; // Safe to send to the server
//    NSString *fullName = user.profile.name;
//    NSString *givenName = user.profile.givenName;
//    NSString *familyName = user.profile.familyName;
//    NSString *email = user.profile.email;
//    NSLog(@"%@",user.profile);
//    //https://www.googleapis.com/oauth2/v2/userinfo
//    
//    
//    
//   // https://www.googleapis.com/oauth2/v2/
//    
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com"]];
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
//                                                            path:[NSString stringWithFormat:@"/oauth2/v1/userinfo?access_token=%@",idToken]
//                                                      parameters:nil];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSData *JSONdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//        
//        if (JSONdata != nil) {
//            
//            NSError *e;
//            NSMutableDictionary *JSON =
//            [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
//                                            options: NSJSONReadingMutableContainers
//                                              error: &e];
//            NSLog(@"%@",JSON);
//       
//            
//         
//            
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    [operation start];
//
//    
//    // ...
//}

#pragma mark - HarpyDelegate
- (void)harpyDidShowUpdateDialog
{
   // self.window
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidLaunchAppStore
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidSkipVersion
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidCancel
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyDidDetectNewVersionWithoutAlert:(NSString *)message
{
    NSLog(@"%@", message);
}
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}
-(BOOL) needsUpdate{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http:itunes.apple.com/lookup?bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([lookup[@"resultCount"] integerValue] == 1){
        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
        if (![appStoreVersion isEqualToString:currentVersion]){
            NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
            return YES;
        }
    }
    return NO;
}
+(NSString*)HourCalculation:(NSString*)PostDate

{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [[NSDate alloc] init];
    date = [dateFormat dateFromString:PostDate];
   
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormat setTimeZone:gmt];
    NSDate *ExpDate = date;//[dateFormat dateFromString:PostDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:ExpDate toDate:[NSDate date] options:0];
    NSString *time;
    if(components.year!=0)
    {
        if(components.year==1)
        {
            time=[NSString stringWithFormat:@"%ld year",(long)components.year];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld years",(long)components.year];
        }
    }
    else if(components.month!=0)
    {
        if(components.month==1)
        {
            time=[NSString stringWithFormat:@"%ld month",(long)components.month];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld months",(long)components.month];
        }
    }
    else if(components.week!=0)
    {
        if(components.week==1)
        {
            time=[NSString stringWithFormat:@"%ld week",(long)components.week];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld weeks",(long)components.week];
        }
    }
    else if(components.day!=0)
    {
        if(components.day==1)
        {
            time=[NSString stringWithFormat:@"%ld day",(long)components.day];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld days",(long)components.day];
        }
    }
    else if(components.hour!=0)
    {
        if(components.hour==1)
        {
            time=[NSString stringWithFormat:@"%ld hour",(long)components.hour];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld hours",(long)components.hour];
        }
    }
    else if(components.minute!=0)
    {
        if(components.minute==1)
        {
            time=[NSString stringWithFormat:@"%ld minute",(long)components.minute];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld minutes",(long)components.minute];
        }
    }
    else if(components.second>=0)
    {
        if(components.second==0)
        {
            time=[NSString stringWithFormat:@"1 second"];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld seconds",(long)components.second];
        }
    }
    return [NSString stringWithFormat:@"%@",time];
}
@end
