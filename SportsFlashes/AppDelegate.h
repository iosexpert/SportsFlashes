//
//  AppDelegate.h
//  SportsFlashes
//
//  Created by Apple on 06/09/16.
//  Copyright © 2016 SuperSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Google/SignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,GIDSignInDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
@property (strong, nonatomic) UIWindow *window;

@property () BOOL restrictRotation;

@property () BOOL notification;
@property () int notiNewsId;
@property () BOOL liveoFound;

@property () BOOL batOrBowl;

//@property (readonly, strong) NSPersistentContainer *persistentContainer;
//@property (readonly, strong) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//- (void)saveContext;
+(NSString*)HourCalculation:(NSString*)PostDate;


@end

