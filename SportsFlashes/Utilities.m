//
//  Utilities.m
//  CarDealership
//

//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
//#import "TopVehicleInfoView.h"
//#import "Contants.h"
//#import "ConfirmMaintenanceViewController.h"

//#define plist_path @"CarDeslrShipSummary.plist"


@implementation Utilities
MBProgressHUD *HUD;
Reachability *m_internetReach;
int m_internetWorking;


#pragma mark -
#pragma mark Internet Reachability Methods

+(BOOL)CheckInternetConnection
{
	Reachability *m_reachibility = [Reachability reachabilityForInternetConnection] ;
	[m_reachibility startNotifier];
	BOOL statusInternet = [self updateInterfaceWithReachability:m_reachibility];
    
    //release the reachibility object
    
    
    //return the status
	return statusInternet;
}

+ (BOOL) updateInterfaceWithReachability: (Reachability*) curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            HUD.hidden=YES;
            //UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"" message:@"No Internet Connection. Please Check Your Internet Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
           
            //[al show];
            //al=nil;
            
            HUD.hidden=YES;
            return FALSE;
            break;
        }
        case ReachableViaWiFi:
        {
            return TRUE;
            break;
        }
        case ReachableViaWWAN:
        {
            return TRUE;
            break;
            
        }
        default:
        {
            //UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"" message:@"No Internet Connection.Please Check Your Internet Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            //[al show];
            
            HUD.hidden=YES;
           // al=nil;
            return FALSE;
            break;
            
        }
            
    }
}
@end
