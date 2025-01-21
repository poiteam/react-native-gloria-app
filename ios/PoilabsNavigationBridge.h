//
//  PoilabsNavigationBridge.h
//  GloriaNavigation
//
//  Created by Emre Kuru on 21.01.2025.
//

#ifndef PoilabsNavigationBridge_h
#define PoilabsNavigationBridge_h

#import <React/RCTBridgeModule.h>

@interface PoilabsNavigationBridge : NSObject <RCTBridgeModule>

-(void) showPointOnMap:(NSString *)storeId;
-(void) getRouteTo:(NSString *)storeId;

@end
#endif /* PoilabsNavigationBridge_h */
