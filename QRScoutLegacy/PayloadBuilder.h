#import <Foundation/Foundation.h>

@interface PayloadBuilder : NSObject

+ (NSArray<NSString *> *)columnNames;
+ (NSString *)delimiter;
+ (NSString *)sanitizeValue:(NSString *)value;
+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values;
+ (NSString *)scannerPayloadFromValues:(NSArray<NSString *> *)values;

@end
