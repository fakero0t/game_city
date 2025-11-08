# Activity Card Data Format

This document describes the shape of data returned for each activity type from `POST /api/session/:id/next`.

## Base Response Structure

All activities return the following base structure:

```typescript
{
  itemId: string;              // UUID of the session item
  activityType: string;         // Activity type identifier
  phase?: "new" | "review";     // Learning phase
  phaseProgress?: {             // Progress within current phase
    current: number;
    total: number;
  };
  word: {                       // Vocabulary word data
    wordId: string;
    headword?: string;          // Hidden for spell_typed, definition_typed, paraphrase_typed_gen
    definition: string;
    pos: string;                // Part of speech
    media: Array<{               // Media associated with the word
      mediaId: string;
      kind: "audio" | "image";
      url: string;
      mimeType?: string;
      role: "word_pronunciation" | "alt_pronunciation" | "sentence_audio" | "illustration";
      orderNo: number;
    }>;
  };
  params: unknown | null;        // Activity-specific parameters (see below)
}
```

---

## Activity Types

### 1. `flashcard_usage`

**When:** First activity for NEW words (introduction/encoding)

**Word Object:**
- `headword`: ✅ Visible
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available (typically includes pronunciation audio and illustration)

**Params:**
```typescript
{
  options: Array<{
    exampleId: string;  // UUID of the example
    text: string;       // Sentence text
  }>;  // Exactly 4 options: 1 correct_usage + 3 incorrect_usage, shuffled
}
```

**Answer Format:**
```typescript
string  // The exampleId (UUID) of the selected option
```

**Notes:**
- Requires `timeSpentS >= 10` when submitting answer
- Options are deterministically shuffled based on `(sessionId, wordId)`

---

### 2. `connect_def`

**When:** Meaning activity for NEW or REVIEW words

**Word Object:**
- `headword`: ✅ Visible
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
{
  options: string[];  // Array of headword strings (4 options total)
                      // One is the target word, others are distractors
                      // Shuffled deterministically
}
```

**Answer Format:**
```typescript
string  // The headword text that matches the definition
```

**Notes:**
- Correct answer is the target word's headword (case-insensitive matching)

---

### 3. `context_cloze` (Connect Sentence)

**When:** Meaning activity for NEW or REVIEW words

**Word Object:**
- `headword`: ✅ Visible
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
{
  sentence: string;   // Sentence with target word replaced by "____"
  options: string[];  // Array of headword strings (4 options total)
                      // One is the target word, others are distractors
                      // Shuffled deterministically
}
```

**Answer Format:**
```typescript
string  // The headword text that fills the blank
```

**Notes:**
- Sentence is a `correct_usage` example with the target word blanked out
- Attempts to avoid using the same example as the flashcard for the same word

---

### 4. `select_usage`

**When:** Meaning activity for NEW or REVIEW words

**Word Object:**
- `headword`: ✅ Visible
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
{
  options: Array<{
    exampleId: string;  // UUID of the example
    text: string;        // Sentence text
  }>;  // Exactly 4 options: 1 correct_usage + 3 incorrect_usage, shuffled
}
```

**Answer Format:**
```typescript
string  // The exampleId (UUID) of the selected option
```

**Notes:**
- Similar to flashcard but used later in the sequence (tests recall without definition)
- Filters out cloze-style examples (those with `{blank}` or `____`)

---

### 5. `synonym_mcq`

**When:** Meaning activity for REVIEW words (typically higher stability)

**Word Object:**
- `headword`: ✅ Visible
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
{
  targetWord: {
    wordId: string;
    headword: string;
  };
  options: Array<{
    headword: string;  // Synonym text or distractor text
  }>;  // Exactly 4 options: 1 correct synonym + 3 distractors, shuffled
}
```

**Answer Format:**
```typescript
string  // The headword text that matches a synonym
```

**Notes:**
- Uses curated synonym text (not word IDs)
- Answer must match one of the word's synonyms (case-insensitive)

---

### 6. `spell_typed`

**When:** Spelling activity for NEW or REVIEW words

**Word Object:**
- `headword`: ❌ Hidden
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available (typically includes pronunciation audio)

**Params:**
```typescript
null  // No params needed
```

**Answer Format:**
```typescript
string  // User's typed spelling of the word
```

**Notes:**
- Scoring accepts orthographic variants (e.g., "color" vs "colour")
- Supports hints (first two letters)
- Max 1 retry

---

### 7. `definition_typed`

**When:** Spelling activity for NEW or REVIEW words

**Word Object:**
- `headword`: ❌ Hidden
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
null  // No params needed
```

**Answer Format:**
```typescript
string  // User's typed spelling of the word
```

**Notes:**
- Similar to `spell_typed` but shows definition instead of audio
- Scoring accepts orthographic variants

---

### 8. `sentence_typed_gen`

**When:** Generation activity for REVIEW words (higher stability)

**Word Object:**
- `headword`: ✅ Visible
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
{
  cueWord: string;      // Word to use in the sentence
  cuePos?: string;      // Part of speech of the cue word (optional)
}
```

**Answer Format:**
```typescript
string  // User's typed sentence using both the target word and cue word
```

**Notes:**
- GenAI-graded (checks meaning, grammar, spelling, and cue usage)
- Returns additional scoring details: `label` ("good" | "hard" | "again"), `meaningPass`, `spellingPass`, `detail`
- Slow responses (> threshold) downgrade the label

---

### 9. `paraphrase_typed_gen`

**When:** Generation activity for REVIEW words (higher stability)

**Word Object:**
- `headword`: ❌ Hidden
- `definition`: ✅ Visible
- `pos`: ✅ Visible
- `media`: ✅ Available

**Params:**
```typescript
null  // No params needed (definition is in word object)
```

**Answer Format:**
```typescript
string  // User's typed paraphrase of the definition
```

**Notes:**
- GenAI-graded (checks meaning and grammar)
- Returns additional scoring details: `label` ("good" | "hard" | "again"), `meaningPass`, `spellingPass`, `detail`
- Slow responses (> threshold) downgrade the label

---

## Common Patterns

### Media Roles
- `word_pronunciation`: Primary pronunciation audio
- `alt_pronunciation`: Alternative pronunciation
- `sentence_audio`: Audio for example sentences
- `illustration`: Image associated with the word

### Answer Submission
All activities submit answers via `POST /api/session/:id/attempt` with:
```typescript
{
  itemId: string;
  answer: unknown;        // Format varies by activity (see above)
  latencyMs: number;
  hintsUsed: number;
  retriesUsed: number;
  timeSpentS?: number;     // Required for flashcard_usage (>= 10)
  attemptId?: string;      // Optional UUID for idempotency
}
```

### Headword Visibility
- **Hidden** for: `spell_typed`, `definition_typed`, `paraphrase_typed_gen`
- **Visible** for: All other activities

