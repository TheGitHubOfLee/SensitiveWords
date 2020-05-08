//
//  BKYSQLHelper.m
//  bkvoice
//
//  Created by mac on 2019/12/24.
//  Copyright © 2019 bkvoice. All rights reserved.
//

#import "BKYSQLHelper.h"
#import "BKYKeyWordsModel.h"
#import <sqlite3.h>

#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
#define BAD_WORDSUPDATED @"BADKEYSHAVESAVEDUSERDEFAULT"



@implementation BKYSQLHelper
static sqlite3 *_db;
//首先需要有数据库
+(void)initialize
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *saved_app_Version = [[NSUserDefaults standardUserDefaults] valueForKey:BAD_WORDSUPDATED];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError* error=nil;
    
    NSString *documentPath = PATH_OF_DOCUMENT;
    
    NSString *fileName = [documentPath stringByAppendingPathComponent:@"localkeys.db"];
    
    if (![saved_app_Version isEqualToString:app_Version]){ //判断版本号是否升级
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *filenameAgo = [bundle pathForResource:@"localkeys"ofType:@"db"];
        [fileManager removeItemAtPath:fileName error:&error]; // 删除之前的数据库
        if (![fileManager fileExistsAtPath:fileName]) { // 删除成功
            [fileManager copyItemAtPath:filenameAgo toPath:fileName error:&error]; // 吧新的数据库copy过去
            if (error!=nil) {
                NSLog(@"%@", error);
                NSLog(@"%@", [error userInfo]);
                [[NSUserDefaults standardUserDefaults] setValue:app_Version forKey:BAD_WORDSUPDATED]; //保存标记
            }
        }
    }
   
    //将OC字符串转换为c语言的字符串
    const char *cfileName=fileName.UTF8String;
    
    //1.打开数据库文件（如果数据库文件不存在，那么该函数会自动创建数据库文件）
    int result = sqlite3_open(cfileName, &_db);
    
    if (result==SQLITE_OK) {        //打开成功
        NSLog(@"成功打开数据库");
//        char *sql;
        //2.创建表
        const char  *sql="CREATE TABLE IF NOT EXISTS bad_word (id integer PRIMARY KEY AUTOINCREMENT,bad_word text NOT NULL);";
        /* Create SQL statement */

        char *errmsg=NULL;
        result = sqlite3_exec(_db, sql, NULL, NULL, &errmsg);
        if (result==SQLITE_OK) {
            NSLog(@"创表成功");
        }else
        {
            printf("创表失败---%s",errmsg);
        }
    }else{
        NSLog(@"打开数据库失败");
// 数据库打开失败，失败之后要掉用关闭数据库方法
        int ret = sqlite3_close(_db);

        if (ret == SQLITE_OK) {
            _db = nil;
        } else {
            
        }
    }

}
//保存一条数据
+(void)save:(BKYKeyWordsModel *)keyword
{
    //1.拼接SQL语句
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO bad_word (bad_word,id) VALUES ('%@',%d);",keyword.bad_word, keyword.id];
    
    //2.执行SQL语句
    char *errmsg=NULL;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {//如果有错误信息
        NSLog(@"插入数据失败--%s",errmsg);
    }else
    {
        NSLog(@"插入数据成功");
    }

}

/**
 *  删除一个关键字
 */
+(void)remove:(BKYKeyWordsModel *)keyword
{
    
//    if (keyword.id <= 0) {
//        keyword.id = [BKYSQLHelper queryaBadWordWithWord:keyword.bad_word];
//    }
    //1.拼接SQL语句
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM bad_word WHERE bad_word = '%@';", keyword.bad_word];
    
    //2.执行SQL语句
    char *errmsg=NULL;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {//如果有错误信息
        NSLog(@"删除数据失败--%s",errmsg);
    }else
    {
        NSLog(@"删除数据成功");
    }

}




+(NSArray *)query
{
    return [self queryaAll];
}

