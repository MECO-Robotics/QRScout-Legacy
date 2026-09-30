#import "ScoutViewController.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "ChoiceControl.h"
#import "CounterControl.h"
#import "PayloadBuilder.h"

@interface ScoutViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIStackView *contentStack;
@property (strong, nonatomic) UIImageView *qrImageView;
@property (strong, nonatomic) UITextView *payloadTextView;

@property (strong, nonatomic) UITextField *scouterInitialsField;
@property (strong, nonatomic) UITextField *matchNumberField;
@property (strong, nonatomic) UITextField *teamNumberField;
@property (strong, nonatomic) UITextView *commentsView;

@property (strong, nonatomic) ChoiceControl *startingPosition;
@property (strong, nonatomic) ChoiceControl *noShow;
@property (strong, nonatomic) ChoiceControl *autoFuelCollection;
@property (strong, nonatomic) ChoiceControl *autoAdditionalActions;
@property (strong, nonatomic) ChoiceControl *autoStuck;
@property (strong, nonatomic) ChoiceControl *autoClimbed;
@property (strong, nonatomic) ChoiceControl *bumpTrench;
@property (strong, nonatomic) ChoiceControl *defendedByOpponent;
@property (strong, nonatomic) ChoiceControl *opposingZoneActions;
@property (strong, nonatomic) ChoiceControl *endgameClimbed;
@property (strong, nonatomic) ChoiceControl *mechanicalIssue;
@property (strong, nonatomic) ChoiceControl *died;
@property (strong, nonatomic) ChoiceControl *tipped;
@property (strong, nonatomic) ChoiceControl *scoredHow;
@property (strong, nonatomic) ChoiceControl *scoringLocation;
@property (strong, nonatomic) ChoiceControl *passedHow;
@property (strong, nonatomic) ChoiceControl *card;
@property (strong, nonatomic) ChoiceControl *firstPick;
@property (strong, nonatomic) ChoiceControl *secondPick;

@property (strong, nonatomic) CounterControl *autoFuelScored;
@property (strong, nonatomic) CounterControl *teleopFuelScored;
@property (strong, nonatomic) CounterControl *fuelFed;
@property (strong, nonatomic) CounterControl *scoringEffectiveness;
@property (strong, nonatomic) CounterControl *feedingPassingSkill;
@property (strong, nonatomic) CounterControl *defenseSkill;

@end


