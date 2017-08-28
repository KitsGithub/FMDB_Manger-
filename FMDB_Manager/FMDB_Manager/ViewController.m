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

@property (nonatomic, strong) NSMutableArray<DBModel *> *dataArray;

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
    
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 100, 30)];
    button3.backgroundColor = [UIColor grayColor];
    [button3 setTitle:@"新增数据" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(creatDataToDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(140, 100, 100, 30)];
    button1.backgroundColor = [UIColor grayColor];
    [button1 setTitle:@"关闭数据库" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(closeDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
}


- (void)creatDB {
    [[FMDB_Manager shareManager] creatTableIfNotExistWithTableType:[DBModel class]];
}

- (void)closeDB {
    [[FMDB_Manager shareManager] closeAllSquilteTable];
}

- (void)creatDataToDB {
    [[FMDB_Manager shareManager] InsertDataInTable:[DBModel class] modelArray:self.dataArray];
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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        for (NSInteger index = 0; index < 10; index++) {
            DBModel *model = [DBModel new];
            
            model.name = @"哈哈";
            model.age = index * 10;
            if (index % 2) {
                model.sex = @"男";
            } else {
                model.sex = @"女";
            }
            model.school = index % 2;
            
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}


@end
