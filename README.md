# Voting System Smart Contract

This repository contains a Solidity-based smart contract for implementing a secure, transparent, and efficient voting system on the Ethereum blockchain. The contract ensures fair voting, prevents unauthorized actions, and handles edge cases like ties during elections.

---

## Key Features

### Candidate Management (`Proposals`)
- **Efficient Storage**: Candidate names are stored as `bytes32` to reduce gas consumption.
- **Vote Tracking**: Tracks and updates vote counts for each candidate during the voting process.

### Voter Management (`Voters`)
- **Grant Voting Rights**: The chairman can grant voting rights to specific users using the `giveRightToVote` function.
- **Voting Status**: Tracks whether a voter has voted and their eligibility to vote.

### Voting Period Control
- **Start and End Time**: Voting start and end times are defined during contract deployment.
- **Dynamic Timers**: Functions to check elapsed time and remaining time during voting.

### Chairman Voting Option
- **Configurable Voting**: Option to allow or disallow the chairman to vote, set during contract deployment.

### Tie Handling
- **Tie Detection**: If a tie occurs among candidates with the highest votes, the system emits a `TieDetected` event and does not declare a winner.

### Security
- **Access Control**: Ensures only authorized users can vote or manage the contract.
- **Duplicate Prevention**: Prevents users from voting more than once.
- **Gas Optimization**: Uses `bytes32` for candidate names to minimize gas usage.

---

## Key Functions

### 1. **Constructor**
```solidity
constructor(string[] memory candidateNames, uint durationInSeconds, bool _chairmanCanVote)
```

- **Parameters**:
  - `candidateNames`: Array of candidate names (`string[]`).
  - `durationInSeconds`: Voting duration in seconds.
  - `_chairmanCanVote`: Boolean to enable or disable chairman voting.
- **Actions**:
  - Converts candidate names to `bytes32`.
  - Initializes the voting period start and end times.
  - Enables voting.

---

### 2. **Grant Voting Rights**
```solidity
function giveRightToVote(address voter) public onlyChairman
```
- Grants voting rights to a specified user.
- Ensures the user does not already have voting rights.

---

### 3. **Vote**
```solidity
function vote(uint candidateIndex) public votingOpen withinVotingPeriod eligibleVoter
```
- Allows users to cast a vote for a candidate by their index.
- Updates vote counts and emits the `VoteCast` event.

---

### 4. **End Voting**
```solidity
function votingEnd() public onlyChairman
```
- Ends the voting process.
- Determines the winner using the `findWinner` function.
- Emits:
  - `VotingEnded` event if a winner is declared.
  - `TieDetected` event if no winner can be declared due to a tie.

---

### 5. **Find Winner**
```solidity
function findWinner() internal view returns (uint winningProposalIndex, uint winningVoteCount, bool isTie)
```
- Finds the candidate with the most votes.
- Detects ties and returns a flag indicating a tie.

---

### 6. **Get Candidate Details**
```solidity
function getCandidate(uint index) public view returns (bytes32 name, uint voteCount)
```
- Returns the name and vote count of a candidate by index.

---

### 7. **Time Management**
- **Get Elapsed Time**:
  ```solidity
  function getElapsedTime() public view returns (uint)
  ```
  - Returns the time elapsed since the voting started.
- **Get Remaining Time**:
  ```solidity
  function getRemainingTime() public view returns (uint)
  ```
  - Returns the time left until voting ends.

---

## Events

- **`VoteCast`**:
  - Triggered when a voter casts their vote.
  - Includes the voter's address and candidate index.
- **`VotingEnded`**:
  - Triggered when voting ends with a winner.
  - Includes the winner's name and vote count.
- **`TieDetected`**:
  - Triggered when a tie is detected, and no winner can be declared.

---

## Usage Instructions

### Deployment
Deploy the contract with:
- Candidate names as a `string[]`.
- Voting duration in seconds.
- Boolean flag to enable or disable chairman voting.

Example:
```solidity
["Alice", "Bob", "Charlie"], 3600, true
```

### Grant Voting Rights
```solidity
giveRightToVote(0x123...); // Grants voting rights to a specific address.
```

### Voting
```solidity
vote(1); // Casts a vote for the candidate at index 1.
```

### End Voting
```solidity
votingEnd(); // Ends the voting process and announces the results.
```

---

## Gas Optimization

- **`bytes32` for Names**: Candidate names are converted to `bytes32` to reduce storage and gas costs.
- **Efficient Loops**: Winner determination and vote tracking are optimized for minimal computation.

---

## Tie Handling

- If a tie is detected:
  - The contract emits the `TieDetected` event.
  - No winner is declared.

---

## Edge Cases Handled
1. Voting before the start time or after the end time is prevented.
2. A user cannot vote more than once.
3. If all votes result in a tie, no winner is declared.
