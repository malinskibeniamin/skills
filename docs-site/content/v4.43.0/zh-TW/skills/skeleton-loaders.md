---
description: "為非同步內容、等待中的路由和流光佔位元素建立骨架載入狀態。用於匹配載入後的版面，或避免資料擷取期間的版面位移。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["skeleton loaders"]}
sidebar: {"label":"/skeleton-loaders"}
title: "/skeleton-loaders"
type: "skill"
---
![/skeleton-loaders 技能示意圖](/diagrams/skills/skeleton-loaders.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/skeleton-loaders.excalidraw)

## 匹配內容

將以下程式碼片段視為範本。檢查實際元件和已安裝的樣式工具，
依儲存庫調整匯入、設計權杖、翻譯和檔案路徑。

1. 在相容的情況下沿用現有骨架元件和載入慣例。
2. 複製載入後版面的容器、間距、斷點、邊框和文字排版。
   保持相同的元素類型、行高、字級、字重、換行和截斷行為。
3. 靜態標籤的透明文字元素使用相同的 `t()` 值。對於未知的執行階段資料，
   使用具代表性的佔位文字和合理的行數。排版可匹配已知的幾何尺寸，
   但未知文字的寬度和換行仍是近似值。除非載入後的版面另有尺寸限制，區塊元素仍填滿容器。
4. 依圖片、圖示和頭像的實際尺寸或長寬比預留空間。
   明確尺寸應用於這些非文字區域，而非猜測的文字 `h-*` / `w-*` 矩形。

## 流光動畫只定義一次

先沿用既有動畫，再考慮新增。對於 **Tailwind v4**，找到負責佈景主題的樣式表，
將缺少的權杖和關鍵影格加入既有的 `@theme` 區塊：

```css
@theme {
  --animate-shimmer: shimmer 2s linear infinite;
  @keyframes shimmer {
    from { background-position: 100% 0; }
    to { background-position: -100% 0; }
  }
}
```

`animate-shimmer` 是自訂類別，並非內建類別。其他版本使用專案本身的動畫設定；
檢查產生的 CSS 和類別名稱檢查結果。使用者選擇減少動態效果時，保留靜態的柔和背景。
在元件內共用類別字串：

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

傳入實際元件已翻譯的標題和操作標籤。匹配實際 Button 的變體、尺寸和類別，
移除覆蓋透明文字的前景色工具類別。佔位控制項應停用，不綁定事件處理函式或導覽目標；
僅設定 `tabIndex={-1}` 無法阻止啟動。對輔助科技隱藏骨架根元素。
在持續存在的內容區域上，等待時設定 `aria-busy`，成功或失敗後清除。
若要播報載入狀態，在隱藏或忙碌子樹之外放置一個在地化的 `role="status"`，避免播報被抑制。

## 延遲顯示而不造成版面位移

優先使用路由或查詢既有的等待延遲機制。約 **200 ms** 是起點，而非強制等待時間：
有資料時立即顯示，背景重新整理時保留舊內容。沒有內容時，在整個延遲期間預留載入後區域的
幾何空間，不要直接傳回未預留空間的 `null`，導致區域塌陷。

若需要本機計時器，只針對該次等待操作掛載延遲元件；使用具名 Effect，卸載時清除計時器。
每次新操作都重新掛載或重設，包括仍在等待時請求識別發生變更的情況。
完成、取消或失敗時取消待顯示的骨架；顯示錯誤或空狀態，避免無限載入。

## 驗證切換

在相同檢視區、字型、語系和佈景主題下，比較載入中和載入後的畫面，包括長文字和窄版面。
檢查延遲及切換期間的區域邊界；只對實際比較過的幾何尺寸宣稱像素級匹配。
測試快速和慢速載入、重複導覽、取消或卸載、背景重新整理、空狀態或錯誤後的復原、
鍵盤焦點和減少動態效果。延遲測試使用模擬計時器，不使用實際等待。

語法細節請參閱 [Tailwind 動畫](https://tailwindcss.com/docs/animation)。
計時器清理請參閱 [React Effects](https://react.dev/reference/react/useEffect)。
載入語義請參閱 [ARIA busy](https://www.w3.org/TR/wai-aria-1.2/#aria-busy)。
