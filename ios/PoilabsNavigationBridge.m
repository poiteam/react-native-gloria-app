//
//  PoilabsNavigationBridge.m
//  GloriaNavigation
//
//  Created by Emre Kuru on 21.01.2025.
//

#import <Foundation/Foundation.h>
#import "PoilabsNavigationBridge.h"

@implementation PoilabsNavigationBridge: NSObject


RCT_EXPORT_MODULE(PoilabsNavigationBridge);

RCT_EXPORT_METHOD(showPointOnMap:(NSString *)storeId) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSDictionary* userInfo = @{@"storeId": storeId};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPointOnMap" object:self userInfo:userInfo];
  });
}

RCT_EXPORT_METHOD(getRouteTo:(NSString *)storeId) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSDictionary* userInfo = @{@"storeId": storeId};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getRouteTo" object:self userInfo:userInfo];
  });
}

@end
