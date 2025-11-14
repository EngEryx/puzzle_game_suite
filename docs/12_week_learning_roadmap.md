# 12-Week Learning Roadmap: Puzzle Game Development

## How to Use This Roadmap

- **Each day = 3-4 focused hours** (perfect for ADHD-friendly sprints)
- **Quick wins built in** - you'll see progress every day
- **Learning checkpoints** - validate understanding before moving on
- **Buffer time included** - if a task takes longer, that's expected
- **Weekends optional** - catch up or rest

---

## Week 1: Foundation & First Visual (21 hours)

### Day 1: Setup & Architecture Understanding (3h)
**Goal:** Understand game architecture and get environment ready

**Morning (1.5h):**
- Install Flutter SDK (latest stable)
- Set up IDE (VS Code + Flutter extensions)
- Create new Flutter project: `puzzle_game_suite`
- Review architecture quick reference

**Afternoon (1.5h) with Claude Code:**
- Understand game vs app architecture
- Set up folder structure (guided by Claude)
- Create basic routing setup
- Get "Hello World" on screen

**Deliverable:** Empty project with proper structure
**Learning Check:** Can you explain why games need different architecture?

---

### Day 2: Core Data Models (3h)
**Goal:** Build Container and GameColor models

**With Claude Code:**
- Implement `GameColor` enum
- Build `Container` class (immutable)
- Add computed properties (isEmpty, isFull, isSolved)
- Write unit tests for Container
- Understand immutability in games

**Deliverable:** Container class with passing tests
**Learning Check:** Why must game state be immutable?

---

### Day 3: Move Validation Logic (3h)
**Goal:** Implement game rules as pure functions

**With Claude Code:**
- Create `Move` value object
- Build `MoveValidator` class
- Implement canMove() logic
- Write comprehensive tests
- Understand pure functions in games

**Deliverable:** Move validation working with tests
**Learning Check:** What makes a function "pure"?

---

### Day 4: Game State Management (4h)
**Goal:** Set up Riverpod and game controller

**With Claude Code:**
- Install Riverpod
- Create `GameState` class
- Build `GameController` StateNotifier
- Implement makeMove() and undo()
- Connect to simple UI

**Deliverable:** State management working end-to-end
**Learning Check:** How does game state differ from app state?

---

### Day 5: First Visual Game (4h)
**Goal:** See something playable on screen!

**With Claude Code:**
- Create basic ContainerWidget (just colored boxes)
- Build simple GameBoard layout
- Wire up tap handlers
- Show selected state
- Make a move and see it work

**Deliverable:** Ugly but functional game you can play!
**Quick Win:** 🎉 You can actually play the game!

---

### Day 6-7: Polish & Testing (4h)
**Goal:** Clean up Week 1 code and validate learning

**Tasks:**
- Refactor any messy code
- Add more unit tests
- Test edge cases
- Document your code
- Review architecture decisions

**Learning Checkpoint:**
- Quiz yourself: Why this architecture?
- Can you explain move validation to someone?
- Do you understand Riverpod's role?

---

## Week 2: Animation & Visual Polish (18 hours)

### Day 8: Animation Fundamentals (3h)
**Goal:** Understand Flutter animation system

**With Claude Code:**
- Learn AnimationController
- Understand Tween and CurvedAnimation
- Create simple test animation
- Learn about vsync and performance

**Deliverable:** Understanding of animation system
**Learning Check:** What's the purpose of AnimationController?

---

### Day 9: Pour Animation - Part 1 (4h)
**Goal:** Implement basic pour animation

**With Claude Code:**
- Create animated ContainerWidget
- Implement simple pour transition
- Learn about AnimatedBuilder
- Add easing curves

**Deliverable:** Colors move between containers (basic)
**Quick Win:** It looks like a game now!

---

### Day 10: Pour Animation - Part 2 (4h)
**Goal:** Make animation feel great

**With Claude Code:**
- Add liquid physics feel
- Implement color stacking animation
- Add slight wobble/bounce
- Tune timing for satisfaction

**Deliverable:** Smooth, satisfying pour animation
**Learning Check:** Why does timing matter in game feel?

---

### Day 11: Custom Painting (3h)
**Goal:** Learn CustomPainter for advanced rendering

