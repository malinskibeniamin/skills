---
title: /wayfinder
description: 透過議題追蹤器中的決策票券，規劃跨多個工作階段的工作。
type: skill
sidebar:
  label: /wayfinder
---
![／wayfinder 技能示意圖](/diagrams/skills/wayfinder.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/wayfinder.excalidraw)

當目標過於龐大，無法在單一上下文視窗內完成，而且通往**目的地**的路徑仍不明朗時使用。Wayfinder 透過**決策票券**找出路線——這些問題的解答是一項決策，而不是要執行的建置工作切片。目的地可能是規格、決策，或路徑尚不明確的變更。

## 規劃，不要執行
Wayfinder 僅用於規劃。每張票券都會解決一項決策；當有人著手執行工作之前已沒有任何事情需要決定時，地圖便告完成。想要開始執行的衝動，表示已經抵達地圖的邊界。請將規劃偏好與決策支援工作保留在 Notes 中；Notes 不代表已授權實作或交付。

## 不變條件
- 請以**名稱**（標題）指稱地圖和票券，不要只使用 id 或 slug。需要時請為名稱加上連結。
- 地圖是**索引**，不是儲存區：決策存放在其票券中；地圖只保留一行摘要與指標。
- 若有 `CLAUDE.md`，請先閱讀；否則閱讀 `AGENTS.md`。依循該檔案中的 **Issue tracker** 指標，接著閱讀 **Wayfinding operations**。絕不可假設文件路徑。若這兩個檔案或指標都不存在，請使用本機 Markdown 備援方案。
- 開始工作前，先將票券指派給主導開發人員以認領票券；這必須是該工作階段的第一次寫入。開啟且未指派表示尚未認領。
- 若追蹤器提供原生的阻擋／相依性功能，請使用該功能；只有在原生阻擋功能不可用時，才改用明確的 `Blocked by:` 行。
- 在主要上下文中，每個工作階段最多解決一張票券。明確委派或
  `/swarm` 可授權平行處理已就緒的研究票券；僅叫用 wayfinder 並不會授予此權限。
- 對於已授權平行處理的地圖，請在每波票券之間套用 `/efficient-frontier`，
  並由協調者負責彙整。
- 在信任地圖之前，若要稽核其他工作階段已解決的票券、認領狀態、分支或前沿摘要，請使用 `/agent-watchdog`。

## 地圖結構
地圖是一個標有 `wayfinder:map` 標籤／記號的議題或檔案。

```markdown
## Destination
<what reaching the end of this map looks like -- the spec, decision, or change this effort is finding its way to>
## Notes
<domain; skills every session should consult; standing planning preferences for this effort>
## Decisions so far
- [<closed ticket title>](link) -- <one-line gist of the answer>
## Not yet specified
<in-scope future questions or risks not sharp enough to ticket yet>
## Out of scope
<work ruled beyond this destination>
```

開啟中的票券不會列在地圖本文中；請查詢議題追蹤器中的開啟中子項目／前沿票券。

## 票券
每張決策票券都是一個子議題／檔案，其中包含一個聚焦的問題，規模應適合由代理程式在單一 100K token 工作階段內處理：

```markdown
## Question

<the decision or investigation this ticket resolves>
```

每張票券不是 **HITL**，就是 **AFK**。HITL 代表人類參與迴圈，需與能代表自己發言的人類共同處理；AFK 則由代理程式獨自推動。HITL 票券只能透過即時交流解決；代理程式不得自行回答自己的深度提問。

票券類型：

- **研究**（AFK）：在主要上下文中透過
  `/research` 閱讀文件、API、規格、原始碼或其他第一手來源。連結至包含引用資料的 Markdown 摘要。只有在明確委派或使用 `/swarm` 後，
  才能使用研究工作線。
