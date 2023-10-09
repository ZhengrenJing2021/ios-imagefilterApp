//
//  FilterBar.h
//  OpenGLESGLSL
//
//  ImageFilter
//
//  Created by yonas on 2022/4/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FilterBar;

@protocol FilterBarDelegate <NSObject>

- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index;

@end
@interface FilterBar : UIView
@property (nonatomic, strong) NSArray <NSString *> *itemList;

@property (nonatomic, weak) id<FilterBarDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
