# FMDB_Manger
基于FMDB的二次封装

## 目录结构FMDB_Manger

- 更新日志
- API介绍


### 更新日志
> 10.25 基本完成FMDB_Manager的方法编写


### API介绍
打开数据库
<pre><code>
/**
创建数据库

@param modelClass      数据模型Class
@param callBack        结果回调
*/
- (void)creatTableIfNotExistWithModelClass:(id)modelClass callBack:(CallBack)callBack;
</code></pre>
