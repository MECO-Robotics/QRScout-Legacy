#import "CounterControl.h"

@interface CounterControl () <UITextFieldDelegate>

@property (nonatomic, readwrite) NSInteger value;
@property (strong, nonatomic) UITextField *valueField;

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
    self.backgroundColor = [UIColor colorWithRed:0.97 green:0.98 blue:0.99 alpha:1.0];
    self.layer.cornerRadius = 11.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0].CGColor;
    [self.heightAnchor constraintEqualToConstant:52.0].active = YES;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithRed:0.04 green:0.09 blue:0.18 alpha:1.0];
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.78;
    [titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                 forAxis:UILayoutConstraintAxisHorizontal];

    UIButton *minusButton = [self buttonWithTitle:@"−" fontSize:26.0];
    [minusButton addTarget:self action:@selector(decrement) forControlEvents:UIControlEventTouchUpInside];

    self.valueField = [[UITextField alloc] init];
    self.valueField.text = @"0";
    self.valueField.textAlignment = NSTextAlignmentCenter;
    self.valueField.font = [UIFont monospacedDigitSystemFontOfSize:22.0 weight:UIFontWeightSemibold];
    self.valueField.textColor = [UIColor whiteColor];
    self.valueField.backgroundColor = [UIColor colorWithRed:0.04 green:0.09 blue:0.18 alpha:1.0];
    self.valueField.layer.cornerRadius = 9.0;
    self.valueField.layer.masksToBounds = YES;
    self.valueField.keyboardType = UIKeyboardTypeNumberPad;
    self.valueField.delegate = self;
    [self.valueField addTarget:self action:@selector(valueFieldBegan:) forControlEvents:UIControlEventEditingDidBegin];
    [self.valueField addTarget:self action:@selector(valueFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    self.valueField.inputAccessoryView = [self numberPadToolbar];
    [self.valueField.heightAnchor constraintEqualToConstant:40.0].active = YES;
    [self.valueField.widthAnchor constraintEqualToConstant:52.0].active = YES;

    UIButton *plusButton = [self buttonWithTitle:@"+" fontSize:24.0];
    [plusButton addTarget:self action:@selector(increment) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc]
        initWithArrangedSubviews:@[titleLabel, minusButton, self.valueField, plusButton]];
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

- (UIToolbar *)numberPadToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *flexibleSpace =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
    UIBarButtonItem *done =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(doneEditingValue:)];
    toolbar.items = @[flexibleSpace, done];
    return toolbar;
}

- (void)doneEditingValue:(id)sender {
    [self.valueField resignFirstResponder];
    [self commitTypedValue];
}

- (void)valueFieldChanged:(UITextField *)field {
    if (field.text.length > 0) {
        [self commitTypedValue];
    }
}

- (void)commitTypedValue {
    NSInteger typedValue = self.valueField.text.length > 0 ? self.valueField.text.integerValue : self.minimumValue;
    self.value = typedValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)valueFieldBegan:(UITextField *)field {
    [field selectAll:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self commitTypedValue];
}

- (UIButton *)buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.04 green:0.09 blue:0.18 alpha:1.0]
                  forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    button.backgroundColor = [UIColor colorWithRed:0.12 green:0.78 blue:0.82 alpha:0.18];
    button.layer.cornerRadius = 10.0;
    [button.widthAnchor constraintEqualToConstant:44.0].active = YES;
    [button.heightAnchor constraintEqualToConstant:40.0].active = YES;
    return button;
}

- (void)setValue:(NSInteger)value {
    NSInteger boundedValue = MAX(self.minimumValue, MIN(self.maximumValue, value));
    _value = boundedValue;
    self.valueField.text = [NSString stringWithFormat:@"%ld", (long)boundedValue];
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
