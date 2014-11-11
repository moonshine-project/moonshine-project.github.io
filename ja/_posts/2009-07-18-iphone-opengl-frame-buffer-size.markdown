---
author: akira
lang: ja
date: 2009-07-18 02:01:42+00:00
layout: post
title: iPhoneでOpneGLのフレームバッファを好きなサイズで作るには
tags:
- 開発
---

{% app_banner kyoto_summer %}

    
```objc
[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)view.layer];
glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
		
glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
```

view.layer のサイズでフレームバッファが作成される。
