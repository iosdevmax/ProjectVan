//
//  SMSideMenuViewCell.h
//  ManWithVan
//
//  Created by Syngmaster on 19/07/2017.
//  Copyright © 2017 Syngmaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMSideMenuViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sideMenuImageView;
@property (weak, nonatomic) IBOutlet UILabel *sideMenuLabel;

- (void)configureCell:(NSIndexPath *) indexPath;

@end

