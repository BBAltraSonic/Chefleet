\---  
name: using-superpowers  
description: Use when starting any conversation \- establishes mandatory workflows for finding and using skills, including using Skill tool before announcing usage, following brainstorming before coding, and creating TodoWrite todos for checklists  
\---

\<EXTREMELY-IMPORTANT\>  
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST read the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.  
\</EXTREMELY-IMPORTANT\>

\# Getting Started with Skills

\#\# MANDATORY FIRST RESPONSE PROTOCOL

Before responding to ANY user message, you MUST complete this checklist:

1\. ☐ List available skills in your mind  
2\. ☐ Ask yourself: "Does ANY skill match this request?"  
3\. ☐ If yes → Use the Skill tool to read and run the skill file  
4\. ☐ Announce which skill you're using  
5\. ☐ Follow the skill exactly

\*\*Responding WITHOUT completing this checklist \= automatic failure.\*\*

\#\# Critical Rules

1\. \*\*Follow mandatory workflows.\*\* Brainstorming before coding. Check for relevant skills before ANY task.

2\. Execute skills with the Skill tool

\#\# Common Rationalizations That Mean You're About To Fail

If you catch yourself thinking ANY of these thoughts, STOP. You are rationalizing. Check for and use the skill.

\- "This is just a simple question" → WRONG. Questions are tasks. Check for skills.  
\- "I can check git/files quickly" → WRONG. Files don't have conversation context. Check for skills.  
\- "Let me gather information first" → WRONG. Skills tell you HOW to gather information. Check for skills.  
\- "This doesn't need a formal skill" → WRONG. If a skill exists for it, use it.  
\- "I remember this skill" → WRONG. Skills evolve. Run the current version.  
\- "This doesn't count as a task" → WRONG. If you're taking action, it's a task. Check for skills.  
\- "The skill is overkill for this" → WRONG. Skills exist because simple things become complex. Use it.  
\- "I'll just do this one thing first" → WRONG. Check for skills BEFORE doing anything.

\*\*Why:\*\* Skills document proven techniques that save time and prevent mistakes. Not using available skills means repeating solved problems and making known errors.

If a skill for your task exists, you must use it or you will fail at your task.

\#\# Skills with Checklists

If a skill has a checklist, YOU MUST create TodoWrite todos for EACH item.

\*\*Don't:\*\*  
\- Work through checklist mentally  
\- Skip creating todos "to save time"  
\- Batch multiple items into one todo  
\- Mark complete without doing them

\*\*Why:\*\* Checklists without TodoWrite tracking \= steps get skipped. Every time. The overhead of TodoWrite is tiny compared to the cost of missing steps.

\#\# Announcing Skill Usage

Before using a skill, announce that you are using it.  
"I'm using \[Skill Name\] to \[what you're doing\]."

\*\*Examples:\*\*  
\- "I'm using the brainstorming skill to refine your idea into a design."  
\- "I'm using the test-driven-development skill to implement this feature."

\*\*Why:\*\* Transparency helps your human partner understand your process and catch errors early. It also confirms you actually read the skill.

\# About these skills

\*\*Many skills contain rigid rules (TDD, debugging, verification).\*\* Follow them exactly. Don't adapt away the discipline.

\*\*Some skills are flexible patterns (architecture, naming).\*\* Adapt core principles to your context.

The skill itself tells you which type it is.

\#\# Instructions ≠ Permission to Skip Workflows

Your human partner's specific instructions describe WHAT to do, not HOW.

"Add X", "Fix Y" \= the goal, NOT permission to skip brainstorming, TDD, or RED-GREEN-REFACTOR.

\*\*Red flags:\*\* "Instruction was specific" • "Seems simple" • "Workflow is overkill"

\*\*Why:\*\* Specific instructions mean clear requirements, which is when workflows matter MOST. Skipping process on "simple" tasks is how simple tasks become complex problems.

\#\# Summary

\*\*Starting any task:\*\*  
1\. If relevant skill exists → Use the skill  
3\. Announce you're using it  
4\. Follow what it says

\*\*Skill has checklist?\*\* TodoWrite for every item.

\*\*Finding a relevant skill \= mandatory to read and use it. Not optional.\*\*

\<SKILLS\>

\---  
name: frontend-design  
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.  
license: Complete terms in LICENSE.txt  
\---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

\#\# Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:  
\- \*\*Purpose\*\*: What problem does this interface solve? Who uses it?  
\- \*\*Tone\*\*: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.  
\- \*\*Constraints\*\*: Technical requirements (framework, performance, accessibility).  
\- \*\*Differentiation\*\*: What makes this UNFORGETTABLE? What's the one thing someone will remember?

