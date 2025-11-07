# Vocabulary Cat - Version 2.0 PRD
**Product Requirements Document**

---

## 1. Product Overview

**Product Name:** Vocabulary Cat  
**Version:** 2.0 (Game Logic Implementation)  
**Target Audience:** Children aged 8-11  
**Platform:** Godot 4.x  
**Devices:** Laptops and tablets (common aspect ratios)  
**Status:** Phase 2 - Gameplay Implementation

### Purpose
Implement actual vocabulary learning gameplay across 5 distinct game modes, replacing v1's placeholder screens with fully functional games. All games share a single vocabulary dataset and maintain the engaging, play-focused experience established in v1.

### Changes from v1.0
- **Replace** placeholder game screens with full game logic
- **Expand** game sequence from 4 to 5 games
- **Add** vocabulary data system (JSON-based)
- **Implement** scoring and feedback systems
- **Retain** character animations, modal system, and linear flow

---

## 2. Game Modes Overview

### Game Sequence (Linear Flow)

```
Main Screen → Info Modal → 
  Game 1: Memory/Concentration → Ready Modal →
  Game 2: Meaning Multiple Choice → Ready Modal →
  Game 3: Context Fill-in-the-Blank → Ready Modal →
  Game 4: Synonym/Antonym Selection → Ready Modal →
  Game 5: Word/Meaning Matching → 
  Completion Screen
```

