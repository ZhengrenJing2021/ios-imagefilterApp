//
//  FilterBarCell.m
//  OpenGLESGLSL
//
//  ImageFilter
//
//  Created by yonas on 2022/4/30.
//

#import "FilterBarCell.h"

@interface FilterBarCell()

@property (nonatomic, strong) UILabel *label;

@end

@implementation FilterBarCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
-(void)initUI{
    self.label =[[UILabel alloc]initWithFrame:self.bounds];
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.label];
}
-(void)setTitle:(NSString *)title{
    if (_title != title) {
        _title = title;
        self.label.text = title;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}
- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    self.label.backgroundColor = isSelect ? [UIColor blackColor] : [UIColor clearColor];
    self.label.textColor = isSelect ? [UIColor whiteColor] : [UIColor blackColor];
}
@end