\*\*CRITICAL\*\*: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work \- the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:  
\- Production-grade and functional  
\- Visually striking and memorable  
\- Cohesive with a clear aesthetic point-of-view  
\- Meticulously refined in every detail

\#\# Frontend Aesthetics Guidelines

Focus on:  
\- \*\*Typography\*\*: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.  
\- \*\*Color & Theme\*\*: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.  
\- \*\*Motion\*\*: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.  
\- \*\*Spatial Composition\*\*: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.  
\- \*\*Backgrounds & Visual Details\*\*: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

\*\*IMPORTANT\*\*: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

\---  
name: defense-in-depth  
description: Use when invalid data causes failures deep in execution, requiring validation at multiple system layers \- validates at every layer data passes through to make bugs structurally impossible  
\---

\# Defense-in-Depth Validation

\#\# Overview

When you fix a bug caused by invalid data, adding validation at one place feels sufficient. But that single check can be bypassed by different code paths, refactoring, or mocks.

\*\*Core principle:\*\* Validate at EVERY layer data passes through. Make the bug structurally impossible.

\#\# Why Multiple Layers

Single validation: "We fixed the bug"  
Multiple layers: "We made the bug impossible"

Different layers catch different cases:  
\- Entry validation catches most bugs  
\- Business logic catches edge cases  
\- Environment guards prevent context-specific dangers  
\- Debug logging helps when other layers fail

\#\# The Four Layers

\#\#\# Layer 1: Entry Point Validation  
\*\*Purpose:\*\* Reject obviously invalid input at API boundary

