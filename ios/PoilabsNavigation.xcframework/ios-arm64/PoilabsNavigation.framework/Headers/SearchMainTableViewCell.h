//
//  SearchMainTableViewCell.h
//  PoiNavigationMainApp
//
//  Created by ERCAN AYYILDIZ on 05/04/2017.
//  Copyright © 2017 poilabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLPoi.h"

@interface SearchMainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *storeTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorNameLabel;


@property (weak, nonatomic) IBOutlet UILabel *showOnMapLabel;
@property (weak, nonatomic) IBOutlet UIButton *showOnMapButton;
@property (weak, nonatomic) IBOutlet UILabel *getNavigationLabel;
@property (weak, nonatomic) IBOutlet UIButton *getNavigationButton;



-(void)configureLabels:(PLPoi *)poi floorTitle:(NSString *)floorTitle;









@end
