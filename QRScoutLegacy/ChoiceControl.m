#import "ChoiceControl.h"

@interface ChoiceControl ()

@property (copy, nonatomic) NSArray<NSString *> *values;
@property (copy, nonatomic) NSArray<NSString *> *defaultValues;
@property (copy, nonatomic) NSArray<UIButton *> *buttons;
@property (nonatomic) BOOL allowsMultipleSelection;

@end

@implementation ChoiceControl

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles
                         values:(NSArray<NSString *> *)values
        allowsMultipleSelection:(BOOL)allowsMultipleSelection
                  defaultValues:(NSArray<NSString *> *)defaultValues {
    NSParameterAssert(titles.count == values.count);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _values = [values copy];
        _defaultValues = [defaultValues copy] ?: @[];
        _allowsMultipleSelection = allowsMultipleSelection;
        [self configureWithTitles:titles];
        [self applySelectedValues:_defaultValues];
    }
    return self;
}

- (void)configureWithTitles:(NSArray<NSString *> *)titles {
    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    NSMutableArray<UIView *> *rows = [NSMutableArray array];

    for (NSUInteger index = 0; index < titles.count; index += 2) {
        NSMutableArray<UIView *> *rowViews = [NSMutableArray array];
        NSUInteger endIndex = MIN(index + 2, titles.count);
        for (NSUInteger buttonIndex = index; buttonIndex < endIndex; buttonIndex++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:titles[buttonIndex] forState:UIControlStateNormal];
            [button setTitleColor:[self navyColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
            button.titleLabel.numberOfLines = 2;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.layer.cornerRadius = 9.0;
            button.layer.borderWidth = 1.0;
            button.layer.borderColor = [self redColor].CGColor;
            button.tag = (NSInteger)buttonIndex;
            [button addTarget:self action:@selector(optionTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button.heightAnchor constraintEqualToConstant:44.0].active = YES;
            [buttons addObject:button];
            [rowViews addObject:button];
        }

        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:rowViews];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.distribution = UIStackViewDistributionFillEqually;
        row.spacing = 8.0;
        [rows addObject:row];
    }

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:rows];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.topAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    self.buttons = buttons;
}

- (UIColor *)navyColor {
    return [UIColor colorWithRed:0.04 green:0.09 blue:0.18 alpha:1.0];
}

- (UIColor *)redColor {
    return [UIColor colorWithRed:0.88 green:0.08 blue:0.12 alpha:1.0];
}

- (void)optionTapped:(UIButton *)sender {
    if (self.allowsMultipleSelection) {
        sender.selected = !sender.selected;
        [self updateAppearanceForButton:sender];
    } else if (!sender.selected) {
        for (UIButton *button in self.buttons) {
            button.selected = button == sender;
            [self updateAppearanceForButton:button];
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateAppearanceForButton:(UIButton *)button {
    button.backgroundColor = button.selected ? [self redColor] : [UIColor whiteColor];
}

- (void)applySelectedValues:(NSArray<NSString *> *)selectedValues {
    NSSet<NSString *> *selection = [NSSet setWithArray:selectedValues ?: @[]];
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
        (void)stop;
        button.selected = [selection containsObject:self.values[index]];
        [self updateAppearanceForButton:button];
    }];
}

- (NSString *)selectedValue {
    NSMutableArray<NSString *> *selectedValues = [NSMutableArray array];
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
        (void)stop;
        if (button.selected) {
            [selectedValues addObject:self.values[index]];
        }
    }];
    return [selectedValues componentsJoinedByString:@","];
}

- (void)reset {
    [self applySelectedValues:self.defaultValues];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
