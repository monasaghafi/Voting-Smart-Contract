// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Voter {
        bool hasVoted; // Indicates if the voter has already voted
        bool canVote;  // Indicates if the voter is eligible to vote
        uint candidateIndex; // Index of the candidate the voter voted for
    }

    struct Proposal {
        bytes32 name;     // Candidate's name (optimized as bytes32)
        uint voteCount;  // Total votes received
    }

    address public chairman;   // Address of the chairman
    bool public votingActive;  // Indicates if voting is active
    uint public votingStartTime; // Start time of voting
    uint public votingEndTime;   // End time of voting
    bool public chairmanCanVote; // Determines if the chairman can vote

    mapping(address => Voter) public voters; // Mapping to track voter information
    Proposal[] public proposals;            // Array of proposals (candidates)

    // Events for logging actions
    event VoteCast(address voter, uint candidateIndex);
    event VotingEnded(uint winnerIndex, bytes32 winnerName, uint winnerVoteCount);
    event TieDetected(); // Event to indicate a tie
    event VotingStarted(uint startTime, uint endTime); // Event for voting start

    // Modifiers for access control and validations
    modifier onlyChairman() {
        require(msg.sender == chairman, "Only the chairman can perform this action.");
        _;
    }

    modifier votingOpen() {
        require(votingActive, "Voting is not active.");
        _;
    }

    modifier withinVotingPeriod() {
        require(block.timestamp >= votingStartTime, "Voting has not started yet.");
        require(block.timestamp <= votingEndTime, "Voting period has ended.");
        _;
    }

    modifier eligibleVoter() {
        require(
            (msg.sender == chairman && chairmanCanVote) || voters[msg.sender].canVote,
            "You are not eligible to vote."
        );
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        _;
    }

    constructor(string[] memory candidateNames) {
        require(candidateNames.length > 1, "There must be at least two candidates.");
        chairman = msg.sender;
        chairmanCanVote = true;
        
        // اگر مدیر بتواند رأی دهد، مقدار canVote برابر true می‌شود
        if (chairmanCanVote) {
            voters[chairman].canVote = true;
        }

        for (uint i = 0; i < candidateNames.length; i++) {
            proposals.push(Proposal({
                name: stringToBytes32(candidateNames[i]), // Convert string to bytes32
                voteCount: 0
            }));
        }
        votingActive = false; // Voting is initially inactive
    }


    // Function to set the voting period
    function setVotingPeriod(uint durationInSeconds) public onlyChairman {
        require(!votingActive, "Cannot set voting period while voting is active.");
        votingStartTime = block.timestamp; // Set the voting start time
        votingEndTime = block.timestamp + durationInSeconds; // Set the voting end time
    }

    // Function to start the voting process
    function startVoting() public onlyChairman {
        require(votingStartTime > 0 && votingEndTime > 0, "Voting period not set.");
        require(!votingActive, "Voting is already active.");
        require(block.timestamp >= votingStartTime, "Voting start time not reached.");

        votingActive = true; // Mark voting as active
        emit VotingStarted(votingStartTime, votingEndTime);
    }

    // Function to grant voting rights to a user
    function giveRightToVote(address voter) public onlyChairman {
        require(!voters[voter].canVote, "Voter already has the right to vote.");
        voters[voter].canVote = true;
    }

    // Function to cast a vote
    function vote(uint candidateIndex) public votingOpen withinVotingPeriod eligibleVoter {
        require(candidateIndex < proposals.length, "Invalid candidate index.");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].candidateIndex = candidateIndex;
        proposals[candidateIndex].voteCount += 1;

        emit VoteCast(msg.sender, candidateIndex);
    }

        // Function to end the voting process
    function votingEnd() public onlyChairman {
        require(votingStartTime > 0 && votingEndTime > 0, "Voting period is not set.");
        require(votingActive, "Voting has not started or has already ended.");

        votingActive = false;

        (uint winningProposalIndex, uint winningVoteCount, bool isTie) = findWinner();

        if (isTie) {
            emit TieDetected(); // Emit event for a tie
        } else {
            bytes32 winnerName = proposals[winningProposalIndex].name;
            emit VotingEnded(winningProposalIndex, winnerName, winningVoteCount);
        }

        // Reset voting data for next round
        resetVotingData();
    }

    // Function to reset all voting-related data
    function resetVotingData() internal {
        // Reset proposals' vote counts
        for (uint i = 0; i < proposals.length; i++) {
            proposals[i].voteCount = 0;
        }

        // Reset voters' statuses
        for (uint i = 0; i < proposals.length; i++) {
            voters[chairman].hasVoted = false; // Reset chairman's voting status
        }
    }


    // Internal function to determine the winner
    function findWinner() internal view returns (uint winningProposalIndex, uint winningVoteCount, bool isTie) {
        uint maxVotes = 0;
        uint winnerIndex = 0;
        bool tie = false;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winnerIndex = i;
                tie = false; // Reset tie flag when a new maximum is found
            } else if (proposals[i].voteCount == maxVotes && maxVotes > 0) {
                tie = true; // Detect a tie
            }
        }
        return (winnerIndex, maxVotes, tie);
    }

    // Helper function to convert string to bytes32
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory temp = bytes(source);
        require(temp.length <= 32, "String exceeds maximum length of 32 bytes.");
        assembly {
            result := mload(add(source, 32))
        }
    }

    // Function to get the elapsed time since the voting started
    function getElapsedTime() public view returns (uint) {
        require(votingStartTime > 0, "Voting has not started.");
        return block.timestamp - votingStartTime;
    }

    // Function to get the remaining time until the voting ends
    function getRemainingTime() public view returns (uint) {
        if (block.timestamp > votingEndTime) {
            return 0; // If the voting period is over
        }
        return votingEndTime - block.timestamp;
    }
}
