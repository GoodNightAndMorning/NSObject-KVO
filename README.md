# NSObject-KVO

/**
 监听对象属性变化  
  
 @param keyPath 监听的属性  
 @param completeHandler 回调  
 */  
-(void)addObserverForKeyPath:(NSString *)keyPath complete:(CompleteHandler)completeHandler;  
  
/**  
 监听事件  
  
 @param selector 事件方法字符串  
 @param funcHandler 回调  
 */  
-(void)addFuncObserverForSelector:(NSString *)selector withFuncHandler:(FuncHandler)funcHandler;  
  
/**  
 监听通知  
  
 @param name 通知名  
 @param object obj  
 @param notificationHandler 回调  
 */  
-(void)addNotificationObserverForName:(NSString *)name object:(id)object withNotificationHandler:(NotificationHandler)notificationHandler;  
  

/**  
 监听UITextField、UITextView的text变化  
  
 @param textHandler 回调  
 */  
-(void)addTextObserverWithTextHandler:(TextHandler)textHandler;  
