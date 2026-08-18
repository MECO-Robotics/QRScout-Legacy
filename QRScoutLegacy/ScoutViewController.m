#import "ScoutViewController.h"
#import <CoreImage/CoreImage.h>
#import "CounterControl.h"
#import "PayloadBuilder.h"

@interface ScoutViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIStackView *contentStack;
@property (strong, nonatomic) UIImageView *qrImageView;
@property (strong, nonatomic) UITextView *payloadTextView;

@property (strong, nonatomic) UITextField *scoutField;
@property (strong, nonatomic) UITextField *matchField;
@property (strong, nonatomic) UITextField *teamField;
@property (strong, nonatomic) UITextField *robotField;
@property (strong, nonatomic) UITextView *commentsView;

@property (strong, nonatomic) UISegmentedControl *allianceControl;
@property (strong, nonatomic) UISegmentedControl *stationControl;
@property (strong, nonatomic) UISegmentedControl *endgameControl;

@property (strong, nonatomic) CounterControl *autoFuelScored;
@property (strong, nonatomic) CounterControl *autoFuelMissed;
@property (strong, nonatomic) CounterControl *autoTowerLevel1;
@property (strong, nonatomic) CounterControl *teleopFuelScored;
@property (strong, nonatomic) CounterControl *teleopFuelMissed;
@property (strong, nonatomic) CounterControl *teleopFuelInactive;
@property (strong, nonatomic) CounterControl *fouls;
@property (strong, nonatomic) CounterControl *defense;

@end


@implementation ScoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"QRScout REBUILT 2026";
    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    [self createControls];
    [self configureNavigation];
    [self configureLayout];
    [self generateQRCode];
}

- (void)createControls {
    self.scrollView = [[UIScrollView alloc] init];
    self.contentStack = [[UIStackView alloc] init];
    self.qrImageView = [[UIImageView alloc] init];
    self.payloadTextView = [[UITextView alloc] init];

    self.scoutField = [self textFieldWithPlaceholder:@"Scout name"];
    self.matchField = [self textFieldWithPlaceholder:@"Match"];
    self.teamField = [self textFieldWithPlaceholder:@"Team"];
    self.robotField = [self textFieldWithPlaceholder:@"Robot notes"];
    self.commentsView = [self notesTextView];

    self.allianceControl = [[UISegmentedControl alloc] initWithItems:@[@"Red", @"Blue"]];
    self.stationControl = [[UISegmentedControl alloc] initWithItems:@[@"1", @"2", @"3"]];
    self.endgameControl =
        [[UISegmentedControl alloc] initWithItems:@[@"None", @"Level 1", @"Level 2", @"Level 3"]];

    self.autoFuelScored = [[CounterControl alloc] initWithTitle:@"Auto Fuel Scored"];
    self.autoFuelMissed = [[CounterControl alloc] initWithTitle:@"Auto Fuel Missed"];
    self.autoTowerLevel1 = [[CounterControl alloc] initWithTitle:@"Auto Tower Level 1"];
    self.autoTowerLevel1.maximumValue = 1;
    self.teleopFuelScored = [[CounterControl alloc] initWithTitle:@"Teleop Fuel Scored (Active Hub)"];
    self.teleopFuelMissed = [[CounterControl alloc] initWithTitle:@"Teleop Fuel Missed"];
    self.teleopFuelInactive = [[CounterControl alloc] initWithTitle:@"Teleop Fuel (Inactive Hub)"];
    self.fouls = [[CounterControl alloc] initWithTitle:@"Fouls"];
    self.defense = [[CounterControl alloc] initWithTitle:@"Defense Rating"];
    self.defense.maximumValue = 5;
}

- (void)configureNavigation {
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Commit"
                                        style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(commitTapped)];
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                        style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(resetTapped)];
}

