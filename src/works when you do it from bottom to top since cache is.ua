# Experimental!
Fib ← |1 memo(⨬(+∩(memoFib)⊃-₁-₂|∘)⊸≤1)
# works when you do it from bottom to top since cache is
# reset after each run
# ⊣Fib⇡1e3

C   ← ⨬(÷₂|+₁×₃)⊸◿2
Col ← |1 memo(⨬(memoCol C|∘)⊸=1)
# does not work sadly
ColList ← ◌⍢⊂⊸(¬⊸∊⟜(C⊢))

ColInit ← map 1_2_4 1_2_3
Setup   ← ¤⤙∩∘
# keep adding to list till map has key
What    ← ×∩¬⊙=₁ ◡(⤚has⊢)
Build   ← ⊂C ⊸⊢
MemoIns ← ∧(insert⊃⊣⊢)⍉⊟+◡⊃(⇡⧻)(get⊢)
⍢(⊙+₁ MemoIns ⍢Build What Setup|◡(<1e4⋅∘)) ColInit 1
∩⊣°map⍆
# loop done, offset chain lengths and add to map
# ↘¯2 ↻2ColList 3 ColInit
# ∩⊣°map⍆map1_3_0_9 12_4_8_0
# ⧻map1_3_0_9 12_4_8_0
# ⍥(⊙+₁ MemoIns◌?⊸⧻⍢Build What Setup)4 ColInit 837796
