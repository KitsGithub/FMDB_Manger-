//
//  DBModel.h
//  FMDB_Manager
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 kit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBModel : NSObject

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSNumber *age;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, assign) NSNumber *school;

#warning todo 1.测试带'_'的参数, 2.测试带数字的参数 3.测试其他情况

@property (nonatomic, copy) NSString *_testProperty1;

@property (nonatomic, copy) NSString *TestProperty2;

@property (nonatomic, copy) NSString *_01TestProperty3;

@property (nonatomic, copy) NSString *test01Property4;






@end
