# Claude Code Prompt: Multi-Theme Puzzle Game Builder

## Project Context

I'm building a multi-theme puzzle game suite with 4 themes (Water Sort, Nuts & Bolts, Ball Sort, Test Tubes) for a commercial client. This is a learning project where I want to deeply understand game development patterns, state management, and mobile game architecture.

**My Background:**
- Experienced software engineer with Laravel, Next.js, Docker expertise
- Strong database and backend skills
- Limited game development experience
- Want to learn Flutter game development from first principles
- ADHD patterns - need clear milestones and quick wins
- Perfectionist - want to understand the "why" behind architectural decisions

**Project Goals:**
1. Build production-ready puzzle game
2. Learn game development patterns and best practices
3. Understand mobile game architecture deeply
4. Create reusable, maintainable code
5. Learn animation and performance optimization for games

**Commercial Context:**
- Client: Truth Wireless Limited
- Budget: KES 450,000
- Timeline: 12 weeks
- Platform: Android & iOS (Flutter)
- Must be scalable and maintainable

---

## Teaching Approach I Need

**For Each Implementation:**
1. **Explain the concept first** - What are we building and why?
2. **Show the pattern** - What's the game development pattern we're using?
3. **Implement together** - Write code with clear explanations
4. **Explain trade-offs** - Why this approach over alternatives?
5. **Connect to first principles** - How does this relate to fundamentals?

**I learn best when:**
- You explain the architectural decision before writing code
- You show me the game development pattern/principle being applied
- You explain performance implications
- You connect to concepts I already know (backend, state management, databases)
- You give me quick wins (seeing something work) frequently

---

## Phase 1: Foundation Learning (Week 1-3)

### Project Setup & Core Architecture

**Help me understand and build:**

1. **Project Structure Decision**
   - Explain Flutter project architecture for games vs typical apps
   - Why certain folder structures work better for games
   - How to separate game engine logic from UI
   - Show me the initial project scaffold

2. **Core Game Engine - Container System**
   ```
   Teach me:
   - How to model a game container (tube/bolt/ball holder)
   - State management patterns for games (vs typical app state)
   - Why immutability matters in game state
   - How to implement the Container class with proper encapsulation
   ```

3. **Move Validation Logic**
   ```
   Teach me:
   - How to think about game rules as pure functions
   - Why separating validation from execution matters
   - How to make rules testable and extensible
   - Implement the move validator with test cases
   ```

4. **Game State Management**
   ```
   Teach me:
   - Different state management approaches for games
   - Why Riverpod/Provider/Bloc for this type of game
   - How to handle undo/redo (command pattern?)
   - How to persist game state
   - Implement the state management layer
   ```

**Deliverable for Phase 1:**
A working (ugly) single-theme game with:
- Basic containers displaying colors
- Move validation working
- Win condition detection
- Undo functionality
- No animations yet - just functional

**Learning Checkpoint:**
Before moving on, quiz me on:
- Why we structured state this way
- How the move validation works
- What patterns we used and why

---

## Phase 2: Animation & Theme System (Week 4-6)

### Making It Feel Like a Game

**Help me understand and build:**

1. **Animation Fundamentals**
   ```
   Teach me:
   - How game animations differ from UI animations
   - Flutter's animation system for games
   - When to use Tween vs AnimationController
   - Performance implications of animation choices
   - Implement the pour/move animation
   ```

2. **Theme Abstraction Pattern**
   ```
   Teach me:
   - How to design for multiple themes from start
   - Abstract class vs interface for game themes
   - Strategy pattern application in games
   - Asset management for multiple themes
   - Build the theme system architecture
   ```

3. **Rendering Pipeline**
   ```
   Teach me:
   - How Flutter renders game objects
   - CustomPainter vs Widget-based rendering
   - When to use Canvas vs Widgets
   - Performance optimization for 60fps
   - Implement the rendering layer
   ```

4. **Sound System**
   ```
   Teach me:
   - Audio architecture for mobile games
   - When to preload vs stream sounds
   - Sound pooling concepts
   - Implement basic sound system
   ```

**Deliverable for Phase 2:**
- Water theme with smooth animations
- Theme switching system working
- 3 more themes implemented (Nuts/Bolts, Balls, Test Tubes)
- Basic sound effects
- Feels good to play

**Learning Checkpoint:**
- How animations impact performance
- Why we chose this theme architecture
- What rendering optimizations we applied

---

## Phase 3: Level Design & Progression (Week 7-8)

### Content Pipeline

**Help me understand and build:**

1. **Level Generation System**
   ```
   Teach me:
   - How to design solvable puzzle algorithms
   - Procedural generation vs hand-crafted levels
   - Difficulty curve design
   - Level format (JSON structure)
   - Build level generator/validator
   ```

2. **Progression System**
   ```
   Teach me:
   - How to model player progression
   - Unlocking mechanisms
   - Star rating algorithms
   - XP/points systems
   - Implement progression tracking
   ```

