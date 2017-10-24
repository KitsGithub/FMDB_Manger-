//
//  DBModel.h
//  FMDB_Manager
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 kit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBModel : NSObject

@property (nonatomic, assign,getter=isSchool) BOOL school;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, copy) NSString *sex;







@end
