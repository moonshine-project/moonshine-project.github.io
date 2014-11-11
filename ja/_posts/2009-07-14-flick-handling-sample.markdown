---
author: akira
date: 2009-07-14 07:01:44+00:00
layout: post
lang: ja
title: 自前でフリックするプログラムを書く
tags:
- 開発
---

{% app_banner kyoto_summer %}


こんな感じでフリックできます。

{% youtube 9iqMH_9bP5A %}


コードはこちら。説明は開発を優先したいので割愛させてください。コードを感じ取ってください。


```c++
//--------------------------------
void ManualThum::touchesBegan(NSSet* touches, UIEvent* event){
    for(UITouch *touch in touches){
        UIView* view = Scene::getInstance()->getView();
        CGPoint touchPos = [touch locationInView:view];
        ms::Vector2n screenSize = Scene::getInstance()->getScreenSize();
        if(touchPos.y >= (screenSize.y-THUM_FLICK_H)){
            touchStartPos = touchPos;
            touchNowPos = touchStartPos;
            touchGapPos = CGPointMake(0.0f, 0.0f);
            state = STATE_MOVE;
        }
        break;
    }
}
//--------------------------------
void ManualThum::touchesMoved(NSSet* touches, UIEvent* event){
    for(UITouch *touch in touches){
        UIView* view = Scene::getInstance()->getView();
        CGPoint touchPos = [touch locationInView:view];
        ms::Vector2n screenSize = Scene::getInstance()->getScreenSize();
        if(touchPos.y >= (screenSize.y-THUM_FLICK_H)){
            CGPoint prevPos = touchNowPos;
            touchNowPos = touchPos;
            touchGapPos = CGPointMake(touchNowPos.x-prevPos.x, touchNowPos.y-prevPos.y);
        }
        break;
    }
}
//--------------------------------
void ManualThum::touchesEnded(NSSet* touches, UIEvent* event){
    for(UITouch *touch in touches){
        UIView* view = Scene::getInstance()->getView();
        CGPoint touchPos = [touch locationInView:view];
        if(ABS(touchPos.x-touchStartPos.x) < 10.0f &&
           ABS(touchPos.y-touchStartPos.y)  10.0){
                slideSpeed = touchGapPos.x * 1000.0f;
                state = STATE_THROW;
            }
            touchStartPos = CGPointMake(0.0f, 0.0f);
            touchNowPos = touchStartPos;
            touchGapPos = CGPointMake(0.0f, 0.0f);
        }
        break;
    }
}
//--------------------------------
void ManualThum::touchesCancelled(NSSet* touches, UIEvent* event){
    touchesEnded(touches, event);
}
```
