//
//  NSObject+JSONMapper.m
//  NSObject+JSONMapper <https://github.com/QiaokeZ/iOS_JSONMapper>
//
//  Created by admin on 2019/1/18.
//  Copyright © 2019 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//


#import "NSObject+JSONMapper.h"
#import <objc/message.h>

typedef NS_ENUM (NSUInteger, _DataType) {
    Bool,
    Float,
    Double,
    Char,
    Short,
    Int,
    LongLong,
    UnsignedChar,
    UnsignedShort,
    UnsignedInt,
    UnsignedLongLong,
    Number,
    String,
    MutableString,
    Array,
    MutableArray,
    Dictionary,
    MutableDictionary,
    CustomObject,
    Other
};

@interface _Property : NSObject
- (instancetype)initWithProperty:(objc_property_t)property;
@property (nonatomic, assign) objc_property_t property;
@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, assign) _DataType dataType;
@property (nonatomic, assign) Class propertyClass;
@property (nonatomic, assign) SEL setter;
@property (nonatomic, assign) SEL getter;
@end

@interface _Class : NSObject
+ (instancetype)infoWithClass:(Class)cls;
@property (nonatomic, assign) Class cls;
@property (nonatomic, strong) NSDictionary<NSString *, _Property *> *propertys;
@property (nonatomic, strong) NSDictionary<NSString *, Class> *modelClassInArray;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *loadModelCustomPropertyMapper;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *exportModelCustomPropertyMapper;
@end

@implementation _Property

- (instancetype)initWithProperty:(objc_property_t)property{
    if(self = [super init]){
        _property = property;
        const char *propertyName = property_getName(property);
        const char *value = property_copyAttributeValue(property, "T");
        _propertyName = [NSString stringWithUTF8String:propertyName];
        _getter = NSSelectorFromString(_propertyName);
        _dataType = [self dataTypeForAttributeValue:value];
        _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",
                                        [_propertyName substringToIndex:1].uppercaseString,
                                        [_propertyName substringFromIndex:1]]);
    }
    return self;
}

