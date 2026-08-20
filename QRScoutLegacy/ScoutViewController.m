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
    self.view.backgroundColor = [self canvasColor];
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [self navyColor];
    self.navigationController.navigationBar.tintColor = [self whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [self whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]
    };
    UIBarButtonItem *commitButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Commit"
                                        style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(commitTapped)];
    NSString *updateURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"QRScoutUpdateURL"];
    if (updateURL.length > 0) {
        UIBarButtonItem *updateButton =
            [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(updateTapped)];
        self.navigationItem.rightBarButtonItems = @[commitButton, updateButton];
    } else {
        self.navigationItem.rightBarButtonItem = commitButton;
    }
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

    [self.contentStack addArrangedSubview:[self heroHeader]];

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

- (UIView *)heroHeader {
    UIView *hero = [[UIView alloc] init];
    hero.backgroundColor = [self navyColor];
    hero.layer.cornerRadius = 16.0;
    hero.layer.shadowColor = [UIColor blackColor].CGColor;
    hero.layer.shadowOpacity = 0.16;
    hero.layer.shadowRadius = 10.0;
    hero.layer.shadowOffset = CGSizeMake(0.0, 5.0);

    UILabel *eyebrow = [[UILabel alloc] init];
    eyebrow.text = @"FRC 2026  •  MATCH SCOUTING";
    eyebrow.font = [UIFont boldSystemFontOfSize:11.0];
    eyebrow.textColor = [self cyanColor];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"REBUILT";
    title.font = [UIFont boldSystemFontOfSize:30.0];
    title.textColor = [self whiteColor];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Fuel. Hub control. Tower climbs.";
    subtitle.font = [UIFont systemFontOfSize:14.0];
    subtitle.textColor = [UIColor colorWithWhite:0.78 alpha:1.0];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[eyebrow, title, subtitle]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 4.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:18.0],
        [stack.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-18.0],
        [stack.topAnchor constraintEqualToAnchor:hero.topAnchor constant:17.0],
        [stack.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor constant:-17.0]
    ]];
    return hero;
}

- (void)configureOutputSection {
    self.qrImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.qrImageView.backgroundColor = [UIColor whiteColor];
    self.qrImageView.layer.cornerRadius = 14.0;
    self.qrImageView.layer.borderColor = [self borderColor].CGColor;
    self.qrImageView.layer.borderWidth = 1.0;
    self.qrImageView.layer.masksToBounds = YES;
    self.qrImageView.accessibilityLabel = @"Scouting QR code";
    [self.qrImageView.heightAnchor constraintEqualToConstant:240.0].active = YES;

    self.payloadTextView.editable = NO;
    self.payloadTextView.font = [UIFont monospacedDigitSystemFontOfSize:14.0 weight:UIFontWeightRegular];
    self.payloadTextView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    self.payloadTextView.layer.cornerRadius = 10.0;
    self.payloadTextView.layer.borderColor = [self borderColor].CGColor;
    self.payloadTextView.layer.borderWidth = 1.0;
    [self.payloadTextView.heightAnchor constraintEqualToConstant:86.0].active = YES;

    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [copyButton setTitle:@"Copy Payload" forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyPayloadTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton *columnsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [columnsButton setTitle:@"Copy Column Names" forState:UIControlStateNormal];
    [columnsButton addTarget:self action:@selector(copyColumnsTapped) forControlEvents:UIControlEventTouchUpInside];

    for (UIButton *button in @[copyButton, columnsButton]) {
        button.backgroundColor = [self cyanColor];
        [button setTitleColor:[self navyColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        button.layer.cornerRadius = 10.0;
        [button.heightAnchor constraintEqualToConstant:44.0].active = YES;
    }

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"QR Output" views:@[
        self.qrImageView, self.payloadTextView, [self rowWithViews:@[copyButton, columnsButton]]
    ]]];
}

- (UIView *)sectionWithTitle:(NSString *)title views:(NSArray<UIView *> *)views {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 14.0;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.07;
    card.layer.shadowRadius = 9.0;
    card.layer.shadowOffset = CGSizeMake(0.0, 3.0);

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [self navyColor];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [self orangeColor];
    [accent.widthAnchor constraintEqualToConstant:5.0].active = YES;
    [accent.heightAnchor constraintEqualToConstant:23.0].active = YES;
    UIStackView *header = [[UIStackView alloc] initWithArrangedSubviews:@[accent, label]];
    header.axis = UILayoutConstraintAxisHorizontal;
    header.spacing = 9.0;
    header.alignment = UIStackViewAlignmentCenter;

    NSMutableArray<UIView *> *arrangedViews = [NSMutableArray arrayWithObject:header];
    [arrangedViews addObjectsFromArray:views];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:arrangedViews];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16.0],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16.0],
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:16.0],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16.0]
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
    field.borderStyle = UITextBorderStyleNone;
    field.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    field.layer.cornerRadius = 10.0;
    field.layer.borderWidth = 1.0;
    field.layer.borderColor = [self borderColor].CGColor;
    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 11.0, 1.0)];
    field.leftViewMode = UITextFieldViewModeAlways;
    field.textColor = [self navyColor];
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [field.heightAnchor constraintEqualToConstant:44.0].active = YES;
    return field;
}

- (UITextView *)notesTextView {
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    textView.font = [UIFont systemFontOfSize:16.0];
    textView.layer.cornerRadius = 10.0;
    textView.layer.borderColor = [self borderColor].CGColor;
    textView.layer.borderWidth = 1.0;
    [textView.heightAnchor constraintEqualToConstant:110.0].active = YES;
    return textView;
}

- (UIColor *)navyColor {
    return [UIColor colorWithRed:0.04 green:0.09 blue:0.18 alpha:1.0];
}

- (UIColor *)cyanColor {
    return [UIColor colorWithRed:0.12 green:0.78 blue:0.82 alpha:1.0];
}

- (UIColor *)orangeColor {
    return [UIColor colorWithRed:1.0 green:0.52 blue:0.08 alpha:1.0];
}

- (UIColor *)canvasColor {
    return [UIColor colorWithRed:0.94 green:0.96 blue:0.98 alpha:1.0];
}

- (UIColor *)borderColor {
    return [UIColor colorWithRed:0.85 green:0.89 blue:0.93 alpha:1.0];
}

- (UIColor *)whiteColor {
    return [UIColor whiteColor];
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

- (void)updateTapped {
    NSString *updateURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"QRScoutUpdateURL"];
    NSString *escapedManifestURL =
        [updateURLString stringByAddingPercentEncodingWithAllowedCharacters:
            [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *otaURLString = [NSString stringWithFormat:
        @"itms-services://?action=download-manifest&url=%@", escapedManifestURL];
    NSURL *updateURL = [NSURL URLWithString:otaURLString];
    if (updateURL == nil) {
        [self showMessageWithTitle:@"Update Unavailable"
                           message:@"Configure an HTTPS update manifest URL for this build."];
        return;
    }
    [[UIApplication sharedApplication] openURL:updateURL];
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
