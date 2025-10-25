# 🧠 Wisdom Pool - Collective Intelligence & Prediction Market

## Overview

**Wisdom Pool** is a production-ready, error-free Clarity smart contract that harnesses the wisdom of crowds through stake-weighted voting. It enables anyone to create questions, stake on outcomes, and earn rewards for accurate predictions - proving that collective intelligence beats individual expertise.

## 🎯 The Wisdom of Crowds Revolution

### The Problem with Individual Predictions:

**Experts Are Often Wrong:**
- ❌ Single experts have biases
- ❌ Pundits wrong 60%+ of the time
- ❌ No accountability for predictions
- ❌ Overconfidence in expertise
- ❌ Cherry-picking past successes

**Wisdom Pool Solutions:**
✅ Aggregate crowd wisdom  
✅ Stake-weighted voting (skin in the game)  
✅ Financial incentives for accuracy  
✅ Transparent track records  
✅ Mathematically proven superior predictions  

## 🌟 Groundbreaking Features

### 1. **Stake-Weighted Consensus**
Money where mouth is:
- Vote with STX stake
- More confident = stake more
- Winning side shares losing stakes
- Proportional payouts
- No house edge

### 2. **Flexible Question Format**
Multi-option support:
- Binary questions (A or B)
- Three-option questions (A, B, or C)
- Custom time periods
- Category tagging
- Resolution deadlines

### 3. **Automatic Resolution**
Stake-weighted outcomes:
- Highest stake wins
- Consensus-based truth
- No arbitrator needed
- Transparent calculation
- Final after deadline

### 4. **Comprehensive Statistics**
Track prediction accuracy:
- Total predictions
- Correct predictions
- Accuracy rate
- Total earned
- Total staked
- On-chain reputation

### 5. **Winner-Takes-All Economics**
Incentivized accuracy:
- Winners split total pool
- Losers lose stake
- Proportional to contribution
- Platform takes no fees
- Pure peer-to-peer

### 6. **Optimized Security**
✅ Minimum stake: 1 STX  
✅ Minimum voting period: 10 days  
✅ One vote per person  
✅ Deadline enforcement  
✅ Option validation  
✅ Claim protection  

## 💡 Powerful Use Cases

### 1. **Cryptocurrency Price Prediction**
```clarity
;; Will Bitcoin exceed $100K by end of 2025?
(contract-call? .wisdom-pool create-question
  u"Will Bitcoin (BTC) price exceed $100,000 USD by December 31, 2025 23:59:59 UTC?"
  u"Yes - BTC will exceed $100K"
  u"No - BTC will stay below $100K"
  none                               ;; Binary question
  u26280                             ;; 6 months voting
  u1440                              ;; 10 days resolution
  "crypto")
;; Returns: (ok u1)
```

### 2. **Political Election Outcome**
```clarity
;; Who will win 2026 midterm elections?
(contract-call? .wisdom-pool create-question
  u"Which party will control the US House of Representatives after November 2026 midterm elections?"
  u"Democratic Party majority"
  u"Republican Party majority"
  (some u"No clear majority (tie)")
  u35040                             ;; 8 months voting
  u2160                              ;; 15 days resolution
  "politics")
```

### 3. **Technology Prediction**
```clarity
;; AI breakthrough prediction
(contract-call? .wisdom-pool create-question
  u"Will a major tech company (Google, OpenAI, Microsoft, Meta, or Amazon) release an AGI (Artificial General Intelligence) system by end of 2026?"
  u"Yes - AGI released by 2026"
  u"No - No AGI by 2026"
  none
  u52560                             ;; 1 year voting
  u4320                              ;; 30 days resolution
  "technology")
```

### 4. **Sports Outcome**
```clarity
;; Super Bowl prediction
(contract-call? .wisdom-pool create-question
  u"Who will win Super Bowl LX in February 2026?"
  u"AFC Team wins"
  u"NFC Team wins"
  none
  u17280                             ;; 4 months voting
  u720                               ;; 5 days resolution
  "sports")
```

