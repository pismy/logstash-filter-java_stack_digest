# Details about stack digest

This page gives details about the **stack digest** feature (goal and implementation).


## Why generating stack digests?

A full Java stack trace is very helpful to analyse and debug a single error, but is not very handy to compare two
errors.

The idea is to turn a full Java stack trace into a **short** and **stable** digest, that could help matching several 
distinct occurrences of the same type of error:

* **short** for easing elasticsearch indexing, and take advantage of it (we use a MD5 hash),
* **stable** is the tricky part, as the same type of error occurring twice may not generate exactly the same stack trace 
(see below).

This done, it becomes easy with elasticsearch or any other logs centralization and indexation system to:

* **count** distinct type of errors that occur in your code over time,
* **count** occurrences and frequency of a given type of error,
* **detect** when a (new) type of error occurred for the first time (maybe linking this to a new version being deployed?).

The stack digest may also become a simple error id that you can link your bug tracker with...


## Stack digest stability challenge by examples

### Let's consider error stack 1

*(the stack trace presented here has been cut by half from useless lines)*

<pre>
<b>com.xyz.MyApp$MyClient$MyClientException</b>: <strike>An error occurred while getting Alice's things</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$MyClient.getTheThings(MyApp.java:26)</b>
  at <b>com.xyz.MyApp$MyService.displayThings(MyApp.java:16)</b>
  at <strike>com.xyz.MyApp$MyService$$FastClassByCGLIB$$e7645040.invoke()</strike><sup>(aop)</sup>
  at <i>net.sf.cglib.proxy.MethodProxy.invoke()</i><sup>(aop)</sup>
  at <i>org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed()</i><sup>(fwk)</sup>
  at <i>sun.reflect.NativeMethodAccessorImpl.invoke0()</i><sup>(aop)</sup>
  at <i>sun.reflect.NativeMethodAccessorImpl.invoke()</i><sup>(aop)</sup>
  at <i>sun.reflect.DelegatingMethodAccessorImpl.invoke()</i><sup>(aop)</sup>
  at <i>java.lang.reflect.Method.invoke()</i><sup>(aop)</sup>
  at <i>org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.AspectJAroundAdvice.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.interceptor.AbstractTraceInterceptor.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.transaction.interceptor.TransactionInterceptor.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept()</i><sup>(fwk)</sup>
  at <strike>com.xyz.MyApp$MyService$$EnhancerBySpringCGLIB$$c673c675.displayThings(&lt;generated&gt;)</strike><sup>(aop)</sup>
  at <strike>sun.reflect.GeneratedMethodAccessor647.invoke(Unknown Source)</strike><sup>(aop)</sup>
  at <i>sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)</i><sup>(aop)</sup>
  at <i>java.lang.reflect.Method.invoke(Method.java:498)</i><sup>(aop)</sup>
  at <i>org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:133)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:116)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:827)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:738)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:85)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:963)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:897)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:970)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.servlet.FrameworkServlet.doGet(FrameworkServlet.java:861)</i><sup>(fwk)</sup>
  at <i>javax.servlet.http.HttpServlet.service(HttpServlet.java:624)</i><sup>(jee)</sup>
  at <i>org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:846)</i><sup>(fwk)</sup>
  at <i>javax.servlet.http.HttpServlet.service(HttpServlet.java:731)</i><sup>(jee)</sup>
  at <i>org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:303)</i><sup>(jee)</sup>
  at <i>org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:208)</i><sup>(jee)</sup>
  at <i>org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52)</i><sup>(jee)</sup>
  at <i>org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:241)</i><sup>(jee)</sup>
  at <i>org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:208)</i><sup>(jee)</sup>
  ...
  at <i>org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:331)</i><sup>(fwk)</sup>
  at <i>org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:214)</i><sup>(fwk)</sup>
  at <i>org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:177)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.filter.DelegatingFilterProxy.invokeDelegate(DelegatingFilterProxy.java:346)</i><sup>(fwk)</sup>
  at <i>org.springframework.web.filter.DelegatingFilterProxy.doFilter(DelegatingFilterProxy.java:262)</i><sup>(fwk)</sup>
  at <i>org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:241)</i><sup>(jee)</sup>
  at <i>org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:208)</i><sup>(jee)</sup>
  ...
  at <i>org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:116)</i><sup>(jee)</sup>
  at <i>org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:436)</i><sup>(jee)</sup>
  at <i>org.apache.coyote.http11.AbstractHttp11Processor.process(AbstractHttp11Processor.java:1078)</i><sup>(jee)</sup>
  at <i>org.apache.coyote.AbstractProtocol$AbstractConnectionHandler.process(AbstractProtocol.java:625)</i><sup>(jee)</sup>
  at <i>org.apache.tomcat.util.net.JIoEndpoint$SocketProcessor.run(JIoEndpoint.java:316)</i><sup>(jee)</sup>
  at <i>java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)</i><sup>(jee)</sup>
  at <i>java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)</i><sup>(jee)</sup>
  at <i>org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)</i><sup>(jee)</sup>
  at <i>java.lang.Thread.run(Thread.java:748)</i><sup>(jee)</sup>
  ...
Caused by: <b>com.xyz.MyApp$HttpStack$HttpError</b>: <strike>I/O error on GET http://dummy/user/alice/things</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$HttpStack.get(MyApp.java:40)</b>
  at <b>com.xyz.MyApp$MyClient.getTheThings(MyApp.java:24)</b>
  ... 23 common frames omitted
Caused by: <b>java.net.SocketTimeoutException</b>: <strike>Read timed out</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$HttpStack.get(MyApp.java:38)</b>
  ... 24 common frames omitted
</pre>

---

<strike>Strike out elements</strike> may vary from one occurrence to the other:

