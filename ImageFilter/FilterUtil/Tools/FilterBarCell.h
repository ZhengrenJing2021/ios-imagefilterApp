//
//  FilterBarCell.h
//  OpenGLESGLSL
//
//  ImageFilter
//
//  Created by yonas on 2022/4/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterBarCell : UICollectionViewCell
@property (strong, nonatomic) NSString *title;
@property (nonatomic, assign) BOOL isSelect;
@end

NS_ASSUME_NONNULL_END
