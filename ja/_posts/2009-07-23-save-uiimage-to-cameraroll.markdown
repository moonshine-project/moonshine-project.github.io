---
author: akira
lang: ja
date: 2009-07-23 11:26:48+00:00
layout: post
title: UIImageをカメラロールに保存する方法
tags:
- 開発
---

{% app_banner kyoto_summer %}


これだけ。簡単ですね。


    
```objc
UIImage* uiImage = [UIImage imageNamed:name];
PMS1AppDelegate* app = getAppDelegateInstance();
UIImageWriteToSavedPhotosAlbum(uiImage, app, @selector(localSavedImage:didFinishSavingWithError:contextInfo:), NULL);
```

保存が完了した時にアラートを出すようにしてみました。

```objc
- (void)localSavedImage:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
    if(!error){
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:@"保存"
                                  message:@"写真の保存ができました"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil];
        [alertView show];
        [alertView release];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:@"保存"
                                  message:@"写真の保存ができませんでした"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil];
        [alertView show];
        [alertView release];
    }
}
```