- (void)configureLayout {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 14.0;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:16.0],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-16.0],
        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:16.0],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-24.0],
        [self.contentStack.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-32.0]
    ]];

    NSArray<UITextField *> *fields =
        @[self.scoutField, self.matchField, self.teamField, self.robotField];
    for (UITextField *field in fields) {
        field.delegate = self;
        [field addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventEditingChanged];
    }
    self.matchField.keyboardType = UIKeyboardTypeNumberPad;
    self.teamField.keyboardType = UIKeyboardTypeNumberPad;
    self.commentsView.delegate = self;

    self.allianceControl.selectedSegmentIndex = 0;
    self.stationControl.selectedSegmentIndex = 0;
    self.endgameControl.selectedSegmentIndex = 0;
    for (UISegmentedControl *control in
         @[self.allianceControl, self.stationControl, self.endgameControl]) {
        [control addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventValueChanged];
    }

    for (CounterControl *control in [self counterControls]) {
        [control addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventValueChanged];
    }

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Prematch" views:@[
        [self rowWithViews:@[self.scoutField, self.matchField, self.teamField]],
        [self labeledControlWithTitle:@"Alliance" control:self.allianceControl],
        [self labeledControlWithTitle:@"Station" control:self.stationControl],
        self.robotField
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Autonomous (20 seconds)" views:@[
        self.autoFuelScored, self.autoFuelMissed, self.autoTowerLevel1
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Teleop (2:20)" views:@[
        self.teleopFuelScored, self.teleopFuelMissed, self.teleopFuelInactive,
        self.fouls, self.defense
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Endgame & Notes" views:@[
        [self labeledControlWithTitle:@"Tower Level (endgame)" control:self.endgameControl], self.commentsView
    ]]];

    [self configureOutputSection];
}

- (void)configureOutputSection {
    self.qrImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.qrImageView.backgroundColor = [UIColor whiteColor];
    self.qrImageView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    self.qrImageView.layer.borderWidth = 1.0;
    self.qrImageView.accessibilityLabel = @"Scouting QR code";
    [self.qrImageView.heightAnchor constraintEqualToConstant:240.0].active = YES;

    self.payloadTextView.editable = NO;
    self.payloadTextView.font = [UIFont monospacedDigitSystemFontOfSize:14.0 weight:UIFontWeightRegular];
    self.payloadTextView.layer.cornerRadius = 6.0;
    self.payloadTextView.layer.borderColor = [UIColor colorWithWhite:0.82 alpha:1.0].CGColor;
    self.payloadTextView.layer.borderWidth = 1.0;
    [self.payloadTextView.heightAnchor constraintEqualToConstant:86.0].active = YES;

    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [copyButton setTitle:@"Copy Payload" forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyPayloadTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton *columnsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [columnsButton setTitle:@"Copy Column Names" forState:UIControlStateNormal];
    [columnsButton addTarget:self action:@selector(copyColumnsTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"QR Output" views:@[
        self.qrImageView, self.payloadTextView, [self rowWithViews:@[copyButton, columnsButton]]
    ]]];
}

- (UIView *)sectionWithTitle:(NSString *)title views:(NSArray<UIView *> *)views {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 8.0;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = [UIColor colorWithWhite:0.86 alpha:1.0].CGColor;

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.textColor = [UIColor colorWithWhite:0.12 alpha:1.0];

    NSMutableArray<UIView *> *arrangedViews = [NSMutableArray arrayWithObject:label];
    [arrangedViews addObjectsFromArray:views];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:arrangedViews];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 10.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14.0],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14.0],
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:14.0],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14.0]
    ]];
    return card;
}

- (UIStackView *)rowWithViews:(NSArray<UIView *> *)views {
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:views];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 10.0;
    stack.distribution = UIStackViewDistributionFillEqually;
    return stack;
}

- (UIStackView *)labeledControlWithTitle:(NSString *)title control:(UISegmentedControl *)control {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[label, control]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 6.0;
    return stack;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [field.heightAnchor constraintEqualToConstant:44.0].active = YES;
    return field;
}

- (UITextView *)notesTextView {
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:16.0];
    textView.layer.cornerRadius = 6.0;
    textView.layer.borderColor = [UIColor colorWithWhite:0.78 alpha:1.0].CGColor;
    textView.layer.borderWidth = 1.0;
    [textView.heightAnchor constraintEqualToConstant:110.0].active = YES;
    return textView;
}