**With Claude Code:**
- Introduction to Canvas API
- Build ContainerPainter
- Draw containers with gradients
- Add shadows and highlights

**Deliverable:** Beautiful container rendering
**Learning Check:** When to use CustomPainter vs Widgets?

---

### Day 12-13: Sound System (4h)
**Goal:** Add audio feedback

**With Claude Code:**
- Set up audioplayers package
- Create AudioService
- Add pour sounds
- Add tap feedback
- Implement sound pooling

**Deliverable:** Game with satisfying sounds
**Quick Win:** 🎉 Game feels professional!

---

### Day 14: Week 2 Review
**Goal:** Consolidate learning

**Tasks:**
- Play your game and find rough edges
- Optimize animation performance
- Review code quality
- Document learnings

---

## Week 3: Theme System & Multi-Theme (18 hours)

### Day 15: Theme Architecture (3h)
**Goal:** Design extensible theme system

**With Claude Code:**
- Create GameTheme abstract class
- Understand Strategy pattern
- Plan theme differences
- Set up theme assets structure

**Deliverable:** Theme system architecture
**Learning Check:** Why abstract classes for themes?

---

### Day 16: Water Theme Implementation (3h)
**Goal:** Extract current code into Water theme

**With Claude Code:**
- Implement WaterTheme class
- Add translucency effects
- Create water-specific animations
- Add wave effects (optional polish)

**Deliverable:** Water theme as separate class
**Quick Win:** Same game, cleaner code!

---

### Day 17: Nuts & Bolts Theme (3h)
**Goal:** Build second theme

**With Claude Code:**
- Implement NutsAndBoltsTheme
- Create metallic styling
- Add mechanical sounds
- Implement rotation animation

**Deliverable:** Second playable theme
**Quick Win:** 🎉 Multi-theme working!

---

### Day 18: Balls & Test Tubes Themes (4h)
**Goal:** Complete all four themes

**With Claude Code:**
- Implement BallTheme (bouncy physics)
- Implement TestTubeTheme (scientific look)
- Add theme-specific sounds
- Polish visual differences

**Deliverable:** All four themes playable
**Learning Check:** How does Strategy pattern help here?

---

### Day 19: Theme Selector UI (3h)
**Goal:** Let user choose theme

**With Claude Code:**
- Design theme picker screen
- Add theme previews
- Implement theme switching
- Save theme preference

**Deliverable:** Theme selection working
**Quick Win:** User can pick any theme!

---

### Day 20-21: Week 3 Polish & Testing (2h)
**Goal:** Ensure quality across themes

**Tasks:**
- Test all themes thoroughly
- Fix theme-specific bugs
- Optimize asset loading
- Performance check

**Client Checkpoint:** Ready to demo to Truth Wireless!

---

## Week 4: Level System & Progression (18 hours)

### Day 22: Level Data Structure (3h)
**Goal:** Design level format

**With Claude Code:**
- Create Level model
- Design JSON format
- Implement level loader
- Create 5 test levels

**Deliverable:** Level system architecture
**Learning Check:** Why JSON for levels?

---

### Day 23: Level Generation Algorithm (4h)
**Goal:** Understand puzzle generation

**With Claude Code:**
- Learn puzzle generation techniques
- Implement basic generator
- Ensure puzzles are solvable
- Create difficulty parameters

**Deliverable:** Level generator working
**Learning Check:** What makes a puzzle solvable?

---

### Day 24-25: Create 200 Levels (6h)
**Goal:** Build content library

**With Claude Code:**
- Generate 50 levels per theme
- Manually test key levels
- Adjust difficulty curve
- Create level metadata

**Deliverable:** 200 playable levels
**Quick Win:** Massive content library!

---

### Day 26: Level Selector UI (3h)
**Goal:** Beautiful level selection

**With Claude Code:**
- Design level grid
- Add level thumbnails
- Show completion status
- Implement unlocking logic

**Deliverable:** Level selector screen
**Quick Win:** 🎉 Feels like a real game!

---

### Day 27-28: Progression System (2h)
**Goal:** Track player progress

**With Claude Code:**
- Implement star rating
- Add XP/points system
- Save progress locally
- Show statistics

**Deliverable:** Full progression tracking

---

## Week 5: AI Hint System (12 hours)

