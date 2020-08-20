//
//  Constants.h
//  InvoiceRecognition
//
//  Created by 羊小咩 on 2020/4/26.
//  Copyright © 2020 羊小咩. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//#define NSLog(args...) CustomLog(__FILE__, __LINE__, __PRETTY_FUNCTION__, args)
#define NSLog(args...) CustomLogClear(__FILE__, __LINE__, __PRETTY_FUNCTION__, args)

static inline void CustomLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
  // Type to hold information about variable arguments.
  va_list ap;
  // Initialize a variable argument list.
  va_start (ap, format);
  // NSLog only adds a newline to the end of the NSLog format if
  // one is not already there.
  // Here we are utilizing this feature of NSLog()
  if (![format hasSuffix: @"\n"])
  {
    format = [format stringByAppendingString: @"\n"];
  }
  NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
  // End using variable argument list.
  va_end (ap);
  NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
  fprintf(stderr, "(%s) (%s:%d) %s",
      functionName, [fileName UTF8String],
      lineNumber, [body UTF8String]);
}


static inline void CustomLogClear(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
  // Type to hold information about variable arguments.
  va_list ap;
  // Initialize a variable argument list.
  va_start (ap, format);
  // NSLog only adds a newline to the end of the NSLog format if
  // one is not already there.
  // Here we are utilizing this feature of NSLog()
  if (![format hasSuffix: @"\n"])
  {
    format = [format stringByAppendingString: @"\n"];
  }
  NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
  // End using variable argument list.
  va_end (ap);
  fprintf(stderr, "%s", [body UTF8String]);
}


#endif /* Constants_h */
