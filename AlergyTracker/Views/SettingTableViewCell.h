//
//  SettingTableViewCell.h
//  AlergyTracker
//
//  Created by Emily Toop on 22/03/2015.
//  Copyright (c) 2015 Radical Robot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;

@end
