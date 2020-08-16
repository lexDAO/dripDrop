/*
██████╗ ██████╗  █████╗ ██╗    ██╗
██╔══██╗██╔══██╗██╔══██╗██║    ██║
██║  ██║██████╔╝███████║██║ █╗ ██║
██║  ██║██╔══██╗██╔══██║██║███╗██║
██████╔╝██║  ██║██║  ██║╚███╔███╔╝
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ 
██████╗ ██████╗  ██████╗ ██████╗  
██╔══██╗██╔══██╗██╔═══██╗██╔══██╗ 
██║  ██║██████╔╝██║   ██║██████╔╝ 
██║  ██║██╔══██╗██║   ██║██╔═══╝  
██████╔╝██║  ██║╚██████╔╝██║ 

DEAR MSG.SENDER(S):

/ DD is a project in beta.
// Please audit and use at your own risk.
/// Entry into DD shall not create an attorney/client relationship.
//// Likewise, DD should not be construed as legal advice or replacement for professional counsel.
///// STEAL THIS C0D3SL4W 

~presented by Open, ESQ || LexDAO LLC
*/

pragma solidity 0.5.17;

contract Context { // describes current contract execution context (metaTX support) / openzeppelin-contracts/blob/master/contracts/GSN/Context.sol
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath { // wrappers over solidity arithmetic operations with added overflow checks
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

library Address { // helper for address type / openzeppelin-contracts/blob/master/contracts/utils/Address.sol
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC20 { // brief interface for erc20 token txs
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library SafeERC20 { // wrappers around erc20 token txs that throw on failure (when the token contract returns false) / openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   function _callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

contract MemberDrawDrop is Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    /***************
    INTERNAL DETAILS
    ***************/
    address payable[] members;
    IERC20 public memberToken;
    uint256 public joinMin;
    uint256 public repMax;
    uint256 public repMin;
    uint256 public repTimeDelay;
    uint256 public rewardTimeDelay;
    uint256 public tapTimeDelay;
    bytes32 public message;
    
    mapping(address => Member) public memberList;
    
    struct Member {
        uint8 exists;
        uint256 memberIndex;
        uint256 reputation;
        uint256 repTime;
        uint256 rewardTime;
        uint256 tapTime;
    }

    event MemberAdded(address indexed member);
    event MemberRemoved(address indexed member);

    constructor(
        address payable[] memory _members,
        address _memberToken,
        uint256 _joinMin,
        uint256 _repMax,
        uint256 _repMin,
        uint256 _repTimeDelay,
        uint256 _rewardTimeDelay,
        uint256 _tapTimeDelay,
        bytes32 memory _message) payable public { 
        for (uint256 i = 0; i < _members.length; i++) {
            memberList[_members[i]].memberIndex = members.push(_members[i]).sub(1);
            memberList[_members[i]].reputation = _repMin;
            memberList[_members[i]].exists = 1;
        }
        
        memberToken = IERC20(_memberToken);
        joinMin = _joinMin;
        repMax = _repMax;
        repMin = _repMin;
        repTimeDelay = _repTimeDelay;
        rewardTimeDelay = _rewardTimeDelay;
        tapTimeDelay = _tapTimeDelay;
        message = _message;
    }
    
    /************************
    DRAW/DROP TOKEN FUNCTIONS
    ************************/
    function drawToken(address drawnToken) public { // transfer deposited token reward to calling member per memberToken-balanced amounts, reputation, 'reward time'
        require(memberList[_msgSender()].reputation >= repMin, "reputation too low");
        require(now.sub(memberList[_msgSender()].rewardTime) > rewardTimeDelay, "rewardTime too recent");
        memberList[_msgSender()].rewardTime = now;
        IERC20(drawnToken).safeTransfer(_msgSender(), memberToken.balanceOf(_msgSender()).div(memberToken.totalSupply()).mul(drawnToken.balanceOf(address(this))));
    }

    function lumpDropToken(uint256 drop, address lumpDroppedToken) public { // transfer caller token to members per approved 'lump drop' amount
        for (uint256 i = 0; i < members.length; i++) {
            IERC20(lumpDroppedToken).safeTransferFrom(_msgSender(), members[i], drop.div(members.length));
        }
    }
    
    function pinDropToken(uint256[] memory drop, address pinDroppedToken) public { // transfer caller token to each member per approved 'pin drop' amounts
        require(drop.length == members.length, "drop/members mismatch");
        for (uint256 i = 0; i < members.length; i++) {
            pinDroppedToken.safeTransferFrom(_msgSender(), members[i], drop[i]);
        }
    }
    
    /**********************
    DRIP/DROP ETH FUNCTIONS
    **********************/
    function() external payable {} 
    
    function depositETH() public payable {}
    
    function drawETH() public { // transfer deposited ETH to calling member per memberToken-balanced amounts, reputation, 'tap time'
        require(memberList[_msgSender()].reputation >= repMin, "reputation too low");
        require(now.sub(memberList[_msgSender()].tapTime) > tapTimeDelay, "tapTime too recent");
        memberList[_msgSender()].tapTime = now;
        (bool success, ) = _msgSender().call.value(memberToken.balanceOf(_msgSender()).div(memberToken.totalSupply()).mul(ETHBalance()))("");
        require(success, "transfer failed");
    }

    function lumpDropETH() payable public { // transfer caller ETH to members per attached 'lump drop' amount
        for (uint256 i = 0; i < members.length; i++) {
            (bool success, ) = members[i].call.value(msg.value.div(members.length))("");
            require(success, "transfer failed");
        }
    }
    
    function pinDropETH(uint256[] memory drop) payable public { // transfer caller ETH to members per index drop amounts
        require(drop.length == members.length);
        for (uint256 i = 0; i < members.length; i++) {
            require(msg.value == drop[i], "msg.value not sufficient for drop");
            members[i].transfer(drop[i]);
        }
    }
    
    /*******************
    MEMBERSHIP FUNCTIONS
    *******************/
    // ******************
    // DRIP/DROP REGISTRY
    // ******************
    function joinMembership() public { 
        require(memberToken.balanceOf(_msgSender()) >= joinMin, "memberToken balance insufficient");
        require(memberList[_msgSender()].exists != true, "member already exists");
        memberList[_msgSender()].memberIndex = members.push(_msgSender()).sub(1);
        memberList[_msgSender()].reputation = repMin;
        memberList[_msgSender()].exists = true;
        emit MemberAdded(_msgSender());
    }

    function leaveMembership() public {
        require(memberList[_msgSender()].exists == true, "must already be member");
        uint256 memberToDelete = memberList[_msgSender()].memberIndex;
        address payable keyToMove = members[members.length.sub(1)];
        members[memberToDelete] = keyToMove;
        memberList[keyToMove].memberIndex = memberToDelete;
        memberList[_msgSender()].reputation = repMin;
        memberList[_msgSender()].exists = false;
        members.length--;
        emit MemberRemoved(_msgSender());
    }
    
    // ***************
    // REPUTATION MGMT
    // ***************
    function repairMember(address repairedMember) public {
        require(memberList[_msgSender()].reputation >= repMin, "reputation not intact");
        require(now.sub(memberList[_msgSender()].repTime) > repTimeDelay, "last tapTime too recent");
        memberList[repairedMember].reputation = memberList[repairedMember].reputation.add(1);
    }
    
    function reportMember(address reportedMember) public {
        require(memberList[_msgSender()].reputation >= repMin, "reputation not intact");
        require(now.sub(memberList[_msgSender()].repTime) > repTimeDelay, "last tapTime too recent");
        memberList[reportedMember].reputation = memberList[reportedMember].reputation.sub(1);
    }

    /***************
    GETTER FUNCTIONS
    ***************/
    function ETHBalance() public view returns (uint256) { 
        return vault.balance;
    }

    function Membership() public view returns (address payable[] memory) {
        return members;
    }

    function MemberCount() public view returns (uint256) {
        return members.length;
    }

    function isMember(address _member) public view returns (bool) {
        if(members.length == 0) return false;
        return (members[memberList[_member].memberIndex] == _member);
    }
}

contract MemberDrawDropFactory {
    MemberDrawDrop private DrawDrop;

    event newDripDrop(address indexed dripdrop);

    function newMemberDrawDrop(
        address payable[] memory _members, 
        address _memberToken,
        uint256 _joinMin,
        uint256 _repMax,
        uint256 _repMin,
        uint256 _repTimeDelay,
        uint256 _rewardTimeDelay,
        uint256 _tapTimeDelay,
        bytes memory _message) payable public {
            
        DrawDrop = (new MemberDrawDrop).value(msg.value)(
            _members, 
            _memberToken,
            _joinMin,
            _repMax,
            _repMin,
            _repTimeDelay,
            _rewardTimeDelay,
            _tapTimeDelay,
            _message);
            
        emit newDrawDrop(address(DrawDrop));
    }
}
