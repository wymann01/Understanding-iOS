![](assets/20220710_110132_image.png)
- [前言](#前言)
- [CocoaPods 为什么可以管理第三方依赖？](#cocoapods-为什么可以管理第三方依赖)
    - [1. 分析依赖](#1-分析依赖)
    - [2. 下载依赖](#2-下载依赖)
    - [3. 生成`Pods.xcodeproj`文件](#3-生成podsxcodeproj文件)
    - [4. 生成`xcworkspace`](#4-生成xcworkspace)
- [pod install 和 pod update 的区别是什么？](#pod-install-和-pod-update-的区别是什么)
- [Podfile 中如果写死了pod版本号，是不是就可以抛弃Podfile.lock 了？](#podfile-中如果写死了pod版本号是不是就可以抛弃podfilelock-了)
- [除了 CocoaPods，还有哪些选项？](#除了-cocoapods还有哪些选项)
  - [不侵入性](#不侵入性)
  - [灵活性](#灵活性)
  - [去中心化](#去中心化)
  - [编译速度快](#编译速度快)
  - [看不到源码](#看不到源码)
  - [手动操作多，容易出问题](#手动操作多容易出问题)
- [Carthage or CocoaPods如何选择合适的第三方库管理工具？](#carthage-or-cocoapods如何选择合适的第三方库管理工具)
- [参考资料](#参考资料)


# 前言

CocoaPods 是我现在每天使用的第三方依赖管理库，精通`pod install `，`pod install —repo update` ，删除 `Podfile.lock`文件等操作。

我从没觉得这有什么了不起的。直到在一次面试中字节跳动的面试官问我：CocoaPods 的原理是什么？

像我这样年轻的程序员不应该满足于完成日常开发任务，了解下 CocoaPods吧。

# CocoaPods 为什么可以管理第三方依赖？

我们拉取了一个项目后，往往要在项目目录下执行pod install ，从而将项目的第三方依赖库**下载**下来并**导入**项目中，pod install后会产生一个**`xcworkspace`**文件，我们打开这个文件，就能在 Xcode 中打开一个已经把第三方依赖库导入的项目，直接 Run 就可以了。

所以，CocoaPods 管理第三方依赖的奥秘在于`pod install`

来看下 `pod install` 的过程（执行命令`pod install --verbose`）

```PowerShell
$ pod install --verbose

 1.分析依赖
Analyzing dependencies 

Updating spec repositories
Updating spec repo `master`
  $ /usr/bin/git pull
  Already up-to-date.


Finding Podfile changes
  - AFNetworking
  - HockeySDK

Resolving dependencies of `Podfile`
Resolving dependencies for target `Pods' (iOS 6.0)
  - AFNetworking (= 1.2.1)
  - SDWebImage (= 3.2)
    - SDWebImage/Core

Comparing resolved specification to the sandbox manifest
  - AFNetworking
  - HockeySDK

2. 下载依赖
Downloading dependencies

-> Using AFNetworking (1.2.1)

-> Using HockeySDK (3.0.0)
  - Running pre install hooks
    - HockeySDK

3. 生成 Pods 项目
Generating Pods project
  - Creating Pods project
  - Adding source files to Pods project
  - Adding frameworks to Pods project
  - Adding libraries to Pods project
  - Adding resources to Pods project
  - Linking headers
  - Installing libraries
    - Installing target `Pods-AFNetworking` iOS 6.0
      - Adding Build files
      - Adding resource bundles to Pods project
      - Generating public xcconfig file at `Pods/Pods-AFNetworking.xcconfig`
      - Generating private xcconfig file at `Pods/Pods-AFNetworking-Private.xcconfig`
      - Generating prefix header at `Pods/Pods-AFNetworking-prefix.pch`
      - Generating dummy source file at `Pods/Pods-AFNetworking-dummy.m`
    - Installing target `Pods-HockeySDK` iOS 6.0
      - Adding Build files
      - Adding resource bundles to Pods project
      - Generating public xcconfig file at `Pods/Pods-HockeySDK.xcconfig`
      - Generating private xcconfig file at `Pods/Pods-HockeySDK-Private.xcconfig`
      - Generating prefix header at `Pods/Pods-HockeySDK-prefix.pch`
      - Generating dummy source file at `Pods/Pods-HockeySDK-dummy.m`
    - Installing target `Pods` iOS 6.0
      - Generating xcconfig file at `Pods/Pods.xcconfig`
      - Generating target environment header at `Pods/Pods-environment.h`
      - Generating copy resources script at `Pods/Pods-resources.sh`
      - Generating acknowledgements at `Pods/Pods-acknowledgements.plist`
      - Generating acknowledgements at `Pods/Pods-acknowledgements.markdown`
      - Generating dummy source file at `Pods/Pods-dummy.m`
  - Running post install hooks
  - Writing Xcode project file to `Pods/Pods.xcodeproj`
  - Writing Lockfile in `Podfile.lock`
  - Writing Manifest in `Pods/Manifest.lock`

4. 集成到主项目中，生成 xcworkspace 文件
Integrating client project
```

### 1. 分析依赖

首先读取 Podfile 文件，解析出是否有新增的 pod 需要 install，被删除的 pod 需要 remove。

然后读取 Podfile.lock文件（如果存在的话），确定上一次 pod install 成功的 pod 版本号。

最后是解决冲突，根据[Semantic Versioning](http://semver.org/) 里定义的原则，确定第三方依赖 pod 的版本号，如果碰到无法解决会报错，开发者需要手动指定 pod 版本号。（中文文档看这里）

> Semantic Versioning语义版本规则，定义了pod 的版本号应该怎么写：

**MAJOR.MINOR.PATCH** (主版本号.次版本号.补丁版本号)， 例如 1.12.60
如果修改了 API，做了不兼容改造，那么应该修改 MAJOR，**1**.12.60→**2**.0.0
如果做了新功能，应该修改 MINOR，1.**12**.60→1.**13**.0
如果修复了某些 bug，不影响当前功能，应该修改 PATCH，1.12.**60**→1.12.**80**

### 2. 下载依赖

拉取 pod 的源码，放到 Pods 目录下

### 3. 生成`Pods.xcodeproj`文件

> `xcodeproj` 文件是每个Xcode 项目都有的一个文件，里面记录了该项目的工程配置信息

这一步是通过**`CocoaPods/Xcodeproj`** 这个 gem 库去完成的。

由这一步我们可以得出：**CocoaPods 的原理是将所有的依赖库都放在 Pods 项目下，主项目只需要依赖 Pods 项目。这样，pod 源码管理工作就从主项目转到 Pods 项目中。**

在这一阶段，CocoaPods 还会去更新 **`Podfile.lock`** 文件、**`Manifest.lock`** 文件（该文件是 Podfile.lock 文件的副本，用于避免编译第三方库时可能出现的 crash）

### 4. 生成`xcworkspace`

> `xcworkspace` 实际上是一个文件夹，里面包含三个子目录：contents.xcworkspacedata以及两个子文件夹xcshareddata， xcuserdata。contents.xcworkspacedata里记录了当前项目有哪些 project

---

最后，点开这个 xcworksapce，就能得到一个「第三方依赖已经准备好了，编译一下就能跑」的项目

# pod install 和 pod update 的区别是什么？

区别在于**是否按照 ****`Podfile.lock`**** 来安装 pod。**

**`pod install`**会根据 **`Podfile.lock`** 中写好的版本号去拉取pod 的源代码。这样做的好处就是可以利用上一次 **`pod install`** 成功时的第三方库环境。（如果**`Podfile.lock`** 不存在，那么会进行一次依赖关系分析，确定符合条件的pod版本号，最后去拉取pod）

而 **`pod update`**会忽视**`Podfile.lock`**，根据 Podfile 文件，选择「既符合约束条件，尽可能新」的版本号，**`pod update`** 成功后会更新 **`Podfile.lock`** 文件。

当你修改了 Podfile 文件，那应该用 pod install 安装 pod
当你想更新 pod 版本，应该用 pod update，更新 pod

所以官方文档建议，将**`Podfile.lock`** 放入版本控制中，这样就能保证团队里大家都用的是同一套环境（就是各个 pod 的版本一致）。

> **`pod outdated`** ：如果Podfile.lock 中的 pod 有新版本，这条命令会将对应的新版本罗列出来。所以可以用这条命令查看已经安装的 pod 是否可以更新版本

# Podfile 中如果写死了pod版本号，是不是就可以抛弃Podfile.lock 了？

**不行**，理由是 「pod 依赖的 pod 」的版本号可能存在不一致。

假如项目现在依赖了 A 库，Podfile 中这么写：

```Ruby
pod 'A', '1.0.0'
```

但是 A 依赖了一个库 B，在 A 的 podspec 文件中是这么定义的：

```Ruby
dependency 'B', '~> 3.0'
```

那小明跑项目的时候，用的是A（1.0.0）B（3.1.1）。

但是小花跑项目的时候，就可能是A（1.0.0）B（3.2.9）。

这时环境就不一致了。

所以还是得用 `Podfile.lock` ，跑完把 `Podfile.lock` 一起提交上去，大家用的就都是同一套环境了。

# 除了 CocoaPods，还有哪些选项？

**Carthage**。如果说 CocoaPods 是一个傻瓜式的一键工具，那么 Carthage 就是更轻量级的、自定义的，更灵活的，具体优点是：

## 不侵入性

Carthage 做的工作仅仅是下载 pod 源码以及用 xcodebuild 工具把源码编译成frameworks（仅支持动态库）。需要开发者手动将对应的 framework 链接到项目中。

## 灵活性

正式因为 Carthage 的不侵入性，所以它不会像 CocoaPods 一样会影响原项目的结构。这让它**容易集成**，也**容易去除**。

## 去中心化

Carthage 没有 CocoaPods 一样的中心服务器，如果要更新环境或者配置某个 pod 时，直接更新对应 pod，不需要向中心服务器请求数据。

## 编译速度快

使用了CocoaPods的项目，清缓存后重新编译，需要把所有的第三方库编译一遍。而因为 Carthage 是已经把第三方库编译成了frameworks了，于是不需要再一次编译第三方库。

---

当然，Carthage 不是没有**缺点：**

## 看不到源码

以 framework 方法导入的第三方库在 Xcode 中只能看到头文件，而不能直接看到源代码。

## 手动操作多，容易出问题

- 需要开发者自己将编译好的xcframework文件拖进项目中，同时设置对应属性。

---

# Carthage or CocoaPods如何选择合适的第三方库管理工具？

在同一个项目中，Carthage 和 CocoaPods 不是「一山不容二虎」的关系，它们可以混用。再加上考虑CocoaPods 对项目的侵入性，一种显而易见的策略是：

先使用 Carthage，当发现Carthage 无法满足需求时（比如需要查看源码，或者这个第三方库只支持 CocoaPods），再使用 CocoaPods。

---

# 参考资料

- [iOS-CocoaPods的原理及Podfile.lock问题](https://www.codetd.com/article/13754374#:~:text=CocoaPods 的原理是将所有的依赖库都放到另一个名为Pods的项目中，然而让主项目依赖Pods项目， 这样，源码管理工作任务从主项目移到了Pods项目中。,1. Pods项目最终会编译成一个名为libPods.a的文件, 主项目只要依赖这个.a文件即可)
- [CocoaPods Under The Hood](https://www.objc.io/issues/6-build-tools/cocoapods-under-the-hood/)
- [Semantic Versioning 2.0.0](https://semver.org/)， [中文翻译](https://www.jianshu.com/p/e2619a7aa60e)
- 你们是如何使用 cocoapods 的？
  - 用了以下参数:
    - bin:是否使用二进制产物（从而避免 Xcode 的预编译对 pod 造成影响）。[参考](https://medium.com/@gaojiji/加快-cocoapods-项目编译时间-pod-预编译的傻瓜式解决方案-6b791daf192d)
    - configurations:如果复制为["debug"]，那么该 pod 只会在 debug 编译模式下被引入。[参考](https://easeapi.com/blog/blog/126-podspec-configurations.html)
    - modular_headers:对应的 pod 能用「@import pod」的语法导入。[参考](https://www.jianshu.com/p/cdb24bfeb17c)
    - enable:
    - inhibit_warnings: 消除引入第三方库（非 Cocoapods 官方收录的库）时产生的警告
    - git: 指定远程 repo 地址
    - path：指定本地 pod 地址

