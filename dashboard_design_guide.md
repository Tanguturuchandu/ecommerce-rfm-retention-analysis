# RFM Dashboard — FINAL Design Guide (Mint Background + White Cards)

## Base theme
- Canvas background (ALL 3 pages): #A8E6CF (mint green)
- Card/visual background: #FFFFFF (crisp white, floats on top of the mint)
- Banner: deeper emerald gradient, #4FD1A5 to #A8E6CF, with white bold text
- Title text (on white cards): #3A3A4A (soft charcoal)
- Body text (on white cards): #6B6B80 (muted grey-purple)

## KPI Card styling (white cards, colorful borders for distinction)
| Card | Background | Border |
|---|---|---|
| Total Revenue | #FFFFFF | #4FD1A5 (deeper emerald, ties to banner) |
| Total Customers | #FFFFFF | #5DADE2 (sky blue) |
| Avg Customer Value | #FFFFFF | #C7A6EA (lilac) |
| At Risk Revenue | #FFFFFF | #FF6F61 (coral-red, "pay attention" card) |

## Segment palette (used inside charts, which sit on white card backgrounds)
| Segment | Hex |
|---|---|
| Champions | #2ECC71 |
| Loyal Customers | #1ABC9C |
| Potential Loyalist | #5DADE2 |
| New Customers | #85C1E9 |
| Needs Attention | #F5B041 |
| At Risk | #E67E22 |
| Cant Lose Them | #E74C3C |
| Hibernating | #AAB7B8 |
| Lost | #7F8C8D |
(These are a bit more saturated than pure pastel so they read clearly
against white chart backgrounds — still warm-to-cool healthy-to-urgent.)

## Layout principle: "cards floating on a colored canvas"
Every chart/table/slicer sits inside its own white rounded rectangle
(the visual's own background), with the mint canvas showing as the gap
between them. This is what makes it look designed rather than default.

## Build order
1. Set Canvas background to A8E6CF on all 3 pages (done for Page 1 already)
2. Redo the banner in the deeper emerald gradient
3. Finish the 4 KPI cards: white bg, colored borders per table above
4. Build donut chart + bar chart (Page 1), both as white cards
5. Build bubble chart + table (Page 2)
6. Build slicers + drill-down table (Page 3)
