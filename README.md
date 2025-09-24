# FitChain Smart Contract

A decentralized fitness tracking community built on the Stacks blockchain. FitChain gamifies fitness activities by rewarding users with points for workouts, challenges, and wellness goals while maintaining a transparent, community-driven platform.

## 🏋️ Features

- **Decentralized Fitness Tracking**: Track your fitness journey on the blockchain
- **Point-Based Reward System**: Earn points for different types of activities
- **Community Challenges**: Participate in fitness challenges and competitions  
- **Wellness Goal Tracking**: Monitor and achieve personal wellness milestones
- **Fitness Score Degradation**: Encourages consistent activity through score decay over time
- **Admin Controls**: Configurable point values for different exercise types

## 📊 Activity Types

The contract supports three main fitness activity categories:

1. **Workout** (10 calories/points) - Regular exercise sessions
2. **Challenge** (5 calories/points) - Community fitness competitions
3. **Wellness** (15 calories/points) - Health and wellness goal achievements

## 🚀 Getting Started

### Prerequisites

- Stacks wallet (Hiro, Xverse, etc.)
- STX tokens for transaction fees
- Basic understanding of Stacks blockchain

### Joining the Community

```clarity
(contract-call? .fitchain join-fitness-community)
```

This creates your athlete profile with initial stats:
- Fitness score: 0
- Workouts completed: 0
- Challenges won: 0
- Wellness goals achieved: 0

## 📝 Core Functions

### User Functions

#### Log a Workout
```clarity
(contract-call? .fitchain log-workout)
```
Records a workout session and awards 10 points to your fitness score.

#### Win a Challenge
```clarity
(contract-call? .fitchain win-challenge)
```
Records a challenge victory and awards 5 points to your fitness score.

#### Achieve Wellness Goal
```clarity
(contract-call? .fitchain achieve-wellness)
```
Records a wellness milestone and awards 15 points to your fitness score.

### Read-Only Functions

#### Get Athlete Stats
```clarity
(contract-call? .fitchain get-athlete-stats 'SP1234567890ABCDEF)
```
Returns complete stats for a specified athlete.

#### Get Current Fitness Level
```clarity
(contract-call? .fitchain get-current-fitness 'SP1234567890ABCDEF)
```
Returns the current fitness score accounting for activity degradation.

#### Get Exercise Calories
```clarity
(contract-call? .fitchain get-exercise-calories "workout")
```
Returns the point value for a specific exercise type.

## 👨‍💼 Admin Functions

### Modify Exercise Calories
Only the fitness coach (contract deployer) can adjust point values:

```clarity
(contract-call? .fitchain modify-exercise-calories "workout" u15)
```

**Parameters:**
- `exercise-type`: Must be "workout", "challenge", or "wellness"
- `new-cals`: Point value (capped at 1000)

## 📈 Fitness Score System

### Point Allocation
- **Workouts**: 10 points per session
- **Challenges**: 5 points per victory
- **Wellness Goals**: 15 points per achievement

### Score Degradation
Your fitness score gradually decreases based on inactivity:
- Degradation factor = inactive blocks ÷ 1000
- Encourages consistent engagement with the platform
- Prevents indefinite score accumulation without activity

## 🏗️ Data Structure

### Athlete Stats
```clarity
{
    fitness-score: uint,      // Total accumulated points
    workouts-done: uint,      // Number of workouts completed
    challenges-won: uint,     // Number of challenges won
    last-session: uint,       // Block height of last activity
    wellness-goals: uint      // Number of wellness goals achieved
}
```

### Exercise Points
```clarity
{
    exercise: string-ascii 24,  // Exercise type identifier
    calories: uint              // Point value for the exercise
}
```

## ⚠️ Error Codes

- `u100`: Coach-only function access denied
- `u101`: Athlete profile not found
- `u102`: General access denied
- `u103`: Athlete profile already exists
- `u104`: No stats available for user
- `u105`: Invalid exercise type
- `u106`: Invalid value provided

## 🔒 Security Features

- **Access Control**: Admin functions restricted to contract deployer
- **Input Validation**: Exercise types validated against whitelist
- **Value Capping**: Calorie values limited to maximum of 1000
- **Duplicate Prevention**: Users cannot create multiple profiles

## 🎯 Use Cases

- **Personal Fitness Tracking**: Monitor your fitness journey on-chain
- **Corporate Wellness Programs**: Companies can deploy for employee health initiatives
- **Fitness Communities**: Gyms and fitness groups can gamify member engagement
- **Health Insurance**: Transparent activity tracking for wellness-based premiums
- **Fitness Challenges**: Organize community competitions with verifiable results

## 🛠️ Development

### Testing
Comprehensive testing should cover:
- User registration and duplicate prevention
- Activity logging and point allocation
- Score degradation calculations
- Admin permission controls
- Input validation and error handling

### Deployment
1. Deploy contract to Stacks testnet/mainnet
2. Initialize with fitness coach address
3. Configure initial exercise point values
4. Test all functions with sample users
