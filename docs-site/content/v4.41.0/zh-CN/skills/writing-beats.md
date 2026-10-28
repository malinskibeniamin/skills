---
title: /writing-beats
description: 根据原始素材，按照用户选择的转折逐拍构建文章。
type: skill
sidebar:
  label: /writing-beats
---
![/writing-beats 技能示意图](/diagrams/skills/writing-beats.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/writing-beats.excalidraw)

输入：Markdown 原始素材。如果缺少输出路径，询问一次。

## 循环

1. 根据原始素材提供 2–3 个候选起始节拍。由用户选择。
2. 只将该节拍写入文章文件。
3. 从磁盘重新读取文章。
4. 提供 2–3 个后续候选节拍。
5. 重复以上步骤，直到自然结束。

## 节拍

叙事进程中的一个推进动作：场景、观点、问题、插叙或转折。长度按需而定。如果需要多个章节，则进行拆分。

## 规则

- 每次追加一个节拍。切勿提前写后续内容。
- 保留用户的编辑：每次写入前都重新读取。
- 可以不使用剩余的原始素材。
- 如果用户要求重写、返回或删减，只编辑指定的节拍，其余内容保持不变。