### Day 29-30: Puzzle Solver Algorithm (6h)
**Goal:** Build AI that solves puzzles

**With Claude Code:**
- Learn BFS/DFS algorithms
- Implement puzzle solver
- Optimize for performance
- Handle unsolvable states

**Deliverable:** Working puzzle solver
**Learning Check:** How does BFS work?

---

### Day 31-32: Hint System UI (4h)
**Goal:** Present hints to player

**With Claude Code:**
- Create hint button
- Animate suggested move
- Implement hint cooldown
- Add hint cost (for monetization)

**Deliverable:** Hint system working
**Quick Win:** AI helps stuck players!

---

### Day 33-34: Week 5 Testing (2h)
**Goal:** Ensure solver works for all levels

**Tasks:**
- Test solver on all 200 levels
- Fix solver edge cases
- Optimize solver performance

---

## Week 6: Buffer & Polish Week (15 hours)

### Day 35-38: Catch-Up Time (12h)
**Purpose:** Reality check - tasks took longer than planned

**Use this time to:**
- Finish incomplete features
- Fix accumulated bugs
- Improve code quality
- Add missing tests

---

### Day 39-41: Visual Polish Pass (3h)
**Goal:** Make it beautiful

**With Claude Code:**
- Polish all animations
- Add particle effects
- Improve transitions
- Add juice (screen shake, etc.)

**Deliverable:** Polished, professional feel

---

## Week 7-8: Monetization & Backend (24 hours)

### Day 42-43: AdMob Integration (6h)
**Goal:** Implement ads properly

**With Claude Code:**
- Set up AdMob account
- Add Google Mobile Ads SDK
- Implement interstitial ads
- Add rewarded video for hints
- Test ad placement UX

**Deliverable:** Ads working without annoying users
**Learning Check:** When to show ads?

---

### Day 44-46: In-App Purchases (8h)
**Goal:** Implement IAP

**With Claude Code:**
- Set up IAP products
- Implement purchase flow
- Add restore purchases
- Create ad-free option
- Add level pack purchases

**Deliverable:** IAP fully functional
**Learning Check:** How does IAP verification work?

---

### Day 47-48: Firebase Setup (6h)
**Goal:** Analytics and cloud services

**With Claude Code:**
- Set up Firebase project
- Add Analytics tracking
- Implement Crashlytics
- Add Cloud Firestore for saves
- Set up Remote Config

**Deliverable:** Backend services integrated

---

### Day 49-50: Analytics Events (4h)
**Goal:** Track meaningful metrics

**With Claude Code:**
- Define key events
- Implement event tracking
- Set up conversion funnels
- Test analytics flow

**Deliverable:** Comprehensive analytics

---

## Week 9: Performance & Optimization (18 hours)

### Day 51-52: Performance Profiling (6h)
**Goal:** Find and fix performance issues

**With Claude Code:**
- Use Flutter DevTools
- Profile frame rendering
- Find memory leaks
- Optimize hot paths

**Deliverable:** 60fps on low-end devices

---

### Day 53-54: Battery Optimization (4h)
**Goal:** Reduce battery drain

**With Claude Code:**
- Pause animations when inactive
- Reduce background work
- Optimize rendering
- Test battery usage

**Deliverable:** Battery-efficient game

---

### Day 55-56: APK Size Optimization (4h)
**Goal:** Reduce download size

**With Claude Code:**
- Compress assets
- Remove unused resources
- Optimize images
- Enable ProGuard/R8

**Deliverable:** <50MB APK

---

### Day 57-58: Low-End Device Testing (4h)
**Goal:** Works on cheap phones

**Tasks:**
- Test on budget Android phones
- Fix performance issues
- Adjust graphics for low-end
- Ensure playability

**Deliverable:** Runs well on cheap phones

---

## Week 10: UI/UX Polish & Testing (18 hours)

### Day 59-61: UI Polish Pass (8h)
**Goal:** Professional, polished UI

**With Claude Code:**
- Design menu screens
- Add transitions
- Improve button feedback
- Polish all interactions

**Deliverable:** Beautiful UI/UX

---

### Day 62-64: User Testing (6h)
**Goal:** Get real user feedback

**Tasks:**
- Give game to 5-10 testers
- Collect feedback
- Identify pain points
- Fix critical UX issues

**Deliverable:** User-tested game

---

