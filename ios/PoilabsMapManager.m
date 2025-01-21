//
//  PoilabsMapManager.m
//  GloriaNavigation
//
//  Created by Emre Kuru on 21.01.2025.
//

#import <React/RCTViewManager.h>
#import "GloriaNavigation-Swift.h"
@interface PoilabsMapManager : RCTViewManager
@end

@implementation PoilabsMapManager

RCT_EXPORT_MODULE(PoilabsNavigationMap)
RCT_EXPORT_VIEW_PROPERTY(language, NSString)
RCT_EXPORT_VIEW_PROPERTY(showOnMap, NSString)
RCT_EXPORT_VIEW_PROPERTY(getRouteTo, NSString)

- (UIView *)view
{
  return [[NavigationView alloc] init];
}

@end
