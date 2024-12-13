# Voting System Smart Contract

This is a smart contract designed for a transparent and secure voting system built on Ethereum. The voting process is managed by a chairman who sets up the voting system, including the candidates and the voting period. Eligible voters can vote, and the contract ensures transparency and fairness throughout the voting process.

## Features

### Key Functionalities
1. **Candidate Management**
   - Names of candidates are stored as `bytes32` to optimize gas usage.
   - Each candidate's vote count is tracked and updated when a vote is cast.

2. **Voter Management**
   - The chairman can grant voting rights to users.
   - Tracks whether a voter is eligible to vote and whether they have already voted.

3. **Voting Process**
   - Chairman sets the voting period using the `setVotingPeriod` function.
   - Voting can only start after the `startVoting` function is called by the chairman.
   - Voting can be ended by the chairman using the `votingEnd` function.

4. **Tie Detection**
   - Detects if there's a tie among candidates and emits a `TieDetected` event.

5. **Time Management**
   - Tracks the start and end times of voting.
   - Allows querying the elapsed time since voting started and the remaining time until voting ends.

6. **Security**
   - Access control to ensure only the chairman can manage critical operations.
   - Prevents duplicate voting and voting outside the allowed period.

---

## Contract Structure

### 1. **Data Structures**
- **`Voter`**
  - Tracks voting status (`hasVoted`).
  - Determines voting eligibility (`canVote`).
  - Stores the index of the candidate voted for.

- **`Proposal`**
  - Stores the candidate's name (`bytes32`).
  - Tracks the number of votes received.

### 2. **Main Functions**
#### `constructor(string[] memory candidateNames, bool _chairmanCanVote)`
- Initializes the contract with a list of candidate names.
- Converts candidate names to `bytes32` for gas optimization.
- Sets whether the chairman can vote.

#### `setVotingPeriod(uint durationInSeconds)`
- Allows the chairman to set the voting period.
- Defines the start and end times for voting.

#### `startVoting()`
- Marks the voting process as active.
- Emits a `VotingStarted` event.

#### `giveRightToVote(address voter)`
- Grants voting rights to a specific voter.
- Ensures the voter has not been granted voting rights previously.

#### `vote(uint candidateIndex)`
- Allows eligible voters to cast their votes for a candidate.
- Updates the candidate's vote count.
- Emits a `VoteCast` event.

#### `votingEnd()`
- Ends the voting process.
- Determines the winner or detects a tie.
- Emits `VotingEnded` or `TieDetected` events.

#### `findWinner()`
- Internally calculates the candidate with the most votes.
- Detects ties and returns the result.

#### `getCandidate(uint index)`
- Returns the name and vote count of a candidate.

#### `getElapsedTime()`
- Returns the elapsed time since voting started.

#### `getRemainingTime()`
- Returns the remaining time until voting ends.

### 3. **Helper Function**
#### `stringToBytes32(string memory source)`
- Converts a string to `bytes32` for efficient storage.

---

## Deployment and Usage

### Deployment
1. Deploy the contract by providing:
   - A list of candidate names as `string[]`.
   - A boolean value to indicate whether the chairman can vote.

   Example:
   ```javascript
   ["Alice", "Bob", "Charlie"], true

### 2. **Main Functions**
#### `constructor(string[] memory candidateNames)`
- Initializes the contract with a list of candidate names.
- Converts candidate names to `bytes32` for gas optimization.


#### `setVotingPeriod(uint durationInSeconds)`
- Allows the chairman to set the voting period.
- Defines the start and end times for voting.

#### `startVoting()`
- Marks the voting process as active.
- Emits a `VotingStarted` event.

#### `giveRightToVote(address voter)`
- Grants voting rights to a specific voter.
- Ensures the voter has not been granted voting rights previously.

#### `vote(uint candidateIndex)`
- Allows eligible voters to cast their votes for a candidate.
- Updates the candidate's vote count.
- Emits a `VoteCast` event.

#### `votingEnd()`
- Ends the voting process.
- Determines the winner or detects a tie.
- Emits `VotingEnded` or `TieDetected` events.

#### `findWinner()`
- Internally calculates the candidate with the most votes.
- Detects ties and returns the result.

#### `getCandidate(uint index)`
- Returns the name and vote count of a candidate.

#### `getElapsedTime()`
- Returns the elapsed time since voting started.

#### `getRemainingTime()`
- Returns the remaining time until voting ends.

### 3. **Helper Function**
#### `stringToBytes32(string memory source)`
- Converts a string to `bytes32` for efficient storage.

---

## Deployment and Usage

### Deployment
1. Deploy the contract by providing:
   - A list of candidate names as `string[]`.
   - A boolean value to indicate whether the chairman can vote.

   Example:
   ```javascript
   ["Alice", "Bob", "Charlie"], true
   ```

2. After deployment, the chairman must:
   - Set the voting period using `setVotingPeriod`.
   - Start the voting process using `startVoting`.

### Example Workflow
1. **Set Voting Period**
   ```solidity
   setVotingPeriod(3600); // Set voting period to 1 hour (3600 seconds)
   ```

2. **Start Voting**
   ```solidity
   startVoting();
   ```

3. **Grant Voting Rights**
   ```solidity
   giveRightToVote(0x123...ABC); // Address of the voter
   ```

4. **Cast Vote**
   ```solidity
   vote(1); // Vote for candidate at index 1
   ```

5. **End Voting**
   ```solidity
   votingEnd();
   ```

6. **Get Candidate Details**
   ```solidity
   getCandidate(0); // Returns name and vote count of candidate at index 0
   ```

---

## Events
- **`VoteCast`**: Emits when a voter casts a vote.
- **`VotingEnded`**: Emits when voting ends and a winner is determined.
- **`TieDetected`**: Emits when a tie is detected.
- **`VotingStarted`**: Emits when voting starts, indicating the start and end times.

---

## Testing
- Ensure at least two candidates are provided during deployment.
- Verify that only the chairman can start and end voting.
- Confirm that voters cannot vote before the voting period starts or after it ends.
- Test tie detection by casting equal votes for candidates.
```