| # | Game Mode | Character | Color | Core Mechanic |
|---|-----------|-----------|-------|---------------|
| 1 | Memory/Concentration | Cat | Purple (#8B5CF6) | Card flipping & matching |
| 2 | Meaning Multiple Choice | Dog | Orange (#F97316) | Button selection |
| 3 | Context Fill-in-the-Blank | Rabbit | Blue (#3B82F6) | Button/text input |
| 4 | Synonym/Antonym Selection | Fox | Red-Orange (#F97316) | Button selection |
| 5 | Word/Meaning Matching | Bird (new) | Green (#10B981) | Button selection |

---

## 3. Vocabulary Data Structure

### JSON Format

**File:** `assets/vocabulary.json`

```json
{
  "words": [
    {
      "word": "abundant",
      "definition": "existing in large quantities; plentiful",
      "synonyms": ["plentiful", "ample", "copious"],
      "antonyms": ["scarce", "rare", "lacking"],
      "example_sentence": "The garden had an _____ supply of fresh vegetables.",
      "difficulty": 1
    },
    {
      "word": "cautious",
      "definition": "careful to avoid potential problems or dangers",
      "synonyms": ["careful", "wary", "prudent"],
      "antonyms": ["reckless", "careless", "rash"],
      "example_sentence": "She was _____ when crossing the busy street.",
      "difficulty": 1
    }
  ]
}
```

### Data Requirements

- **Minimum 20 words** for functional gameplay
- **Recommended 40-60 words** for varied experience
- Each word must include:
  - `word` (string): The vocabulary word
  - `definition` (string): Clear, age-appropriate definition
  - `synonyms` (array): 3-5 synonyms
  - `antonyms` (array): 3-5 antonyms
  - `example_sentence` (string): Sentence with word replaced by "___"
  - `difficulty` (int): 1-3 scale (for future difficulty levels)

### Distractor Generation

For multiple-choice questions, distractors should be:
- **Plausible but incorrect** definitions/words from the vocabulary set
- **Not obviously wrong** (avoid extreme opposites unless testing antonyms)
- **Randomly selected** from other words in the dataset

---

## 4. Game Mode Specifications

### 4.1 Game 1: Memory / Concentration

**Character:** Cat (Purple)  
**Screen Title:** "Memory Match"  
**Objective:** Match all word-definition pairs

#### Screen Layout

```
┌─────────────────────────────────────────┐
│ Memory Match              Score: 0/6    │
│                                          │
│         [Card] [Card] [Card] [Card]     │
│         [Card] [Card] [Card] [Card]     │
│         [Card] [Card] [Card] [Card]     │
│                                          │
│                    🐱                    │
│                                          │
│                              [Next]      │
└─────────────────────────────────────────┘
```

#### Game Logic

1. **Setup:**
   - Select 6 random word-definition pairs from vocabulary
   - Create 12 cards (6 words + 6 definitions)
   - Shuffle and assign to grid positions
   - All cards start face-down

2. **Card Structure:**
   - Front: Blank with decorative back design (purple gradient)
   - Back: Text (word OR definition)
   - Border: 3px, rounded corners (12px radius)
   - Size: 150x100px (responsive)

3. **Gameplay Loop:**
   - Click card → flip to reveal text
   - Click second card → flip to reveal text
   - If word + definition match:
     - Cards stay revealed
     - Change border color to green (#10B981)
     - Play success sound (optional)
     - Increment score
     - Cat plays celebration animation (bounce)
   - If cards don't match:
     - Wait 1.5 seconds
     - Flip both cards back face-down
     - No penalty
   - Prevent clicking:
     - During flip animations (0.3s)
     - During mismatch delay (1.5s)
     - On already-matched cards

4. **Win Condition:**
   - All 6 pairs matched
   - Display "All Matched!" message (2s)
   - Enable "Next" button
   - Cat plays celebration animation

5. **UI Elements:**
   - Score display: "Score: X/6" (top right)
   - Timer (optional): "Time: MM:SS" (top left)
   - Next button: Initially disabled, enables on win

#### Technical Implementation

**Scene Structure:**
```
MemoryGame (Control)
├─ Background (ColorRect - purple)
├─ HeaderBar (HBoxContainer)
│  ├─ TitleLabel
│  └─ ScoreLabel
├─ GridContainer (3 columns, 4 rows)
│  ├─ Card1...Card12 (Button with custom style)
├─ Character (Node2D - Cat with tail wiggle)
├─ NextButton
└─ WinMessage (Label - hidden initially)
```

**Card Data Structure:**
```gdscript
class Card:
    var content: String
    var is_word: bool  # true if word, false if definition
    var pair_id: int   # matching cards have same pair_id
    var is_flipped: bool = false
    var is_matched: bool = false
```

**Signals:**
```gdscript
signal card_flipped(card_index: int)
signal pair_matched(pair_id: int)
signal game_won()
```

---

### 4.2 Game 2: Meaning Multiple Choice

**Character:** Dog (Orange)  
**Screen Title:** "Pick the Meaning"  
**Objective:** Select the correct definition for each word

#### Screen Layout

```
┌─────────────────────────────────────────┐
│ Pick the Meaning          Question 1/10 │
│                                          │
│                                          │
│           What does "abundant" mean?    │
│                                          │
│         [A] existing in large quantities│
│         [B] very small in size          │
│         [C] moving very quickly         │
│         [D] difficult to understand     │
│                                          │
│                    🐶                    │
│                                          │
│  Score: 0/10                    [Next]  │
└─────────────────────────────────────────┘
```

#### Game Logic

1. **Setup:**
   - Select 10 random words from vocabulary
   - For each word, prepare question with 4 options
   - Shuffle question order

2. **Question Structure:**
   - Word displayed prominently: "What does '[word]' mean?"
   - 4 answer buttons (A-D)
   - 1 correct definition
   - 3 distractor definitions (randomly selected from other words)
   - Options shuffled randomly

3. **Gameplay Loop:**
   - Display word and 4 definition options
   - User clicks one answer button
   - **Immediate feedback:**
     - Correct answer: 
       - Button turns green (#10B981)
       - Show checkmark icon ✓
       - Display "Correct! 🎉" message (1s)
       - Increment score
       - Dog plays happy animation
     - Wrong answer:
       - Clicked button turns red (#EF4444)
       - Correct button highlights green
       - Display "Not quite. The answer is [A]" (2s)
       - Dog plays sympathetic animation
   - Wait 2 seconds for feedback display
   - Auto-advance to next question
   - After question 10, enable "Next" button

4. **Progression:**
   - Questions 1-10 displayed sequentially
   - No skipping forward/backward
   - Score tracked and displayed
   - Progress indicator: "Question X/10"

5. **Win/Complete Condition:**
   - All 10 questions answered (any score)
   - Display final score: "You got X/10 correct!"
   - Enable "Next" button

#### Technical Implementation

**Scene Structure:**
```
MultipleChoice (Control)
├─ Background (ColorRect - orange)
├─ HeaderBar (HBoxContainer)
│  ├─ TitleLabel
│  └─ ProgressLabel
├─ QuestionPanel (PanelContainer)
│  └─ VBoxContainer
│     ├─ QuestionLabel ("What does X mean?")
│     ├─ Spacer
│     ├─ AnswerA (Button)
│     ├─ AnswerB (Button)
│     ├─ AnswerC (Button)
│     └─ AnswerD (Button)
├─ FeedbackLabel (Label - animated, hidden initially)
├─ Character (Node2D - Dog with tail wiggle)
├─ FooterBar (HBoxContainer)
│  ├─ ScoreLabel
│  └─ NextButton
```

**Question Data Structure:**
```gdscript
class Question:
    var word: String
    var correct_definition: String
    var options: Array[String]  # 4 options, shuffled
    var correct_index: int      # index of correct answer in options
```

---

### 4.3 Game 3: Context Fill-in-the-Blank

**Character:** Rabbit (Blue)  
**Screen Title:** "Complete the Sentence"  
**Objective:** Choose the correct word to complete each sentence

#### Screen Layout

```
┌─────────────────────────────────────────┐
│ Complete the Sentence     Question 1/10 │
│                                          │
│                                          │
│   The garden had an _____ supply of     │
│          fresh vegetables.              │
│                                          │
│         [A] abundant                    │
│         [B] cautious                    │
│         [C] distant                     │
│         [D] fragile                     │
│                                          │
│                    🐰                    │
│                                          │
│  Score: 0/10                    [Next]  │
└─────────────────────────────────────────┘
```

#### Game Logic

1. **Setup:**
   - Select 10 random words with example sentences
   - For each sentence, prepare 4 word options
   - Shuffle question order

2. **Question Structure:**
   - Display sentence with blank: "The ___ was very tall."
   - 4 word options (A-D)
   - 1 correct word (matches sentence context)
   - 3 distractor words (other vocabulary words)
   - Options shuffled randomly

3. **Gameplay Loop:**
   - Display sentence with blank and 4 word options
   - User clicks one answer button
   - **Immediate feedback:**
     - Correct answer:
       - Button turns green
       - Show full sentence with word filled in
       - Display "Perfect! ✨" message (1s)
       - Increment score
       - Rabbit plays hop animation
     - Wrong answer:
       - Clicked button turns red
       - Correct button highlights green
       - Show correct sentence
       - Display "The correct word is [word]" (2s)
       - Rabbit plays sympathetic animation
   - Wait 2 seconds for feedback
   - Auto-advance to next question
   - After question 10, enable "Next" button

4. **Progression:**
   - Same as Multiple Choice (10 questions, sequential)
   - Score tracked and displayed
   - Progress indicator: "Question X/10"

5. **Alternative: Text Input Mode (Optional)**
   - Replace buttons with text input field
   - User types the word
   - Check for exact match (case-insensitive)
   - More challenging but better learning

#### Technical Implementation

**Scene Structure:**
```
FillInBlank (Control)
├─ Background (ColorRect - blue)
├─ HeaderBar (HBoxContainer)
│  ├─ TitleLabel
│  └─ ProgressLabel
├─ SentencePanel (PanelContainer)
│  └─ VBoxContainer
│     ├─ SentenceLabel (sentence with ___)
│     ├─ Spacer
│     ├─ AnswerA (Button)
│     ├─ AnswerB (Button)
│     ├─ AnswerC (Button)
│     └─ AnswerD (Button)
│     # OR: InputField (LineEdit) for typing mode
├─ FeedbackLabel (Label - animated)
├─ Character (Node2D - Rabbit with tail wiggle)
├─ FooterBar (HBoxContainer)
│  ├─ ScoreLabel
│  └─ NextButton
```

**Question Data Structure:**
```gdscript
class SentenceQuestion:
    var sentence: String        # with ___ placeholder
    var correct_word: String
    var options: Array[String]  # 4 word options, shuffled
    var correct_index: int
```

---

### 4.4 Game 4: Synonym / Antonym Selection

**Character:** Fox (Red-Orange)  
**Screen Title:** "Word Relationships"  
**Objective:** Identify synonyms or antonyms for given words

#### Screen Layout

```
┌─────────────────────────────────────────┐
│ Word Relationships        Question 1/10 │
│                                          │
│                                          │
│         Which word is a SYNONYM for     │
│                "abundant"?              │
│                                          │
│         [A] plentiful                   │
│         [B] scarce                      │
│         [C] dangerous                   │
│         [D] beautiful                   │
│                                          │
│                    🦊                    │
│                                          │
│  Score: 0/10                    [Next]  │
└─────────────────────────────────────────┘
```

#### Game Logic

1. **Setup:**
   - Select 10 random words from vocabulary
   - For each word, randomly choose SYNONYM or ANTONYM
   - Prepare 4 options per question
   - Mix of synonym and antonym questions (roughly 50/50)

2. **Question Structure:**
   - Instruction: "Which word is a SYNONYM for..." OR "Which word is an ANTONYM for..."
   - Target word displayed prominently
   - 4 word options (A-D)
   - 1 correct synonym/antonym
   - 3 distractors (other synonyms, antonyms, or unrelated words)
   - Options shuffled randomly

3. **Visual Distinction:**
   - SYNONYM questions: Instruction text in green (#10B981)
   - ANTONYM questions: Instruction text in orange (#F97316)
   - Helps user quickly identify question type

4. **Gameplay Loop:**
   - Display question type (synonym/antonym) and target word
   - User clicks one answer button
   - **Immediate feedback:**
     - Correct answer:
       - Button turns green
       - Display "Yes! [word] is a [synonym/antonym] of [target]" (1.5s)
       - Increment score
       - Fox plays clever animation (nod)
     - Wrong answer:
       - Clicked button turns red
       - Correct button highlights green
       - Display "Actually, [correct word] is the [synonym/antonym]" (2s)
       - Fox plays thoughtful animation
   - Wait 2 seconds for feedback
   - Auto-advance to next question
   - After question 10, enable "Next" button

5. **Progression:**
   - 10 questions total (mix of synonym/antonym)
   - Score tracked and displayed
   - Progress indicator: "Question X/10"

#### Technical Implementation

**Scene Structure:**
```
SynonymAntonym (Control)
├─ Background (ColorRect - red-orange)
├─ HeaderBar (HBoxContainer)
│  ├─ TitleLabel
│  └─ ProgressLabel
├─ QuestionPanel (PanelContainer)
│  └─ VBoxContainer
│     ├─ InstructionLabel ("Which word is a SYNONYM/ANTONYM for")
│     ├─ TargetWordLabel (large, bold)
│     ├─ Spacer
│     ├─ AnswerA (Button)
│     ├─ AnswerB (Button)
│     ├─ AnswerC (Button)
│     └─ AnswerD (Button)
├─ FeedbackLabel (Label - animated)
├─ Character (Node2D - Fox with tail wiggle)
├─ FooterBar (HBoxContainer)
│  ├─ ScoreLabel
│  └─ NextButton
```

**Question Data Structure:**
```gdscript
class RelationshipQuestion:
    var target_word: String
    var question_type: String       # "synonym" or "antonym"
    var correct_answer: String
    var options: Array[String]      # 4 options, shuffled
    var correct_index: int
```

---

### 4.5 Game 5: Word/Meaning Matching

**Character:** Bird (Green) - NEW  
**Screen Title:** "Match the Meaning"  
**Objective:** Match words to their correct definitions

#### Screen Layout

```
┌─────────────────────────────────────────┐
│ Match the Meaning         Question 1/8  │
│                                          │
│                                          │
│           Which word means:             │
│                                          │
│     "existing in large quantities;      │
│            plentiful"                   │
│                                          │
│         [A] abundant                    │
│         [B] cautious                    │
│         [C] fragile                     │
│         [D] ancient                     │
│                                          │
│                    🐦                    │
│                                          │
│  Score: 0/8                     [Next]  │
└─────────────────────────────────────────┘
```

#### Game Logic

1. **Setup:**
   - Select 8 random words from vocabulary
   - For each, prepare question with definition → word matching
   - **Note:** This is the REVERSE of Game 2 (word → definition)

2. **Question Structure:**
   - Display definition prominently: "Which word means '[definition]'?"
   - 4 word options (A-D)
   - 1 correct word
   - 3 distractor words (other vocabulary)
   - Options shuffled randomly

3. **Gameplay Loop:**
   - Display definition and 4 word options
   - User clicks one answer button
   - **Immediate feedback:**
     - Correct answer:
       - Button turns green
       - Display "Correct! '[word]' means [definition]" (1.5s)
       - Increment score
       - Bird plays wing flap animation
     - Wrong answer:
       - Clicked button turns red
       - Correct button highlights green
       - Display "The correct word is [word]" (2s)
       - Bird plays sympathetic animation
   - Wait 2 seconds for feedback
   - Auto-advance to next question
   - After question 8, enable "Next" button

4. **Progression:**
   - 8 questions total (shorter than others for variety)
   - Score tracked and displayed
   - Progress indicator: "Question X/8"

5. **Distinction from Game 2:**
   - Game 2 (Multiple Choice): Shows word, asks for definition
   - Game 5 (Matching): Shows definition, asks for word
   - Tests recognition vs. recall (different cognitive skills)

#### Technical Implementation

**Scene Structure:**
```
WordMatching (Control)
├─ Background (ColorRect - green)
├─ HeaderBar (HBoxContainer)
│  ├─ TitleLabel
│  └─ ProgressLabel
├─ QuestionPanel (PanelContainer)
│  └─ VBoxContainer
│     ├─ InstructionLabel ("Which word means:")
│     ├─ DefinitionLabel (definition text)
│     ├─ Spacer
│     ├─ AnswerA (Button)
│     ├─ AnswerB (Button)
│     ├─ AnswerC (Button)
│     └─ AnswerD (Button)
├─ FeedbackLabel (Label - animated)
├─ Character (Node2D - Bird with wing animation)
├─ FooterBar (HBoxContainer)
│  ├─ ScoreLabel
│  └─ NextButton
```

**Question Data Structure:**
```gdscript
class MatchingQuestion:
    var definition: String
    var correct_word: String
    var options: Array[String]  # 4 word options, shuffled
    var correct_index: int
```

---

## 5. Character Updates

### 5.1 Existing Characters (No Changes)

- **Cat** (Game 1): Purple, existing design from v1
- **Dog** (Game 2): Orange, existing design from v1
- **Rabbit** (Game 3): Blue, existing design from v1
- **Fox** (Game 4): Red-Orange, existing design from v1

### 5.2 New Character: Bird

**Appearance:**
- **Color:** Green (#10B981)
- **Style:** Matches existing characters (2D cartoon, 4px outline)
- **Size:** 200-300px tall (consistent with others)
- **Features:**
  - Round head: 95px diameter
  - Round body: 110x90 rectangle, rounded corners
  - Eyes: 33px diameter (35% of head), friendly expression
  - Beak: Small triangle, orange/yellow accent
  - Wings: Two small rounded rectangles on sides (20x30 each)
  - Tail feathers: Separate Node2D, 3 small feather shapes

**Animation:**
- **Idle:** Subtle bounce/breathing (3-5 second cycle)
- **Wing flap:** Left wing animates up/down every 2 seconds
- **Celebration:** Both wings flap rapidly (0.5s)
- **Sympathetic:** Wings droop slightly

**Implementation:**
- Add `CharacterHelper.create_bird()` function
- Wing is separate Node2D for animation (like tail on other characters)
- Use same animation patterns as existing characters

---

## 6. Shared Systems & Features

### 6.1 Vocabulary Manager Singleton

**File:** `scripts/VocabularyManager.gd` (NEW)

**Purpose:** Load, parse, and serve vocabulary data to all games

**Key Methods:**
```gdscript
# Load vocabulary from JSON
func load_vocabulary(file_path: String = "res://assets/vocabulary.json") -> void

# Get random words (for any game)
func get_random_words(count: int) -> Array[Dictionary]

# Get specific word data
func get_word_data(word: String) -> Dictionary

# Get distractors (for multiple choice)
func get_random_distractors(exclude_word: String, count: int, field: String = "definition") -> Array

# Get all words (for testing/debugging)
func get_all_words() -> Array[Dictionary]
```

**Register as AutoLoad:**
```
[autoload]
VocabularyManager="*res://scripts/VocabularyManager.gd"
```

---

### 6.2 Scoring & Progress Tracking

**Per-Game Tracking:**
- Each game tracks its own score internally
- Display score in UI: "Score: X/Y"
- Games don't enforce minimum score (any score passes)

**No Persistence in v2:**
- Scores reset on "Play Again"
- No high scores or saved progress
- No cumulative score across games
- (Future: Add local storage in v2.1+)

**Completion Screen Updates:**
- Show all 5 character sprites (including Bird)
- Display total score: "You answered X/48 questions correctly!" (sum of all games)
- Optional: Show per-game breakdown

---

### 6.3 Feedback & Animation System

**Correct Answer Feedback:**
- Button background: Green (#10B981)
- Checkmark icon: ✓ appears on button
- Feedback text: "Correct! 🎉" / "Perfect! ✨" / "Yes! 🌟"
- Character animation: Celebration (bounce, wiggle, flap)
- Sound effect: Success chime (optional)
- Duration: 1.5-2 seconds before next question

**Wrong Answer Feedback:**
- Clicked button background: Red (#EF4444)
- Correct button background: Green (highlighted)
- Feedback text: "Not quite. The answer is [X]"
- Character animation: Sympathetic (droop, slow tail)
- Sound effect: Gentle "oops" sound (optional)
- Duration: 2 seconds before next question

**Animation Timing:**
- Button feedback: 0.2s (color change)
- Text fade-in: 0.3s (scale bounce)
- Character reaction: 0.4-0.6s
- Total feedback display: 1.5-2s
- Use VocabCatConstants for consistency

---

### 6.4 Accessibility Features

**Visual:**
- High contrast colors (4.5:1 ratio minimum)
- Large text (18-24px for body)
- Clear feedback (color + icons + text)

**Interaction:**
- Touch targets: 44x44px minimum
- Hover states on all buttons
- Press animations for tactile feedback
- No time pressure (no countdown timers)

**Cognitive:**
- Simple language (grade 3-5 reading level)
- Clear instructions per game
- Consistent UI patterns across games
- Immediate, constructive feedback

---

## 7. Technical Requirements

### 7.1 Updated Project Structure

```
/game_city (or rename to /vocabulary_cat)
  /assets
    /fonts
      - fredoka-bold.ttf
      - nunito-regular.ttf
    /characters
      - [existing character sprites]
      - bird.png (body)
      - bird_wing.png
    vocabulary.json (NEW)
    vocab_cat_theme.tres
  /scenes
    - Main.tscn
    - Modal.tscn
    - MemoryGame.tscn (replaces Flashcards.tscn)
    - MultipleChoice.tscn (updated)
    - FillInBlank.tscn (updated)
    - SynonymAntonym.tscn (replaces SentenceGen.tscn)
    - WordMatching.tscn (NEW)
    - Completion.tscn (updated)
  /scripts
    - Main.gd
    - GameManager.gd (updated for 5 games)
    - Modal.gd
    - VocabularyManager.gd (NEW)
    - MemoryGame.gd (NEW)
    - MultipleChoice.gd (updated)
    - FillInBlank.gd (updated)
    - SynonymAntonym.gd (NEW)
    - WordMatching.gd (NEW)
    - Completion.gd (updated)
    - CharacterHelper.gd (add bird)
    - VocabCatColors.gd
    - VocabCatConstants.gd
  project.godot
```

---

### 7.2 GameManager Updates

**Update for 5 games:**
```gdscript
# Game list updated
var games = [
    {"name": "Memory Match", "scene": "res://scenes/MemoryGame.tscn", "character": "Cat"},
    {"name": "Pick the Meaning", "scene": "res://scenes/MultipleChoice.tscn", "character": "Dog"},
    {"name": "Complete the Sentence", "scene": "res://scenes/FillInBlank.tscn", "character": "Rabbit"},
    {"name": "Word Relationships", "scene": "res://scenes/SynonymAntonym.tscn", "character": "Fox"},
    {"name": "Match the Meaning", "scene": "res://scenes/WordMatching.tscn", "character": "Bird"}
]
```

**Track total score:**
```gdscript
var game_scores: Array[int] = [0, 0, 0, 0, 0]

func record_game_score(game_index: int, score: int, total: int) -> void:
    game_scores[game_index] = score

func get_total_score() -> int:
    return game_scores.reduce(func(acc, val): return acc + val, 0)
```

---

### 7.3 Performance Considerations

**Optimization:**
- Preload vocabulary at game start (not per-scene)
- Cache distractor generation (avoid repeated random selections)
- Reuse button nodes (update text/style instead of creating new)
- Tween cleanup (kill previous tweens before starting new ones)

**Target Performance:**
- 60fps on laptops (1080p)
- 60fps on tablets (768p-1080p)
- Memory usage: <200MB (vocabulary data is small)
- Scene load time: <0.5s per game transition

---

## 8. Out of Scope for v2.0

The following are **NOT** included in this version:

❌ User accounts or cloud saving  
❌ Sound effects or background music (optional, but not required)  
❌ Advanced statistics or analytics  
❌ Multiple difficulty levels (all words at difficulty 1)  
❌ Custom vocabulary lists (single JSON file)  
❌ Timed challenges or speed modes  
❌ Multiplayer or competitive features  
❌ Hints or help system  
❌ Achievements or badges  
❌ Tutorial/onboarding flow (assume users understand from UI)  
❌ Settings menu (no volume, accessibility toggles)  

These will be addressed in future versions (v2.1, v3.0).

---

## 9. Acceptance Criteria

### Definition of Done:

#### Functional Requirements:

✅ Vocabulary JSON file created with minimum 20 words (all required fields)  
✅ VocabularyManager singleton loads and serves data correctly  
✅ GameManager updated for 5-game sequence  
✅ Game 1 (Memory): 6 pairs, card flipping, matching logic, win detection  
✅ Game 2 (Multiple Choice): 10 questions, definition selection, scoring  
✅ Game 3 (Fill-in-Blank): 10 questions, sentence completion, scoring  
✅ Game 4 (Synonym/Antonym): 10 questions, mixed question types, scoring  
✅ Game 5 (Word Matching): 8 questions, word selection, scoring  
✅ All games show immediate feedback (correct/wrong)  
✅ All games auto-advance to next question after feedback  
✅ All games track and display score  
✅ All games enable "Next" button only when complete  
✅ Ready modals appear between games 1-4  
✅ Game 5 → Completion Screen (no ready modal)  
✅ Completion screen shows all 5 characters (including Bird)  
✅ "Play Again" returns to Main Screen and resets flow  
✅ No console errors or warnings  
✅ Project runs at 60fps  

#### Content Requirements:

✅ Vocabulary JSON has 20+ words with all fields populated  
✅ Definitions are age-appropriate (grade 3-5 reading level)  
✅ Example sentences are clear and contextual  
✅ Synonyms and antonyms are accurate  
✅ Distractors are plausible (not obviously wrong)  

#### Visual Requirements:

✅ Bird character designed and integrated (matches style guide)  
✅ All game screens match style guide (colors, fonts, spacing)  
✅ Feedback colors (green/red) have sufficient contrast  
✅ Button states (normal, hover, pressed, correct, wrong) are clear  
✅ All character tail/wing animations work smoothly  
✅ UI adapts to common aspect ratios (16:9, 16:10, 4:3)  

---

## 10. Testing Checklist

### Functional Testing:

- [ ] Full game flow: Main → Game 1 → Game 2 → Game 3 → Game 4 → Game 5 → Completion
- [ ] Vocabulary loads without errors
- [ ] Each game displays correct number of questions
- [ ] Correct answers increment score
- [ ] Wrong answers don't break game flow
- [ ] Feedback displays for correct/wrong answers
- [ ] Auto-advance works after feedback timeout
- [ ] Ready modals appear at correct points
- [ ] Completion screen shows all 5 characters
- [ ] Play Again resets all game states

### Game-Specific Testing:

**Memory Game:**
- [ ] Cards shuffle randomly each play
- [ ] Flip animation works smoothly
- [ ] Matching pairs stay revealed
- [ ] Non-matching pairs flip back after delay
- [ ] Can't click during animations/delay
- [ ] Win detection triggers correctly

**Multiple Choice:**
- [ ] Questions randomized each play
- [ ] 4 options per question
- [ ] Correct answer is random position
- [ ] Feedback highlights correct button
- [ ] Score increments only on correct answers

**Fill-in-Blank:**
- [ ] Sentences display with blank properly
- [ ] Word options are plausible
- [ ] Correct word completes sentence logically
- [ ] Feedback shows full sentence

**Synonym/Antonym:**
- [ ] Mix of synonym and antonym questions
- [ ] Instruction text color changes (green/orange)
- [ ] Correct relationships identified
- [ ] Feedback explains relationship

**Word Matching:**
- [ ] Definitions display clearly
- [ ] Correct word matches definition
- [ ] Feedback confirms word-definition pair

### Edge Cases:

- [ ] Rapidly clicking doesn't break state
- [ ] Playing through 3+ times works correctly
- [ ] No memory leaks (scenes properly freed)
- [ ] Works with minimum vocabulary (20 words)
- [ ] Works with large vocabulary (100+ words)

---

## 11. Future Roadmap (v2.1+)

### Phase 2.1 - Polish:
- Add sound effects (correct, wrong, button clicks, completion)
- Add background music (optional toggle)
- Add progress saving (local storage)
- Add high score tracking per game

### Phase 2.2 - Content:
- Expand vocabulary to 100+ words
- Add difficulty levels (easy, medium, hard)
- Add vocabulary categories (animals, nature, emotions, etc.)

### Phase 3.0 - Features:
- Settings menu (volume, difficulty, accessibility)
- Tutorial/onboarding flow
- Hints system (spend points for help)
- Achievements and rewards

### Phase 4.0 - Expansion:
- Custom vocabulary import (teachers/parents)
- Multiplayer mode (local co-op)
- Timed challenge modes
- Learning analytics dashboard

---

## 12. Resources & References

- **v1.0 PRD:** `v1_prd.md` (navigation flow foundation)
- **v1.0 Task List:** `v1_task_list.md` (implementation details)
- **Style Guide:** `vocab_cat_style_guide.md`
- **Theme File:** `assets/vocab_cat_theme.tres`
- **Color Constants:** `scripts/VocabCatColors.gd`
- **Animation Helpers:** `scripts/VocabCatConstants.gd`
- **Godot Documentation:** https://docs.godotengine.org/en/stable/

---

## 13. Sample Vocabulary Data

### Starter Vocabulary Set (20 words)

For testing and initial implementation, use these 20 words:

1. **abundant** - existing in large quantities; plentiful
2. **cautious** - careful to avoid potential problems or dangers
3. **curious** - eager to know or learn something
4. **delicate** - easily broken or damaged; fragile
5. **eager** - wanting to do something very much
6. **generous** - willing to give more than necessary
7. **gloomy** - dark or poorly lit; sad
8. **humble** - having a modest view of one's importance
9. **invisible** - unable to be seen
10. **joyful** - feeling or expressing great happiness
11. **loyal** - giving firm and constant support
12. **mysterious** - difficult to understand or explain
13. **nervous** - easily worried or anxious
14. **obvious** - easily seen or understood; clear
15. **peaceful** - free from disturbance; calm
16. **precious** - of great value; not to be wasted
17. **quiet** - making little or no noise
18. **rapid** - happening in a short time; fast
19. **sturdy** - strong and solid; well-built
20. **thoughtful** - showing consideration for others

**Note:** Full JSON format with synonyms, antonyms, and example sentences should be provided in implementation phase.

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | Nov 2025 | Initial | Game logic implementation |

---

**Status:** 📝 Ready for Planning  
**Priority:** P0 (Core Gameplay)  
**Estimated Effort:** 4-6 development sessions  
**Dependencies:** v1.0 must be complete (navigation flow, characters, modals)

