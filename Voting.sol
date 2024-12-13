// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Voter {
        bool hasVoted;
        bool canVote;
        uint candidateIndex;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public chairman;
    uint public votingStartTime;
    uint public votingEndTime;
    bool public chairmanCanVote;

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    event VoteCast(address voter, uint candidateIndex);
    event VotingEnded(bytes32 winnerName, uint winnerVoteCount);
    event TieDetected();

    modifier onlyChairman() {
        require(msg.sender == chairman, "Only the chairman can call this function.");
        _;
    }

    modifier votingOpen() {
        require(isVotingActive(), "Voting is not active.");
        _;
    }

    modifier withinVotingPeriod() {
        require(block.timestamp >= votingStartTime, "Voting has not started yet.");
        require(block.timestamp <= votingEndTime, "Voting period has ended.");
        _;
    }

    modifier eligibleVoter() {
        require(voters[msg.sender].canVote || (msg.sender == chairman && chairmanCanVote), "You are not eligible to vote.");
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        _;
    }

    constructor(string[] memory candidateNames, uint durationInSeconds, bool _chairmanCanVote) {
        chairman = msg.sender;
        chairmanCanVote = _chairmanCanVote;
        for (uint i = 0; i < candidateNames.length; i++) {
            proposals.push(Proposal({
                name: stringToBytes32(candidateNames[i]),
                voteCount: 0
            }));
        }
        votingStartTime = block.timestamp;
        votingEndTime = block.timestamp + durationInSeconds;
    }

    function isVotingActive() public view returns (bool) {
        return block.timestamp >= votingStartTime && block.timestamp <= votingEndTime;
    }

    function giveRightToVote(address voter) public onlyChairman {
        require(!voters[voter].canVote, "Voter already has the right to vote.");
        voters[voter].canVote = true;
    }

    function vote(uint candidateIndex) public votingOpen withinVotingPeriod eligibleVoter {
        require(candidateIndex < proposals.length, "Invalid candidate index.");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].candidateIndex = candidateIndex;
        proposals[candidateIndex].voteCount += 1;

        emit VoteCast(msg.sender, candidateIndex);
    }

    function votingEnd() public onlyChairman {
        require(!isVotingActive(), "Voting period is still active.");

        (uint winningProposalIndex, uint winningVoteCount, bool isTie) = findWinner();

        if (isTie) {
            emit TieDetected();
        } else {
            bytes32 winnerName = proposals[winningProposalIndex].name;
            emit VotingEnded(winnerName, winningVoteCount);
        }
    }

    function findWinner() internal view returns (uint winningProposalIndex, uint winningVoteCount, bool isTie) {
        uint maxVotes = 0;
        uint winnerIndex = 0;
        bool tie = false;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winnerIndex = i;
                tie = false;
            } else if (proposals[i].voteCount == maxVotes && maxVotes > 0) {
                tie = true;
            }
        }
        return (winnerIndex, maxVotes, tie);
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory temp = bytes(source);
        require(temp.length <= 32, "String exceeds maximum length of 32 bytes.");
        assembly {
            result := mload(add(source, 32))
        }
    }
}
