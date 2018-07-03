---
title: vue源代码学习-vue-router
tags:
  - vue
categories:
  - 前端
date: 2018-06-23 11:18:46
---


Vue router是Vue官方的路由管理器，帮助用户构建单页面应用。作为Vue生态系统的重要组成成员，还是值得了解一下的，下面就来看看它的内部实现吧。

<!--more-->

## 准备工作

当然是clone一份源代码到本地来了, 我们在这里选用2.7版本:

```bash
git clone --branch v2.7.0 https://github.com/vuejs/vue-router.git
cd vue-router
npm i
```

vue-router的example目录已经配置好了调试源代码所需的一切，我们直接执行`npm run dev`来开始吧！

## 单页面应用

构建单页面应用的框架需要做些什么呢？自己曾经也写过单页面框架，简单总结可以如下:

1. 加载路由数据(包括路由名称, 页面资源对应的html、js等)
2. 页面切换(移除旧页面，加载新页面，过度动画)
3. 页面切换中的全生命周期的管理(各种钩子)

当然,vue-router提供了远不止以上所提到的东东。

## 插件

vue-router是一个vue插件，所以我们肯定要看看`VueRouter.install`做了什么, 源代码在src/install.js中, 主要部分如下:

```javascript
Vue.mixin({ // 全局mixin
    beforeCreate () {
      if (isDef(this.$options.router)) { // 有router, 则是根节点
        this._routerRoot = this // 根节点vue对象
        this._router = this.$options.router
        this._router.init(this) // 初始化router, 展示第一个页面
        // 在router-view、router-link render时，其dep加入render watcher, 形成依赖关系
        // 换句话说，改变根节点的_route指向新的route, 将引发重新render
        Vue.util.defineReactive(this, '_route', this._router.history.current)         
      } else {
        this._routerRoot = (this.$parent && this.$parent._routerRoot) || this
      }
      registerInstance(this, this) // matched添加vue instance
    },
    destroyed () {
      registerInstance(this) 
    }
  })

  Object.defineProperty(Vue.prototype, '$router', { // 所有vue对象都可以访问到$router
    get () { return this._routerRoot._router }
  })

  Object.defineProperty(Vue.prototype, '$route', { // 所有vue对象都可以访问到当前$route
    get () { return this._routerRoot._route }
  })

  Vue.component('router-view', View) // vue-router提供的两个组件
  Vue.component('router-link', Link)

```
install中主要做了下面这些事:

1. 初始化router
2. 定义响应式属性`_route`
3. 为vue实例定义`$router`、`$route`等访问属性
4. 定义`router-view`, `router-link`两个组件

注意`$route`实际访问的也是根实例的`_route`，所以在`router-view`, `router-link`两个组件的render函数中出现了对`$route`的访问，会触发依赖收集。所以，`vue-router`在完全一次路由导航后，会更新`_route`属性，以此触发视图更新。



## 路由模式

Vue-router提供了三种模式：abstract、hash、html5。在实现上，它们分别继承自History类，可以用下副图表示：

{% asset_img 1.png %}

1. History
  
  作为基类，跳转页面的主要逻辑处理在这个类完成。由于不同模式对URL的处理，以及支持的功能不尽相同，History暴露了一些方法由子类来实现。
  
2. HashHistory
  
  `hash`模式，URL里会带一个#号，这种模式能支持你直接在URL里直接输入页面地址而不会重新加载。Hash模式的replace通过`location.replace`方法来实现, 这样也可以实现替换浏览器的历史记录。
  
3. HTML5History

  `history`模式，利用H5的pushState、replaceState来改变URL，同时改变浏览器的历史记录。URL直观来看就是会少一个`#`。H5模式特殊之处是提供了页面滚动行为的支持，当发生popstate事件时，可以让应用自由的根据之前访问的滚动位置来重新决定滚动行为。虽然我也不是很明白为什么只在H5模式提供滚动支持...
  
