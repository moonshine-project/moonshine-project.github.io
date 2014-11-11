---
author: ento
lang: en
date: 2010-03-14 04:00:41+00:00
layout: post
name: implicit-animation-of-custom-calayer-properties
title: Implicit animation of custom CALayer properties
tags:
- dev
---

Our quest through various frameworks for creating GUI on Cocoa Touch started out from the UIKit. Unsatisfied with its performance, we then moved on to OpenGL, which is the workhorse of virtually all of our image intensive apps.

However, since last week, I've been playing with Quartz and Core Animation to create a simple clock application and explore their capabilities.

Things have been going well until I tried to animate a clock hand by changing its angle. You can automatically animate a layer's "animatable properties" like opacity, size, etc., just by changing its value. How do I go about applying this "implicit animation" feature to custom parameters like a clock hand's angle?

After three hours of googling, I found that starting from iPhone OS 3.0, CALayer lets you specify which property its content depends on (via needsDisplayForKey:), and which action should be run when the property is changed (via actionForKey:). However, there was one more thing that needed to be taken care of, which I will explain later.

So lets get to the code. Code is worth a thousand words, I believe.

First off, creating the clock hand layer:


```objc
@implementation ClockView

- (void)awakeFromNib {
    [self setupLayers];
    [self start];
}

- (void)start {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 
        target:self
        selector:@selector(tick)
        userInfo:nil
        repeats:YES];
    self.animationTimer = timer;
}

- (void)setupLayers {
    /*
     Add layers for drawing each hand.
     Animation is handled by animating the angle key.
     */
    {
        HandLayer *hand = [[HandLayer alloc] init];
        hand.frame = self.frame;
        self.secondHand = hand;
        [hand release];
        [self.layer addSublayer:self.secondHand];
    }
    // ...
}

- (void) tick {
    // Tell each clock hand that its angle has changed.
}
```


That wasn't particularly interesting. Here comes the climax of this post; the animation:


```objc
@interface HandLayer : CALayer {
}

@property CGFloat angle;

@end


@implementation HandLayer

@dynamic angle;

+ (BOOL)needsDisplayForKey:(NSString*)aKey {
    // Changes in angle require redisplay
    if ([aKey isEqualToString:@"angle"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:aKey];
    }
}

- (id)actionForKey:(NSString *) aKey {
    if ([aKey isEqualToString:@"angle"]) {
        // Create a basic interpolation for "angle" animation
        CABasicAnimation *theAnimation = [CABasicAnimation
            animationWithKeyPath:aKey];
        // Attention: the animation needs to know the fromValue
        theAnimation.fromValue = [[self presentationLayer] valueForKey:aKey];
        return theAnimation;
    } else {
        return [super actionForKey:aKey];
    }
}

- (void)drawInContext:(CGContextRef)context {
    // Draw a hand using the angle property
}
```


Note the line that sets `theAnimation.fromValue` to the current angle of hand in display. It's something not in the textbook. The reason I was able to figure it out is thanks to this [Omni Group's blog post on "Animating CALayer content"](http://www.omnigroup.com/blog/entry/Animating_CALayer_content), which is from a time when you had to "whip up [...] a superclass" and implement your own mechanism of `needsDisplayForKey:`.

Finally, a video!

{% youtube 4rcE0kOrjVA %}

Note: The timing function of the animation used in the video is `kCAMediaTimingFunctionEaseIn`, not the default linear one.

References:

  
  * [Core Animation Programming Guide](http://developer.apple.com/mac/library/documentation/cocoa/conceptual/CoreAnimation_guide/Introduction/Introduction.html)

  
  * [CALayer needsDisplayForKey:](http://developer.apple.com/mac/library/documentation/GraphicsImaging/Reference/CALayer_class/Introduction/Introduction.html#//apple_ref/occ/clm/CALayer/needsDisplayForKey:)

  
  * [CALayer actionForKey:](http://developer.apple.com/mac/library/documentation/GraphicsImaging/Reference/CALayer_class/Introduction/Introduction.html#//apple_ref/occ/instm/CALayer/actionForKey:)