### 5. **Vote with High Confidence**
```clarity
;; Very confident - stake 50 STX
(contract-call? .wisdom-pool vote
  u1                                 ;; question ID
  "a"                                ;; option A (Yes)
  u50000000)                         ;; 50 STX stake
```

### 6. **Vote with Low Confidence**
```clarity
;; Less confident - stake 5 STX
(contract-call? .wisdom-pool vote
  u1
  "b"                                ;; option B (No)
  u5000000)                          ;; 5 STX stake
```

### 7. **View Current Results**
```clarity
;; Check which way crowd is leaning
(contract-call? .wisdom-pool get-question u1)
;; Returns: {
;;   total-stake-a: 150000000,  ;; 150 STX on Yes
;;   total-stake-b: 80000000,   ;; 80 STX on No
;;   total-voters: 45
;; }

;; Check winning option
(contract-call? .wisdom-pool get-winning-option u1)
;; Returns: (ok "a") - Yes is winning
```

### 8. **Finalize After Deadline**
```clarity
;; Anyone can finalize after voting ends
(contract-call? .wisdom-pool finalize-question u1)
;; Determines winner based on stake weight
;; Returns: (ok "a") - Option A wins
```

### 9. **Winners Claim Payouts**
```clarity
;; Calculate potential payout
(contract-call? .wisdom-pool calculate-payout u1 'ST1YOU...)
;; Returns: (ok u75000000) - Would get 75 STX

;; Claim winnings
(contract-call? .wisdom-pool claim-winnings u1)
;; Transfers 75 STX to winner
;; 50 STX original stake + 25 STX from losers
```

### 10. **Losers Acknowledge Loss**
```clarity
;; Mark as claimed (no refund for wrong answer)
(contract-call? .wisdom-pool claim-refund u1)
;; Updates status, no STX returned
```

### 11. **Track Your Accuracy**
```clarity
(contract-call? .wisdom-pool get-voter-stats 'ST1YOU...)
;; Returns: {
;;   total-votes: 10,
;;   correct-predictions: 8,
;;   accuracy-rate: 80,
;;   total-staked: 150000000,
;;   total-earned: 50000000
;; }
;; 80% accuracy rate!
```

## 🏗️ Technical Architecture

### Core Data Structures

**Question**
```clarity
{
  creator: principal,                // Who created
  question: string-utf8 300,         // Question text
  option-a: string-utf8 100,         // Option A
  option-b: string-utf8 100,         // Option B
  option-c: optional string,         // Option C (optional)
  total-stake-a: uint,               // STX on A
  total-stake-b: uint,               // STX on B
  total-stake-c: uint,               // STX on C
  total-voters: uint,                // Participant count
  deadline: uint,                    // Voting end
  resolution-block: uint,            // When to finalize
  correct-option: optional string,   // Winner (a/b/c)
  status: string-ascii 20,           // active/resolved/cancelled
  category: string-ascii 30,         // Category tag
  created-at: uint                   // Creation block
}
```

**Vote**
```clarity
{
  option: string-ascii 1,            // a, b, or c
  stake-amount: uint,                // STX staked
  voted-at: uint,                    // Vote block
  claimed: bool                      // Payout claimed?
}
```

**Voter Statistics**
```clarity
{
  total-votes: uint,                 // Predictions made
  correct-predictions: uint,         // Correct count
  total-staked: uint,                // Total STX risked
  total-earned: uint,                // Total STX won
  accuracy-rate: uint                // Success % (0-100)
}
```

## 📖 Complete Usage Guide

### For Question Creators

#### Step 1: Create Question
```clarity
(contract-call? .wisdom-pool create-question
  u"Your prediction question?"
  u"Option A description"
  u"Option B description"
  none                               ;; or (some u"Option C")
  u17280                             ;; voting period (blocks)
  u1440                              ;; resolution period
  "your-category")
;; Returns question ID
```

