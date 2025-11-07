# Testing Changes - Next Buttons Always Enabled

**Date:** November 7, 2025
**Last Updated:** November 7, 2025 (PR 3 - Answer Validation added)
**Purpose:** Enable Next buttons in all games for faster testing/debugging

## ⚠️ Important Note: Interaction with Answer Validation (PR 3)

As of PR 3, all 4 multiple-choice games now have "retry until correct" logic that:
- Re-enables answer buttons after wrong answers
- Shows encouraging retry messages
- Does NOT auto-advance until correct answer is selected

**However, the testing bypass (always-enabled Next button) still works:**
- Testers can still click Next to skip questions without answering correctly
- The retry logic doesn't conflict with the testing guardrail
- Both systems coexist independently

**In production (after reversing testing changes):**
- Students MUST answer correctly to enable Next button
- Retry logic will be the only way to progress after wrong answers

## Changes Made

All changes involve commenting out the line that disables the Next button in the `_ready()` function of each game script.

### Files Modified:

#### 1. `scripts/MemoryGame.gd` (Line 49)
**BEFORE:**
```gdscript
$NextButton.disabled = true
```

**AFTER:**
```gdscript
# $NextButton.disabled = true  # Disabled for testing
```

---

#### 2. `scripts/MultipleChoice.gd` (Line 55)
**BEFORE:**
```gdscript
$NextButton.disabled = true
```

**AFTER:**
```gdscript
# $NextButton.disabled = true  # Disabled for testing
```

---

#### 3. `scripts/FillInBlank.gd` (Line 55)
**BEFORE:**
```gdscript
$NextButton.disabled = true
```

**AFTER:**
```gdscript
# $NextButton.disabled = true  # Disabled for testing
```

---

#### 4. `scripts/SynonymAntonym.gd` (Line 56)
**BEFORE:**
```gdscript
$NextButton.disabled = true
```

**AFTER:**
```gdscript
# $NextButton.disabled = true  # Disabled for testing
```

---

#### 5. `scripts/WordMatching.gd` (Line 55)
**BEFORE:**
```gdscript
$NextButton.disabled = true
```

**AFTER:**
```gdscript
# $NextButton.disabled = true  # Disabled for testing
```

---

## How to Reverse These Changes

To restore the original behavior (Next button only enabled after completing each game):

1. Open each file listed above
2. Find the line: `# $NextButton.disabled = true  # Disabled for testing`
3. Uncomment it to: `$NextButton.disabled = true`
4. Remove the comment: `# Disabled for testing`

**Final line should be:**
```gdscript
$NextButton.disabled = true
```

### Quick Find & Replace:

**Find:** `# $NextButton.disabled = true  # Disabled for testing`

**Replace with:** `$NextButton.disabled = true`

Apply this change to all 5 files listed above.

---

## Impact

With these changes:
- ✅ Next buttons are always enabled
- ✅ Can skip through games without completing them
- ✅ Faster testing of game flow and transitions
- ❌ Game completion logic is bypassed
- ❌ Scores may not be recorded properly if skipped

**Remember to reverse these changes before final release!**

