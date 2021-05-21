<!--
 * @Author: tangdaoyong
 * @Date: 2021-05-21 10:23:08
 * @LastEditors: tangdaoyong
 * @LastEditTime: 2021-05-21 10:29:56
 * @Description: swift packages manager
-->
# swift packages manager

`iOS`中的包管理方式有三种`CocoaPods`、`Carthage`、`SPM`，对比如下：

| | CocoaPods | Carthage | SPM |
| - | - | - | - |
| 原理 | Cocoapods会将所有的依赖库都放到另一个名为Pods的项目中，然后让主项目依赖Pods项目 | 自动将第三方框架编程为Dynamic framework(动态库) | Swift构建系统集成在一起，可以自动执行依赖项的下载，编译和链接过程 |
| 适用语言 | swift OC | swift OC | swift |
| 是否兼容 | 兼容Carthage，SPM | 兼容 CocoaPods，SPM | 兼容 CocoaPods，Carthage |
| 支持库数量 | 多，基本大部分都支持 | 大部分支持，但少于CocoaPods | 大部分支持，但少于CocoaPods |
| 使用、配置复杂度 | 中 | 高 | 低 |
| 项目入侵性 | 严重入侵 | 没有侵入性 | 没有侵入性 |
| 项目编译速度 | 慢 | 快 | 慢 |
| 源码可见 | 可见 | 不可见 | 可见 |

`swift`以后是趋势，`SPM`应该也是。`SPM`之于`swift`类似于，`npm`之于`node`