- [Hello World 是怎么显示出来的?](#hello-world-是怎么显示出来的)
- [司机端 iOS 工程的主要功能是什么？扮演了什么角色？](#司机端-ios-工程的主要功能是什么扮演了什么角色)
- [Hummer的执行流程和原理？（一个跨端框架是怎么运行的？）](#hummer的执行流程和原理一个跨端框架是怎么运行的)
  - [Hummer-iOS 是如何渲染的？](#hummer-ios-是如何渲染的)
- [Hummer-iOS 分为几个模块？各自的作用是什么？各个模块搭配起来工作？](#hummer-ios-分为几个模块各自的作用是什么各个模块搭配起来工作)

# Hello World 是怎么显示出来的?

Hummer-iOS 工程写好了原生组件（比如HMLabel），我们写的 ts 代码（比如new Text()），会转换成js，然后打包成 JSBundle，Native 工程拉取这个 Bundle，传到 Native 的 JSC 执行，执行的结果是调用原生接口，创建、添加原生组件到 App 上，用 YogaKit 进行布局，创建了 Yoga节点树，渲染出了页面。（这部分由Hummer-iOS完成）

疑惑点：

* **self** .automaticallyAdjustsScrollViewInsets =**NO** ;

# 司机端 iOS 工程的主要功能是什么？扮演了什么角色？

# Hummer 的执行流程和原理？（一个跨端框架是怎么运行的？）

1. 原生端加载
   这一步的意义是：当 JSC 执行 JS 代码（也就是 Hummer 侧写的业务代码）时，可以在 Native 侧找到对应的组件和方法，并能创建组件和执行方法。如果不注册并加载对应的方法和组件，那 Hummer 就没有意义。
   
   1. 注册：把 Hummer 的类**注册**到 Native 侧，用到的是 HM_EXPORT_CLASS（注册类）、HM_EXPORT_PROPERTY（注册 setter 和 getter）
      HM_EXPORT_METHOD（注册方法） 这三个宏
      
      * [x] 导出类的「导出」是什么意思？应该指的是暴露，把 Hummer 侧的类暴露到 Native 侧
      * [x] HM_EXPORT_CLASS 这个宏怎么理解？
        
        ```objectivec
        static const HMExportStruct __hm_export_class_##jsClass##__ = {#jsClass, #objcClass};
        // 调用：创建了 __hm_export_class_BasicAnimation__ （类型为HMExportStruct，结构体中有两个指针，一个指向 jsClass，一个指向 objcClass）
        HM_EXPORT_CLASS(BasicAnimation, HMCABasicAnimation)
        ```
        
        ---
   2. 加载：startEngine，加载上面已经 export 的类
   
   ```objectivec
   static const HMExportStruct __hm_export_class_##jsClass##__ = {#jsClass, #objcClass};
        // 调用：创建了 __hm_export_class_BasicAnimation__ （类型为HMExportStruct，结构体中有两个指针，一个指向 jsClass，一个指向 objcClass）
        HM_EXPORT_CLASS(BasicAnimation, HMCABasicAnimation)
   ```







2. JSBundle 加载
3. 渲染

## Hummer-iOS 是如何渲染的？

从HMJSGlobal#render: 函数开始

1. 创建Text 组件，添加到屏幕，addSubview
2. 设置组件的property，比如给 Text 设置text 属性
3. 设置组件的 style，hm_setStyle
   底下都会调用hm_configureWithTarget:cssAttribute:value:converterManager:
   1. attribute：
   2. layout：

分解为两个问题：

1. **布局的信息是如何确定的？**
   * 断点hummerSetProperty 函数，这个不是
   * HMDom ：标记脏节点，啥意思？hm_markDirty
   * 问题：什么是布局信息？
     估计是 ts 代码中的 style 信息，如：(hm_setStyle)
     ![](
   * 布局信息只能是从 ts 侧传过来的一个 dict，用一个 NSDictionary 保存即可hm_styleStore
   * 总结：ts 侧传过来一个 dict，Native 在 HMDom#hm_setStyle 函数中把数据(layoutInfo ,transitionDelay动画信息, attributes)设置给了hm_styleStore。创建 renderObject，将对应信息填进去，开始标记脏节点，开启渲染。
2. **确定位置（布局）信息之后，是怎么显示（渲染）的** ？

```Objective-C
[self hm_configureWithTarget:layout 
      cssAttribute:key 
      value:obj 
      converterManager:HMYogaConfig.defaulfConfig];
```

```
- 异步对节点进行 layout
```

* 容器节点，叶节点，markDirty
* attachRenderObjectFromViewHierarchyForRootView
* RN用的也是 Yoga，是不是可以借鉴下 RN 是怎么渲染的？
* YOGA_TYPE_WRAPPER这个宏该怎么看?

# Hummer-iOS 分为几个模块？各自的作用是什么？各个模块搭配起来工作？

