//
//  PLPoi.h
//  PLNavigation
//
//  Created by Ercan Ayyıldız on 12/19/16.
//  Copyright © 2016 Ercan Ayyıldız. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLLocation.h"
#import "PLFilter.h"
#import "PLMap.h"
#import "PLPoiNavigation.h"
#import "PLNFacility.h"
#import "PLNCategory.h"
#import "PLSegment.h"
#import "PLPoiProperties.h"

@interface PLPoi : NSObject

-(id)initWithData:(NSDictionary*)data;

@property(strong, nonatomic) NSString *poiId;

@property(strong, nonatomic) NSString *title;

@property(strong, nonatomic) NSString *rotationTitle; // use for Bar rotation informations

@property(strong, nonatomic) PLLocation *location;

@property(strong, nonatomic) PLFilter *filters;

@property(strong, nonatomic) PLNCategory *category;

@property(strong, nonatomic) PLPoiProperties *properties;

@property(strong, nonatomic) NSArray<NSString *> *tags;

@property(strong, nonatomic) NSString *restrictionWarning;

@property(strong, nonatomic) NSString *zoneId;

@property(strong, nonatomic) NSString *placeId;

-(NSString *)getTitleForCategoryOrSubcategory;

- (BOOL)containsKeyword:(NSString *)str;

-(CLLocationCoordinate2D)getCoordinates;
-(int)getSegmentsCount;
-(bool)hasSegment;
-(NSNumber *)getQmsTime;
-(PLSegment *)getSegmentTo:(PLPoi *)poi;

@property(assign, readonly) bool isVisibleOnMap;
@property(assign, readonly) bool isVisibleOnList;
@property(assign, readonly) bool isPrivileged;
@property(assign, readonly) int bufferWithShortest;
@property(strong, nonatomic) NSArray<PLSegment *> *segments;

@end
