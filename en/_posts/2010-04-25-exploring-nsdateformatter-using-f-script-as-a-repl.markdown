---
author: ento
lang: en
date: 2010-04-25 16:33:01+00:00
layout: post
title: Exploring NSDateFormatter using F-Script as a REPL
tags: dev
---

(here be preface)

Let's start by instantiating a formatter and a date.


```
> fmt := NSDateFormatter new.

> fmt
<NSDateFormatter: 0x2004cec80>

> now := NSDate date.

> now
2010-04-25 18:03:26 +0900
```



Note that assignment is :=, not =, and no angled brackets around method calls. Also, a sentence ends in a period, not a semicolon.

OK, what does the virgin formatter output when we feed it a date?


    
```
> fmt stringFromDate:now
''
```


Hmm, after consulting the Xcode Developer Documentation, it seems that we need to set a format string to get a non-empty result. There are also shortcut methods provided to easily set the formats for the date part and the time part.

The argument to these methods is a constant, which we have easy access to in F-Script.


    
```
> NSDateFormatterNoStyle
0

> fmt setDateStyle:NSDateFormatterMediumStyle

> fmt dateFormat
'MMM d, yyyy'

> fmt stringFromDate:now
'Apr 25, 2010'
```



There, the date. Let's try setting the time part format.


    
``` 
> fmt setTimeStyle:NSDateFormatterMediumStyle

> fmt dateFormat
'MMM d, yyyy h:mm:ss a'

> fmt stringFromDate:now
'Apr 25, 2010 6:03:26 PM'
```



With #setDateFormat:, we have more control over the formatting. You can even include arbitrary string. (Which I found out after reading the [date format patterns specification](http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns) adopted by NSDateFormatter.)


```
> fmt setDateFormat:'''Year''YYYY'

> fmt dateFormat
''Year'YYYY'

> fmt stringFromDate:now
'Year2010'
```
