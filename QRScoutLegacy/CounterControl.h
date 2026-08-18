#import <UIKit/UIKit.h>

@interface CounterControl : UIControl

@property (nonatomic, readonly) NSInteger value;
@property (nonatomic) NSInteger minimumValue;
@property (nonatomic) NSInteger maximumValue;

- (instancetype)initWithTitle:(NSString *)title;
- (void)reset;

@end
