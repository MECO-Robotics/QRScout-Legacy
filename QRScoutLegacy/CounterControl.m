#import "CounterControl.h"

@interface CounterControl ()

@property (nonatomic, readwrite) NSInteger value;
@property (strong, nonatomic) UILabel *valueLabel;

@end


@implementation CounterControl

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _minimumValue = 0;
        _maximumValue = 99;
        _value = 0;
        [self configureWithTitle:title];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    [titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                 forAxis:UILayoutConstraintAxisHorizontal];

    UIButton *minusButton = [self buttonWithTitle:@"−" fontSize:26.0];
    [minusButton addTarget:self action:@selector(decrement) forControlEvents:UIControlEventTouchUpInside];

    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.text = @"0";
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:22.0 weight:UIFontWeightSemibold];
    [self.valueLabel.widthAnchor constraintEqualToConstant:44.0].active = YES;

    UIButton *plusButton = [self buttonWithTitle:@"+" fontSize:24.0];
    [plusButton addTarget:self action:@selector(increment) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc]
        initWithArrangedSubviews:@[titleLabel, minusButton, self.valueLabel, plusButton]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 10.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.topAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

- (UIButton *)buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    button.layer.borderColor = [UIColor colorWithWhite:0.78 alpha:1.0].CGColor;
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 6.0;
    [button.widthAnchor constraintEqualToConstant:44.0].active = YES;
    [button.heightAnchor constraintEqualToConstant:40.0].active = YES;
    return button;
}

- (void)setValue:(NSInteger)value {
    NSInteger boundedValue = MAX(self.minimumValue, MIN(self.maximumValue, value));
    _value = boundedValue;
    self.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)boundedValue];
}

- (void)reset {
    self.value = self.minimumValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)increment {
    self.value += 1;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)decrement {
    self.value -= 1;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
