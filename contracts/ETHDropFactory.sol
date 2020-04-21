pragma solidity 0.5.14;

contract ETHDrop {
    /*******
    INTERNAL
    *******/
    uint256 public drip;
    address payable[] members;
    address payable public secretary;
    
    mapping(address => Member) public memberList;
    
    struct Member {
        uint256 memberIndex;
        bool exists;
    }

    modifier onlySecretary() {
        require(msg.sender == secretary, "caller must be secretary");
        _;
    }
    
    function() external payable { } // contract receives ETH

    constructor(uint256 _drip, address payable[] memory _members) payable public { // initializes contract
        for (uint256 i = 0; i < _members.length; i++) {
            require(_members[i] != address(0), "member address cannot be 0");
            memberList[_members[i]].memberIndex = members.push(_members[i]) - 1;
            memberList[_members[i]].exists = true;
        }
        
        drip = _drip;
        secretary = members[0]; // first address in member array is secretary  
    }
    
    /******************
    DRIP/DROP FUNCTIONS
    ******************/
    function dripETH() public onlySecretary { // transfer ETH to members per stored drip amount
        for (uint256 i = 0; i < members.length; i++) {
            members[i].transfer(drip);
        }
    }

    function dropETH() payable public onlySecretary { // transfer ETH to members per attached drop amount
        for (uint256 i = 0; i < members.length; i++) {
            members[i].transfer(msg.value);
        }
    }
    
    function customDropETH(uint256[] memory drop) payable public onlySecretary { // transfer ETH to members per index amounts
        for (uint256 i = 0; i < members.length; i++) {
            members[i].transfer(drop[i]);
        }
    }

    function getETHBalance() public view returns (uint256) { // get amount of ETH in contract
        return address(this).balance;
    }
    
    /***************
    MEMBER FUNCTIONS
    ***************/
    function addMember(address payable newMember) public onlySecretary { 
        require(memberList[newMember].exists != true, "member already exists");
        memberList[newMember].memberIndex = members.push(newMember) - 1;
        memberList[newMember].exists = true;
    }

    function getMembership() public view returns (address payable[] memory) {
        return members;
    }

    function getMemberCount() public view returns(uint256 memberCount) {
        return members.length;
    }

    function isMember(address memberAddress) public view returns (bool memberExists) {
        if(members.length == 0) return false;
        return (members[memberList[memberAddress].memberIndex] == memberAddress);
    }

    function removeMember(address removedMember) public onlySecretary {
        require(memberList[removedMember].exists = true, "no such member to remove");
        uint256 memberToDelete = memberList[removedMember].memberIndex;
        address payable keyToMove = members[members.length-1];
        members[memberToDelete] = keyToMove;
        memberList[keyToMove].memberIndex = memberToDelete;
        memberList[removedMember].exists = false;
        members.length--;
    }

    function transferSecretary(address payable newSecretary) public onlySecretary {
        secretary = newSecretary;
    }

    function updateDrip(uint256 newDrip) public onlySecretary {
        drip = newDrip;
    }
}

contract ETHDropFactory {
    ETHDrop private Drop;
    address[] public drops;

    event newDrop(address indexed secretary, address indexed drop);

    function newETHDrop(uint256 _drip, address payable[] memory _members) payable public {
        Drop = (new ETHDrop).value(msg.value)(_drip, _members);
        drops.push(address(Drop));
        emit newDrop(_members[0], address(Drop));
    }
}
