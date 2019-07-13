//
//  FriendsProfileViewController.h
//  josinstagram
//
//  Created by josemurillo on 7/11/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendsProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *userFriend;

@end

NS_ASSUME_NONNULL_END
