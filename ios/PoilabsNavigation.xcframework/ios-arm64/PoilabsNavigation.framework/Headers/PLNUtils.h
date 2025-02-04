//
//  PLNUtils.h
//  PoiNavigationMainApp
//
//  Created by ERCAN AYYILDIZ on 05/04/2017.
//  Copyright © 2017 poilabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLAFHTTPSessionManager.h"


@interface PLNUtils : NSObject

typedef NS_ENUM(NSInteger, FloorNameSuffixType) {
    FloorNameSuffixTypeFloorChange,
    FloorNameSuffixTypeTargetFloor
};

+ (instancetype)sharedInstance;
+ (void)destroySharedInstance;

+(void)logDebugInformations:(NSString *)string priority:(int)priorityLevel inManagerType:(NSString *)comingType;

+(PLAFHTTPSessionManager*)getNavigationSessionManager;

+(NSString *)getLocaleStringForQuery:(NSString *)comingStr;
+(NSString *)getLocaleStringForKey:(NSString *) key;
+(void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message onResponder:(UIResponder *)responder;
+ (NSString *)correctSuffixForWord:(NSString *)word;
+ (NSString *)correctSuffixForBuildingPassWord:(NSString *)word;
+ (NSString *)correctSuffixForFloorTitle:(NSString *)title suffixType:(FloorNameSuffixType)suffixType;

@end