- **原型**（HITL）：製作便於回應的低成本產出，包括 `/prototype` UI 或邏輯程式碼。連結至該產出。
- **深度提問**（HITL）：對話。務必叫用 `/grilling` 和 `/domain-modeling`。當問題主要取決於判斷時，預設使用此類型。
- **任務**（HITL 或 AFK）：決策能繼續進行前所需的手動工作。在安全的情況下進行自動化；否則提供人類一份檢查清單。它之所以值得存在，是因為能解除決策阻礙，而不是因為能交付目的地。

答案不屬於本文的一部分。請在解決票券時記錄答案。資產應以連結方式提供，不要直接貼上。

## 戰爭迷霧
不要描繪目前還看不見的事物。**Not yet specified** 用於記錄疑似在範圍內、但還不夠明確而無法指派的問題或風險。票券則用於明確的問題，即使該問題受到阻擋。Not yet specified 不應包含已經決定、已有票券，或超出範圍的事項。

## 超出範圍

迷霧只會朝目的地聚集。超出目的地的工作屬於 **Out of scope**：它不是迷霧，除非重新界定目的地，否則永遠不會演變成票券。若發現某張票券位於目的地之外，請將其關閉，在 Out of scope 中加入一行並說明原因，且不要將它記錄為路線決策。

## 繪製地圖

1. 為 Destination 命名。執行 `/grilling` 和 `/domain-modeling`，確立這張地圖要通往的目標。
2. 描繪前沿。以廣度優先方式深入詢問整個空間，找出尚未解決的決策與初始步驟。**若這個過程沒有揭露任何迷霧**，就不需要地圖；請停止並詢問使用者接下來要如何進行。
3. 建立地圖，包含 Destination、Notes、空白的 Decisions so far、Not yet specified 和 Out of scope。
4. 只建立目前能明確描述的票券。若追蹤器支援原生子項目／子議題關係，請透過該關係附加每張票券；只有在原生階層功能不可用時，才使用本文或工作清單連結。重新閱讀地圖並確認每張票券都顯示為子項目，接著在第二輪設定阻擋關係。
5. 在主要上下文中直接解決一張已就緒的 AFK Research 票券。若使用者已明確
   授權委派或叫用 `/swarm`，請啟動彼此不同且已就緒的研究工作線；每條工作線
   都應先認領其票券、依循 `/research` 指定的產出位置，且不得擅自建立根目錄
   檔案或分支。
6. 完成那一張已就緒的研究票券後便停止；不要在此工作階段解決其他票券。

## 依循地圖工作

1. 以低解析度載入地圖；不要載入每張票券的本文。
2. 選擇票券：使用指定名稱的票券，或選擇第一張開啟中、未受阻擋、尚未認領的前沿票券。先認領它。
3. 解決票券，只在需要時深入查看相關／已關閉的票券。叫用 Notes 中指定的技能；不確定時，使用 `/grilling` 和 `/domain-modeling`。
4. 將答案記錄為解決留言或答案區段，關閉／解決票券，接著在 Decisions so far 附加上下文指標。
5. 加入新浮現的票券與阻擋關係；清除已演變為票券的 Not yet specified 項目，讓每項事實只存在於一個位置。若票券位於 Destination 之外，請將它判定為 Out of scope，而不是將它當作路線上的項目解決。

其他工作階段可能會同時編輯追蹤器；寫入前請先讀取追蹤器的目前狀態。

## 交接

地圖清晰後，將它交給 `/to-spec`，把相互連結的決策整合為一份可實作的計畫，再交給 `/to-tickets`。只有在確認工作確實很小時，才略過這個整合步驟。

先重新檢查你的主張。顯示前沿之前，請重新閱讀解決答案、Decisions-so-far 摘要、連結的資產和追蹤器狀態。在要求人類處理後續票券前，先修正任何過時或缺乏依據的主張。

最後提供可直接複製貼上的後續步驟：針對下一張建議票券提供一個命令；若可安全地使用平行工作階段，則針對每張開啟中、未受阻擋、尚未認領的前沿票券各提供一個固定命令。