- (NSArray<CounterControl *> *)counterControls {
    return @[
        self.autoFuelScored, self.autoFuelMissed, self.autoTowerLevel1,
        self.teleopFuelScored, self.teleopFuelMissed, self.teleopFuelInactive,
        self.fouls, self.defense
    ];
}

- (void)commitTapped {
    [self.view endEditing:YES];
    [self generateQRCode];
    [self showMessageWithTitle:@"QR Code Ready"
                       message:@"The scouting payload has been encoded."];
}

- (void)resetTapped {
    self.matchField.text = [self nextMatchValue];
    self.teamField.text = @"";
    self.robotField.text = @"";
    self.commentsView.text = @"";
    self.stationControl.selectedSegmentIndex = 0;
    self.endgameControl.selectedSegmentIndex = 0;
    for (CounterControl *control in [self counterControls]) {
        [control reset];
    }
    [self generateQRCode];
}

- (void)copyPayloadTapped {
    [UIPasteboard generalPasteboard].string = self.payloadTextView.text;
    [self showMessageWithTitle:@"Copied" message:@"Payload copied to the clipboard."];
}

- (void)copyColumnsTapped {
    [UIPasteboard generalPasteboard].string = [[PayloadBuilder columnNames] componentsJoinedByString:@","];
    [self showMessageWithTitle:@"Copied" message:@"Column names copied to the clipboard."];
}

- (void)formChanged {
    [self generateQRCode];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self generateQRCode];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSArray<NSString *> *)values {
    return @[
        [PayloadBuilder sanitizeValue:self.scoutField.text],
        [PayloadBuilder sanitizeValue:self.matchField.text],
        [PayloadBuilder sanitizeValue:self.teamField.text],
        [self selectedTitleForControl:self.allianceControl],
        [self selectedTitleForControl:self.stationControl],
        [PayloadBuilder sanitizeValue:self.robotField.text],
        [NSString stringWithFormat:@"%ld", (long)self.autoFuelScored.value],
        [NSString stringWithFormat:@"%ld", (long)self.autoFuelMissed.value],
        [NSString stringWithFormat:@"%ld", (long)self.autoTowerLevel1.value],
        [NSString stringWithFormat:@"%ld", (long)self.teleopFuelScored.value],
        [NSString stringWithFormat:@"%ld", (long)self.teleopFuelMissed.value],
        [NSString stringWithFormat:@"%ld", (long)self.teleopFuelInactive.value],
        [NSString stringWithFormat:@"%ld", (long)self.fouls.value],
        [NSString stringWithFormat:@"%ld", (long)self.defense.value],
        [self selectedTitleForControl:self.endgameControl],
        [PayloadBuilder sanitizeValue:self.commentsView.text]
    ];
}

- (NSString *)selectedTitleForControl:(UISegmentedControl *)control {
    if (control.selectedSegmentIndex == UISegmentedControlNoSegment) {
        return @"";
    }
    return [control titleForSegmentAtIndex:(NSUInteger)control.selectedSegmentIndex] ?: @"";
}

- (NSString *)nextMatchValue {
    NSScanner *scanner = [NSScanner scannerWithString:self.matchField.text ?: @""];
    scanner.charactersToBeSkipped = nil;
    NSInteger match = 0;
    if ([scanner scanInteger:&match] && scanner.isAtEnd) {
        return [NSString stringWithFormat:@"%ld", (long)(match + 1)];
    }
    return @"";
}

- (void)generateQRCode {
    NSString *payload = [PayloadBuilder payloadFromValues:[self values]];
    self.payloadTextView.text = payload;
    self.qrImageView.image = [self qrImageFromText:payload];
}

- (UIImage *)qrImageFromText:(NSString *)text {
    NSData *data = [text dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:NO];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    if (data == nil || filter == nil) {
        return nil;
    }

    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    CIImage *output = filter.outputImage;
    if (output == nil) {
        return nil;
    }

    CIImage *scaled = [output imageByApplyingTransform:CGAffineTransformMakeScale(12.0, 12.0)];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:scaled fromRect:scaled.extent];
    if (imageRef == nil) {
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return image;
}

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
