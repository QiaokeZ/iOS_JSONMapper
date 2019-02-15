

#import "ViewController3.h"
#import "BaseModel.h"
#import "NSObject+JSONMapper.h"

@interface ViewController3 ()

@end

@implementation ViewController3

- (void)dealloc{
    NSLog(@"dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"模型转字典";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *json = @{
                           @"desciption":@"1111",
                           @"id":@"8888888",
                           @"newName":@"Android",
                           @"null":[NSNull null],
                           @"person": @{
                                   @"name" : @"iOS",
                                   @"age" : @"26",
                                   @"sex" : @"男"
                                   },
                           @"dic": @{
                                   @"name" : @"PHP",
                                   @"age" : @"26",
                                   @"sex" : @"男",
                                   @"dic1": @{
                                           @"name" : @"Java",
                                           @"age" : @"26",
                                           @"sex" : @"男"
                                           }
                                   }
                           };
    
    
    BaseModel *model = [BaseModel yx_modelWithObject:json];
    NSDictionary *d = [model yx_keyValues];
    NSLog(@"%@", d);
}

@end
