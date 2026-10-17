#import <Foundation/Foundation.h>

@interface PayloadBuilder : NSObject

+ (NSArray<NSString *> *)columnNames;
+ (NSArray<NSString *> *)fieldIdentifiers;
+ (NSString *)delimiter;
+ (NSString *)sanitizeValue:(NSString *)value;
+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values;
+ (NSString *)scannerPayloadFromValues:(NSArray<NSString *> *)values;
+ (NSUInteger)scannerPayloadLimit;

@end
