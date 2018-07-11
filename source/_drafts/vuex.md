---
title: vue源代码学习-vuex
tags:
  - flux
  - vue
categories:
  - 前端
---

Vuex 是一个专为 Vue.js 应用程序开发的状态管理模式。它采用集中式存储(单一状态树)管理应用的所有组件的状态，并且严格的规定了状态的变更方式，使得这些变化可追踪、可调试。

## 准备工作

和之前一毛一样，我们先拷贝最新的v3.0.0 tag版本工程到本地吧~

```bash
git clone --branch v3.0.0 https://github.com/vuejs/vuex.git
cd vuex
npm i
npm run dev
```
一切准备就绪, go~

## 核心概念[^1]

在Vue的开发模式中, 数据是单向传递的(这里不是指父子组件), 包含以下几个部分:

* state，驱动应用的数据源；
* view，以声明方式将 state 映射到视图；
* actions，响应在 view 上的用户输入导致的状态变化。

示意图如下: 

{% asset_img flow.png %}

但是以下一些情况就很难处理了, 或者说不能优雅的处理：

* 多个视图依赖同一个状态
* 不同视图需要变更同一个状态

所以，为了解决这个问题，Vuex应运而生。借鉴了如Flux、Redux的思想，Vuex把共享的状态抽取出来，以一个全局的单例模式管理，通过定义和隔离状态管理中的各种概念并且强制遵循一定的规则，使得代码更结构化和易于维护。

Vuex的核心概念如下:

* $Store$ 每一个Vuex对象就是一个store(仓库), 可以理解为一个容器，里面包含了一切数据状态、改变数据的API、子仓库等
* $State$ 顾名思义, State就是状态，它是一个Vuex仓库的状态数据源，储存的数据是响应式的
* $Getter$ Getter可以理解为一个vuex仓库的计算属性, 它同vue的computed一样，只有依赖的值改变时才会重新计算值
* $Mutation$ 修改state状态的唯一方法就是提交mutation，这样看起来mutation很像一个事件。这样的好处是代码更结构化易于维护，并且可以配合插件(devtool)进行调试，保存各个状态下的状态快照。Mutation必须是同步的
* $Action$ Action通过提交Mutation来改变state，同mutation的区别是它可以包含任意的异步操作。
* $Module$ Vuex允许将store切割为模块，自上而下的进行切割，可以嵌套子模块、模块复用等。

使用Mutation来同步改变state状态，action中包裹异步情况再调用mutation，在我看来，Vuex这样分层设计是为了代码逻辑更为清晰和易于维护，同时也兼顾了强大的调试功能。

{% asset_img vuex.png%}

在官网的图示上，做了一点修改，主要是增加了一块从vue对象到mutations的调用连线。下面的内容，我们将逐步学习这个图中每一个节点和节点之间是如何工作的。

## 初始化Store

Store其实就是一个vuex的实例, 它的初始化主要做如下一些工作：

1. 注册当前module(若首次则为root module, 可能为空对象`{}`)
2. 生成这个模块的局部上下文context(包含自身模块的state等)
3. 为当前module注册mutation、action、getter到store中, 回调对应的参数就包含了局部context和全局store或它们的属性
4. 递归的将子模块依次重新完成1-3步骤
5. 创建内部的vue对象，以此将state转化为响应式对象，并且将getters转化为计算属性computed
6. 根据配置，决定是否启用严格模式、加载自定义插件、开启vue Devtools



经过以上步骤，一个vuex对象就初始化完毕了，看起来很简单是不是。确实如此，依托了vue自身的功能，vuex很轻松优雅的就实现了响应式的数据仓库，并且建立了一套有效的调试机制。

## 局部上下文

为什么要有局部上下文？其实这是vuex为了实现模块划分引入的，局部上下文和全局store的区别如下:

| 属性 | local context | store | 
| :---: | :---: | :---: | 
| state | 子模块自身的state | 根模块state, 子模块的state作为它的属性, 如: `$store._modules.root._children["cart"].state == $store.state.cart`|
| getters | 


## Getters



## 调试功能


[^1]: 摘自vuex官网: https://vuex.vuejs.org/zh/