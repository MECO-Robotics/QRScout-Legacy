#import "PayloadBuilder.h"

@implementation PayloadBuilder

+ (NSArray<NSString *> *)columnNames {
    return @[
        @"Scouter Initials", @"Match Number", @"Team Number", @"Starting Position", @"No Show",
        @"Fuel Scored", @"Where collected Fuel", @"Other Auto actions",
        @"Robot Stuck or a Stop in Auto", @"Climbed", @"Fuel Scored", @"Bump Trench",
        @"Deffended by Opponent", @"Fuel Fed", @"Opposing Zone Actions", @"Climbed",
        @"Mechanical Issue", @"Died", @"Triped/Fell Over", @"Scoring Efectiveness",
        @"Scored How?", @"Scoring Location", @"Feeding/Passing Skill", @"Passed How?",
        @"Defense Skill", @"Yello/Red Card", @"First Pick", @"Second Pick", @"Comments"
    ];
}

+ (NSArray<NSString *> *)fieldIdentifiers {
    return @[
        @"si", @"mn", @"tn", @"sp", @"ns", @"afs", @"afc", @"aaa", @"ast", @"acl",
        @"tfs", @"bt", @"dbo", @"ff", @"oza", @"ecl", @"mi", @"di", @"ti", @"se",
        @"sh", @"sl", @"fps", @"ph", @"ds", @"ca", @"fp", @"s2p", @"co"
    ];
}

+ (NSString *)delimiter {
    return @"\t";
}

+ (NSString *)sanitizeValue:(NSString *)value {
    if (value == nil) {
        return @"";
    }

    NSString *sanitized = [value stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return [sanitized stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values {
    if (values.count != [self columnNames].count) {
        return @"";
    }
    return [values componentsJoinedByString:[self delimiter]];
}

+ (NSString *)scannerPayloadFromValues:(NSArray<NSString *> *)values {
    if (values.count != [self fieldIdentifiers].count) {
        return @"";
    }

    NSMutableDictionary<NSString *, NSString *> *fields = [NSMutableDictionary dictionary];
    [[self fieldIdentifiers] enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
        (void)stop;
        fields[identifier] = [self sanitizeValue:values[index]];
    }];
    NSDictionary *envelope = @{ @"v": @2, @"fields": fields };
    NSData *data = [NSJSONSerialization dataWithJSONObject:envelope options:0 error:nil];
    if (data == nil) {
        return @"";
    }
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return [@"QRSCOUT2-" stringByAppendingString:base64];
}

@end
