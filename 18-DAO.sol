// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface INFT{

    function balanceOf(address owner) external view returns(uint256) ;

    function tokenOfOwnerByIndex(address owner,uint256 index) external view returns(uint256);

}

// - Allows user who owns a certain tokens or a NFT
// - then can participate in voting and governance decision

/// this DAO bounds the entry for all those who have the DAO nft , they can create and vote on proposals
/// it is similar to voting but we just added the nft ownership functionality that restricts them to vote only if they are part od DAO 
contract DAO{

    /// we are checking if the user owns the nft or not and then allowing them to mint
    INFT nft ;


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

    address owner;

    constructor(address _nft) payable {
        nft = INFT(_nft) ;
        owner = msg.sender; 
    }

     // Create a modifier which only allows a function to be
    // called by someone who owns at least a NFT
    modifier nftHolderOnly() {
        require(nft.balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
        _;
    }


    /// @dev to create a proposal for the vote 
    /// @param _proposal - what is the proposal
    /// @return Returns index of the proposal created
    function createProposal(string memory _proposal) external nftHolderOnly returns(uint256) {
        Proposal storage proposal = proposals[numProposals] ;
        proposal.proposal_ = _proposal ;
        proposal.deadline = block.timestamp + 1 days ;
        numProposals++;
        return numProposals - 1;
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

    /// @dev to vote yay for the proposal to be voted
    /// @param _id - for the id of the proposal to be voted
    /// @param _vote - what is the vote , yay or nay
    function vote(uint256 _id, Vote _vote) external nftHolderOnly activeProposalOnly(_id) {
        Proposal storage proposal = proposals[_id] ;
        if (_vote == Vote.YAY) {
            proposal.yayVotes += 1;
        } else {
            proposal.nayVotes += 1; 
        }
    }


    // modifier to check if the deadline is over and the proposal can be executed or not
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "DEADLINE_NOT_EXCEEDED"
        );
        require(
            proposals[proposalIndex].executed == false,
            "PROPOSAL_ALREADY_EXECUTED"
        );
        _;
    }

    /// to exectue the proposal the DAO has voted on by checking the votes
    function executeProposal(uint256 _id) external nftHolderOnly inactiveProposalOnly(_id) {
        Proposal storage proposal = proposals[_id] ;
        if(proposal.yayVotes > proposal.nayVotes){
        /// some action we want for the DAO to perform 
        proposal.executed = true;
        }
        else{
        /// action cannot be peroformed , clear the proposal 
         proposal.executed = false ;
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

    // to check the function call is from owner or not
    modifier onlyOwner() {
        require(msg.sender==owner,"Only Owner can access this function");
        _;
    }

    /// to withdraw the other out of the contract
    function withdrawEther() external onlyOwner {
        address _owner = msg.sender ;
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // The following two functions allow the contract to accept ETH deposits
    // directly from a wallet without calling a function
    receive() external payable {}

    fallback() external payable {}
}