//
//  CustomCell.h
//  here clone
//
//  Created by Joseph Cheung on 18/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "SWTableViewCell.h"

@interface CustomCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end
