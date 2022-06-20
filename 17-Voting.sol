// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - users can create proposal
// - Other users can vote yes or no  , results can be fetched
// -  If the results are in majority , a action can be performed

contract Voting{

    // struct of proposals to be created with all the details required
    struct Proposal {
        //  proposal-  what proposal is  
        string proposal_;
        // deadline - timestamp until which this proposal is active 
        uint256 deadline;
        // yayVotes - number of yay votes for this proposal
        uint256 yayVotes;
        // nayVotes - number of nay votes for this proposal
        uint256 nayVotes;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping to check if the address has casted the vote or not 
        mapping(address => bool) voters;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals=0;

    constructor() {
    }

    /// to check if the proposal is active or not before voting 
    modifier activeProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "DEADLINE_EXCEEDED"
        );
        _;
    }

    // Create an enum named Vote containing possible options for a vote
    enum Vote {
        YAY, // YAY = 0
        NAY // NAY = 1
    }

    /// @dev to create a proposal for the vote 
    /// @param _proposal - what is the proposal
    /// @return Returns index of the proposal created
    function createProposal(string memory _proposal) external returns(uint256) {
        Proposal storage proposal = proposals[numProposals] ;
        proposal.proposal_ = _proposal ;
        proposal.deadline = block.timestamp + 1 days ;
        numProposals++;
        return numProposals - 1;
    }

    /// @dev to vote yay for the proposal to be voted
    /// @param _id - for the id of the proposal to be voted
    /// @param vote - what is the vote , yay or nay
    function vote(uint256 _id, Vote vote) external activeProposalOnly(_id) {
        Proposal storage proposal = proposals[_id] ;
        if (vote == Vote.YAY) {
            proposal.yayVotes += 1;
        } else {
            proposal.nayVotes += 1; 
        }
    }

    ///@dev to get the votes on a particular proposal
    ///@param _id - id of the proposal to be checked 
    ///@return Returns the no of yay votes 
    ///@return Returns the no of nay votes
    function getVotes(uint256 _id)  view external returns(uint256 ,uint256) {
        Proposal storage proposal = proposals[_id] ;
        uint256 _yayVotes = proposal.yayVotes ;
        uint256 _nayVotes = proposal.nayVotes ;
        return (_yayVotes , _nayVotes);
    }
}