//关键字过滤
+ (BOOL)queryWithCondition:(NSString *)condition
{
    
    NSString *newStr= [condition stringByReplacingOccurrencesOfString:@" " withString:@""]; // 去除空格
    
    //数组，用来存放所有查询到的联系人
//    NSMutableArray *persons=nil;
    /*
     [NSString stringWithFormat:@"SELECT id, name, age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;", condition];
    NSString *NSsql=[NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name=%@;",condition];
    */
    NSString *NSsql=[NSString stringWithFormat:@"SELECT bad_word FROM bad_word WHERE '%@' like '%%'||bad_word||'%%' ORDER BY id ASC",newStr];
    NSLog(@"%@",NSsql);
    const char *sql=NSsql.UTF8String;
    
    sqlite3_stmt *stmt=NULL;
    BOOL haveBadKey = NO;
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
//        NSLog(@"查询语句没有问题");
        
//        persons=[NSMutableArray array];
        
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
            
            NSLog(@"id = %d, name = %s, sex = %s, class = %s", sqlite3_column_int(stmt, 0), sqlite3_column_text(stmt, 1), sqlite3_column_text(stmt, 2), sqlite3_column_text(stmt, 3));
            
            
            //取出数据
            //(1)取出第0列字段的值（int类型的值）
//            int ID=sqlite3_column_int(stmt, 0);
//            //(2)取出第1列字段的值（text类型的值）
//            const unsigned char *name=sqlite3_column_text(stmt, 1);
//            //(3)取出第2列字段的值（int类型的值）
////            int age=sqlite3_column_int(stmt, 2);
//            NSLog(@"%d, %s", ID, name);
//            if (name != NULL){
//                BKYKeyWordsModel *p=[[BKYKeyWordsModel alloc]init];
//                p.id=ID;
//                p.bad_word=[NSString stringWithUTF8String:(const char *)name];
//    //            p.age=age;
//             //   NSLog(@"%@",p.name);
//                [persons addObject:p];
//                break;
//
//            }
            NSLog(@"是敏感字段");
            haveBadKey = YES;
            break;
            
         //   NSLog(@"haha%@",persons);
        }
    }else
    {
        NSLog(@"查询语句有问题");
    }
    
    //NSLog(@"haha%@",persons);
    return haveBadKey;
}


//查询所有
+ (NSArray *)queryaAll
{
    
    //数组，用来存放所有查询到的联系人
    NSMutableArray *persons=nil;
    /*
     [NSString stringWithFormat:@"SELECT id, name, age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;", condition];
    NSString *NSsql=[NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name=%@;",condition];
    */
    NSString *NSsql=[NSString stringWithFormat:@"SELECT * FROM bad_word"];
    NSLog(@"%@",NSsql);
    const char *sql=NSsql.UTF8String;
    
    sqlite3_stmt *stmt=NULL;
    
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        NSLog(@"查询语句没有问题");
        
        persons=[NSMutableArray array];
        
//        int count = sqlite3_column_count(stmt);
//        NSLog(@"%d", count);
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录

            //取出数据
            //(1)取出第0列字段的值（int类型的值）
            int ID=sqlite3_column_int(stmt, 0);
            //(2)取出第1列字段的值（text类型的值）
            const unsigned char *name=sqlite3_column_text(stmt, 1);
            //(3)取出第2列字段的值（int类型的值）
//            int age=sqlite3_column_int(stmt, 2);

            BKYKeyWordsModel *p=[[BKYKeyWordsModel alloc]init];
            p.id=ID;
            p.bad_word=[NSString stringWithUTF8String:(const char *)name];
//            p.age=age;
//            NSLog(@"%@",p.bad_word);
            [persons addObject:p];
         //   NSLog(@"haha%@",persons);
        }
    }else
    {
        NSLog(@"查询语句有问题");
    }
    
    //NSLog(@"haha%@",persons);
    return persons;
}