* <strike>error messages</strike><sup>(msg)</sup> often contain stuff related to the very error occurrence context,
* <strike>AOP generated classes</strike><sup>(aop)</sup> may vary from one execution to another.

*Italic* elements are somewhat not stable, or at least useless (purely technical). Ex:

* <i>JEE container stuff</i><sup>(jee)</sup>: may change when you upgrade your JEE container version or add/remove/reorganize your servlet filters chain for instance,
* <i>Spring Framework</i><sup>(fwk)</sup> underlying stacks (MVC, security) for pretty much the same reason,
* <i>AOP and dynamic invocation</i><sup>(aop)</sup>: purely technical, and quite implementation-dependent.

Only **bolded elements** are supposed to be stable.


### Now let's consider error stack 2

*(shortened)*

<pre>
<b>com.xyz.MyApp$MyClient$MyClientException</b>: <strike>An error occurred while getting <b>Bob</b>'s things</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$MyClient.getTheThings(MyApp.java:26)</b>
  at <b>com.xyz.MyApp$MyService.displayThings(MyApp.java:16)</b>
  at <strike>com.xyz.MyApp$MyService$$FastClassByCGLIB$$<b>07e70d1e</b>.invoke()</strike><sup>(aop)</sup>
  at <i>net.sf.cglib.proxy.MethodProxy.invoke()</i><sup>(aop)</sup>
  at <i>org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed()</i><sup>(fwk)</sup>
  at <i>sun.reflect.NativeMethodAccessorImpl.invoke0()</i><sup>(aop)</sup>
  at <i>sun.reflect.NativeMethodAccessorImpl.invoke()</i><sup>(aop)</sup>
  at <i>sun.reflect.DelegatingMethodAccessorImpl.invoke()</i><sup>(aop)</sup>
  at <i>java.lang.reflect.Method.invoke()</i><sup>(aop)</sup>
  at <i>org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.AspectJAroundAdvice.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.interceptor.AbstractTraceInterceptor.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.transaction.interceptor.TransactionInterceptor.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept()</i><sup>(fwk)</sup>
  at <strike>com.xyz.MyApp$MyService$$EnhancerBySpringCGLIB$$<b>e3f570b1</b>.displayThings(&lt;generated&gt;)</strike><sup>(aop)</sup>
  at <strike>sun.reflect.<b>GeneratedMethodAccessor737</b>.invoke(Unknown Source)</strike><sup>(aop)</sup>
  ...
Caused by: <b>com.xyz.MyApp$HttpStack$HttpError</b>: <strike>I/O error on GET http://dummy/user/<b>bob</b>/things</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$HttpStack.get(MyApp.java:40)</b>
  at <b>com.xyz.MyApp$MyClient.getTheThings(MyApp.java:24)</b>
  ... 23 common frames omitted
Caused by: <b>java.net.SocketTimeoutException</b>: <strike>Read timed out</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$HttpStack.get(MyApp.java:38)</b>
  ... 24 common frames omitted
</pre>

---

You may see in this example that most of the <strike>strike elements have slight <b>differences</b></strike> from error stack
1 (messages and generated classes names).

Nevertheless it is the same exact error (despite the context is different as it applies to another user), and the goal
here is to be able to count them as *two occurrences of the same error*.

### Now let's consider error stack 3

*(shortened)*

<pre>
<b>com.xyz.MyApp$MyClient$MyClientException</b>: <strike>An error occurred while getting Alice's things</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$MyClient.getTheThings(MyApp.java:26)</b>
  at <b>com.xyz.MyApp$MyService.displayThings(MyApp.java:16)</b>
  at <strike>com.xyz.MyApp$MyService$$FastClassByCGLIB$$e7645040.invoke()</strike><sup>(aop)</sup>
  at <i>net.sf.cglib.proxy.MethodProxy.invoke()</i><sup>(aop)</sup>
  at <i>org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()</i><sup>(fwk)</sup>
  at <i>org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed()</i><sup>(fwk)</sup>
  at <i>sun.reflect.NativeMethodAccessorImpl.invoke0()</i><sup>(aop)</sup>
  at <i>sun.reflect.NativeMethodAccessorImpl.invoke()</i><sup>(aop)</sup>
  at <i>sun.reflect.DelegatingMethodAccessorImpl.invoke()</i><sup>(aop)</sup>
  at <i>java.lang.reflect.Method.invoke()</i><sup>(aop)</sup>
  ...
Caused by: <b>com.xyz.MyApp$HttpStack$HttpError</b>: <strike>I/O error on GET http://dummy/user/alice/things</strike><sup>(msg)</sup>
  at <b>com.xyz.MyApp$HttpStack.get(MyApp.java:40)</b>
  at <b>com.xyz.MyApp$MyClient.getTheThings(MyApp.java:24)</b>
  ... 23 common frames omitted
Caused by: <b>javax.net.ssl.SSLException</b>: <strike>Connection has been shutdown: javax.net.ssl.SSLHandshakeException: Received fatal alert: certificate_unknown</strike><sup>(msg)</sup>
  at <b>com.sun.net.ssl.internal.ssl.SSLSocketImpl.checkEOF(SSLSocketImpl.java:1172)</b>
  ... 24 common frames omitted
</pre>

---

Here, you can see that the first and second errors are the same as in error stack 1, but the root cause is different (`SSLException` instead of `SocketTimeoutException`).

So in that case we don't want the top error digest computed for error stack 3 to be the same as for error stack 1.

## Stack digest computation rules

As a conclusion, stack digest computation applies the following rules:

1. a stack digest shall **not compute with the error message**
2. a stack digest shall **compute with it's parent cause** (recurses)
3. in order to stabilize the stack digest (over time and space), it's recommended to **exclude non-stable elements**