- (_DataType)dataTypeForAttributeValue:(const char *)attributeValue {
    switch (attributeValue[0]) {
        case 'B': return Bool;
        case 'f': return Float;
        case 'd': return Double;
        case 'c': return Char;
        case 's': return Short;
        case 'i': return Int;
        case 'q': return LongLong;
        case 'C': return UnsignedChar;
        case 'S': return UnsignedShort;
        case 'I': return UnsignedInt;
        case 'Q': return UnsignedLongLong;
        case '@': {
            NSString *propertyClass = [[NSString stringWithUTF8String:attributeValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
            _propertyClass = NSClassFromString(propertyClass);
            if([_propertyClass isSubclassOfClass:[NSNumber class]])              return Number;
            if([_propertyClass isSubclassOfClass:[NSMutableString class]])       return MutableString;
            if([_propertyClass isSubclassOfClass:[NSString class]])              return String;
            if([_propertyClass isSubclassOfClass:[NSMutableArray class]])        return MutableArray;
            if([_propertyClass isSubclassOfClass:[NSArray class]])               return Array;
            if([_propertyClass isSubclassOfClass:[NSMutableDictionary class]])   return MutableDictionary;
            if([_propertyClass isSubclassOfClass:[NSDictionary class]])          return Dictionary;
            if(![propertyClass hasPrefix:@"NS"])  {
                return CustomObject;
            }
            return Other;
        }
        default: return Other;
    }
    return Other;
}
@end

@implementation _Class

- (instancetype)initWithClass:(Class)cls {
    if(self = [super init]){
        _cls = cls;
        if([cls respondsToSelector:@selector(yx_modelClassInArray)]){
            _modelClassInArray = [cls yx_modelClassInArray];
        }
        if([cls respondsToSelector:@selector(yx_loadModelCustomPropertyMapper)]){
            _loadModelCustomPropertyMapper = [cls yx_loadModelCustomPropertyMapper];
        }
        if([cls respondsToSelector:@selector(yx_exportModelCustomPropertyMapper)]){
            _exportModelCustomPropertyMapper = [cls yx_exportModelCustomPropertyMapper];
        }
        NSMutableDictionary *propertys = [NSMutableDictionary new];
        while (cls != [NSObject class]) {
            NSDictionary *dict = [self propertysForClass:cls];
            for(NSString *key in dict){
                [propertys setObject:dict[key] forKey:key];
            }
            cls = class_getSuperclass(cls);
        }
        _propertys = propertys.copy;
    }
    return self;
}

+ (instancetype)infoWithClass:(Class)cls {
    static CFMutableDictionaryRef classCache;
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    _Class *modelClass = CFDictionaryGetValue(classCache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(semaphore);
    if (!modelClass) {
        modelClass = [[_Class alloc]initWithClass:cls];
        if (modelClass) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(classCache, (__bridge const void *)(cls), (__bridge const void *)(modelClass));
            dispatch_semaphore_signal(semaphore);
        }
    }
    return modelClass;
}

- (NSDictionary *)propertysForClass:(Class)cls{
    NSMutableDictionary *propertys = [NSMutableDictionary dictionary];
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(cls, &propertyCount);
    for (int i = 0 ; i < propertyCount; i++) {
        objc_property_t objc_property = propertyList[i];
        _Property *property = [[_Property alloc]initWithProperty:objc_property];
        if(property) {
           propertys[property.propertyName] = property;
        }
    }
    free(propertyList);
    return propertys;
}

@end

@implementation NSObject (JSONMapper)

+ (instancetype)yx_modelWithObject:(id)object{
    return [[self new] yx_setModelWithObject:object];
}

+ (NSMutableArray *)yx_modelArrayWithObject:(id)object{
    return [[self new] yx_setModelArrayWithObject:object];
}

- (NSMutableDictionary *)yx_keyValues{
    _Class *cls = [_Class infoWithClass:self.class];
    return [self dictionaryWithModelClass:cls];
}

- (instancetype)yx_setModelWithObject:(id)object{
    NSDictionary *dictionary = [self dictionaryWithObject:object];
    if(dictionary){
        return [self setModelWithDictionary:dictionary];
    }
    return nil;
}

- (NSMutableArray *)yx_setModelArrayWithObject:(id)object{
    NSArray *array = [self arrayWithObject:object];
    if(array){
        NSMutableArray *models = [NSMutableArray array];
        for (id value in array) {
            if([value isKindOfClass:[NSDictionary class]]){
                NSObject *model = [[self.class new] setModelWithDictionary:value];
                if(model){
                    [models addObject:model];
                }
            }
        }
        return models;
    }
    return nil;
}

- (NSArray *)arrayWithObject:(id)object{
    if(object){
        NSArray *array = nil;
        NSData *jsonData = nil;
        if ([object isKindOfClass:[NSArray class]]) {
            array = object;
        } else if ([object isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)object dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([object isKindOfClass:[NSData class]]) {
            jsonData = object;
        }
        if (jsonData) {
            array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![array isKindOfClass:[NSArray class]]){
                array = nil;
            }
        }
        return array;
    }
    return nil;
}

- (NSDictionary *)dictionaryWithObject:(id)object{
    if (object){
        NSDictionary *dictionary = nil;
        NSData *jsonData = nil;
        if ([object isKindOfClass:[NSDictionary class]]) {
            dictionary = object;
        } else if ([object isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)object dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([object isKindOfClass:[NSData class]]) {
            jsonData = object;
        }
        if (jsonData) {
            dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![dictionary isKindOfClass:[NSDictionary class]]){
                dictionary = nil;
            }
        }
        return dictionary;
    }
    return nil;
}

- (NSArray *)arrayWithModelArray:(NSArray *)array{
    NSMutableArray *objects = [NSMutableArray array];
    for(id object in array){
        if([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]]) {
            [objects addObject:object];
        }else if ([object isKindOfClass:[NSArray class]]) {
            NSArray *array = [self arrayWithModelArray:object];
            if(array) {
                [objects addObject:array];
            }
        }else if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = [self dictionaryWithModelDictionary:object];
            if(dictionary){
                [objects addObject:dictionary];
            }
        }else{
            NSDictionary *dictionary = [object yx_keyValues];
            if(dictionary) {
               [objects addObject:dictionary];
            }
        }
    }
    return objects;
}

- (NSDictionary *)dictionaryWithModelDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary *objects= [NSMutableDictionary dictionary];
    for(id object in dictionary){
        id value = dictionary[object];
        if([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
            objects[object] = value;
        }else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = [self arrayWithModelArray:value];
            if(array){
               objects[object] = array;
            }
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = [self dictionaryWithModelDictionary:value];
            if(dictionary){
                objects[object] = dictionary;
            }
        }else{
            NSDictionary *dictionary = [value yx_keyValues];
            if(dictionary){
                objects[object] = dictionary;
            }
        }
    }
    return objects;
}

