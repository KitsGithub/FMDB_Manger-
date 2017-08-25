//
//  ViewController.m
//  FMDB_Manager
//
//  Created by mac on 2017/8/24.
//  Copyright © 2017年 kit. All rights reserved.
//

#import "ViewController.h"
#import "FMDB_Manager.h"

#import "DBModel.h"

@interface ViewController () <FMDB_Manager_Delegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FMDB_Manager *manager = [FMDB_Manager shareManager];
    manager.delegate = self;
    [manager openAllSqliteTable];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 100, 30)];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"创建数据库" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(creatDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)creatDB {
    
    [[FMDB_Manager shareManager] creatTableWithTableType:[DBModel class]];
}


- (NSString *)dbPath {
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"test.sqlite"];
    return fileName;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
