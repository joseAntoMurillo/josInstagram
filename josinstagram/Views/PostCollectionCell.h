//
//  PostCollectionCell.h
//  josinstagram
//
//  Created by josemurillo on 7/10/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCollectionCell : UICollectionViewCell

// A cell in the collection view has an image
@property (weak, nonatomic) IBOutlet UIImageView *postImage;

@end

NS_ASSUME_NONNULL_END
