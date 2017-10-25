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


@interface ViewController () <FMDB_Manager_Delegate,FMDB_Manager_DataSource>

@property (nonatomic, strong) NSMutableArray<DBModel *> *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FMDB_Manager *manager = [FMDB_Manager shareManager];
    manager.delegate = self;
    manager.dataSource = self;
    [manager openAllSqliteTable];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 100, 30)];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"创建数据库" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(creatDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(140, 100, 100, 30)];
    button1.backgroundColor = [UIColor grayColor];
    [button1 setTitle:@"关闭数据库" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(closeDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 100, 30)];
    button3.backgroundColor = [UIColor grayColor];
    [button3 setTitle:@"新增数据" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(creatDataToDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    
    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, 100, 30)];
    button4.backgroundColor = [UIColor grayColor];
    [button4 setTitle:@"删除数据" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(deletedData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    
    UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(20, 250, 100, 30)];
    button5.backgroundColor = [UIColor grayColor];
    [button5 setTitle:@"查数据" forState:UIControlStateNormal];
    [button5 addTarget:self action:@selector(searchData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5];
    
    
    UIButton *button6 = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 150, 30)];
    button6.backgroundColor = [UIColor grayColor];
    [button6 setTitle:@"删除数据库表" forState:UIControlStateNormal];
    [button6 addTarget:self action:@selector(deletedTable) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button6];
    
    UIButton *button7 = [[UIButton alloc] initWithFrame:CGRectMake(20, 350, 100, 30)];
    button7.backgroundColor = [UIColor grayColor];
    [button7 setTitle:@"更新数据" forState:UIControlStateNormal];
    [button7 addTarget:self action:@selector(updataData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button7];
}

#pragma mark - UIAction
- (void)creatDB {
    //创建数据库
    [[FMDB_Manager shareManager] creatTableIfNotExistWithModelClass:[DBModel class] callBack:^(BOOL success) {
        if (success) {
            NSLog(@"数据库创建成功");
        }
    }];
}

- (void)closeDB {
    [[FMDB_Manager shareManager] closeAllSquilteTable];
}

//删除数据库表
- (void)deletedTable {
    [[FMDB_Manager shareManager] deletedTableWithTableName:[DBModel class] callBack:^(BOOL success) {
        if (success) {
            NSLog(@"删除成功");
        }
    }];
}

//插入数据
- (void)creatDataToDB {
    for (DBModel *model in self.dataArray) {
        [[FMDB_Manager shareManager] InsertDataInTable:[DBModel class] withValuesArray:@[model.name,model.age,model.sex,model.school] callBack:^(BOOL success) {
            if (success) {
                NSLog(@"插入成功");
            } else {
                NSLog(@"插入失败");
            }
        }];
    }
}

//删除数据
- (void)deletedData {
    [[FMDB_Manager shareManager] DeletedDataFromTable:[DBModel class] withOptions:@"age >= 50" callBack:^(BOOL success) {
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
}

//查询数据
- (void)searchData {
    [[FMDB_Manager shareManager] SearchTable:[DBModel class] withOptions:@"age = 10" callBack:^(NSArray<NSObject *> *array) {
        
        NSLog(@"查询出 %zd 个对象",array.count);
        for (NSInteger index = 0; index<array.count; index++) {
            DBModel *model = (DBModel *)array[index];
            NSLog(@"%@",model.name);
        }
        
    }];
}

//更新表数据
- (void)updataData {
    [[FMDB_Manager shareManager] alterTableWithTableName:[DBModel class] withOpton1:@"name = '我是男人'" andOption2:@"sex = '男'" callBack:^(BOOL success) {
        if (success) {
            NSLog(@"修改成功");
        }
    }];
}

#pragma mark - FMDB_ManagerDelegate
//指定表路径
- (NSString *)dbPath {
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"test.sqlite"];
    return fileName;
}

#pragma mark - FMDB_ManagerDataSource
//指定操作表名
- (NSString *)tableNameWithModelClass:(id)Class {
    NSLog(@"%@",NSStringFromClass(Class));
    return @"FistTable";
}

#pragma mark - LazyLoad
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        for (NSInteger index = 0; index < 10; index++) {
            DBModel *model = [DBModel new];
            
            
            model.age = @(index * 10);
            if ([model.age isEqualToNumber:[NSNumber numberWithInteger:10]]) {
                model.name = @"特殊的名字";
            } else {
                model.name = @"哈哈";
            }
            
            if (index % 2) {
                model.sex = @"男";
            } else {
                model.sex = @"女";
            }
            model.school = @(index % 2);
            
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}


@end
