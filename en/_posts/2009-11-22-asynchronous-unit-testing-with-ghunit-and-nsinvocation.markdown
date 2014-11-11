---
author: ento
lang: en
date: 2009-11-22 10:11:51+00:00
layout: post
title: Asynchronous unit testing with GHUnit and NSInvocation
name: async-testing-ghunit-nsinvocation
tags:
- dev
---

## 1. Decoupling the network access code



Suppose you have an app that calls a remote API to store the user's rating of your content:


```objc
@implementation StarService

- (void)star:(NSUInteger)pictureNumber count:(NSUInteger)count {
	// create the request
	NSString *url = [NSString stringWithFormat:@"http://%@:%d/api/star/", serviceHostname, servicePort, nil];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// ... setup the API parameters and HTTP headers ...
	StarRequestDelegate *requestDelegate = [[StarRequestDelegate alloc] initWithService:self delegate:serviceDelegate];
	/* Starting API call! */
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:aRequest delegate:requestDelegate];
}
...
// NSURLConnection delegate for the star API call
@implementation StarRequestDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (delegate && [(NSObject*)delegate respondsToSelector:@selector(starService:didFinishStar:)]) {
		/* API call returned normally, invoke the delegate's callback */
		[delegate starService:service didFinishStar:receivedData];
	}
	[super connectionDidFinishLoading:connection];
}
```


The first thing you want to do is to implement a fake version of the calling class to slice out the network dependency. Then you can use the fake service to develop other parts of the app without worrying about setting up the API server each time you do a test run.


```objc
@implementation FakeStarService

- (void)star:(NSUInteger)pictureNumber count:(NSUInteger)count {
	/* invocation to call the delegate method directly */
	NSInvocation *invocation;
	[[NSInvocation retainedInvocationWithTarget:serviceDelegate invocationOut:&invocation]
	 starService:self didFinishStar:nil];

	/* wrap it around with another invocation to simulate network delay */
	NSInvocation *delayInvocation;
	[[NSInvocation retainedInvocationWithTarget:invocation invocationOut:&delayInvocation]
	 performSelector:@selector(invoke) withObject:nil afterDelay:delay];
	[delayInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
}
```



Here I'm creating two NSInvocations to simulate a delayed API call. Wait, there must be more to creating an NSInvocation? You're right. This code wouldn't be possible without the excellent [ForwardedConstruction extension](http://cocoawithlove.com/2008/03/construct-nsinvocation-for-any-message.html) for NSInvocation.

To use the extension on iPhone, download the code from the original article and add/modify the following parts:

```diff
--- Downloads/NSInvocationForwardedConstruction/NSInvocation(ForwardedConstruction).h	2009-05-04 11:55:34.000000000 +0900
+++ NSInvocation(ForwardedConstruction).h	2009-12-02 10:17:07.000000000 +0900
@@ -11,7 +11,7 @@
 //  appreciated but not required.
 //
 
-#import <Cocoa/Cocoa.h>
+#import <UIKit/UIKit.h>
 
 @interface NSInvocation (ForwardedConstruction)
 
@@ -21,3 +21,10 @@
 	invocationOut:(NSInvocation **)invocationOut;
 
 @end
+
+#if (TARGET_OS_IPHONE)
+@interface NSObject (ForwardedConstruction)
+- (NSString *)className;
++ (NSString *)className;
+@end
+#endif
--- Downloads/NSInvocationForwardedConstruction/NSInvocation+ForwardedConstruction.m	2009-05-04 11:55:34.000000000 +0900
+++ NSInvocation(ForwardedConstruction).m	2009-12-02 10:17:43.000000000 +0900
@@ -12,7 +12,9 @@
 //
 
 #import "NSInvocation(ForwardedConstruction).h"
-#import <objc/objc-runtime.h>
+//#import <objc/objc-runtime.h>
+#import <objc/runtime.h>
+#import <objc/message.h>
 
 //
 // InvocationProxy is a private class for receiving invocations via the
@@ -376,4 +378,21 @@
 	return invocationProxy;
 }
 
+@end 
+
+#if (TARGET_OS_IPHONE)
+
+@implementation NSObject (ForwardedConstruction)
+
+- (NSString *)className
+{
+	return [NSString stringWithUTF8String:class_getName([self class])];
+}
++ (NSString *)className
+{
+	return [NSString stringWithUTF8String:class_getName(self)];
+}
+
 @end
+
+#endif
```

## 2. Choosing the right thread


[GHUnit](http://github.com/gabriel/gh-unit) is a test framework for Objective-C (Mac OS X 10.5 and iPhone 2.x/3.x) with a pretty GUI test runner. It has the ability to run itself on a separate thread, which comes in handy when dealing with NSURLConnection related tests.

Why? Because for some internal working of NSURLConnection, invoking it from the main thread seems to be the most hassle-free way of using. By having the test framework running on a separate thread, we can keep the network related code on the main thread while enjoying a smooth testing UI.

So here is the working setup I have:


```objc
// test cases for the real service class.
// there's another similar class for testing the fake service.
@implementation HttpNetTest

- (BOOL)shouldRunOnMainThread {
	/* Tell GHUnit to run on a separate thread */
	return NO;
}

- (void)test_send_star {
	[tester do_test_send_star:service];
}

@implementation StarServiceTests

- (void)do_test_send_star:(id)service {
	// setup an invocation and
	NSInvocation *invocation;
	[[NSInvocation retainedInvocationWithTarget:service invocationOut:&invocation]
	  star:0 count:1];
	/* invoke it on the main thread */
	[invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];

	/* wait */
	BOOL notTimeout = [AsyncTestHelper wait:service.delegate property:@selector(receivedDidFinishGetStarsCount) atLeast:1];

	/* asserts */
	GHAssertTrue(notTimeout, @"Should not timeout");
	GHAssertEquals((NSUInteger)1, [service.delegate receivedDidFinishStarCount], @"delegate should receive star callback");		
}
```


## 3. Waiting for the async call to finish


The final snippet is a little helper for testing asynchronous operation. You might have noticed the line using it in the test case:


```objc
@implementation StarServiceTests

- (void)do_test_send_star:(id)service {
	// .. 
	[AsyncTestHelper wait:service.delegate property:@selector(receivedDidFinishStarCount) atLeast:1];
	// ..
}
```



Basically the method just loops until the specified property value is equal or more than a certain threshold:


```objc
@implementation AsyncTestHelper

+ (BOOL)wait:(id)target property:(SEL)getter atLeast:(NSUInteger)count {
	int tried = 0;
	while((NSUInteger)[target performSelector:getter]  10) {
			return FALSE;
		}
		[NSThread sleepForTimeInterval:0.5];
	}
	return TRUE;
}
```


Now you can get the pleasure of full green tests with iPhone network programming too.

![ghunit_test_runner](http://img.skitch.com/20091202-rdp1ea91iuxwcjtwpbndua1i9w.png)

Finally, here's a class diagram of all the classes mentioned above, produced with a little help from Xcode's Core Data modeling interface.

![](http://img.skitch.com/20091122-j6q7axd8up53qb1m1xdaxswrai.png)
