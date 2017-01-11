//
//  Utilities.h
//  CarDealership
//

//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@class TopVehicleInfoView;
@interface Utilities : NSObject
    
    
+ (BOOL) updateInterfaceWithReachability: (Reachability*) curReach;
+(BOOL)CheckInternetConnection;


@end




