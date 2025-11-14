# First Day Quick Start Guide

## 🎯 Today's Mission (3-4 hours)
By the end of today, you'll have a Flutter project with proper structure and understand why games need different architecture than typical apps.

---

## Before You Start (30 minutes)

### 1. Install Flutter (if not already installed)
```bash
# Check if Flutter is installed
flutter --version

# If not installed, go to: https://docs.flutter.dev/get-started/install
```

### 2. Set Up Your IDE
**VS Code (Recommended):**
```bash
# Install extensions:
# - Flutter
# - Dart
# - Error Lens (helpful for real-time errors)
```

**Or Android Studio:**
- Already has Flutter/Dart support built-in

### 3. Create Project Directory
```bash
# Create a workspace
mkdir ~/workspace/puzzle-game
cd ~/workspace/puzzle-game
```

---

## Step 1: Create Flutter Project (10 minutes)

```bash
# Create new Flutter project
flutter create puzzle_game_suite

# Enter directory
cd puzzle_game_suite

# Run to verify it works
flutter run
```

**What you should see:**
- Flutter demo app appears
- Hot reload works

**Stop the app** (Ctrl+C or Cmd+C)

---

## Step 2: Open Claude Code (5 minutes)

### Option A: Terminal
```bash
# From your project directory
code .
# Then open integrated terminal and run:
# claude

# Or directly:
claude
```

### Option B: Desktop App
- Open Claude desktop
- Enable Claude Code
- Navigate to your project directory

---

## Step 3: Paste the Main Prompt

**Copy everything from `claude_code_prompt.md`** and paste into Claude Code.

**Important:** Tell Claude Code you're starting fresh at Day 1.

Say something like:
> "I'm Eric, starting Day 1 of this project. I've created the Flutter project 'puzzle_game_suite' and I'm ready to learn. Let's begin with setting up the project structure. Please explain the architecture decisions as we go."

---

## Step 4: Work Through Project Setup with Claude Code (2 hours)

Claude Code will guide you through:

### 4.1 Understanding Game Architecture
- Why games are different from apps
- What patterns we'll use
- How code will be organized

**Your job:** Ask questions! Understand the WHY.

Example questions to ask:
- "Why do we separate game logic from UI?"
- "What's the difference between game state and widget state?"
- "Why do we need immutable state?"

### 4.2 Creating Folder Structure
Claude will help you create:
```
lib/
├── main.dart
├── core/
│   ├── engine/
│   ├── models/
│   └── services/
├── features/
│   ├── game/
│   ├── levels/
│   ├── home/
│   └── settings/
├── shared/
│   ├── widgets/
│   ├── constants/
│   └── utils/
└── config/
```

**Your job:** Create these folders and understand what goes where.

Ask Claude:
- "What types of files go in core/engine vs features/game?"
- "Why do we separate these concerns?"

### 4.3 Set Up Basic Routing
Claude will help create simple navigation:
- Home screen
- Game screen
- Settings screen

**Your job:** Get basic routing working and understand it.

### 4.4 Get Something on Screen
By end of today, you should see:
- A simple home screen
- A button that navigates to game screen
- Game screen showing placeholder text

**This proves:** Your project structure works!

---

## Step 5: First Learning Checkpoint (30 minutes)

### Stop and Reflect

**Write down (or tell Claude Code):**

1. **What did I learn today?**
   - Example: "I learned that game state should be immutable because..."
   
2. **What makes game architecture different?**
   - In your own words, explain the difference
   
3. **What are the main folders for?**
   - core/ is for...
   - features/ is for...
   - shared/ is for...

4. **What questions do I still have?**
   - Write them down to ask Claude Code tomorrow

### Quick Quiz (Answer without looking)

1. Why do we separate game logic from UI code?
2. What does "immutable state" mean?
3. Where would you put code for move validation?
4. Where would you put code for drawing a container?

**If you can't answer these:** That's OK! Ask Claude Code to explain again.

---

## Step 6: Commit Your Work (10 minutes)

```bash
# Initialize git if not already
git init

# Create .gitignore (Flutter already has one, but verify)
# Add these if missing:
# *.lock
# .idea/
# .vscode/

# First commit
git add .
git commit -m "feat: initial project structure and routing setup

- Created folder structure for game architecture
- Set up basic routing (home, game, settings)
- Added placeholder screens
- Learning: understanding game vs app architecture"
```

**Why detailed commit message?**
- Documents your learning journey
- Shows client your progress
- Helps you remember what you did

---

## End of Day 1 Checklist

- [ ] Flutter project created and runs
- [ ] Project structure created (folders)
- [ ] Basic routing working
- [ ] Can navigate between screens
- [ ] Understand why games need different architecture
- [ ] Code committed to git
- [ ] Learning reflection written
- [ ] Tomorrow's plan clear (Day 2: Container class)

---

## Common Issues & Solutions

