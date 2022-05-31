// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;


contract InfoBoardAuction
{

   uint256 public slotcounter;
   uint256 public winnerinfocounter;
   uint256 public auctiondeadline;
   uint256 public listinginfodeadlinebywinners;
   address public immutable owner;

   struct Slot
   {
       address currentleader;
       string slotname;
       uint256 slotid;
       uint256 highestbid;
   }

   struct Winner
   {
       string company;
       string logo;
       string link;
       string text;
       string ads;
   }

   mapping(uint256=>Slot) public slots;

   mapping(uint256=>Winner) public winnerinfo;

   mapping(uint256 => mapping(address=>uint256)) public balances;

  constructor()
  {
    owner = msg.sender;
    auctiondeadline = block.timestamp + 1 days;
  }

  modifier OnlyOwner()
  {
      require(msg.sender == owner,"Only Owner can use this function");
      _;
  }

  function CreateSlot(Slot memory _slot) public OnlyOwner returns(Slot memory)
  {
      require(block.timestamp < auctiondeadline,"Deadline has already passed");
      slots[slotcounter++] = _slot;
      return slots[slotcounter-1];
  }

  function BidSlot(uint256 _slotid) public payable
  {
      require(block.timestamp < auctiondeadline,"Deadline has already passed"); 
      require(msg.value > slots[_slotid].highestbid,"Higher Bid Already exists");
      balances[_slotid][msg.sender] += msg.value;
      slots[_slotid].currentleader = msg.sender;
      slots[_slotid].highestbid = msg.value;
  }

  function WithdrawFunds(uint256 _slotid) public
  {
      require(slots[_slotid].currentleader != msg.sender,"Current Leader cant withdraw the funds");
      require(balances[_slotid][msg.sender]>0,"The balance is equal to zero");
      uint256 amount = balances[_slotid][msg.sender];
      balances[_slotid][msg.sender] = 0;
      (bool result ,) = payable(msg.sender).call{value:amount}("");
      require(result,"Ether not sent successfully");
  }

  function WithdrawFundsIfCurrentLeaderWhoBiddedMoreThanOnce(uint256 _slotid) public
  {
      require(slots[_slotid].currentleader == msg.sender,"Only current leader of a particular slot can use this function");
      require(balances[_slotid][msg.sender] > slots[_slotid].highestbid,"Cant withdraw");
      uint256 amount = balances[_slotid][msg.sender] - slots[_slotid].highestbid;
      balances[_slotid][msg.sender] = slots[_slotid].highestbid;
      (bool result,) = payable(msg.sender).call{value:amount}("");
      require(result,"Ether not sent successfully");
 }

  function WinnerInfo(Winner memory _winner,uint256 _slotid) public returns(Winner memory) 
  {
      require(block.timestamp > auctiondeadline,"Auction Deadline didnot pass and winner is not yet decided");
      require(slots[_slotid].currentleader == msg.sender , "You are not the winner");
      winnerinfo[winnerinfocounter++] = _winner;
      return winnerinfo[winnerinfocounter-1];
  }

  function AuctionDeadlineEnded() public OnlyOwner
  {
      require(block.timestamp > auctiondeadline,"Auction deadline not ended");
      listinginfodeadlinebywinners = block.timestamp + 1 days;
  }

  function RestartAuction() public OnlyOwner
  {
      require(block.timestamp > listinginfodeadlinebywinners,"Winners Listing Info Deadline not ended");
      auctiondeadline = block.timestamp + 1 days;
      
  }
  function getbalance() public view returns(uint256)
  {
      return address(this).balance;
  }

  receive() external payable{}

  fallback() external payable{}

  


}