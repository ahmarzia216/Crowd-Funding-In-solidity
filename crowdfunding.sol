// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract funding
{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public requireAmount;
    uint public minimumcontribution;
    uint public deadline;
    uint public noOfcontributors;
    uint public raisedAmount;
    uint public currentTime = block.timestamp;
    struct Request
    {
        string name;
        uint value;
        address payable recipent;
        uint noofvoters;
        bool completed;
        mapping(address=>bool) voters;
    }
    mapping (uint=>Request)public requests;
    uint public numrequest;
    constructor(uint _amount, uint _deadline)
    {
        requireAmount = _amount;
        deadline = block.timestamp + _deadline;
        minimumcontribution = 100 wei;
        manager = msg.sender;
    }
    function sendEth() public payable 
    {
        require(deadline > block.timestamp,"TimeUp");
        require(requireAmount>raisedAmount,"Thank You for your love but target is completed");
        require(msg.value > minimumcontribution,"Minimum amount is 100wei");

        if (contributors[msg.sender]== 0){
            noOfcontributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    function checkbalance() public view returns(uint)
    {
        return address(this).balance;
    }
   function refund() public payable 
   {
       require(block.timestamp>deadline && requireAmount>raisedAmount ,"You are not eligible");
       require(contributors[msg.sender]>0,"You have zero contribute");
       address payable user = payable (msg.sender);
       user.transfer(contributors[msg.sender]);
       contributors[msg.sender]=0;
   }
   function createRequest(string memory _name,address payable _recipent,uint _value) public
   {
       require(msg.sender==manager,"Manager has the authority to create a Request");
       Request storage newrequest = requests[numrequest];
       numrequest++;
       newrequest.name = _name;
       newrequest.recipent=_recipent;
       newrequest.value=_value;
       newrequest.noofvoters=0;
       newrequest.completed=false;
   }
   function voteRequest(uint _requestNo) public
   {
       require(contributors[msg.sender]>0,"You are not eligible");
       Request storage thisrequest = requests[_requestNo];
       require(thisrequest.voters[msg.sender]==false,"You have already voted");
       thisrequest.completed=true;
       thisrequest.noofvoters++;
   }
   function makePayment(uint _requestNo) public 
  {
    require(msg.sender==manager);
    require(requireAmount<=raisedAmount,"Payment is not reach to target");
    Request storage paymentrequest = requests[_requestNo];
    require(paymentrequest.completed==false,"Already maked");
    require(paymentrequest.noofvoters > noOfcontributors/2,"Decision dose not support");
    paymentrequest.recipent.transfer(paymentrequest.value);
    paymentrequest.completed=true;
  }

} 