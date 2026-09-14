#import <Foundation/Foundation.h>

@interface PayloadBuilder : NSObject

+ (NSArray<NSString *> *)columnNames;
+ (NSString *)delimiter;
+ (NSString *)sanitizeValue:(NSString *)value;
+ (NSString *)payloadFromValues:(NSArray<NSString *> *)values;

@end
