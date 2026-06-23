# Foundation Models Framework — Research Notes
> Sources: WWDC25 #286, #248, #301, #259, Meet with Apple #205

---

## Table of Contents
1. [What Is the Foundation Models Framework?](#1-what-is-the-foundation-models-framework)
2. [The Model — Specs & Limitations](#2-the-model--specs--limitations)
3. [Core API — Sessions](#3-core-api--sessions)
4. [Guided Generation — Structured Output](#4-guided-generation--structured-output)
5. [Snapshot Streaming](#5-snapshot-streaming)
6. [Tool Calling](#6-tool-calling)
7. [Dynamic Schemas (Runtime)](#7-dynamic-schemas-runtime)
8. [Prompt Design Best Practices](#8-prompt-design-best-practices)
9. [AI Safety](#9-ai-safety)
10. [Availability Checking](#10-availability-checking)
11. [Developer Tooling](#11-developer-tooling)
12. [Performance & Optimization](#12-performance--optimization)
13. [Error Handling](#13-error-handling)
14. [Specialized Adapters / Use Cases](#14-specialized-adapters--use-cases)
15. [API Quick Reference](#15-api-quick-reference)

---

## 1. What Is the Foundation Models Framework?

A Swift API that gives developers **direct access to the on-device Large Language Model** powering Apple Intelligence.

### Key Benefits
| Benefit | Detail |
|---|---|
| **Private** | All processing stays on-device — no server, no data upload |
| **Offline** | No internet connection required |
| **Free** | No API keys, no per-request fees |
| **Zero app size impact** | Model ships as part of the OS |

### Platform Support
- macOS Tahoe 26+
- iOS 26+
- iPadOS 26+
- visionOS

### Optimized Use Cases
- Content generation
- Summarization
- Extraction
- Classification
- Multi-turn conversation
- Text composition & revision
- Generating tags from text

---

## 2. The Model — Specs & Limitations

### Specifications
- **~3 billion parameters**, quantized to 2 bits for on-device efficiency
- Compare: Server-based LLMs (ChatGPT, etc.) = hundreds of billions of parameters
- Specialized **adapters** available for specific domains (e.g., content tagging)
- Requires Apple Intelligence-enabled devices in supported regions

### Limitations
| Limitation | Recommendation |
|---|---|
| Complex reasoning | Break tasks into simpler steps |
| Math calculations | Use non-AI code instead |
| Code generation | Avoid — model not optimized for it |
| Limited world knowledge | Don't rely on it for facts |
| Post-training-date events | Not available |
| Hallucinations | Provide verified facts in the prompt |

---

## 3. Core API — Sessions

Sessions are **stateful** — the transcript records all prompts and responses automatically.

### Basic Session

```swift
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "Create an itinerary for Joshua Tree.")
print(response.content) // String output
```

### Session with Instructions

```swift
let session = LanguageModelSession(
    instructions: "You are a friendly travel planner."
)
let response = try await session.respond(to: "Give me a 3-day Japan trip.")
```

### Instructions vs. Prompts
| | Instructions | Prompts |
|---|---|---|
| **Set by** | Developer | Developer or user |
| **Scope** | Entire session | Single request |
| **Priority** | Higher (model obeys over prompts) | Lower |
| **Safety** | Never interpolate user input here | Dynamic, can include user input |

### Multi-turn Conversations

```swift
let session = LanguageModelSession()
let first  = try await session.respond(to: "Write a haiku about fishing")
let second = try await session.respond(to: "Do another one about golf")
// Model understands "another one" = haiku, from context
print(session.transcript)
```

### Builder API for Instructions

```swift
let session = LanguageModelSession {
    "You are a travel planner."
    "Generate a 3-day itinerary for \(landmark.name)."
    Itinerary.exampleTripToJapan // Pass a @Generable instance as example
}
```

### Temperature / Sampling Control

```swift
GenerationOptions(sampling: .greedy)     // Deterministic — same input = same output
GenerationOptions(temperature: 0.5)      // Low variance
GenerationOptions(temperature: 2.0)      // High variance / creative
```

> ⚠️ Greedy output can change when Apple updates the OS model.

### Gate on `isResponding`

```swift
Button("Generate") { ... }
    .disabled(session.isResponding)
```

### Context Window Management

```swift
catch LanguageModelSession.GenerationError.exceededContextWindowSize {
    // Option: carry over only essential entries
    let condensed = Transcript(entries: [firstEntry, lastEntry])
    session = LanguageModelSession(transcript: condensed)
}
```

---

## 4. Guided Generation — Structured Output

Solves the problem of unreliable/malformed structured output from LLMs using **constrained decoding** — the model is physically prevented from generating invalid fields or types.

### Two Key Macros

- `@Generable` — marks a `struct` or `enum` so the model can generate it
- `@Guide` — adds constraints and hints to individual properties

### Basic Example

```swift
@Generable
struct SearchSuggestions {
    @Guide(description: "A list of suggested search terms", .count(4))
    var searchTerms: [String]
}

let response = try await session.respond(
    to: "Generate search terms for a landmark app.",
    generating: SearchSuggestions.self
)
print(response.content.searchTerms)
```

### Nested Structures

```swift
@Generable
struct Itinerary {
    @Guide(description: "A catchy title for the trip")
    var title: String

    @Guide(description: "Brief description", .count(3))
    var days: [DayPlan]

    var rationale: String
}

@Generable
struct DayPlan {
    var summary: String
    var activities: [String]
}
```

### Enums with Associated Values

```swift
@Generable
enum Encounter {
    case orderCoffee(String)
    case wantToTalkToManager(complaint: String)
}
```

### `@Guide` Constraint Options

| Type | Options |
|---|---|
| `Int` / numeric | `.range(1...10)`, `.min()`, `.max()` |
| `Array` | `.count(3)`, `.maximumCount(5)`, element guides |
| `String` | `.anyOf([...])`, regex pattern |

### Regex Guide Example

```swift
@Guide(Regex {
    Capture { ChoiceOf { "Mr"; "Mrs" } }
    ". "
    OneOrMore(.word)
})
let name: String
// Output guaranteed: "Mrs. Brewster"
```

### Benefits of Guided Generation
- Simpler prompts (no format specification needed in text)
- Improves model accuracy
- Speeds up inference
- **Guarantees structural correctness**
- Properties generated in declaration order — order matters

> **Tip:** Declare `summary`/`rationale` fields last — earlier fields influence them positively.

---

## 5. Snapshot Streaming

Instead of raw token deltas, the framework streams **snapshots** — fully valid partial states of the `@Generable` struct.

### The `PartiallyGenerated` Type

`@Generable` auto-generates a mirror type where **all properties are Optional**:

```swift
// Declared
@Generable struct Itinerary {
    var title: String
    var days: [DayPlan]
}

// Auto-generated by macro
// Itinerary.PartiallyGenerated {
//     var title: String?
//     var days: [DayPlan.PartiallyGenerated]?
// }
```

### Streaming API

```swift
let stream = session.streamResponse(
    to: "Craft a 3-day itinerary to Mt. Fuji.",
    generating: Itinerary.self
)

for try await partial in stream {
    self.itinerary = partial // Itinerary.PartiallyGenerated
}
```

### SwiftUI Integration

```swift
@State private var itinerary: Itinerary.PartiallyGenerated?

// Render with safe unwrapping
if let title = itinerary?.title {
    Text(title)
}

ForEach(itinerary?.days ?? []) { day in
    DayPlanView(day: day)
        .contentTransition(.numericText())
        .animation(.easeIn, value: itinerary)
}
```

### Best Practices
- Use SwiftUI animations/transitions to hide latency
- Be careful with array view identity
- Declare properties in the order you want them generated

---

## 6. Tool Calling

Enables the model to **autonomously call functions you define** to fetch real-world data during generation.

### How It Works

```
1. Session initialized with tool definitions + instructions
2. User sends prompt
3. Model decides to call one or more tools
4. Framework validates arguments via @Generable (no invalid args possible)
5. Framework executes tool call(s) — parallel if multiple
6. Tool output injected back into transcript
7. Model generates final response using tool outputs
```

### Defining a Tool

```swift
struct GetWeatherTool: Tool {
    let name = "getWeather"                                      // Verb-based, readable
    let description = "Retrieve the latest weather for a city"   // ~1 sentence

    @Generable
    struct Arguments {
        @Guide(description: "The city to fetch the weather for")
        var city: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let places = try await CLGeocoder().geocodeAddressString(arguments.city)
        let weather = try await WeatherService.shared.weather(for: places.first!.location!)
        let temperature = weather.currentWeather.temperature.value
        return ToolOutput("\(arguments.city)'s temperature is \(temperature)°.")
    }
}
```

### Attaching Tools to a Session

```swift
let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "Help the user with weather forecasts."
)
let response = try await session.respond(to: "What is the temperature in Cupertino?")
// Output: "It's 71°F in Cupertino!"
```

### Stateful Tools (use `class`)

```swift
class FindContactTool: Tool {
    var usedContacts = Set<String>()  // Persists across calls within the session

    func call(arguments: Arguments) async throws -> ToolOutput {
        contacts.removeAll { usedContacts.contains($0.givenName) }
        // ...
    }
}
```

### Tool Naming Rules
- Use **verbs**: `findContact`, `getWeather`, `fetchPointsOfInterest`
- Avoid abbreviations
- Keep description to ~1 sentence
- Name + description go **verbatim into the prompt as tokens** — keep them concise

### Privacy Advantage
Since tools run on-device, you can safely pass **Contacts, Calendar, Health, and other personal data** directly to the model — it never leaves the device.

---

## 7. Dynamic Schemas (Runtime)

For structures whose shape is unknown at compile time (e.g., user-defined content types):

```swift
// Build schema at runtime
var riddleBuilder = LevelObjectCreator(name: "Riddle")
riddleBuilder.addStringProperty(name: "question")
riddleBuilder.addArrayProperty(name: "answers", customType: "Answer")

var answerBuilder = LevelObjectCreator(name: "Answer")
answerBuilder.addStringProperty(name: "text")
answerBuilder.addBoolProperty(name: "isCorrect")

let schema = try GenerationSchema(
    root: riddleBuilder.root,
    dependencies: [answerBuilder.root]
)

let response = try await session.respond(
    to: "Generate a fun riddle about coffee",
    schema: schema
)

// Access via property names (returns GeneratedContent, not typed struct)
let question = try response.content.value(String.self, forProperty: "question")
let answers  = try response.content.value([GeneratedContent].self, forProperty: "answers")
```

Still uses guided generation — no unexpected fields possible.

---

## 8. Prompt Design Best Practices

### Control Output Length

```swift
// Shorter
"Generate a bedtime story about a fox in one paragraph."

// Longer
"Generate a bedtime story about a fox in detail."
```

### Assign a Role / Persona

```swift
"You are a fox who speaks Shakespearean English. Write a diary entry."
```

### Key Tips
- **Phrase as a clear, single command**
- **Provide < 5 examples** of desired output directly in the prompt (few-shot prompting)
- Use `"DO NOT"` (all caps) to suppress unwanted behaviors
- Pass `@Generable` instances as examples — framework converts them automatically
- Use `PromptBuilder` for conditional prompts:

```swift
let prompt = Prompt {
    "Generate a 3-day itinerary to Grand Canyon"
    if isFamilyFriendly {
        "The itinerary must be kid-friendly."
    }
}
```

### One-Shot Prompting

```swift
let prompt = Prompt {
    "Generate a \(dayCount) day itinerary to \(landmark.name)"
    "Here is an example of the desired format, but don't copy its content:"
    Itinerary.exampleTripToJapan
}
```

---

## 9. AI Safety

### Apple's Core Safety Principles
1. Empower people
2. Prevent misuse and harm
3. Protect privacy
4. Avoid perpetuating stereotypes and biases

### Built-in Guardrails
- Applied to **both inputs and outputs**
- Covers: instructions, prompts, tool calls, and model responses

### Handling Safety Errors

```swift
do {
    let response = try await session.respond(to: prompt)
} catch {
    // Proactive features: silently ignore
    // User-initiated features: show alert or offer alternatives
}
```

### The Swiss Cheese Safety Model (Layered Defense)

```
Layer 1: Built-in guardrails (Foundation Models framework)
Layer 2: Safety instructions in your session
Layer 3: Controlled / validated user input
Layer 4: Use-case-specific mitigations
```
Safety fails only when **all layers** are bypassed simultaneously.

### User Input Safety Patterns

| Pattern | Flexibility | Risk |
|---|---|---|
| Raw user input as prompt | High | High |
| Your prompt + user input combined | Medium | Medium |
| Curated list of built-in prompts | Low | Low |

### Critical Rule
> **Never interpolate untrusted user input into instructions.** Instructions must only come from you.

### Use-Case Specific Examples
- **Recipe app**: Show allergy warning UI; add dietary restriction filters
- **Trivia app**: Add safety instructions; maintain a keyword deny-list; train a classifier

### Safety Checklist
- [ ] Handle guardrail errors in all prompting code
- [ ] Add safety language to your instructions
- [ ] Validate and sanitize user input before including in prompts
- [ ] Anticipate use-case-specific harms and mitigate
- [ ] Build a test dataset covering safety edge cases
- [ ] Report safety issues via Feedback Assistant

---

## 10. Availability Checking

```swift
let model = SystemLanguageModel.default

switch model.availability {
case .available:
    // Show AI features
case .unavailable(.deviceNotEligible):
    // Hide AI features, show static content
case .unavailable(.appleIntelligenceNotEnabled):
    // Guide user to enable Apple Intelligence in Settings
case .unavailable(.modelNotReady):
    // Model still downloading — ask user to try again later
}
```

### Language Support

```swift
let supported = SystemLanguageModel.default.supportedLanguages
guard supported.contains(Locale.current.language) else { return }
```

### Testing in Xcode
- Edit Scheme → **Simulated Foundation Models Availability** override
- Or: Edit Scheme → **Foundation Models Availability Override**

---

## 11. Developer Tooling

### Xcode Playgrounds (`#Playground` macro)

```swift
import FoundationModels
import Playgrounds

#Playground {
    let session = LanguageModelSession()
    let response = try await session.respond(
        to: "What's a good name for a trip to Japan? Respond only with a title"
    )
}
```

- Iterate on prompts without rebuilding the app
- Works like SwiftUI Previews but for arbitrary Swift code
- Has access to all project types including `@Generable` structs

### Instruments — Foundation Models Template
- Tracks: **Asset Loading**, **Inference**, **Tool Calling**, **Input Token Count**
- Profile model request latency
- Identify optimization opportunities
- Quantify improvements before/after changes

### Feedback Attachment API

```swift
let feedback = LanguageModelFeedbackAttachment(
    input: [...],
    output: [...],
    sentiment: .negative,
    issues: [
        LanguageModelFeedbackAttachment.Issue(
            category: .incorrect,
            explanation: "The model gave wrong directions."
        )
    ],
    desiredOutputExamples: [[...]]
)
let data = try JSONEncoder().encode(feedback)
// Submit via Feedback Assistant
```

### Custom Adapter Training
- Available via **adapter training toolkit** for ML practitioners
- Requires retraining when Apple updates the base model

---

## 12. Performance & Optimization

### Key Metrics to Watch
- **Asset Loading** — time to load system language model + safety guardrail into memory
- **Inference** — time for model to generate tokens
- **Tool Calling** — time your tool functions take to execute
- **Input Token Count** — grows with: instructions + prompt + tool definitions + schema

> Tokens have cost: more input tokens = more latency.

### Optimization 1: Pre-warming

```swift
// Trigger when user signals intent (taps a cell, opens a view)
func prewarm() {
    session.prewarm()
}

// With prompt prefix (even better)
await session.prewarm(
    promptPrefix: Prompt { "Generate a 3-day itinerary to \(landmark.name)" }
)
```

**Result:** Model loads into memory while user reads — near-instant first token when they tap "Generate."

### Optimization 2: Exclude Schema from Prompt

```swift
let response = try await session.respond(
    to: "Create an itinerary.",
    generating: Itinerary.self,
    options: .init(includeSchemaInPrompt: false)
)
```

**When to use:**
- Subsequent turns in a multi-turn session (schema already in context)
- When instructions include a full one-shot example of the schema

**Result:** Token count dropped from ~1,044 → ~700 in code-along demo (33% reduction).

> ⚠️ Trade-off: `@Guide` descriptions are ignored when schema is excluded — rely on thorough examples instead.

### Optimization 3: Greedy Sampling for Tool Calls

```swift
let stream = session.streamResponse(
    to: prompt,
    generating: Itinerary.self,
    options: GenerationOptions(sampling: .greedy)
)
```

Ensures model **reliably calls tools every time** — default random sampling can cause inconsistent tool invocation.

---

## 13. Error Handling

```swift
do {
    let response = try await session.respond(to: prompt)
} catch LanguageModelSession.GenerationError.guardrailViolation {
    // Content violated safety guardrails
} catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
    // User's language not supported
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
    // Session transcript too long — condense and retry
} catch {
    // Other errors
}
```

---

## 14. Specialized Adapters / Use Cases

### Content Tagging Adapter

```swift
// Default: generates topic tags
let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging)
)

// Custom: extract actions + emotions
@Generable struct TagResult {
    @Guide(.maximumCount(3)) let actions: [String]
    @Guide(.maximumCount(3)) let emotions: [String]
}

let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    instructions: "Tag the 3 most important actions and emotions."
)
```

---

## 15. API Quick Reference

| API | Purpose |
|---|---|
| `LanguageModelSession()` | Create a stateful session |
| `session.respond(to:)` | Single async response |
| `session.streamResponse(to:generating:)` | Streaming async sequence |
| `session.prewarm(promptPrefix:)` | Pre-load model into memory |
| `session.transcript` | Full conversation history |
| `session.isResponding` | Bool — whether generation is in progress |
| `@Generable` | Mark struct/enum for model generation |
| `@Guide(description:)` | Hint + constraints for a property |
| `Prompt { }` | PromptBuilder for dynamic prompts |
| `GenerationOptions(sampling: .greedy)` | Deterministic output |
| `T.PartiallyGenerated` | Auto-generated optional mirror for streaming |
| `SystemLanguageModel.default.availability` | Check model availability state |
| `SystemLanguageModel(useCase: .contentTagging)` | Specialized adapter |
| `Tool` protocol | Define a callable tool for the model |
| `ToolOutput` | Return type from a tool's `call()` method |
| `GenerationSchema` | Runtime/dynamic schema building |
| `includeSchemaInPrompt: false` | Reduce token count for performance |
| `LanguageModelFeedbackAttachment` | Structure feedback for Feedback Assistant |

---

## Suggested Keynote Flow

```
Slide 1  — Title: "Foundation Models Framework"
Slide 2  — What is it? (on-device LLM, 4 key benefits)
Slide 3  — The Model (3B params, what it CAN do, what it can't)
Slide 4  — Core API: Sessions (code snippet + multi-turn diagram)
Slide 5  — Guided Generation (flowchart: prompt → @Generable → constrained decode → typed output)
Slide 6  — Snapshot Streaming (UI diagram showing progressive reveal)
Slide 7  — Tool Calling (flowchart: model → tool call → execute → result → response)
Slide 8  — Prompt Design Best Practices (checklist / tips)
Slide 9  — AI Safety (Swiss Cheese model diagram)
Slide 10 — Developer Tooling (#Playground, Instruments)
Slide 11 — Performance Optimization (pre-warm + schema exclusion)
Slide 12 — API Quick Reference table
Slide 13 — Resources & Next Steps
```

---

## Source Videos

| Session | Title |
|---|---|
| WWDC25 #286 | Meet the Foundation Models Framework |
| WWDC25 #248 | Explore Prompt Design & Safety for On-Device Foundation Models |
| WWDC25 #301 | Deep Dive into the Foundation Models Framework |
| WWDC25 #259 | Code-along: Bring On-Device AI to Your App |
| Meet with Apple #205 | Foundation Models Framework Code-Along |