### Day 65-66: Bug Bash (4h)
**Goal:** Find and fix bugs

**Tasks:**
- Systematic testing all features
- Fix all critical bugs
- Fix high-priority bugs
- Document known issues

**Deliverable:** Stable, bug-free game

---

## Week 11: Launch Preparation (18 hours)

### Day 67-68: Play Store Assets (6h)
**Goal:** Create store presence

**With Claude Code (for descriptions):**
- Design app icon
- Create screenshots (all themes)
- Write app description
- Make feature graphic
- Record gameplay video

**Deliverable:** Complete Play Store listing

---

### Day 69-70: ASO Optimization (4h)
**Goal:** Optimize for discovery

**Tasks:**
- Keyword research
- Optimize title and description
- Localize for key markets
- Set up A/B testing

**Deliverable:** ASO-optimized listing

---

### Day 71-72: Beta Testing (4h)
**Goal:** Closed beta on Play Console

**Tasks:**
- Upload to Play Console beta
- Invite 20-50 beta testers
- Collect feedback
- Fix critical issues

**Deliverable:** Beta tested game

---

### Day 73-74: Documentation (4h)
**Goal:** Create all documentation

**Tasks:**
- Write user guide
- Create support FAQ
- Document codebase
- Write handover docs

**Deliverable:** Complete documentation

---

## Week 12: Launch & Support (15 hours)

### Day 75-76: Final Polish (4h)
**Goal:** Last-minute improvements

**Tasks:**
- Fix any remaining bugs
- Final performance check
- Test on multiple devices
- Final code review

---

### Day 77: Launch Day! (2h)
**Goal:** Ship it!

**Tasks:**
- Submit to Play Store
- Set pricing/IAP
- Enable ads
- Monitor for issues

**🎉 GAME IS LIVE! 🎉**

---

### Day 78-80: Post-Launch Monitoring (6h)
**Goal:** Ensure smooth launch

**Tasks:**
- Monitor analytics
- Watch for crashes
- Respond to reviews
- Fix critical bugs quickly

---

### Day 81-84: Post-Launch Support (3h)
**Goal:** Support period included in quote

**Tasks:**
- Bug fixes as needed
- Answer user questions
- Small improvements
- Prepare for v1.1

---

## Daily Routine Template

**Morning Sprint (2 hours):**
1. Review yesterday's work (10 min)
2. Read today's goal (5 min)
3. Deep work with Claude Code (1h 45min)

**Break (15 minutes)**

**Afternoon Sprint (1.5 hours):**
1. Continue implementation
2. Test what you built
3. Document learnings

**Evening (30 min):**
1. Test today's work thoroughly
2. Commit code with good message
3. Write quick reflection note
4. Preview tomorrow's goal

---

## Success Metrics

**By Week 4:** Playable demo for client
**By Week 8:** Feature complete
**By Week 10:** Production ready
**By Week 12:** Launched and stable

**Learning Goals:**
- ✅ Understand game architecture patterns
- ✅ Master Flutter animations
- ✅ Implement AI/algorithms (solver)
- ✅ Handle monetization properly
- ✅ Ship production mobile game
- ✅ Confidence to build more games

---

## When You Get Stuck

1. **Review the Quick Reference** - pattern probably there
2. **Ask Claude Code** - explain what you're stuck on
3. **Break it smaller** - what's the simplest version?
4. **Take a break** - ADHD brain needs rest
5. **Check existing code** - similar pattern elsewhere?

---

## Motivation Boosts

**Week 2:** You can actually play the game!
**Week 3:** Four themes working - looks like a real product!
**Week 5:** AI solver works - feels like magic!
**Week 8:** Money-making features done - it's a business!
**Week 12:** SHIPPED! You built a commercial game!

---

## Remember

**This is aggressive but doable:**
- 18 hours/week average
- Some weeks lighter, some heavier
- Buffer weeks built in
- Real learning, not just coding

**You're not just building a game:**
- You're learning game development
- Building commercial product
- Proving you can ship
- Earning KES 450,000
- Building portfolio piece

**Most important:**
- Focus on daily progress
- Don't compare to where you want to be
- Celebrate small wins
- Trust the process
- Learn deeply

Now start with Day 1! Open Claude Code and paste in the main prompt. Let's build this! 🚀