//根据内容查询id
+ (int)queryaBadWordWithWord:(NSString *)words{
    
    
    int idValue = 0;
    /*
     [NSString stringWithFormat:@"SELECT id, name, age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;", condition];
    NSString *NSsql=[NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name=%@;",condition];
    */
    NSString *NSsql= [NSString stringWithFormat:@"SELECT bad_word FROM bad_word WHERE bad_word = '%@'", words];
    NSLog(@"%@",NSsql);
    const char *sql=NSsql.UTF8String;
    
    sqlite3_stmt *stmt=NULL;
    
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        NSLog(@"查询语句没有问题");
        
        
//        int count = sqlite3_column_count(stmt);
//        NSLog(@"%d", count);
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录

            //取出数据
            //(1)取出第0列字段的值（int类型的值）
            int ID=sqlite3_column_int(stmt, 0);
            idValue = ID;
            //(2)取出第1列字段的值（text类型的值）
//            const unsigned char *name=sqlite3_column_text(stmt, 1);
//            words = [NSString stringWithUTF8String:(const char *)name];
            //(3)取出第2列字段的值（int类型的值）
//            int age=sqlite3_column_int(stmt, 2);

//            BKYKeyWordsModel *p=[[BKYKeyWordsModel alloc]init];
//            p.id=ID;
//            p.bad_word=[NSString stringWithUTF8String:(const char *)name];
//            p.age=age;
//            NSLog(@"%@",p.bad_word);
         //   NSLog(@"haha%@",persons);
        }
    }else
    {
        NSLog(@"查询语句有问题");
    }
    NSLog(@"%d", idValue);
    //NSLog(@"haha%@",persons);
    return idValue;
}

// 根据id 查询内容
+ (NSString *)queryaBadWordWithID:(int)ID{
    
    
    NSString *words = @"";
    /*
     [NSString stringWithFormat:@"SELECT id, name, age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;", condition];
    NSString *NSsql=[NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name=%@;",condition];
    */
    NSString *NSsql= [NSString stringWithFormat:@"SELECT FROM bad_word WHERE id = '%d'", ID];
    NSLog(@"%@",NSsql);
    const char *sql=NSsql.UTF8String;
    
    sqlite3_stmt *stmt=NULL;
    
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        NSLog(@"查询语句没有问题");
        
        
//        int count = sqlite3_column_count(stmt);
//        NSLog(@"%d", count);
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录

            //取出数据
            //(1)取出第0列字段的值（int类型的值）
//            int ID=sqlite3_column_int(stmt, 0);
//            idvalue = ID;
            //(2)取出第1列字段的值（text类型的值）
            const unsigned char *name=sqlite3_column_text(stmt, 1);
            words = [NSString stringWithUTF8String:(const char *)name];
            //(3)取出第2列字段的值（int类型的值）
//            int age=sqlite3_column_int(stmt, 2);

//            BKYKeyWordsModel *p=[[BKYKeyWordsModel alloc]init];
//            p.id=ID;
//            p.bad_word=[NSString stringWithUTF8String:(const char *)name];
//            p.age=age;
//            NSLog(@"%@",p.bad_word);
         //   NSLog(@"haha%@",persons);
        }
    }else
    {
        NSLog(@"查询语句有问题");
    }
    NSLog(@"%@", words);
    //NSLog(@"haha%@",persons);
    return words;
}

//查询id最大
+ (int)queryaLastItem
{
    
    //id最大
    int idvalue=0;
    /*
     [NSString stringWithFormat:@"SELECT id, name, age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;", condition];
    NSString *NSsql=[NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name=%@;",condition];
    */
    NSString *NSsql=[NSString stringWithFormat:@"SELECT max(id) FROM bad_word"];
    NSLog(@"%@",NSsql);
    const char *sql=NSsql.UTF8String;
    
    sqlite3_stmt *stmt=NULL;
    
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        NSLog(@"查询语句没有问题");
        
        
//        int count = sqlite3_column_count(stmt);
//        NSLog(@"%d", count);
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录

            //取出数据
            //(1)取出第0列字段的值（int类型的值）
            int ID=sqlite3_column_int(stmt, 0);
            idvalue = ID;
            //(2)取出第1列字段的值（text类型的值）
//            const unsigned char *name=sqlite3_column_text(stmt, 1);
            //(3)取出第2列字段的值（int类型的值）
//            int age=sqlite3_column_int(stmt, 2);

//            BKYKeyWordsModel *p=[[BKYKeyWordsModel alloc]init];
//            p.id=ID;
//            p.bad_word=[NSString stringWithUTF8String:(const char *)name];
//            p.age=age;
//            NSLog(@"%@",p.bad_word);
         //   NSLog(@"haha%@",persons);
        }
    }else
    {
        NSLog(@"查询语句有问题");
    }
    NSLog(@"%d", idvalue);
    //NSLog(@"haha%@",persons);
    return idvalue;
}





@end
