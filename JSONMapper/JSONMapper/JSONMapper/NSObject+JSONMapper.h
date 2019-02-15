
#import <Foundation/Foundation.h>

@protocol JSONMapper <NSObject>
@optional
+ (NSDictionary<NSString *, Class> *)yx_modelClassInArray;
+ (NSDictionary<NSString *, NSString *> *)yx_loadModelCustomPropertyMapper;
+ (NSDictionary<NSString *, NSString *> *)yx_exportModelCustomPropertyMapper;
+ (void)yx_objectTransformModelDidFinish;
@end

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (JSONMapper)

+ (nullable instancetype)yx_modelWithObject:(id)object;
- (nullable instancetype)yx_setModelWithObject:(id)object;

+ (nullable NSMutableArray *)yx_modelArrayWithObject:(id)object;
- (nullable NSMutableArray *)yx_setModelArrayWithObject:(id)object;

- (nullable NSMutableDictionary *)yx_keyValues;

@end
NS_ASSUME_NONNULL_END
