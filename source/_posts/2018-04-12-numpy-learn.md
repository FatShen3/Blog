---
title: numpy-学习记录
tags:
  - python
  - numpy
categories:
  - 机器学习
date: 2018-04-12 09:56:51
---


初学numpy, 有些方法感觉确实值得记录，所以这篇应该会时不时更新，作为一个方便备查的文章。

<!--more-->

## numpy基本概念

numpy的主要对象ndarray, 是一个同类型元素的多维数组(homogeneous multidimensional array)。在numpy中, dimensions(维度)也称为axes(轴)。

* 举个栗子: 

  [1,2]这个数组只有一个axis，这个axis有两个元素，所以我们说这个axis长度为2.
  
* 再举个栗子:

  [[1,2,3],[4,5,6]]这个数组，它有两个axes，第一个axis的长度为2，第二个axis的长度为3，我们可以理解其为一个2 * 3的数组。
  
接着上面的说，ndarray还有一个重要的属性也就是shape, 是一个表明数组在各个dimension上长度的元组。比如上面两个栗子中，其shape分别为(2,)和(3,2)

## [numpy.meshgrid](https://docs.scipy.org/doc/numpy/reference/generated/numpy.meshgrid.html#numpy.meshgrid)

我的理解是,meshgrid函数就是将参数中的n个1-D array,转变为n-D 坐标矩阵。看下例子：

```python
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 1, 3) # x = [0, 0,5, 1]
y = np.linspace(0, 1, 2) # y = [0, 1]

X, Y = np.meshgrid(x, y) 
'''
X = [[0.  0.5 1. ]
 [0.  0.5 1. ]]
Y = [[0. 0. 0.]
 [1. 1. 1.]]
'''
plt.plot(X, Y, marker='.', color='blue', linestyle='none')
plt.show()
```
结果如图: 

{% asset_img meshgrid.png %}

以上只是两个数组的结果非常直观。但是针对n个数组，感觉就比较抽象了。参看了官网的定义，我的理解是，对于长度为Ni = len（xi）输入数组x1，x2，...，xn，返回n个shape(N2，N1，N3 ，... Nn)的ndarray数组, 若indexing参数为'ij'则返回(N1, N2，N3 ，... Nn)，然后xi对应的元素在各自所在的axis重复(x1和x2取决于参数indexing)。其实呢，就可以理解为，将所有的n个array,可以组成N1 * N2 * .... * Nn个坐标点(当然很可能已经超越了3维的范畴)，但是返回的n个ndarray, 则是对应的只保留xi的数据，他们组合起来其实就是这些坐标点。看下图:

{% asset_img meshgrid-example.png %}

对于参数sparse=True的情况，其实就是把非xi所属axis的重复数据清理，但是保留shape，这样也可以方便的还原。如下图:

{% asset_img meshgrid-example-2.png %}