- (NSMutableDictionary *)dictionaryWithModelClass:(_Class *)modelClass{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *replacedValues = modelClass.exportModelCustomPropertyMapper.allKeys;
    for (NSString *key in modelClass.propertys) {
        NSString *replacedKey = key;
        _Property *property = modelClass.propertys[key];
        if(property){
            if([replacedValues containsObject:key]){
                replacedKey = modelClass.exportModelCustomPropertyMapper[key];
            }
            switch (property.dataType) {
                case Bool:{
                    NSNumber *value = @(((bool (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Float:{
                    NSNumber *value = @(((float (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Double:{
                    NSNumber *value = @(((double (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Char:{
                    NSNumber *value = @(((char (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Short:{
                    NSNumber *value = @(((short (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Int:{
                    NSNumber *value = @(((int (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case LongLong:{
                    NSNumber *value = @(((long long (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case UnsignedChar:{
                    NSNumber *value = @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case UnsignedShort:{
                    NSNumber *value = @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case UnsignedInt:{
                    NSNumber *value = @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case UnsignedLongLong:{
                    NSNumber *value = @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Number:{
                    NSNumber *value = ((NSNumber * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case String:
                case MutableString:{
                    NSString *value = ((NSString * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                    if(value){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Dictionary:
                case MutableDictionary:{
                    NSDictionary *modelDictionary = ((NSDictionary * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                    NSDictionary *value = [self dictionaryWithModelDictionary:modelDictionary];
                    if(value.count){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case Array:
                case MutableArray:{
                    NSArray *modelArray = ((NSArray * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                    NSArray *value = [self arrayWithModelArray:modelArray];
                    if(value.count){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                case CustomObject:{
                    NSObject *object = ((NSObject * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                    NSDictionary *value = [object yx_keyValues];
                    if(value.count){
                        dictionary[replacedKey] = value;
                    }
                    break;
                }
                default:break;
            }
        }
    }
    return dictionary;
}

- (instancetype)setModelWithDictionary:(NSDictionary *)dictionary{
    _Class *modelClass = [_Class infoWithClass:self.class];
    NSArray *replacedKeys = modelClass.loadModelCustomPropertyMapper.allKeys;
    for (NSString *key in dictionary) {
        NSString *propertyKey = key;
        if([replacedKeys containsObject:propertyKey]){
            propertyKey = modelClass.loadModelCustomPropertyMapper[propertyKey];
        }
        _Property *property = modelClass.propertys[propertyKey];
        if(property){
            id value = dictionary[key];
            switch (property.dataType) {
                case Bool:
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)(self, property.setter, [value boolValue] ? YES : NO);
                    break;
                case Float:
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value floatValue] : 0);
                    break;
                case Double:
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value doubleValue] : 0);
                    break;
                case Char:
                    ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value charValue] : 0);
                    break;
                case Short:
                    ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value shortValue] : 0);
                    break;
                case Int:
                    ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value intValue] : 0);
                    break;
                case LongLong:
                    ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value longLongValue] : 0);
                    break;
                case UnsignedChar:
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedCharValue] : 0);
                    break;
                case UnsignedShort:
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedShortValue] : 0);
                    break;
                case UnsignedInt:
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedIntValue] : 0);
                    break;
                case UnsignedLongLong:
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedLongLongValue] : 0);
                    break;
                case Number:
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, property.setter, [value isKindOfClass:[NSNumber class]] ? value : nil);
                    break;
                case CustomObject:
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, property.setter, [property.propertyClass yx_modelWithObject:value]);
                    break;
                case String:
                case MutableString:{
                    if([value isKindOfClass:[NSString class]]){
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, property.setter, property.dataType == MutableString ? ((NSString *)value).mutableCopy : value);
                        break;
                    }
                }
                case Dictionary:
                case MutableDictionary:
                    if([value isKindOfClass:[NSDictionary class]]){
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, property.setter, property.dataType == MutableDictionary ? ((NSDictionary *)value).mutableCopy : value);
                        break;
                    }
                case Array:
                case MutableArray:
                    if([value isKindOfClass:[NSArray class]]){
                        if([modelClass.modelClassInArray.allKeys containsObject:property.propertyName] && modelClass.modelClassInArray[property.propertyName]){
                            Class cls = modelClass.modelClassInArray[property.propertyName];
                            NSMutableArray *models = [NSMutableArray array];
                            for(id obj in (NSArray *)value){
                                NSObject *model = [cls yx_modelWithObject:obj];
                                if(model) {
                                    [models addObject:model];
                                }
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, property.setter, property.dataType == MutableArray ? models : models.copy);
                        }else{
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, property.setter, property.dataType == MutableArray ? ((NSArray *)value).mutableCopy : ((NSArray *)value).copy);
                        }
                        break;
                    }
                default:break;
            }
        }
    }
    if([modelClass.cls respondsToSelector:@selector(yx_objectTransformModelDidFinish)]){
        [modelClass.cls yx_objectTransformModelDidFinish];
    }
    return self;
}

@end

