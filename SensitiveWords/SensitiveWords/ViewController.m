//
//  ViewController.m
//  SensitiveWords
//
//  Created by kevin on 2020/5/8.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "ViewController.h"
#import "BKYKeyWordsModel.h"
#import "BKYSQLHelper.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *wordtextFiled;
@property (weak, nonatomic) IBOutlet UITextField *idtextFiled;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

///string 传入需要检测的字符串
- (BOOL)checkFilterInvaildChar:(NSString *)string{
    if (string.length > 0){
        BOOL isExist = [BKYSQLHelper queryWithCondition:string];
        return isExist;
    }
    return NO;
}

// 插入数据
- (IBAction)joinSensitiveWordsAction:(UIButton *)sender {
    NSString *badWord = _wordtextFiled.text;
    NSString *message = @"";
    
    if (badWord.length > 0){
        int MaximumID = [BKYSQLHelper queryaLastItem]; //查询最大id
        BKYKeyWordsModel *model = [[BKYKeyWordsModel alloc] init];
        model.id = MaximumID + 1;
        model.bad_word = badWord;
        [BKYSQLHelper save:model];
        message = @"加入成功";
    }
    else{
        message = @"关键词不能为空";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"action cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"action cancel did clicked");
    }];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

// 删除数据
- (IBAction)removeSensitiveWordsAction:(UIButton *)sender {
    
    NSString *badWord = _wordtextFiled.text;
    NSString *idstr = _idtextFiled.text;
    NSString *message = @"";

    if (badWord.length == 0) {
        message = @"关键字不能为空";
    }else{
        int wordId = 0;
        if (idstr.length > 0){
           wordId = (int)_idtextFiled.text;
        }
       
        BKYKeyWordsModel *model = [[BKYKeyWordsModel alloc] init];
        model.id = wordId;
        model.bad_word = badWord;
        [BKYSQLHelper remove:model];
        message = @"删除成功";
    }
   
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"action cancel did clicked");
    }];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}


- (IBAction)checkBadWordsIsExit:(id)sender {
    NSString *string = _wordtextFiled.text;
    NSString *message = @"";
    if (string.length > 0){
        if([self checkFilterInvaildChar:string]){// s包含敏感字
            message = [NSString stringWithFormat:@"%@包含敏感字", string];
        }else{// 不包含敏感字
            message = [NSString stringWithFormat:@"%@不包含敏感字", string];
        }
    }else{
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"action cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"action cancel did clicked");
    }];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}

- (IBAction)checkAllWords:(id)sender {
    NSArray *arr = [BKYSQLHelper queryaAll];
    for (BKYKeyWordsModel *model in arr) {
        NSLog(@"%@-------%d", model.bad_word, model.id);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