4. AbstractHistory

  `abstract`模式，是用于非browser环境的，或者也可以用于nested router的场景。这种模式不会呈现路由对应的URL，也根本不会用到window.history对象，其内部自己维护了一个stack来储存访问的路由页面。


## 路由匹配

`vue-router`使用[path-to-regexp](https://github.com/pillarjs/path-to-regexp)来支持动态路由匹配。比如默认情况下:

* path: `/parent`会转为正则`/^\/parent(?:\/(?=$))?$/i` 
* path: `/parent/qux/:quxId`会转为正则`/^\/parent\/qux\/((?:[^\/]+?))(?:\/(?=$))?$/i`

所以，当URL改变时，会将所有的路由拿出来依次匹配得出所有匹配的结果`matched`数组。有时候，同一个路径可以匹配多个路由，此时，匹配的优先级就按照路由的定义顺序：谁先定义的，谁的优先级就最高; 当然，如果有`router-view`嵌套的情况，会根据深度来访问匹配的路由`matched`。

## 内置组件

`Vue-router`提供了两个组件

### router-link

`router-link`支持用户在具有路由功能的应用中实现导航。具体代码可以看src/components/link.js。`router-link`可以让应用只关注相对路径，并且针对h5 history模式会自动阻止页面重加载。

### router-view

`router-view`用来渲染匹配的路由视图组件，它还可以嵌套自身，根据匹配的深度来渲染match的路由。`router-view`源代码如下(已添加注释)：

```javascript

export default {
  name: 'router-view',
  functional: true,
  props: {
    name: {
      type: String,
      default: 'default'
    }
  },
  render (_, { props, children, parent, data }) { // 函数式组件没有this, 所以把需要的参数直接显示的写出来
    data.routerView = true

    // directly use parent context's createElement() function
    // so that components rendered by router-view can resolve named slots
    const h = parent.$createElement
    const name = props.name
    const route = parent.$route // 触发依赖收集
    const cache = parent._routerViewCache || (parent._routerViewCache = {})

    // determine current view depth, also check to see if the tree
    // has been toggled inactive but kept-alive.
    let depth = 0
    let inactive = false
    while (parent && parent._routerRoot !== parent) { // 判断_routerRoot是因为可能有嵌套的router(看例子nested-router)
      if (parent.$vnode && parent.$vnode.data.routerView) {
        depth++
      }
      if (parent._inactive) {
        inactive = true
      }
      parent = parent.$parent
    }
    data.routerViewDepth = depth

    // render previous view if the tree is inactive and kept-alive
    if (inactive) { // 包裹于keep-alive的情况
      return h(cache[name], data, children)
    }

    const matched = route.matched[depth] // 根据深度来获取匹配的路由
    // render empty node if no matched route
    if (!matched) { // 没有匹配的返回空节点
      cache[name] = null
      return h()
    }

    const component = cache[name] = matched.components[name]

    // attach instance registration hook
    // this will be called in the instance's injected lifecycle hooks
    data.registerRouteInstance = (vm, val) => { // 对应src/install里全局mixin，在beforeCreate和destroy时调用
      // val could be undefined for unregistration
      const current = matched.instances[name]
      if (
        (val && current !== vm) || // beforecreate时, 若router-view不一致
        (!val && current === vm) // destroy时, 若router-view一致
      ) {
        matched.instances[name] = val // 更新
      }
    }

    // also regiseter instance in prepatch hook
    // in case the same component instance is reused across different routes
    ;(data.hook || (data.hook = {})).prepatch = (_, vnode) => { // 在创建component的时候，vue会自动添加prepatch钩子，所以这个钩子会被覆盖啊，不理解了
      matched.instances[name] = vnode.componentInstance
    }

    // resolve props
    data.props = resolveProps(route, matched.props && matched.props[name]) // 利用props来解耦

    return h(component, data, children) // 返回vnode节点
  }
}

```

`router-view`主要做了以下一些功能支持：

1. 通过_routerRoot字段(src/install.js), 支持nested router
2. 通过_inactive字段(定义于vue中), 支持了keep-alive
3. 嵌套路由(nested route)会匹配多个路由，通过depth来决定当前`router-view`渲染哪个路由
4. 支持了利用props来解耦，不必在`router-view`子组件里使用`$route.params.fieldName`来获取传参数据

## 路由的导航流程

  下面我们跟着源码来一步一步解析导航的整个流程：
  
1. 调用`router.push(location)`(当然也可能是别的方式)， 触发路由导航
2. 获取匹配的路由`route`
3. 根据当前匹配路由current.matched, 新匹配路由route.matched，获得如下三个数组:
  * deactivated 要移除的视图组件
  * updated 要更新的视图组件
  * actived 要新增的视图组件
  
  $注意，这些数组并不一定都有值$
  
4. 将一系列钩子放入数组，等待顺序执行: 

```javascript
const queue: Array<?NavigationGuard> = [].concat( // route更新周期的各个钩子，按照顺序排排坐
      // in-component leave guards
      extractLeaveGuards(deactivated), // 页面组件的beforeRouteLeave
      // global before hooks
      this.router.beforeHooks, // router的全局beforeEach
      // in-component update hooks
      extractUpdateHooks(updated), // 页面组件的beforeRouteUpdate
      // in-config enter guards
      activated.map(m => m.beforeEnter), // 路由本身的beforeEnter钩子
      // async components
      resolveAsyncComponents(activated) // 万一activated里有异步组件, 则需要获取成功再next
    )
```

5. 执行完上述queue之后(假设都成功)，将开始准备执行激活组件的beforeRouteEnter, 全局的beforeResolve钩子:

  * 针对执行beforeRouteEnter钩子，本来在此时，新的视图组件还并没有生成，所以不能通过this直接获取组件实例。但是`Vue-router`提供了通过函数来获取的方式如：
  
  ```javascript
    beforeRouteEnter (to, from, next) {
      next(vm => {
        // 通过 `vm` 访问组件实例
      })
    }
  ```
  
  * `Vue-router`又是如何获取到实例的呢? 记得我们在查看`router-view`的代码和`install.js`代码时，`vue-router`通过`beforeCreate`钩子为匹配的路由定义了`route.instances`数组，这个数组就用到储存对应的命名视图的组件实例。所以`Vue-router`在`Vue.$nextTick`中，再执行用户定义的函数，这样就可以获取到组件实例`vm`了。
  
  * 除此之外，这里还有一个有意思的地方。还记得之前提到`transition`的`out-in`模式吧，这种模式会先将旧组件彻底移除后（动画结束），再采用`$forceUpdate`的方式加入新的组件。这样带来一个问题就是，在第一次的`$nextTick`中`vue-router`还是无法为用户提供`vm`实例，所以`vue-router`这里粗暴的采用了循环检测的方式，等`route.instances`数组中有了对应的实例值后，再调用用户的钩子函数提供`vm`。

6. 以上都成功后(注意beforeRouteEnter若用户传入函数，则不影响导航的确认), 导航就被确认。
7. 更新路由, 修改路由所属`vue根实例`的`_route`值，准备触发DOM视图更新(无论是micro task或macro task，异步更新)
8. 在DOM视图更新前，触发`afterEach`钩子
9. DOM视图更新
10. 用创建好的实例传给`beforeRouteEnter`钩子中`next`的回调函数(第5步中)

## 总结

在看源码的时候，等于是又复习了一下hash和h5 history的知识，也明白了`vue-router`的原理。清楚了整个导航流程，以后使用中碰到问题也能结合起来快速定位了。最后，附上添加了注释的源代码，水平有限难免理解有误。

[点击下载](/Blog/download/vue-router-src.zip)

Over~