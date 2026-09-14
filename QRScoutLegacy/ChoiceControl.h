#import <UIKit/UIKit.h>

@interface ChoiceControl : UIControl

@property (nonatomic, readonly, copy) NSString *selectedValue;

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles
                         values:(NSArray<NSString *> *)values
        allowsMultipleSelection:(BOOL)allowsMultipleSelection
                  defaultValues:(NSArray<NSString *> *)defaultValues;
- (void)reset;

@end
