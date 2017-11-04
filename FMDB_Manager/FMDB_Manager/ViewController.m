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


@interface ViewController () <FMDB_Manager_Delegate,FMDB_Manager_DataSource,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<NSString *>*titleArray;

@property (nonatomic, strong) NSMutableArray <DBModel *> *inserArray;
@property (nonatomic, strong) NSMutableArray<DBModel *> *dataArray;

@end

@implementation ViewController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FMDB_Manager *manager = [FMDB_Manager shareManager];
    manager.delegate = self;
    manager.dataSource = self;
    [manager openAllSqliteTable];
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"id"];
    [self.view addSubview:_tableView];
    
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:     //创建数据库
            [self creatDB];
            break;
        case 1:     //新增索引
            [self creatIndex];
            break;
        case 2:     //插入新数据
            [self creatDataToDB];
            break;
        case 3:     //删除数据
            [self deletedData];
            break;
        case 4:     //搜索数据
            [self searchData];
            break;
        case 5:     //删除数据库表
            [self deletedTable];
            break;
        case 6:     //更新数据库字段
            [self updataData];
            break;
        case 7:     //插入数据 - 如果不存在
            [self inserDataIfNotExit];
            break;
        default:
            break;
    }
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


//新增索引
- (void)creatIndex {
    [[FMDB_Manager shareManager] creatIndexInTable:[DBModel class] withString:@"userId" andIndexName:@"MyIndex" callBack:^(BOOL success) {
        if (success) {
            NSLog(@"新增索引成功");
        }
    }];
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
    [[FMDB_Manager shareManager] InsertDataInTable:[DBModel class]
                                   withModelsArray:[self.dataArray copy]
                                          callBack:^(BOOL success)
    {
        if (success) {
            NSLog(@"插入成功");
        } else {
            NSLog(@"插入失败");
        }
    }];
    
}

//删除数据
- (void)deletedData {
    [[FMDB_Manager shareManager] DeletedDataFromTable:[DBModel class] withOptions:@"age >= 50" callBack:^(BOOL success) {
        if (success) {
            NSLog(@"删除成功");
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

- (void)inserDataIfNotExit {
    
    NSMutableArray *newData = [NSMutableArray arrayWithArray:self.inserArray];
    [newData addObjectsFromArray:self.dataArray];
    
    [[FMDB_Manager shareManager] InsertDataToTable:[DBModel class] ifDataNotExite:newData withOperation:@"userId" callBack:^(BOOL success) {
        
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
    return @"FistTable";
}

#pragma mark - LazyLoad
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        for (NSInteger index = 0; index < 10; index++) {
            DBModel *model = [DBModel new];
            
            model.userId = [NSString stringWithFormat:@"%zd",index];
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
            model._testProperty1 = @"测试属性1";
            model.TestProperty2 = @"测试属性2";
            model._01TestProperty3 = @"测试属性3";
            model.test01Property4 = @"测试属性4";
            
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}

- (NSMutableArray<DBModel *> *)inserArray {
    if (!_inserArray) {
        
        _inserArray = [NSMutableArray array];
        
        for (NSInteger index = 20; index < 30; index++) {
            DBModel *model = [DBModel new];
            
            model.userId = [NSString stringWithFormat:@"%zd",index];
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
            model._testProperty1 = @"测试属性1";
            model.TestProperty2 = @"测试属性2";
            model._01TestProperty3 = @"测试属性3";
            model.test01Property4 = @"测试属性4";
            
            [_inserArray addObject:model];
        }
        
        
        
        
    }
    return _inserArray;
}

- (NSMutableArray<NSString *> *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray arrayWithObjects:@"创建数据库",@"新增索引",@"新增数据",@"删除数据",@"查数据",@"删除数据库表",@"更新数据",@"插入数据，有则更新，没有则插入新的", nil];
    }
    return _titleArray;
}

@end
