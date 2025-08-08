# FocusIsland 🏝️

**Dynamic Island meets deep work.** Transform your MacBook's notch into a productivity powerhouse that actually helps you get stuff done.

Built as a weekend project by a UT Austin CSB student who got tired of losing focus every 20 minutes and wanted something better than basic timers that just... tick.

## Why This Exists

During my sophomore year at college, I kept bouncing between assignments and never felt like I was making real progress. Traditional productivity apps felt either too basic (just timers) or too complex (project management overkill). I wanted something that would:

- **Actually use** the MacBook Pro's notch instead of just tolerating it
- Follow **time-blocking principles** without the manual calendar tetris
- Implement **progressive break scaling** (longer projects = longer breaks)
- Show me **visual progress** through my work blocks

The result is a Dynamic Island-style focus timer that turns the Pomodoro Technique into something that feels native to macOS.

## ✨ Features

- **🎯 Dynamic Island Integration** - Your focus sessions live in the notch area, accessible but not distracting
- **📅 Smart Session Planning** - Visual timeline showing your upcoming work blocks and breaks  
- **⚡ Progressive Break System** - Break lengths scale with goal complexity (longer goals = longer recovery)
- **🔄 Automatic Session Flow** - Seamlessly transitions between focus blocks and breaks
- **⚙️ Customizable Settings** - Adjust focus durations, break lengths, and scaling factors
- **📊 Menu Bar Controls** - Quick access without disrupting your workflow

## Technical Implementation

This project demonstrates several key engineering decisions I made while learning SwiftUI and macOS development:

### Architecture Choices
- **Reactive State Management**: Used Combine framework with `@Published` properties to create a unidirectional data flow between UI and business logic
- **Separation of Concerns**: Goals → Sessions → Timer pipeline keeps the data transformation logic separate from UI rendering
- **Observer Pattern**: Timer completion events trigger UI state changes without tight coupling between components

### Problem Solving
- **Dynamic Island Integration**: Forked and modified `DynamicNotchKit` to handle custom notification overlays and smooth state transitions
- **Calendar Rendering**: Built a custom time-based layout system that positions session blocks accurately across hour boundaries
- **State Synchronization**: Solved SwiftUI's async update challenges by centralizing timer/session state management in the AppDelegate

### Performance Considerations
- **Lazy Loading**: Session generation only occurs when goals or settings change
- **Efficient Rendering**: Calendar view uses absolute positioning to avoid expensive layout recalculations
- **Memory Management**: Weak references and proper cleanup prevent retain cycles in timer callbacks

## 🚀 Installation

### Download (Recommended)
1. Go to [Releases](https://github.com/renil-edu/FocusIsland-MacOS/releases)
2. Download the latest `FocusIsland.app.zip`
3. Unzip and drag to Applications folder
4. **First launch**: Right-click → "Open" to bypass Gatekeeper security

### Build from Source
```
git clone https://github.com/renil-edu/FocusIsland-MacOS/
cd FocusIsland
open FocusIsland.xcodeproj
```



**Requirements**: macOS 13.0+, Xcode 15.0+

## 🎯 How to Use

1. **Launch FocusIsland** - Icon appears in your menu bar, interface in your notch
2. **Set up goals** - Click the pencil icon to add focus sessions with time estimates
3. **Configure settings** - Adjust focus block length and break scaling to match your work style
4. **Start focusing** - Hit play and watch your progress in the timeline view
5. **Take breaks** - Get notified when it's time to rest (and actually take the break!)

## 🛠️ Built With

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for state management  
- **DynamicNotchKit** - Custom fork for notch integration
- **UserDefaults** - Lightweight persistence for settings

## 🧠 The Science Behind It

FocusIsland implements **time-blocking** with **progressive recovery periods**:

- **Focus blocks** are capped at manageable chunks (default 20min) to maintain deep work without burnout
- **Standard breaks** (10min) help with task switching and mental reset
- **Scaled breaks** increase proportionally with goal length - bigger projects need bigger recovery
- **Visual timeline** reduces cognitive load of tracking "what's next"

This approach combines the **Pomodoro Technique's** time structure with **Timeboxing's** goal-oriented planning, while avoiding the rigidity that makes both hard to stick with.

## 🤝 Contributing

Found a bug? Have ideas for better productivity features? Contributions welcome!

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under a custom non-commercial license - see the [LICENSE](https://github.com/renil-edu/FocusIsland-MacOS/blob/main/LICENSE.md) file for details.

## 🙏 Acknowledgments

- **[DynamicNotchKit](https://github.com/MrKai77/DynamicNotchKit)** - For making notch integration possible
- **Apple's HIG** - Design inspiration for the Dynamic Island UX
- **Cal Newport** - Deep Work principles that shaped the focus block approach
- **Claude Sonnet 4.0**

---

**Developed by: Renil Gupta, August 2025**

Current Version: v1.0.0

*If FocusIsland helps you stay focused, consider starring the repo!*