### Issue: "flutter: command not found"
**Solution:**
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Or install Flutter properly:
# https://docs.flutter.dev/get-started/install
```

### Issue: "Hot reload not working"
**Solution:**
- Stop the app
- Run: `flutter clean`
- Run: `flutter run` again

### Issue: "Claude Code not available"
**Solution:**
- Check Claude desktop app is running
- Verify Claude Code is enabled in settings
- Try terminal: `claude` command

### Issue: "Feeling overwhelmed by new concepts"
**Solution:**
- This is normal! Game dev is different.
- Focus on understanding one concept at a time
- Ask Claude Code to explain in simpler terms
- Connect new concepts to what you already know (backend, databases)
- Take breaks when needed

### Issue: "Code not making sense"
**Solution:**
- Ask Claude Code: "Can you explain this in terms of Laravel/backend concepts?"
- Ask for analogies
- Ask Claude to break it down smaller
- It's OK to not understand everything on Day 1

---

## Tomorrow Preview (Day 2)

**Goal:** Build the Container class

**What you'll learn:**
- Creating immutable data models
- Using Dart's class features
- Writing unit tests for game logic
- Why immutability matters

**What you'll build:**
- Container class with all properties
- Unit tests proving it works
- Understanding of your core data model

**Prep:**
- Read Quick Reference section on Container
- Think about what a container needs to track
- Rest your brain - tomorrow is logic-heavy

---

## Quick Reference During Day 1

### What Goes Where?

**core/engine/** - Pure game logic (no UI)
- Move validation
- Game rules
- Win conditions
- Solver algorithm

**features/game/** - Game UI and interaction
- Game screen
- Container widgets
- Game controller (state management)

**shared/** - Reusable across app
- Common widgets
- Constants (colors, sizes)
- Helper functions

**config/** - App-wide settings
- Theme configuration
- Routes
- Environment settings

### Key Concepts to Understand

**Immutable State:**
```dart
// Bad (mutable)
container.addColor(red);

// Good (immutable)
final newContainer = container.withColorAdded(red);
```

**Separation of Concerns:**
```
Data (Container) ← Logic (MoveValidator) → UI (ContainerWidget)
     ↓                       ↓                      ↓
  Models              Pure Functions            Widgets
```

**Game Loop (simplified):**
```
User Input → Update State → Render UI → Repeat
```

---

## Motivation for Day 1

**What you're building:**
Not just a game - you're building:
- A commercial product worth KES 450,000
- Mobile game development skills
- Portfolio piece for future clients
- Foundation for more games

**Today's achievement:**
You went from zero to a structured Flutter project with proper architecture. That's huge!

**Remember:**
- Every expert was once a beginner
- Learning is supposed to feel challenging
- Questions mean you're thinking deeply
- Slow and steady wins the race

---

## Your Advantages

**You already know:**
- State management (backend experience)
- Data modeling (databases)
- Architecture patterns (Laravel, Next.js)
- System design (network infrastructure)

**These translate directly to:**
- Game state management
- Data modeling (Container, Move)
- Game architecture patterns
- Performance optimization

**You've got this!** 💪

---

## Evening Routine (15 minutes)

**Before you close your laptop:**

1. **Test your app** (2 min)
   - Run it one more time
   - Navigate between screens
   - Verify everything works

2. **Quick reflection** (5 min)
   - What worked well today?
   - What was challenging?
   - What do I want to focus on tomorrow?

3. **Commit if you haven't** (3 min)
   ```bash
   git add .
   git commit -m "End of Day 1: [brief summary]"
   ```

4. **Preview tomorrow** (5 min)
   - Skim Day 2 in the roadmap
   - Read Container section in Quick Reference
   - Get excited about building game logic!

---

## Pro Tips for Working with Claude Code

### Get the Most Out of Your AI Pair Programmer

**When asking questions:**
- ✅ "Can you explain why we make state immutable?"
- ✅ "What's the trade-off between X and Y approach?"
- ✅ "How does this relate to backend state management?"
- ❌ "Just write the code" (you won't learn)

**When implementing:**
- Ask Claude to explain before writing code
- Ask for the pattern/principle being used
- Request analogies to concepts you know
- Ask about performance implications

**When stuck:**
- "I don't understand why this is needed"
- "Can you break this down smaller?"
- "What's the simplest version of this?"
- "How would you debug this issue?"

### Working Style

**Pomodoro Technique works great:**
- 25 min focused coding with Claude Code
- 5 min break
- 25 min focused coding
- 5 min break
- After 4 rounds: 15-30 min break

**ADHD-Friendly Tips:**
- Set timer for focused sprints
- One concept at a time
- Celebrate small wins
- Move around during breaks
- Use standing desk if available

---

## Success Definition for Day 1

**Minimum Success:**
- [ ] Project created
- [ ] Basic structure in place
- [ ] Something runs on screen

**Target Success:**
- [ ] Everything in minimum success
- [ ] Understand game vs app architecture
- [ ] Can explain folder structure purpose
- [ ] Routing working between screens

**Stretch Success:**
- [ ] Everything in target success
- [ ] Started Container class
- [ ] Wrote first unit test
- [ ] Feeling confident about Day 2

**Remember:** Minimum success is totally fine for Day 1!

---

## Final Encouragement

You're about to start building something real. A commercial product. A game that people will play. Skills that will serve you for years.

**Day 1 is about:**
- Setting up correctly
- Understanding fundamentals  
- Building confidence
- Getting excited

**Day 1 is NOT about:**
- Finishing everything
- Perfect code
- Complete understanding
- Comparing to others

Take your time. Ask questions. Enjoy learning.

**Now go open Claude Code and start! 🚀**

---

## Quick Start Commands

```bash
# Create project
flutter create puzzle_game_suite
cd puzzle_game_suite

# Open in editor
code .

# Start Claude Code
claude

# Run app (when ready)
flutter run

# Hot reload (when app is running)
# Press 'r' in terminal

# Git commands
git init
git add .
git commit -m "feat: initial setup"

# Check Flutter setup
flutter doctor
```

---

You've got this, Eric! See you on Day 2! 💪
