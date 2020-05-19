//
//  NSObject+JSONMapper.h
//  NSObject+JSONMapper <https://github.com/QiaokeZ/iOS_JSONMapper>
//
//  Created by zhouqiao on 2019/1/18.
//  Copyright © 2019 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

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