3. **Hint System (AI Solver)**
   ```
   Teach me:
   - Basic game-solving algorithms (BFS/DFS)
   - How to implement a puzzle solver
   - Computational complexity considerations
   - Implement hint generation
   ```

**Deliverable for Phase 3:**
- 50 levels per theme (200 total)
- Level selector UI
- Progression system
- Hint system working
- Difficulty curve validated

---

## Phase 4: Monetization & Polish (Week 9-10)

### Making It Commercial

**Help me understand and build:**

1. **AdMob Integration**
   ```
   Teach me:
   - Mobile ad ecosystem basics
   - When to show ads (UX considerations)
   - Rewarded video implementation
   - Ad mediation concepts
   - Integrate AdMob properly
   ```

2. **In-App Purchases**
   ```
   Teach me:
   - IAP architecture patterns
   - Consumable vs non-consumable products
   - Receipt validation
   - Restore purchases flow
   - Implement IAP system
   ```

3. **Analytics & Tracking**
   ```
   Teach me:
   - What metrics matter for puzzle games
   - Event tracking strategy
   - Firebase Analytics setup
   - Funnel analysis
   - Implement analytics layer
   ```

4. **Performance Optimization**
   ```
   Teach me:
   - How to profile Flutter game performance
   - Memory management for games
   - Battery optimization
   - Reducing APK size
   - Optimize the game
   ```

**Deliverable for Phase 4:**
- Ads integrated and tested
- IAP working (test products)
- Analytics tracking key events
- Performance optimized
- Battery-efficient

---

## Phase 5: Launch Preparation (Week 11-12)

**Help me understand and build:**

1. **Device Testing Strategy**
   ```
   Teach me:
   - How to test across device spectrum
   - Low-end device optimization
   - Screen size adaptation
   - Build testing checklist
   ```

2. **Play Store Optimization**
   ```
   Teach me:
   - ASO basics for games
   - Screenshot best practices
   - App icon design principles
   - Store listing optimization
   - Create store assets
   ```

3. **Backend Services (if needed)**
   ```
   Teach me:
   - When games need backend
   - Leaderboard architecture
   - Cloud save implementation
   - Build minimal backend
   ```

---

## Specific Technical Questions I Want Answered Along The Way

1. **Architecture:**
   - Clean Architecture vs MVC vs MVVM for games - which and why?
   - How to structure code for maximum reusability
   - When to use inheritance vs composition in game objects

2. **Performance:**
   - How to achieve 60fps consistently
   - Memory management best practices
   - When to use compute vs UI isolates
   - Battery optimization techniques

3. **State Management:**
   - Why game state differs from app state
   - How to handle complex state transitions
   - Undo/redo implementation patterns

4. **Testing:**
   - How to test game logic effectively
   - Widget testing for game UI
   - Integration testing for game flows

5. **Monetization:**
   - Ad placement strategy that doesn't annoy users
   - IAP pricing psychology
   - Balancing free vs premium content

---

## Teaching Style Preferences

**Do:**
- Explain concepts before code
- Use analogies from backend/database world I know
- Show me the pattern/principle being applied
- Give me decision frameworks (when to use X vs Y)
- Provide quick wins - something visual working fast
- Connect to first principles
- Explain performance implications
- Show me how professionals structure game code

**Don't:**
- Just dump code without explanation
- Assume I know game development conventions
- Skip over "obvious" architectural decisions
- Give me everything at once (ADHD - need milestones)

---

## Success Criteria

**By the end, I should be able to:**
1. Explain game architecture patterns to another developer
2. Build another puzzle game from scratch
3. Optimize mobile game performance
4. Implement any common game mechanic
5. Understand mobile game monetization
6. Debug game-specific issues
7. Make informed architectural decisions for games

**Commercial Success:**
- Production-ready code (maintainable, documented)
- Smooth 60fps gameplay
- <50MB APK size
- Works on low-end Android devices
- Professional UI/UX
- Analytics tracking all key metrics
- Monetization properly implemented

---

## How to Work With Me

**Start each session with:**
1. What we're building in this session
2. Why this component/feature matters
3. What pattern/principle we're applying
4. Then guide me through implementation

**During coding:**
- Explain non-obvious decisions
- Point out game-specific patterns
- Show me where I could go wrong
- Teach me debugging techniques

**End each session with:**
- Summary of what we built
- Key concepts learned
- How it connects to the bigger picture
- What's next

---

## Current Status

- Project not started yet
- Need to set up development environment
- Ready to commit focused time to learning
- Want to build this properly, not rush

---

## Initial Request

**Let's start with Phase 1, Day 1-2:**

1. Help me set up the optimal Flutter project structure for this game
2. Explain the architecture we're using and why
3. Create the core Container class with me
4. Teach me how to think about game state
5. Get something visual on screen (even if ugly)

**Remember:** I want to understand WHY we make each decision, not just WHAT to code. Teach me like I'm a senior backend engineer learning game development for the first time.

Ready to begin! 🎮