#### Optional: Cancel Before Votes
```clarity
(contract-call? .wisdom-pool cancel-question u1)
;; Only works if no votes yet
```

### For Voters/Predictors

#### Step 1: Browse Questions
```clarity
;; View question details
(contract-call? .wisdom-pool get-question u1)

;; Check current stakes
(contract-call? .wisdom-pool get-winning-option u1)
```

#### Step 2: Vote with Stake
```clarity
(contract-call? .wisdom-pool vote
  u1                                 ;; question ID
  "a"                                ;; your choice (a, b, or c)
  u20000000)                         ;; 20 STX stake
;; Locks your STX
```

#### Step 3: Wait for Resolution
After deadline passes, anyone can finalize

#### Step 4: Claim Outcome
```clarity
;; If you won
(contract-call? .wisdom-pool claim-winnings u1)

;; If you lost
(contract-call? .wisdom-pool claim-refund u1)
```

### Query Functions

#### Check Your Vote
```clarity
(contract-call? .wisdom-pool get-vote u1 'ST1YOU...)
```

#### Your Statistics
```clarity
(contract-call? .wisdom-pool get-voter-stats 'ST1YOU...)
```

#### Platform Statistics
```clarity
(contract-call? .wisdom-pool get-platform-stats)
```

#### Creator's Questions
```clarity
(contract-call? .wisdom-pool get-creator-question-count 'ST1CREATOR...)
(contract-call? .wisdom-pool get-creator-question-id 'ST1CREATOR... u0)
```

## 💰 Economic Model

### Stake Requirements
- **Minimum Stake**: 1 STX
- **No Maximum**: Stake confidence level
- **Higher Stake**: More winnings if correct

### Payout Formula
```
Your Payout = (Your Stake / Winning Pool) × Total Pool
```

**Example:**
- Total Pool: 230 STX (150 on A, 80 on B)
- You staked: 30 STX on A
- A wins
- Your Payout: (30 / 150) × 230 = 46 STX
- Profit: 16 STX (46 - 30)

### No Platform Fees
- 100% of losing stakes go to winners
- Pure peer-to-peer
- Zero house edge
- No middleman

## 🧠 The Science Behind It

### Wisdom of Crowds Principles

**Why It Works:**
1. **Diversity**: Many viewpoints
2. **Independence**: No groupthink
3. **Decentralization**: No central authority
4. **Aggregation**: Combines all knowledge
5. **Financial Stakes**: Serious predictions only

**Historical Accuracy:**
- Betting markets beat polls in elections
- Prediction markets beat expert forecasts
- Aggregated estimates beat individual experts
- Financial incentives improve accuracy

### Success Examples
- **Iowa Electronic Markets**: 74% accurate (vs 61% polls)
- **PredictIt**: Beat pundits in 2020 election
- **Polymarket**: Accurate COVID predictions
- **Hollywood Stock Exchange**: Predicts box office

## 📊 Use Case Categories

**Finance**: Price predictions, market moves  
**Politics**: Elections, policy outcomes  
**Sports**: Game winners, championships  
**Technology**: Product launches, breakthroughs  
**Science**: Research outcomes, discoveries  
**Entertainment**: Awards, box office  
**Current Events**: News, global events  

## 🎯 Building Reputation

### Accuracy Levels
- **Beginner**: <60% accuracy
- **Intermediate**: 60-70% accuracy
- **Advanced**: 70-80% accuracy
- **Expert**: 80-90% accuracy  
- **Master**: 90%+ accuracy

### Reputation Benefits
- Higher accuracy = more trusted
- Track record visible on-chain
- Attract followers
- Command higher stakes
- Build prediction brand

---

**Harness the wisdom of crowds. Profit from accurate predictions.** 🧠💎