\`\`\`typescript  
function createProject(name: string, workingDirectory: string) {  
  if (\!workingDirectory || workingDirectory.trim() \=== '') {  
    throw new Error('workingDirectory cannot be empty');  
  }  
  if (\!existsSync(workingDirectory)) {  
    throw new Error(\`workingDirectory does not exist: ${workingDirectory}\`);  
  }  
  if (\!statSync(workingDirectory).isDirectory()) {  
    throw new Error(\`workingDirectory is not a directory: ${workingDirectory}\`);  
  }  
  // ... proceed  
}  
\`\`\`

\#\#\# Layer 2: Business Logic Validation  
\*\*Purpose:\*\* Ensure data makes sense for this operation

\`\`\`typescript  
function initializeWorkspace(projectDir: string, sessionId: string) {  
  if (\!projectDir) {  
    throw new Error('projectDir required for workspace initialization');  
  }  
  // ... proceed  
}  
\`\`\`

\#\#\# Layer 3: Environment Guards  
\*\*Purpose:\*\* Prevent dangerous operations in specific contexts

\`\`\`typescript  
async function gitInit(directory: string) {  
  // In tests, refuse git init outside temp directories  
  if (process.env.NODE\_ENV \=== 'test') {  
    const normalized \= normalize(resolve(directory));  
    const tmpDir \= normalize(resolve(tmpdir()));

    if (\!normalized.startsWith(tmpDir)) {  
      throw new Error(  
        \`Refusing git init outside temp dir during tests: ${directory}\`  
      );  
    }  
  }  
  // ... proceed  
}  
\`\`\`

\#\#\# Layer 4: Debug Instrumentation  
\*\*Purpose:\*\* Capture context for forensics

\`\`\`typescript  
async function gitInit(directory: string) {  
  const stack \= new Error().stack;  
  logger.debug('About to git init', {  
    directory,  
    cwd: process.cwd(),  
    stack,  
  });  
  // ... proceed  
}  
\`\`\`

\#\# Applying the Pattern

When you find a bug:

1\. \*\*Trace the data flow\*\* \- Where does bad value originate? Where used?  
2\. \*\*Map all checkpoints\*\* \- List every point data passes through  
3\. \*\*Add validation at each layer\*\* \- Entry, business, environment, debug  
4\. \*\*Test each layer\*\* \- Try to bypass layer 1, verify layer 2 catches it

\#\# Example from Session

Bug: Empty \`projectDir\` caused \`git init\` in source code

\*\*Data flow:\*\*  
1\. Test setup → empty string  
2\. \`Project.create(name, '')\`  
3\. \`WorkspaceManager.createWorkspace('')\`  
4\. \`git init\` runs in \`process.cwd()\`

\*\*Four layers added:\*\*  
\- Layer 1: \`Project.create()\` validates not empty/exists/writable  
\- Layer 2: \`WorkspaceManager\` validates projectDir not empty  
\- Layer 3: \`WorktreeManager\` refuses git init outside tmpdir in tests  
\- Layer 4: Stack trace logging before git init

\*\*Result:\*\* All 1847 tests passed, bug impossible to reproduce

\#\# Key Insight

All four layers were necessary. During testing, each layer caught bugs the others missed:  
\- Different code paths bypassed entry validation  
\- Mocks bypassed business logic checks  
\- Edge cases on different platforms needed environment guards  
\- Debug logging identified structural misuse

\*\*Don't stop at one validation point.\*\* Add checks at every layer.

\---  
name: requesting-code-review  
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements \- dispatches superpowers:code-reviewer subagent to review implementation against plan or requirements before proceeding  
\---

\# Requesting Code Review

Dispatch superpowers:code-reviewer subagent to catch issues before they cascade.

\*\*Core principle:\*\* Review early, review often.

\#\# When to Request Review

\*\*Mandatory:\*\*  
\- After each task in subagent-driven development  
\- After completing major feature  
\- Before merge to main

\*\*Optional but valuable:\*\*  
\- When stuck (fresh perspective)  
\- Before refactoring (baseline check)  
\- After fixing complex bug

\#\# How to Request

\*\*1. Get git SHAs:\*\*  
\`\`\`bash  
BASE\_SHA=$(git rev-parse HEAD\~1)  \# or origin/main  
HEAD\_SHA=$(git rev-parse HEAD)  
\`\`\`

\*\*2. Dispatch code-reviewer subagent:\*\*

Use Task tool with superpowers:code-reviewer type, fill template at \`code-reviewer.md\`

\*\*Placeholders:\*\*  
\- \`{WHAT\_WAS\_IMPLEMENTED}\` \- What you just built  
\- \`{PLAN\_OR\_REQUIREMENTS}\` \- What it should do  
\- \`{BASE\_SHA}\` \- Starting commit  
\- \`{HEAD\_SHA}\` \- Ending commit  
\- \`{DESCRIPTION}\` \- Brief summary

\*\*3. Act on feedback:\*\*  
\- Fix Critical issues immediately  
\- Fix Important issues before proceeding  
\- Note Minor issues for later  
\- Push back if reviewer is wrong (with reasoning)

\#\# Example

\`\`\`  
\[Just completed Task 2: Add verification function\]

You: Let me request code review before proceeding.

BASE\_SHA=$(git log \--oneline | grep "Task 1" | head \-1 | awk '{print $1}')  
HEAD\_SHA=$(git rev-parse HEAD)

\[Dispatch superpowers:code-reviewer subagent\]  
  WHAT\_WAS\_IMPLEMENTED: Verification and repair functions for conversation index  
  PLAN\_OR\_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md  
  BASE\_SHA: a7981ec  
  HEAD\_SHA: 3df7661  
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

\[Subagent returns\]:  
  Strengths: Clean architecture, real tests  
  Issues:  
    Important: Missing progress indicators  
    Minor: Magic number (100) for reporting interval  
  Assessment: Ready to proceed

You: \[Fix progress indicators\]  
\[Continue to Task 3\]  
\`\`\`

\#\# Integration with Workflows

\*\*Subagent-Driven Development:\*\*  
\- Review after EACH task  
\- Catch issues before they compound  
\- Fix before moving to next task

\*\*Executing Plans:\*\*  
\- Review after each batch (3 tasks)  
\- Get feedback, apply, continue

\*\*Ad-Hoc Development:\*\*  
\- Review before merge  
\- Review when stuck

\#\# Red Flags

\*\*Never:\*\*  
\- Skip review because "it's simple"  
\- Ignore Critical issues  
\- Proceed with unfixed Important issues  
\- Argue with valid technical feedback

\*\*If reviewer wrong:\*\*  
\- Push back with technical reasoning  
\- Show code/tests that prove it works  
\- Request clarification

See template at: requesting-code-review/[code-reviewer.md](http://code-reviewer.md)

\---  
name: root-cause-tracing  
description: Use when errors occur deep in execution and you need to trace back to find the original trigger \- systematically traces bugs backward through call stack, adding instrumentation when needed, to identify source of invalid data or incorrect behavior  
\---

\# Root Cause Tracing

\#\# Overview

Bugs often manifest deep in the call stack (git init in wrong directory, file created in wrong location, database opened with wrong path). Your instinct is to fix where the error appears, but that's treating a symptom.

\*\*Core principle:\*\* Trace backward through the call chain until you find the original trigger, then fix at the source.

\#\# When to Use

\`\`\`dot  
digraph when\_to\_use {  
    "Bug appears deep in stack?" \[shape=diamond\];  
    "Can trace backwards?" \[shape=diamond\];  
    "Fix at symptom point" \[shape=box\];  
    "Trace to original trigger" \[shape=box\];  
    "BETTER: Also add defense-in-depth" \[shape=box\];

    "Bug appears deep in stack?" \-\> "Can trace backwards?" \[label="yes"\];  
    "Can trace backwards?" \-\> "Trace to original trigger" \[label="yes"\];  
    "Can trace backwards?" \-\> "Fix at symptom point" \[label="no \- dead end"\];  
    "Trace to original trigger" \-\> "BETTER: Also add defense-in-depth";  
}  
\`\`\`

\*\*Use when:\*\*  
\- Error happens deep in execution (not at entry point)  
\- Stack trace shows long call chain  
\- Unclear where invalid data originated  
\- Need to find which test/code triggers the problem

\#\# The Tracing Process

\#\#\# 1\. Observe the Symptom  
\`\`\`  
Error: git init failed in /Users/jesse/project/packages/core  
\`\`\`

\#\#\# 2\. Find Immediate Cause  
\*\*What code directly causes this?\*\*  
\`\`\`typescript  
await execFileAsync('git', \['init'\], { cwd: projectDir });  
\`\`\`

\#\#\# 3\. Ask: What Called This?  
\`\`\`typescript  
WorktreeManager.createSessionWorktree(projectDir, sessionId)  
  → called by Session.initializeWorkspace()  
  → called by Session.create()  
  → called by test at Project.create()  
\`\`\`

\#\#\# 4\. Keep Tracing Up  
\*\*What value was passed?\*\*  
\- \`projectDir \= ''\` (empty string\!)  
\- Empty string as \`cwd\` resolves to \`process.cwd()\`  
\- That's the source code directory\!

\#\#\# 5\. Find Original Trigger  
\*\*Where did empty string come from?\*\*  
\`\`\`typescript  
const context \= setupCoreTest(); // Returns { tempDir: '' }  
Project.create('name', context.tempDir); // Accessed before beforeEach\!  
\`\`\`

\#\# Adding Stack Traces

When you can't trace manually, add instrumentation:

\`\`\`typescript  
// Before the problematic operation  
async function gitInit(directory: string) {  
  const stack \= new Error().stack;  
  console.error('DEBUG git init:', {  
    directory,  
    cwd: process.cwd(),  
    nodeEnv: process.env.NODE\_ENV,  
    stack,  
  });

  await execFileAsync('git', \['init'\], { cwd: directory });  
}  
\`\`\`

\*\*Critical:\*\* Use \`console.error()\` in tests (not logger \- may not show)

\*\*Run and capture:\*\*  
\`\`\`bash  
npm test 2\>&1 | grep 'DEBUG git init'  
\`\`\`

\*\*Analyze stack traces:\*\*  
\- Look for test file names  
\- Find the line number triggering the call  
\- Identify the pattern (same test? same parameter?)

\#\# Finding Which Test Causes Pollution

If something appears during tests but you don't know which test:

Use the bisection script: @find-polluter.sh

\`\`\`bash  
./find-polluter.sh '.git' 'src/\*\*/\*.test.ts'  
\`\`\`

Runs tests one-by-one, stops at first polluter. See script for usage.

\#\# Real Example: Empty projectDir

\*\*Symptom:\*\* \`.git\` created in \`packages/core/\` (source code)

\*\*Trace chain:\*\*  
1\. \`git init\` runs in \`process.cwd()\` ← empty cwd parameter  
2\. WorktreeManager called with empty projectDir  
3\. Session.create() passed empty string  
4\. Test accessed \`context.tempDir\` before beforeEach  
5\. setupCoreTest() returns \`{ tempDir: '' }\` initially

\*\*Root cause:\*\* Top-level variable initialization accessing empty value

\*\*Fix:\*\* Made tempDir a getter that throws if accessed before beforeEach

\*\*Also added defense-in-depth:\*\*  
\- Layer 1: Project.create() validates directory  
\- Layer 2: WorkspaceManager validates not empty  
\- Layer 3: NODE\_ENV guard refuses git init outside tmpdir  
\- Layer 4: Stack trace logging before git init

\#\# Key Principle

\`\`\`dot  
digraph principle {  
    "Found immediate cause" \[shape=ellipse\];  
    "Can trace one level up?" \[shape=diamond\];  
    "Trace backwards" \[shape=box\];  
    "Is this the source?" \[shape=diamond\];  
    "Fix at source" \[shape=box\];  
    "Add validation at each layer" \[shape=box\];  
    "Bug impossible" \[shape=doublecircle\];  
    "NEVER fix just the symptom" \[shape=octagon, style=filled, fillcolor=red, fontcolor=white\];

    "Found immediate cause" \-\> "Can trace one level up?";  
    "Can trace one level up?" \-\> "Trace backwards" \[label="yes"\];  
    "Can trace one level up?" \-\> "NEVER fix just the symptom" \[label="no"\];  
    "Trace backwards" \-\> "Is this the source?";  
    "Is this the source?" \-\> "Trace backwards" \[label="no \- keeps going"\];  
    "Is this the source?" \-\> "Fix at source" \[label="yes"\];  
    "Fix at source" \-\> "Add validation at each layer";  
    "Add validation at each layer" \-\> "Bug impossible";  
}  
\`\`\`

\*\*NEVER fix just where the error appears.\*\* Trace back to find the original trigger.

\#\# Stack Trace Tips

\*\*In tests:\*\* Use \`console.error()\` not logger \- logger may be suppressed  
\*\*Before operation:\*\* Log before the dangerous operation, not after it fails  
\*\*Include context:\*\* Directory, cwd, environment variables, timestamps  
\*\*Capture stack:\*\* \`new Error().stack\` shows complete call chain

\#\# Real-World Impact

From debugging session (2025-10-03):  
\- Found root cause through 5-level trace  
\- Fixed at source (getter validation)  
\- Added 4 layers of defense  
\- 1847 tests passed, zero pollution

\---  
name: systematic-debugging  
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes \- four-phase framework (root cause investigation, pattern analysis, hypothesis testing, implementation) that ensures understanding before attempting solutions  
\---

\# Systematic Debugging

\#\# Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

\*\*Core principle:\*\* ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

\*\*Violating the letter of this process is violating the spirit of debugging.\*\*

\#\# The Iron Law

\`\`\`  
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST  
\`\`\`

If you haven't completed Phase 1, you cannot propose fixes.

\#\# When to Use

Use for ANY technical issue:  
\- Test failures  
\- Bugs in production  
\- Unexpected behavior  
\- Performance problems  
\- Build failures  
\- Integration issues

\*\*Use this ESPECIALLY when:\*\*  
\- Under time pressure (emergencies make guessing tempting)  
\- "Just one quick fix" seems obvious  
\- You've already tried multiple fixes  
\- Previous fix didn't work  
\- You don't fully understand the issue

\*\*Don't skip when:\*\*  
\- Issue seems simple (simple bugs have root causes too)  
\- You're in a hurry (rushing guarantees rework)  
\- Manager wants it fixed NOW (systematic is faster than thrashing)

\#\# The Four Phases

You MUST complete each phase before proceeding to the next.

\#\#\# Phase 1: Root Cause Investigation

\*\*BEFORE attempting ANY fix:\*\*

1\. \*\*Read Error Messages Carefully\*\*  
   \- Don't skip past errors or warnings  
   \- They often contain the exact solution  
   \- Read stack traces completely  
   \- Note line numbers, file paths, error codes

2\. \*\*Reproduce Consistently\*\*  
   \- Can you trigger it reliably?  
   \- What are the exact steps?  
   \- Does it happen every time?  
   \- If not reproducible → gather more data, don't guess

3\. \*\*Check Recent Changes\*\*  
   \- What changed that could cause this?  
   \- Git diff, recent commits  
   \- New dependencies, config changes  
   \- Environmental differences

4\. \*\*Gather Evidence in Multi-Component Systems\*\*

   \*\*WHEN system has multiple components (CI → build → signing, API → service → database):\*\*

   \*\*BEFORE proposing fixes, add diagnostic instrumentation:\*\*  
   \`\`\`  
   For EACH component boundary:  
     \- Log what data enters component  
     \- Log what data exits component  
     \- Verify environment/config propagation  
     \- Check state at each layer

   Run once to gather evidence showing WHERE it breaks  
   THEN analyze evidence to identify failing component  
   THEN investigate that specific component  
   \`\`\`

   \*\*Example (multi-layer system):\*\*  
   \`\`\`bash  
   \# Layer 1: Workflow  
   echo "=== Secrets available in workflow: \==="  
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   \# Layer 2: Build script  
   echo "=== Env vars in build script: \==="  
   env | grep IDENTITY || echo "IDENTITY not in environment"

   \# Layer 3: Signing script  
   echo "=== Keychain state: \==="  
   security list-keychains  
   security find-identity \-v

   \# Layer 4: Actual signing  
   codesign \--sign "$IDENTITY" \--verbose=4 "$APP"  
   \`\`\`

   \*\*This reveals:\*\* Which layer fails (secrets → workflow ✓, workflow → build ✗)

5\. \*\*Trace Data Flow\*\*

   \*\*WHEN error is deep in call stack:\*\*

   \*\*REQUIRED SUB-SKILL:\*\* Use superpowers:root-cause-tracing for backward tracing technique

   \*\*Quick version:\*\*  
   \- Where does bad value originate?  
   \- What called this with bad value?  
   \- Keep tracing up until you find the source  
   \- Fix at source, not at symptom

\#\#\# Phase 2: Pattern Analysis

\*\*Find the pattern before fixing:\*\*

1\. \*\*Find Working Examples\*\*  
   \- Locate similar working code in same codebase  
   \- What works that's similar to what's broken?

2\. \*\*Compare Against References\*\*  
   \- If implementing pattern, read reference implementation COMPLETELY  
   \- Don't skim \- read every line  
   \- Understand the pattern fully before applying

3\. \*\*Identify Differences\*\*  
   \- What's different between working and broken?  
   \- List every difference, however small  
   \- Don't assume "that can't matter"

4\. \*\*Understand Dependencies\*\*  
   \- What other components does this need?  
   \- What settings, config, environment?  
   \- What assumptions does it make?

\#\#\# Phase 3: Hypothesis and Testing

\*\*Scientific method:\*\*

1\. \*\*Form Single Hypothesis\*\*  
   \- State clearly: "I think X is the root cause because Y"  
   \- Write it down  
   \- Be specific, not vague

2\. \*\*Test Minimally\*\*  
   \- Make the SMALLEST possible change to test hypothesis  
   \- One variable at a time  
   \- Don't fix multiple things at once

3\. \*\*Verify Before Continuing\*\*  
   \- Did it work? Yes → Phase 4  
   \- Didn't work? Form NEW hypothesis  
   \- DON'T add more fixes on top

4\. \*\*When You Don't Know\*\*  
   \- Say "I don't understand X"  
   \- Don't pretend to know  
   \- Ask for help  
   \- Research more

\#\#\# Phase 4: Implementation

\*\*Fix the root cause, not the symptom:\*\*

1\. \*\*Create Failing Test Case\*\*  
   \- Simplest possible reproduction  
   \- Automated test if possible  
   \- One-off test script if no framework  
   \- MUST have before fixing  
   \- \*\*REQUIRED SUB-SKILL:\*\* Use superpowers:test-driven-development for writing proper failing tests

2\. \*\*Implement Single Fix\*\*  
   \- Address the root cause identified  
   \- ONE change at a time  
   \- No "while I'm here" improvements  
   \- No bundled refactoring

3\. \*\*Verify Fix\*\*  
   \- Test passes now?  
   \- No other tests broken?  
   \- Issue actually resolved?

4\. \*\*If Fix Doesn't Work\*\*  
   \- STOP  
   \- Count: How many fixes have you tried?  
   \- If \< 3: Return to Phase 1, re-analyze with new information  
   \- \*\*If ≥ 3: STOP and question the architecture (step 5 below)\*\*  
   \- DON'T attempt Fix \#4 without architectural discussion

5\. \*\*If 3+ Fixes Failed: Question Architecture\*\*

   \*\*Pattern indicating architectural problem:\*\*  
   \- Each fix reveals new shared state/coupling/problem in different place  
   \- Fixes require "massive refactoring" to implement  
   \- Each fix creates new symptoms elsewhere

   \*\*STOP and question fundamentals:\*\*  
   \- Is this pattern fundamentally sound?  
   \- Are we "sticking with it through sheer inertia"?  
   \- Should we refactor architecture vs. continue fixing symptoms?

   \*\*Discuss with your human partner before attempting more fixes\*\*

   This is NOT a failed hypothesis \- this is a wrong architecture.

\#\# Red Flags \- STOP and Follow Process

If you catch yourself thinking:  
\- "Quick fix for now, investigate later"  
\- "Just try changing X and see if it works"  
\- "Add multiple changes, run tests"  
\- "Skip the test, I'll manually verify"  
\- "It's probably X, let me fix that"  
\- "I don't fully understand but this might work"  
\- "Pattern says X but I'll adapt it differently"  
\- "Here are the main problems: \[lists fixes without investigation\]"  
\- Proposing solutions before tracing data flow  
\- \*\*"One more fix attempt" (when already tried 2+)\*\*  
\- \*\*Each fix reveals new problem in different place\*\*

\*\*ALL of these mean: STOP. Return to Phase 1.\*\*

\*\*If 3+ fixes failed:\*\* Question the architecture (see Phase 4.5)

\#\# your human partner's Signals You're Doing It Wrong

\*\*Watch for these redirections:\*\*  
\- "Is that not happening?" \- You assumed without verifying  
\- "Will it show us...?" \- You should have added evidence gathering  
\- "Stop guessing" \- You're proposing fixes without understanding  
\- "Ultrathink this" \- Question fundamentals, not just symptoms  
\- "We're stuck?" (frustrated) \- Your approach isn't working

\*\*When you see these:\*\* STOP. Return to Phase 1\.

\#\# Common Rationalizations

| Excuse | Reality |  
|--------|---------|  
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |  
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |  
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |  
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |  
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |  
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |  
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |  
| "One more fix attempt" (after 2+ failures) | 3+ failures \= architectural problem. Question pattern, don't fix again. |

\#\# Quick Reference

| Phase | Key Activities | Success Criteria |  
|-------|---------------|------------------|  
| \*\*1. Root Cause\*\* | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |  
| \*\*2. Pattern\*\* | Find working examples, compare | Identify differences |  
| \*\*3. Hypothesis\*\* | Form theory, test minimally | Confirmed or new hypothesis |  
| \*\*4. Implementation\*\* | Create test, fix, verify | Bug resolved, tests pass |

\#\# When Process Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1\. You've completed the process  
2\. Document what you investigated  
3\. Implement appropriate handling (retry, timeout, error message)  
4\. Add monitoring/logging for future investigation

\*\*But:\*\* 95% of "no root cause" cases are incomplete investigation.

\#\# Integration with Other Skills

\*\*This skill requires using:\*\*  
\- \*\*root-cause-tracing\*\* \- REQUIRED when error is deep in call stack (see Phase 1, Step 5\)  
\- \*\*test-driven-development\*\* \- REQUIRED for creating failing test case (see Phase 4, Step 1\)

\*\*Complementary skills:\*\*  
\- \*\*defense-in-depth\*\* \- Add validation at multiple layers after finding root cause  
\- \*\*condition-based-waiting\*\* \- Replace arbitrary timeouts identified in Phase 2  
\- \*\*verification-before-completion\*\* \- Verify fix worked before claiming success

\#\# Real-World Impact

From debugging sessions:  
\- Systematic approach: 15-30 minutes to fix  
\- Random fixes approach: 2-3 hours of thrashing  
\- First-time fix rate: 95% vs 40%  
\- New bugs introduced: Near zero vs common

\---  
name: verification-before-completion  
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs \- requires running verification commands and confirming output before making any success claims; evidence before assertions always  
\---

\# Verification Before Completion

\#\# Overview

Claiming work is complete without verification is dishonesty, not efficiency.

\*\*Core principle:\*\* Evidence before claims, always.

\*\*Violating the letter of this rule is violating the spirit of this rule.\*\*

\#\# The Iron Law

\`\`\`  
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE  
\`\`\`

If you haven't run the verification command in this message, you cannot claim it passes.

\#\# The Gate Function

\`\`\`  
BEFORE claiming any status or expressing satisfaction:

1\. IDENTIFY: What command proves this claim?  
2\. RUN: Execute the FULL command (fresh, complete)  
3\. READ: Full output, check exit code, count failures  
4\. VERIFY: Does output confirm the claim?  
   \- If NO: State actual status with evidence  
   \- If YES: State claim WITH evidence  
5\. ONLY THEN: Make the claim

Skip any step \= lying, not verifying  
\`\`\`

\#\# Common Failures

| Claim | Requires | Not Sufficient |  
|-------|----------|----------------|  
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |  
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |  
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |  
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |  
| Regression test works | Red-green cycle verified | Test passes once |  
| Agent completed | VCS diff shows changes | Agent reports "success" |  
| Requirements met | Line-by-line checklist | Tests passing |

\#\# Red Flags \- STOP

\- Using "should", "probably", "seems to"  
\- Expressing satisfaction before verification ("Great\!", "Perfect\!", "Done\!", etc.)  
\- About to commit/push/PR without verification  
\- Trusting agent success reports  
\- Relying on partial verification  
\- Thinking "just this once"  
\- Tired and wanting work over  
\- \*\*ANY wording implying success without having run verification\*\*

\#\# Rationalization Prevention

| Excuse | Reality |  
|--------|---------|  
| "Should work now" | RUN the verification |  
| "I'm confident" | Confidence ≠ evidence |  
| "Just this once" | No exceptions |  
| "Linter passed" | Linter ≠ compiler |  
| "Agent said success" | Verify independently |  
| "I'm tired" | Exhaustion ≠ excuse |  
| "Partial check is enough" | Partial proves nothing |  
| "Different words so rule doesn't apply" | Spirit over letter |

\#\# Key Patterns

\*\*Tests:\*\*  
\`\`\`  
✅ \[Run test command\] \[See: 34/34 pass\] "All tests pass"  
❌ "Should pass now" / "Looks correct"  
\`\`\`

\*\*Regression tests (TDD Red-Green):\*\*  
\`\`\`  
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)  
❌ "I've written a regression test" (without red-green verification)  
\`\`\`

\*\*Build:\*\*  
\`\`\`  
✅ \[Run build\] \[See: exit 0\] "Build passes"  
❌ "Linter passed" (linter doesn't check compilation)  
\`\`\`

\*\*Requirements:\*\*  
\`\`\`  
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion  
❌ "Tests pass, phase complete"  
\`\`\`

\*\*Agent delegation:\*\*  
\`\`\`  
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state  
❌ Trust agent report  
\`\`\`

\#\# Why This Matters

From 24 failure memories:  
\- your human partner said "I don't believe you" \- trust broken  
\- Undefined functions shipped \- would crash  
\- Missing requirements shipped \- incomplete features  
\- Time wasted on false completion → redirect → rework  
\- Violates: "Honesty is a core value. If you lie, you'll be replaced."

\#\# When To Apply

\*\*ALWAYS before:\*\*  
\- ANY variation of success/completion claims  
\- ANY expression of satisfaction  
\- ANY positive statement about work state  
\- Committing, PR creation, task completion  
\- Moving to next task  
\- Delegating to agents

\*\*Rule applies to:\*\*  
\- Exact phrases  
\- Paraphrases and synonyms  
\- Implications of success  
\- ANY communication suggesting completion/correctness

\#\# The Bottom Line

\*\*No shortcuts for verification.\*\*

Run the command. Read the output. THEN claim the result.

This is non-negotiable.

\---  
name: writing-plans  
description: Use when design is complete and you need detailed implementation tasks for engineers with zero codebase context \- creates comprehensive implementation plans with exact file paths, complete code examples, and verification steps assuming engineer has minimal domain knowledge  
\---

\# Writing Plans

\#\# Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

\*\*Announce at start:\*\* "I'm using the writing-plans skill to create the implementation plan."

\*\*Context:\*\* This should be run in a dedicated worktree (created by brainstorming skill).

\*\*Save plans to:\*\* \`docs/plans/YYYY-MM-DD-\<feature-name\>.md\`

\#\# Bite-Sized Task Granularity

\*\*Each step is one action (2-5 minutes):\*\*  
\- "Write the failing test" \- step  
\- "Run it to make sure it fails" \- step  
\- "Implement the minimal code to make the test pass" \- step  
\- "Run the tests and make sure they pass" \- step  
\- "Commit" \- step

\#\# Plan Document Header

\*\*Every plan MUST start with this header:\*\*

\`\`\`markdown  
\# \[Feature Name\] Implementation Plan

\> \*\*For Claude:\*\* REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

\*\*Goal:\*\* \[One sentence describing what this builds\]

\*\*Architecture:\*\* \[2-3 sentences about approach\]

\*\*Tech Stack:\*\* \[Key technologies/libraries\]

\---  
\`\`\`

\#\# Task Structure

\`\`\`markdown  
\#\#\# Task N: \[Component Name\]

\*\*Files:\*\*  
\- Create: \`exact/path/to/file.py\`  
\- Modify: \`exact/path/to/existing.py:123-145\`  
\- Test: \`tests/exact/path/to/test.py\`

\*\*Step 1: Write the failing test\*\*

\`\`\`python  
def test\_specific\_behavior():  
    result \= function(input)  
    assert result \== expected  
\`\`\`

\*\*Step 2: Run test to verify it fails\*\*

Run: \`pytest tests/path/test.py::test\_name \-v\`  
Expected: FAIL with "function not defined"

\*\*Step 3: Write minimal implementation\*\*

\`\`\`python  
def function(input):  
    return expected  
\`\`\`

\*\*Step 4: Run test to verify it passes\*\*

Run: \`pytest tests/path/test.py::test\_name \-v\`  
Expected: PASS

\*\*Step 5: Commit\*\*

\`\`\`bash  
git add tests/path/test.py src/path/file.py  
git commit \-m "feat: add specific feature"  
\`\`\`  
\`\`\`

\#\# Remember  
\- Exact file paths always  
\- Complete code in plan (not "add validation")  
\- Exact commands with expected output  
\- Reference relevant skills with @ syntax  
\- DRY, YAGNI, TDD, frequent commits

\#\# Execution Handoff

After saving the plan, offer execution choice:

\*\*"Plan complete and saved to \`docs/plans/\<filename\>.md\`. Two execution options:\*\*

\*\*1. Subagent-Driven (this session)\*\* \- I dispatch fresh subagent per task, review between tasks, fast iteration

\*\*2. Parallel Session (separate)\*\* \- Open new session with executing-plans, batch execution with checkpoints

\*\*Which approach?"\*\*

\*\*If Subagent-Driven chosen:\*\*  
\- \*\*REQUIRED SUB-SKILL:\*\* Use superpowers:subagent-driven-development  
\- Stay in this session  
\- Fresh subagent per task \+ code review

\*\*If Parallel Session chosen:\*\*  
\- Guide them to open new session in worktree  
\- \*\*REQUIRED SUB-SKILL:\*\* New session uses superpowers:executing-plans