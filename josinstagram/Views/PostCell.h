//
//  PostCell.h
//  josinstagram
//
//  Created by josemurillo on 7/9/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PostCellDelegate;

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *postCaption;
@property (weak, nonatomic) IBOutlet UILabel *postDate;
@property (weak, nonatomic) IBOutlet UILabel *postUser;
@property (weak, nonatomic) IBOutlet UIButton *heartIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelLikeCount;
@property (weak, nonatomic) IBOutlet UIImageView *postProfileImage;

@property (strong, nonatomic) Post *post;

@property (nonatomic, weak) id<PostCellDelegate> delegate;

- (void)refreshData;
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender;

@end

@protocol PostCellDelegate

- (void)tapProfile:(PostCell *)postCell didTap: (PFUser *)user;

@end

NS_ASSUME_NONNULL_END
