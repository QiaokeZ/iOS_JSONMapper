//
//  ViewController.m
//  HSKModel-master
//
//  Created by scott on 2016/12/20.
//  Copyright © 2016年 ZQ. All rights reserved.
//

#import "ViewController.h"
#import "ViewController1.h"
#import "ViewController2.h"
#import "ViewController3.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>{
    UITableView *_tableView;
    NSArray *_tableViewDataSource;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HSKModel";
    
    _tableViewDataSource = @[@"字典转模型",@"数组字典转模型",@"模型转字典"];
    [self prepareView];
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[ViewController1 new] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[ViewController2 new] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[ViewController3 new] animated:YES];
            break;
        default:break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableViewDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    }
    cell.textLabel.text = _tableViewDataSource[indexPath.row];
    return cell;
}

- (void)prepareView{
    if(!_tableView){
        UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        _tableView = tableView;
        [self.view addSubview:tableView];
    }
}

@end
