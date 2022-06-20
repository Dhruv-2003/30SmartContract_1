// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - A Subscription service is started
// -  Payment can be deducted after a period of 30 days , and anyone can trigger it 
// - Payment is done from a particular ERC20 token , and approval needs to be given by payee

///  instance of an ERC20 token , which allows the function like transfer and approve
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol" ;

contract SubscriptionPlan {

    IERC20 token; 
    address public owner ;
    address public merchant ;

    uint256 public frequency; 
    uint256 public amount ;
    /// frequency of payment 

    struct Subscription{
        address subscriber;
        uint start;
        uint nextPayment ;
    }

    mapping(address => subscription) public subscriptions ;

    /// events for subscription creation , cancellation and payment 

    event subscriptionCreated(
        address subscriber,
        uint date
    ) ; 

    event subscriptionCancelled(
        address subscriber,
        uint date
    ) ;

    event paymentSent(
        address from ,
        address to ,
        uint amount,
        uint date
    ) ;


    /// costructor to take all the details needed for a subscription plan 
    constructor(address _token , address _merchant ,uint _amount,uint _frequency) {
        token = IERC20(_token) ;
        owner = msg.sender ;
        require(_merchant != address(0),"address can not be null address");
        merchant=  _merchant ;
        require(_amount != 0 ,"amount can not be zero");
        amount =_amount ;
        require(_frequency != 0 ,"frequency can not be zero");
        frequency = _frequency;
    }


    /// @dev to subscribe for the plan
    function subscribe() external {
        token.transferFrom(msg.sender,merchant, amount) ;
        emit paymentSent(msg.sender, merchant, amount, block.timestamp);

        subscriptions[msg.sender] = Subscription(
            msg.sender,
            block.timestamp,
            block.timestamp + frequency
        ) ;
        emit subscriptionCreated(msg.sender, block.timestamp);
    }

    /// @dev to cancel the subscription plan
    function cancel() external {
        Subscription storage subscription = subscriptions[subscriber] ;
        require(subscription.subscriber != address(0), "This subscription does not exsist");
        /// to delete any record , use delete 
        delete subscriptions[msg.sender] ;
        emit subscriptionCancelled(msg.sender, block.timestamp);
    }

    /// @dev to pay the amount after the peroid 
    /// @param subscriber -  address of the subscriber for which payment is to be done
    function pay(address subscriber) external {
        Subscription storage subscription = subscriptions[subscriber] ;
        require(subscription.subscriber != address(0), "This subscription does not exsist");
        require(block.timestamp > subscription.nextPayment,"Not due yet");

        token.transferFrom(subscriber, merchant , amount) ;
        emit paymentSent(subscriber, merchant, amount, block.timestamp);

        subscription.nextPayment += frequency ;
    }

}