@implementation ScoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MECO 8324  •  QRSCOUT";
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

    self.scouterInitialsField = [self textFieldWithPlaceholder:@"Initials"];
    self.matchNumberField = [self textFieldWithPlaceholder:@"Match"];
    self.teamNumberField = [self textFieldWithPlaceholder:@"Team"];
    self.commentsView = [self notesTextView];

    self.startingPosition = [[ChoiceControl alloc]
        initWithTitles:@[@"Outpost Trench", @"Outpost Bump — Trench", @"Outpost Bump — Hub",
                         @"Hub", @"Depot Bump — Hub", @"Depot Bump — Trench", @"Depot Trench"]
                 values:@[@"Outpost Trench", @"Outpost Bump — Trench", @"Outpost Bump — Hub",
                          @"Hub", @"Depot Bump — Hub", @"Depot Bump — Trench", @"Depot Trench"]
        allowsMultipleSelection:NO
          defaultValues:@[]];
    self.noShow = [[ChoiceControl alloc]
        initWithTitles:@[@"No", @"Yes"] values:@[@"false", @"true"]
        allowsMultipleSelection:NO defaultValues:@[@"false"]];
    self.autoFuelCollection = [[ChoiceControl alloc]
        initWithTitles:@[@"Outpost", @"Depot", @"Neutral Zone", @"Neutral Zone — 2nd Pass",
                         @"Did Not Move", @"Moved Without Collecting"]
                 values:@[@"Outpost", @"Depot", @"Neutral Zone", @"Neutral Zone — 2nd Pass",
                          @"Did Not Move", @"Moved Without Collecting"]
        allowsMultipleSelection:YES
          defaultValues:@[]];
    self.autoAdditionalActions = [[ChoiceControl alloc]
        initWithTitles:@[@"Passed", @"Bump", @"Trench"] values:@[@"Passed", @"Bump", @"Trench"]
        allowsMultipleSelection:YES defaultValues:@[]];
    self.autoStuck = [[ChoiceControl alloc]
        initWithTitles:@[@"No", @"Yes"] values:@[@"false", @"true"]
        allowsMultipleSelection:NO defaultValues:@[@"false"]];
    self.autoClimbed = [[ChoiceControl alloc]
        initWithTitles:@[@"No Climb", @"Climbed", @"Failed Climb"] values:@[@"No", @"C", @"F"]
        allowsMultipleSelection:NO defaultValues:@[@"No"]];
    self.bumpTrench = [[ChoiceControl alloc]
        initWithTitles:@[@"Bump", @"Trench"] values:@[@"Bump", @"Trench"]
        allowsMultipleSelection:YES defaultValues:@[]];
    self.defendedByOpponent = [[ChoiceControl alloc]
        initWithTitles:@[@"No", @"Yes"] values:@[@"false", @"true"]
        allowsMultipleSelection:NO defaultValues:@[@"false"]];
    self.opposingZoneActions = [[ChoiceControl alloc]
        initWithTitles:@[@"Collecting", @"Defense"] values:@[@"Collecting", @"Defense"]
        allowsMultipleSelection:YES defaultValues:@[]];
    self.endgameClimbed = [[ChoiceControl alloc]
        initWithTitles:@[@"No Climb", @"Level 1", @"Level 2", @"Level 3", @"Failed Climb"]
                 values:@[@"No", @"L1", @"L2", @"L3", @"F"]
        allowsMultipleSelection:NO
          defaultValues:@[@"No"]];
    self.mechanicalIssue = [[ChoiceControl alloc]
        initWithTitles:@[@"No", @"Yes"] values:@[@"false", @"true"]
        allowsMultipleSelection:NO defaultValues:@[@"false"]];
    self.died = [[ChoiceControl alloc]
        initWithTitles:@[@"No", @"Yes"] values:@[@"false", @"true"]
        allowsMultipleSelection:NO defaultValues:@[@"false"]];
    self.tipped = [[ChoiceControl alloc]
        initWithTitles:@[@"No", @"Yes"] values:@[@"false", @"true"]
        allowsMultipleSelection:NO defaultValues:@[@"false"]];
    self.scoredHow = [[ChoiceControl alloc]
        initWithTitles:@[@"While Driving", @"While Stationary", @"Both", @"No Scoring"]
                 values:@[@"driving", @"stationary", @"both", @"none"]
        allowsMultipleSelection:NO
          defaultValues:@[]];
    self.scoringLocation = [[ChoiceControl alloc]
        initWithTitles:@[@"Outpost Trench", @"Outpost", @"Hub", @"Ladder", @"Depot", @"Depot Trench"]
                 values:@[@"Outpost Trench", @"Outpost", @"Hub", @"Ladder", @"Depot", @"Depot Trench"]
        allowsMultipleSelection:YES
          defaultValues:@[]];
    self.passedHow = [[ChoiceControl alloc]
        initWithTitles:@[@"While Driving", @"While Stationary", @"Both", @"No Passing"]
                 values:@[@"driving", @"stationary", @"both", @"none"]
        allowsMultipleSelection:NO
          defaultValues:@[]];
    self.card = [[ChoiceControl alloc]
        initWithTitles:@[@"No Card", @"Yellow Card", @"Red Card"] values:@[@"No Card", @"Yellow", @"Red"]
        allowsMultipleSelection:NO defaultValues:@[@"No Card"]];
    self.firstPick = [[ChoiceControl alloc]
        initWithTitles:@[@"Yes", @"Maybe", @"No"] values:@[@"Yes", @"May", @"No"]
        allowsMultipleSelection:NO defaultValues:@[]];
    self.secondPick = [[ChoiceControl alloc]
        initWithTitles:@[@"Yes", @"Maybe", @"No"] values:@[@"Yes", @"May", @"No"]
        allowsMultipleSelection:NO defaultValues:@[]];

    self.autoFuelScored = [[CounterControl alloc] initWithTitle:@"Auto Fuel Scored"];
    self.autoFuelScored.maximumValue = 500;
    self.teleopFuelScored = [[CounterControl alloc] initWithTitle:@"Teleop Fuel Scored"];
    self.teleopFuelScored.maximumValue = 500;
    self.fuelFed = [[CounterControl alloc] initWithTitle:@"Fuel Fed (Herded & Passed)"];
    self.fuelFed.maximumValue = 500;
    self.scoringEffectiveness = [[CounterControl alloc] initWithTitle:@"Scoring Effectiveness (0–5)"];
    self.scoringEffectiveness.maximumValue = 5;
    self.feedingPassingSkill = [[CounterControl alloc] initWithTitle:@"Feeding / Passing Skill (0–5)"];
    self.feedingPassingSkill.maximumValue = 5;
    self.defenseSkill = [[CounterControl alloc] initWithTitle:@"Defense Skill (0–5)"];
    self.defenseSkill.maximumValue = 5;
}

