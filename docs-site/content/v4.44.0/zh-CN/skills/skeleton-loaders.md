---
description: "为异步内容、等待中的路由和流光占位元素构建骨架加载状态。用于匹配加载后的布局，或防止数据获取期间的布局偏移。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["skeleton loaders"]}
sidebar: {"label":"/skeleton-loaders"}
title: "/skeleton-loaders"
type: "skill"
---
![/skeleton-loaders 技能示意图](/diagrams/skills/skeleton-loaders.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/skeleton-loaders.excalidraw)

## 匹配内容

将以下代码片段视为模板。检查实际组件和已安装的样式工具，
根据仓库调整导入、设计令牌、翻译和文件路径。

1. 在兼容的情况下复用现有骨架组件和加载约定。
2. 复制加载后布局的容器、间距、断点、边框和排版。
   保持相同的元素类型、行高、字号、字重、换行和截断行为。
3. 静态标签的透明文本元素使用相同的 `t()` 值。对于未知的运行时数据，
   使用有代表性的占位文本和合理的行数。排版可匹配已知几何尺寸，
   但未知文本的宽度和换行仍是近似值。除非加载后的布局另有尺寸约束，块元素仍填满容器。
4. 按图片、图标和头像的实际尺寸或宽高比预留空间。
   显式尺寸应用于这些非文本区域，而不是猜测的文本 `h-*` / `w-*` 矩形。

## 只定义一次流光动画

先复用已有动画，再考虑新增。对于 **Tailwind v4**，找到负责主题的样式表，
将缺少的令牌和关键帧添加到已有的 `@theme` 块中：

```css
@theme {
  --animate-shimmer: shimmer 2s linear infinite;
  @keyframes shimmer {
    from { background-position: 100% 0; }
    to { background-position: -100% 0; }
  }
}
```

`animate-shimmer` 是自定义类，并非内置类。其他版本使用项目自身的动画配置；
检查生成的 CSS 和类名检查结果。用户选择减少动态效果时保留静态的柔和背景。
在组件内共享类名字符串：

```tsx
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

const shimmer =
  "motion-safe:animate-shimmer rounded-sm bg-muted bg-linear-to-r from-muted via-accent to-muted bg-size-[200%_100%] text-transparent select-none";

export function ProfileSkeleton({ heading, actionLabel }: {
  heading: string;
  actionLabel: string;
}) {
  return (
    <div aria-hidden="true" className="border border-border bg-card p-3">
      <h2 className={cn("text-lg font-bold", shimmer)}>{heading}</h2>
      <div className="flex items-center gap-3">
        <div className={cn("size-14 shrink-0", shimmer)} />
        <div className="min-w-0 flex-1">
          <p className={cn("truncate text-sm font-semibold", shimmer)}>Name</p>
          <p className={cn("truncate text-xs", shimmer)}>Example value</p>
        </div>
      </div>
      <Button disabled type="button" className={cn("w-full", shimmer)}>
        {actionLabel}
      </Button>
    </div>
  );
}
```

传入实际组件已翻译的标题和操作标签。匹配实际 Button 的变体、尺寸和类名，
移除覆盖透明文字的前景色工具类。占位控件应禁用，不绑定事件处理器或导航目标；
仅设置 `tabIndex={-1}` 无法阻止激活。对辅助技术隐藏骨架根元素。
在持续存在的内容区域上，等待时设置 `aria-busy`，成功或失败后清除。
若要播报加载状态，在隐藏或忙碌子树之外放置一个本地化的 `role="status"`，避免播报被抑制。

## 延迟显示而不引起布局偏移

优先使用路由或查询已有的等待延迟机制。约 **200 ms** 是起点，而非强制等待时间：
有数据时立即显示，后台刷新时保留旧内容。没有内容时，在整个延迟期间预留加载后区域的
几何空间，不要直接返回未预留空间的 `null` 导致区域塌陷。

若需要本地计时器，仅针对该次等待操作挂载延迟组件；使用具名 Effect，卸载时清除计时器。
每次新操作都重新挂载或重置，包括仍在等待时请求标识发生变化的情况。
完成、取消或失败时取消待显示的骨架；显示错误或空状态，避免无限加载。

## 验证切换

在相同视口、字体、语言和主题下比较加载中和加载后的视图，包括长文本和窄布局。
检查延迟及切换期间的区域边界；只对实际比较过的几何尺寸声明像素级匹配。
测试快速和慢速加载、重复导航、取消或卸载、后台刷新、空状态或错误后的恢复、
键盘焦点和减少动态效果。延迟测试使用模拟计时器，不使用真实等待。

语法细节参见 [Tailwind 动画](https://tailwindcss.com/docs/animation)。
计时器清理参见 [React Effects](https://react.dev/reference/react/useEffect)。
加载语义参见 [ARIA busy](https://www.w3.org/TR/wai-aria-1.2/#aria-busy)。
