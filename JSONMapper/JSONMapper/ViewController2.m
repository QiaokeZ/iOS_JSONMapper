

#import "ViewController2.h"
#import "Person.h"
#import "User.h"
#import "NSObject+JSONMapper.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)dealloc{
    NSLog(@"dealloc  ");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"数组字典转模型";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *json = @[
                           @{
                               @"desciption":@"1111",
                               @"id":@"111",
                               @"newName":@"1",
                               @"null":[NSNull null],
                               @"strs":@[@"123",@"456",@"789"],
                               @"persons":@[
                                               @{
                                                   @"name" : @"aa",
                                                   @"age" : @"26",
                                                   @"sex" : @"男"
                                               },
                                               @{
                                                   @"name" : @"bb",
                                                   @"age" : @"16",
                                                   @"sex" : @"男"
                                                },
                                               @{
                                                   @"name" : @"cc",
                                                   @"age" : @"36",
                                                   @"sex" : @"女"
                                                }
                        
                                            ]
                              
                               },
                           @{
                               @"desciption":@"2222",
                               @"id":@"222",
                               @"newName":@"2",
                               @"null":[NSNull null],
                               @"strs":@[@"123",@"456",@"789"],
                               @"persons":@[
                                       @{
                                           @"name" : @"dd",
                                           @"age" : @"26",
                                           @"sex" : @"男"
                                           },
                                       @{
                                           @"name" : @"ee",
                                           @"age" : @"16",
                                           @"sex" : @"男"
                                           },
                                       @{
                                           @"name" : @"ff",
                                           @"age" : @"36",
                                           @"sex" : @"女"
                                           }
                                       
                                       ]
                               
                               }
                           ];
    
    NSMutableArray<User *> *models = [User yx_modelArrayWithObject:json];
    NSMutableArray<User *> *models1 = [[User new] yx_setModelArrayWithObject:json];
    NSLog(@"%@",models);
    NSLog(@"%@",models1);
}

@end