- (void)configureNavigation {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [self navyColor];
    self.navigationController.navigationBar.tintColor = [self whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
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
    self.contentStack.spacing = 16.0;
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
        @[self.scouterInitialsField, self.matchNumberField, self.teamNumberField];
    for (UITextField *field in fields) {
        field.delegate = self;
        [field addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventEditingChanged];
    }
    self.matchNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.teamNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.matchNumberField.inputAccessoryView = [self numberPadToolbar];
    self.teamNumberField.inputAccessoryView = [self numberPadToolbar];
    self.commentsView.delegate = self;

    for (ChoiceControl *control in [self choiceControls]) {
        [control addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventValueChanged];
    }

    for (CounterControl *control in [self counterControls]) {
        [control addTarget:self action:@selector(formChanged) forControlEvents:UIControlEventValueChanged];
    }

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Prematch" views:@[
        [self rowWithViews:@[
            [self labeledViewWithTitle:@"Scouter Initials" view:self.scouterInitialsField],
            [self labeledViewWithTitle:@"Match Number" view:self.matchNumberField],
            [self labeledViewWithTitle:@"Team Number" view:self.teamNumberField]
        ]],
        [self labeledViewWithTitle:@"Starting Position" view:self.startingPosition],
        [self labeledViewWithTitle:@"No Show" view:self.noShow]
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Autonomous (20 seconds)" views:@[
        self.autoFuelScored,
        [self labeledViewWithTitle:@"Where Collected Fuel" view:self.autoFuelCollection],
        [self labeledViewWithTitle:@"Other Auto Actions" view:self.autoAdditionalActions],
        [self labeledViewWithTitle:@"Robot Stuck or A-Stop in Auto" view:self.autoStuck],
        [self labeledViewWithTitle:@"Climbed in Auto" view:self.autoClimbed]
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Teleop (2:20)" views:@[
        self.teleopFuelScored,
        [self labeledViewWithTitle:@"Bump / Trench" view:self.bumpTrench],
        [self labeledViewWithTitle:@"Defended by Opponent" view:self.defendedByOpponent],
        self.fuelFed,
        [self labeledViewWithTitle:@"Opposing Zone Actions" view:self.opposingZoneActions]
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Endgame & Robot Health" views:@[
        [self labeledViewWithTitle:@"Climbed" view:self.endgameClimbed],
        [self labeledViewWithTitle:@"Mechanical Issue" view:self.mechanicalIssue],
        [self labeledViewWithTitle:@"Died" view:self.died],
        [self labeledViewWithTitle:@"Tipped / Fell Over" view:self.tipped]
    ]]];

    [self.contentStack addArrangedSubview:[self sectionWithTitle:@"Postmatch Ratings" views:@[
        self.scoringEffectiveness,
        [self labeledViewWithTitle:@"Scored How?" view:self.scoredHow],
        [self labeledViewWithTitle:@"Scoring Location" view:self.scoringLocation],
        self.feedingPassingSkill,
        [self labeledViewWithTitle:@"Passed How?" view:self.passedHow],
        self.defenseSkill,
        [self labeledViewWithTitle:@"Yellow / Red Card" view:self.card],
        [self labeledViewWithTitle:@"First Pick (Scoring)" view:self.firstPick],
        [self labeledViewWithTitle:@"Second Pick (Passing / Defense)" view:self.secondPick],
        [self labeledViewWithTitle:@"Comments" view:self.commentsView]
    ]]];

    [self configureOutputSection];
}

