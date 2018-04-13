# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/java_stack_digest"

describe LogStash::Filters::JavaStackDigest do
  stack_trace = %q(com.xyz.MyApp$MyClient$MyClientException: An error occurred while getting Alice's things
and the error message wraps on
 several lines
  at com.xyz.MyApp$MyClient.getTheThings(MyApp.java:26)
  at com.xyz.MyApp$MyService.displayThings(MyApp.java:16)
  at com.xyz.MyApp$MyService$$FastClassByCGLIB$$e7645040.invoke()
  at net.sf.cglib.proxy.MethodProxy.invoke()
  at org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint()
  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()
  at org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed()
  at sun.reflect.NativeMethodAccessorImpl.invoke0()
  at sun.reflect.NativeMethodAccessorImpl.invoke()
  at sun.reflect.DelegatingMethodAccessorImpl.invoke()
  at java.lang.reflect.Method.invoke()
  at org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs()
  at org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod()
  at org.springframework.aop.aspectj.AspectJAroundAdvice.invoke()
  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()
  at org.springframework.aop.interceptor.AbstractTraceInterceptor.invoke()
  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()
  at org.springframework.transaction.interceptor.TransactionInterceptor.invoke()
  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()
  at org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke()
  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed()
  at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept()
  at com.xyz.MyApp$MyService$$EnhancerBySpringCGLIB$$c673c675.displayThings(<generated>)
  at sun.reflect.GeneratedMethodAccessor647.invoke(Unknown Source)
  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
  at java.lang.reflect.Method.invoke(Method.java:498)
  at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
  at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:133)
  at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:116)
  at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:827)
  at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:738)
  at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:85)
  at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:963)
  at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:897)
  at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:970)
  at org.springframework.web.servlet.FrameworkServlet.doGet(FrameworkServlet.java:861)
  at javax.servlet.http.HttpServlet.service(HttpServlet.java:624)
  at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:846)
  at javax.servlet.http.HttpServlet.service(HttpServlet.java:731)
  at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:303)
  at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:208)
  at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52)
  at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:241)
  at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:208)
  ...
  at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:331)
  at org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:214)
  at org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:177)
  at org.springframework.web.filter.DelegatingFilterProxy.invokeDelegate(DelegatingFilterProxy.java:346)
  at org.springframework.web.filter.DelegatingFilterProxy.doFilter(DelegatingFilterProxy.java:262)
  at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:241)
  at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:208)
  ...
  at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:116)
  at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:436)
  at org.apache.coyote.http11.AbstractHttp11Processor.process(AbstractHttp11Processor.java:1078)
  at org.apache.coyote.AbstractProtocol$AbstractConnectionHandler.process(AbstractProtocol.java:625)
  at org.apache.tomcat.util.net.JIoEndpoint$SocketProcessor.run(JIoEndpoint.java:316)
  at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
  at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
  at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)
  at java.lang.Thread.run(Thread.java:748)
  ...
Caused by: com.xyz.MyApp$HttpStack$HttpError: I/O error on GET http://dummy/user/alice/things
  at com.xyz.MyApp$HttpStack.get(MyApp.java:40)
  at com.xyz.MyApp$MyClient.getTheThings(MyApp.java:24)
  ... 23 common frames omitted
Caused by: java.net.SocketTimeoutException: Read timed out
  at com.xyz.MyApp$HttpStack.get(MyApp.java:38)
  ... 24 common frames omitted)

  # ---------------------------------------------------------------------
  describe "Digest should be computed if stack trace present" do
    let(:config) do <<-CONFIG
      filter {
        java_stack_digest {
        }
      }
    CONFIG
    end

    sample("stack_trace" => stack_trace) do
      expect(subject).to include("stack_digest")
      expect(subject.get('stack_digest')).to eq('e801d2223555804c354eba382af40487')
    end
  end

  # ---------------------------------------------------------------------
  describe "Digest should not be computed if stack not trace present" do
    let(:config) do <<-CONFIG
      filter {
        java_stack_digest {
        }
      }
    CONFIG
    end

    sample("field" => "value") do
      expect(subject).not_to include("stack_digest")
    end
  end

  # ---------------------------------------------------------------------
  describe "Digest with exclusion config 1" do
    let(:config) do <<-CONFIG
      filter {
        java_stack_digest {
          exclude_no_source => false
        }
      }
    CONFIG
    end

    sample("stack_trace" => stack_trace) do
      expect(subject).to include("stack_digest")
      expect(subject.get('stack_digest')).to eq('498f8151629971495ed5dd8c3713d45e')
    end
  end

  # ---------------------------------------------------------------------
  describe "Digest with exclusion config 2" do
    let(:config) do <<-CONFIG
      filter {
        java_stack_digest {
          exclude_no_source => false
          excludes => ['\\$\\$FastClassByCGLIB\\$\\$', '\\$\\$EnhancerBySpringCGLIB\\$\\$']
        }
      }
    CONFIG
    end

    sample("stack_trace" => stack_trace) do
      expect(subject).to include("stack_digest")
      expect(subject.get('stack_digest')).to eq('ff887f4f5d9e588df37afbb4ceee6980')
    end
  end

  # ---------------------------------------------------------------------
  describe "Digest with inclusion and exclusion config" do
    let(:config) do <<-CONFIG
      filter {
        java_stack_digest {
          exclude_no_source => true
          includes => ['^com\\.xyz\\.']
          excludes => ['\\$\\$FastClassByCGLIB\\$\\$', '\\$\\$EnhancerBySpringCGLIB\\$\\$']
        }
      }
    CONFIG
    end

    sample("stack_trace" => stack_trace) do
      expect(subject).to include("stack_digest")
      expect(subject.get('stack_digest')).to eq('fa54771601828e9a2964ed0651e8c09c')
    end
  end

  # ---------------------------------------------------------------------
  describe "Digest should be computed if stack trace present with non default config" do
    let(:config) do <<-CONFIG
      filter {
        java_stack_digest {
          source => "java_stack"
          target => "stack_md5"
        }
      }
    CONFIG
    end

    sample("java_stack" => stack_trace) do
      expect(subject).to include("stack_md5")
      expect(subject.get('stack_md5')).to eq('e801d2223555804c354eba382af40487')
    end
  end


end
