//
//  NSObject+KVO.m
//  KVO
//
//  Created by mac on 2018/3/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

static NSString *handlerDicName = @"handlerDicName";
static NSString *funcHandlerDicName = @"funcHandlerDicName";
static NSString *notificationHandlerDicName = @"notificationHandlerDicName";
static NSString *textHandlerName = @"textHandlerName";

@interface NSObject ()<UITextViewDelegate>
@property(nonatomic,strong)NSMutableDictionary * handlerDic;
@property(nonatomic,strong)NSMutableDictionary * funcHandlerDic;
@property(nonatomic,strong)NSMutableDictionary * notificationHandlerDic;
@property(nonatomic,copy)TextHandler tHandler;
@end

@implementation NSObject (KVO)
#pragma mark -添加kvo
-(void)addObserverForKeyPath:(NSString *)keyPath complete:(CompleteHandler)completeHandler{
    
    if (!self.handlerDic) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        self.handlerDic = dic;
    }
    [self.handlerDic setObject:completeHandler forKey:keyPath];
    
    [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    CompleteHandler handler = self.handlerDic[keyPath];
    if (handler) {
        handler(change[@"new"], change[@"old"]);
    }
}
- (NSMutableDictionary *)handlerDic{
    return objc_getAssociatedObject(self, &handlerDicName);
}
- (void)setHandlerDic:(NSMutableDictionary *)handlerDic{
    objc_setAssociatedObject(self, &handlerDicName, handlerDic,OBJC_ASSOCIATION_RETAIN);
}

#pragma mark -事件监听
-(void)addFuncObserverForSelector:(NSString *)selector withFuncHandler:(FuncHandler)funcHandler{
    
    if (!self.funcHandlerDic) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        self.funcHandlerDic = dic;
    }
    [self.funcHandlerDic setObject:funcHandler forKey:selector];
    
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(selector));
    
    NSString *exc_str = [NSString stringWithFormat:@"func_%@",selector];

    class_addMethod([self class], NSSelectorFromString(exc_str), (IMP)exc_funcMethod, "v@:");
    
    Method exc_method = class_getInstanceMethod([self class], NSSelectorFromString(exc_str));
    
    method_exchangeImplementations(method, exc_method);
}
void exc_funcMethod(id self, SEL _cmd, NSString *param){

    NSObject *obj = self;
    
    FuncHandler handler = obj.funcHandlerDic[NSStringFromSelector(_cmd)];
    if (handler) {
        handler(param);
    }
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"func_%@",NSStringFromSelector(_cmd)]);
    
    [self performSelector:selector withObject:param];
}

- (NSMutableDictionary *)funcHandlerDic{
    return objc_getAssociatedObject(self, &funcHandlerDicName);
}
- (void)setFuncHandlerDic:(NSMutableDictionary *)funcHandlerDic{
    objc_setAssociatedObject(self, &funcHandlerDicName, funcHandlerDic,OBJC_ASSOCIATION_RETAIN);
}


#pragma mark -通知监听
-(void)addNotificationObserverForName:(NSString *)name object:(id)object withNotificationHandler:(NotificationHandler)notificationHandler{
    
    if (![self isKindOfClass:[NSNotificationCenter class]]) {
        @throw [NSException exceptionWithName:@"NotificationObserverError" reason:@"obj isn't NSNotificationCenter" userInfo:nil];
    }
    
    if (!self.notificationHandlerDic) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        self.notificationHandlerDic = dic;
    }
    [self.notificationHandlerDic setObject:notificationHandler forKey:name];
    
    [(NSNotificationCenter *)self addObserver:self selector:@selector(notiAcion:) name:name object:object];
}
-(void)notiAcion:(NSNotification *)noti{
    NotificationHandler handler = self.notificationHandlerDic[noti.name];
    
    if (handler) {
        handler(noti);
    }
}
- (NSMutableDictionary *)notificationHandlerDic{
    return objc_getAssociatedObject(self, &notificationHandlerDicName);
}
- (void)setNotificationHandlerDic:(NSMutableDictionary *)notificationHandlerDic{
    objc_setAssociatedObject(self, &notificationHandlerDicName, notificationHandlerDic,OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - textField.text or textView.text change
-(void)addTextObserverWithTextHandler:(TextHandler)textHandler{
    
    if (![self isKindOfClass:[UITextField class]] && ![self isKindOfClass:[UITextView class]]) {
        @throw [NSException exceptionWithName:@"TextObserverError" reason:@"obj isn't UITextField or UITextView" userInfo:nil];
    }
    
    if ([self isKindOfClass:[UITextField class]]) {
        self.tHandler = textHandler;
        
        UITextField *tf = (UITextField *)self;
        
        [tf addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }else{
        self.tHandler = textHandler;
        
        UITextView *tv = (UITextView *)self;
        
        tv.delegate = self;
    }
}
-(void)textFieldDidChange{
    if (self.tHandler) {
        UITextField *tf = (UITextField *)self;
        self.tHandler(tf.text);
    }
}
-(void)textViewDidChange:(UITextView *)textView{
    if (self.tHandler) {
        self.tHandler(textView.text);
    }
}
- (TextHandler)tHandler{
    return objc_getAssociatedObject(self, &textHandlerName);
}
- (void)setTHandler:(TextHandler)tHandler{
    objc_setAssociatedObject(self, &textHandlerName, tHandler,OBJC_ASSOCIATION_RETAIN);
}
@end