- (UIView *)heroHeader {
    UIView *hero = [[UIView alloc] init];
    hero.backgroundColor = [UIColor whiteColor];
    hero.layer.cornerRadius = 18.0;
    hero.layer.borderColor = [self navyColor].CGColor;
    hero.layer.borderWidth = 3.0;
    hero.layer.shadowColor = [UIColor blackColor].CGColor;
    hero.layer.shadowOpacity = 0.12;
    hero.layer.shadowRadius = 12.0;
    hero.layer.shadowOffset = CGSizeMake(0.0, 6.0);

    UIImageView *teamLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TeamLogo"]];
    teamLogo.contentMode = UIViewContentModeScaleAspectFit;
    teamLogo.accessibilityLabel = @"MECO Robotics Team 8324 logo";
    [teamLogo.widthAnchor constraintEqualToConstant:112.0].active = YES;
    [teamLogo.heightAnchor constraintEqualToConstant:112.0].active = YES;

    UILabel *eyebrow = [[UILabel alloc] init];
    eyebrow.text = @"FRC TEAM 8324";
    eyebrow.font = [UIFont boldSystemFontOfSize:12.0];
    eyebrow.textColor = [self redColor];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"MECO ROBOTICS";
    title.font = [UIFont boldSystemFontOfSize:27.0];
    title.textColor = [self navyColor];
    title.adjustsFontSizeToFitWidth = YES;
    title.minimumScaleFactor = 0.75;

    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [self redColor];
    divider.layer.cornerRadius = 2.0;
    [divider.heightAnchor constraintEqualToConstant:4.0].active = YES;

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"2026 REBUILT  •  MATCH SCOUTING";
    subtitle.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
    subtitle.textColor = [UIColor colorWithRed:0.34 green:0.38 blue:0.45 alpha:1.0];

    UIStackView *textStack = [[UIStackView alloc]
        initWithArrangedSubviews:@[eyebrow, title, divider, subtitle]];
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 6.0;

    UIStackView *headerStack = [[UIStackView alloc]
        initWithArrangedSubviews:@[teamLogo, textStack]];
    headerStack.axis = UILayoutConstraintAxisHorizontal;
    headerStack.alignment = UIStackViewAlignmentCenter;
    headerStack.spacing = 20.0;
    headerStack.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:headerStack];
    [NSLayoutConstraint activateConstraints:@[
        [headerStack.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:20.0],
        [headerStack.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-20.0],
        [headerStack.topAnchor constraintEqualToAnchor:hero.topAnchor constant:18.0],
        [headerStack.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor constant:-22.0]
    ]];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [self redColor];
    accent.layer.cornerRadius = 3.0;
    accent.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:accent];
    [NSLayoutConstraint activateConstraints:@[
        [accent.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:18.0],
        [accent.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-18.0],
        [accent.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor],
        [accent.heightAnchor constraintEqualToConstant:6.0]
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
        button.backgroundColor = [self redColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    card.layer.borderColor = [self borderColor].CGColor;
    card.layer.borderWidth = 1.0;

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [self navyColor];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [self redColor];
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

- (UIStackView *)labeledViewWithTitle:(NSString *)title view:(UIView *)view {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[label, view]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 6.0;
    return stack;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    field.borderStyle = UITextBorderStyleNone;
    field.backgroundColor = [UIColor colorWithWhite:0.985 alpha:1.0];
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
    [field.heightAnchor constraintEqualToConstant:48.0].active = YES;
    return field;
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
                                                      action:@selector(doneEditingNumberField:)];
    toolbar.items = @[flexibleSpace, done];
    return toolbar;
}

- (void)doneEditingNumberField:(id)sender {
    [self.view endEditing:YES];
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

- (UIColor *)redColor {
    return [UIColor colorWithRed:0.88 green:0.08 blue:0.12 alpha:1.0];
}

- (UIColor *)canvasColor {
    return [UIColor colorWithRed:0.94 green:0.95 blue:0.97 alpha:1.0];
}

- (UIColor *)borderColor {
    return [UIColor colorWithRed:0.82 green:0.84 blue:0.89 alpha:1.0];
}

- (UIColor *)whiteColor {
    return [UIColor whiteColor];
}

- (NSArray<CounterControl *> *)counterControls {
    return @[
        self.autoFuelScored, self.teleopFuelScored, self.fuelFed,
        self.scoringEffectiveness, self.feedingPassingSkill, self.defenseSkill
    ];
}

- (NSArray<ChoiceControl *> *)choiceControls {
    return @[
        self.startingPosition, self.noShow, self.autoFuelCollection, self.autoAdditionalActions,
        self.autoStuck, self.autoClimbed, self.bumpTrench, self.defendedByOpponent,
        self.opposingZoneActions, self.endgameClimbed, self.mechanicalIssue, self.died, self.tipped, self.scoredHow,
        self.scoringLocation, self.passedHow, self.card, self.firstPick, self.secondPick
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
    self.matchNumberField.text = [self nextMatchValue];
    self.teamNumberField.text = @"";
    self.commentsView.text = @"";
    for (ChoiceControl *control in [self choiceControls]) {
        [control reset];
    }
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
    [UIPasteboard generalPasteboard].string =
        [[PayloadBuilder columnNames] componentsJoinedByString:[PayloadBuilder delimiter]];
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
        [PayloadBuilder sanitizeValue:self.scouterInitialsField.text],
        [PayloadBuilder sanitizeValue:self.matchNumberField.text],
        [PayloadBuilder sanitizeValue:self.teamNumberField.text],
        self.startingPosition.selectedValue,
        self.noShow.selectedValue,
        [NSString stringWithFormat:@"%ld", (long)self.autoFuelScored.value],
        self.autoFuelCollection.selectedValue,
        self.autoAdditionalActions.selectedValue,
        self.autoStuck.selectedValue,
        self.autoClimbed.selectedValue,
        [NSString stringWithFormat:@"%ld", (long)self.teleopFuelScored.value],
        self.bumpTrench.selectedValue,
        self.defendedByOpponent.selectedValue,
        [NSString stringWithFormat:@"%ld", (long)self.fuelFed.value],
        self.opposingZoneActions.selectedValue,
        self.endgameClimbed.selectedValue,
        self.mechanicalIssue.selectedValue,
        self.died.selectedValue,
        self.tipped.selectedValue,
        [NSString stringWithFormat:@"%ld", (long)self.scoringEffectiveness.value],
        self.scoredHow.selectedValue,
        self.scoringLocation.selectedValue,
        [NSString stringWithFormat:@"%ld", (long)self.feedingPassingSkill.value],
        self.passedHow.selectedValue,
        [NSString stringWithFormat:@"%ld", (long)self.defenseSkill.value],
        self.card.selectedValue,
        self.firstPick.selectedValue,
        self.secondPick.selectedValue,
        [PayloadBuilder sanitizeValue:self.commentsView.text]
    ];
}

- (NSString *)nextMatchValue {
    NSScanner *scanner = [NSScanner scannerWithString:self.matchNumberField.text ?: @""];
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
