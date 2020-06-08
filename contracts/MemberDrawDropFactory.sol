pragma solidity 0.5.17;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract MemberDripDraw is Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    /***************
    INTERNAL DETAILS
    ***************/
    address payable[] members;
    IERC20 public memberToken;
    address private vault = address(this);
    uint256 public joinMin;
    uint256 public repMax;
    uint256 public repMin;
    uint256 public repTimeDelay;
    uint256 public rewardTimeDelay;
    uint256 public tapTimeDelay;
    string public message;
    
    mapping(address => Member) public memberList;
    
    struct Member {
        uint256 memberIndex;
        uint256 rep;
        uint256 repTime;
        uint256 rewardTime;
        uint256 tapTime;
        bool exists;
    }

    event MemberAdded(address indexed _member);
    event MemberRemoved(address indexed _member);
    event MemberRepaired(address indexed caller, address indexed repairedMember);
    event MemberReported(address indexed caller, address indexed reportedMember);

    constructor(
        address payable[] memory _members,
        address _memberToken,
        uint256 _joinMin, // min memberToken balance to join memberIndex
        uint256 _repMax,
        uint256 _repMin,
        uint256 _repTimeDelay,
        uint256 _rewardTimeDelay,
        uint256 _tapTimeDelay,
        string memory _message) payable public { // initializes contract w/ ETH deposit
        for (uint256 i = 0; i < _members.length; i++) {
            require(_members[i] != address(0), "member address cannot be 0");
            require(memberToken.balanceOf(_members[i]) >= _joinMin, "memberToken balance insufficient");
            memberList[_members[i]].memberIndex = members.push(_members[i]).sub(1);
            memberList[_members[i]].rep = _repMin;
            memberList[_members[i]].exists = true;
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
    
    /**********************
    DRIP/DRAW ETH FUNCTIONS
    **********************/
    function() external payable {} 
    
    function depositETH() public payable {}
    
    function drawETH() public { // transfer deposited ETH to calling member per memberToken-balanced amounts, rep, tapTime
        require(memberList[_msgSender()].rep >= repMin, "rep not intact");
        require(now.sub(memberList[_msgSender()].tapTime) > tapTimeDelay, "last tapTime too recent");
        memberList[_msgSender()].tapTime = now;
        _msgSender().transfer(memberToken.balanceOf(_msgSender()).div(memberToken.totalSupply()).mul(ETHBalance()));
    }

    function lumpDropETH() payable public { // transfer caller ETH to members per attached drop amount
        for (uint256 i = 0; i < members.length; i++) { 
            members[i].transfer(msg.value.div(members.length));
        }
    }
    
    function pinDropETH(uint256[] memory drop) payable public { // transfer caller ETH to members per index drop amounts
        require(drop.length == members.length);
        for (uint256 i = 0; i < members.length; i++) {
            require(msg.value == drop[i], "msg.value not sufficient for drop");
            members[i].transfer(drop[i]);
        }
    }
    
    /************************
    DRIP/DRAW TOKEN FUNCTIONS
    ************************/
    function drawToken(address _drawnToken) public { // transfer deposited token to calling member per memberToken-balanced amounts, rep, rewardTime
        require(memberList[_msgSender()].rep >= repMin, "rep not intact");
        require(now.sub(memberList[_msgSender()].rewardTime) > rewardTimeDelay, "last rewardTime too recent");
        memberList[_msgSender()].rewardTime = now;
        IERC20 drawnToken = IERC20(_drawnToken);
        drawnToken.safeTransfer(_msgSender(), memberToken.balanceOf(_msgSender()).div(memberToken.totalSupply()).mul(drawnToken.balanceOf(vault)));
    }

    function lumpDropToken(uint256 drop, address _droppedToken) public { // transfer caller token to members per approved drop amount
        for (uint256 i = 0; i < members.length; i++) {
            IERC20 droppedToken = IERC20(_droppedToken);
            droppedToken.safeTransferFrom(_msgSender(), members[i], drop.div(members.length));
        }
    }
    
    function pinDropToken(uint256[] memory drop, address _droppedToken) public { // transfer caller token to members per approved index drop amounts
        require(drop.length == members.length);
        for (uint256 i = 0; i < members.length; i++) {
            IERC20 droppedToken = IERC20(_droppedToken);
            droppedToken.safeTransferFrom(_msgSender(), members[i], drop[i]);
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
        memberList[_msgSender()].rep = repMin;
        memberList[_msgSender()].exists = true;
        emit MemberAdded(_msgSender());
    }

    function leaveMembership() public {
        require(memberList[_msgSender()].exists == true, "must already be member");
        uint256 memberToDelete = memberList[_msgSender()].memberIndex;
        address payable keyToMove = members[members.length.sub(1)];
        members[memberToDelete] = keyToMove;
        memberList[keyToMove].memberIndex = memberToDelete;
        memberList[_msgSender()].rep = repMin;
        memberList[_msgSender()].exists = false;
        members.length--;
        emit MemberRemoved(_msgSender());
    }
    
    // ***************
    // rep MGMT
    // ***************
    function repairMember(address repairedMember) public {
        require(_msgSender() != repairedMember, "cannot repair self");
        require(memberList[_msgSender()].rep >= repMin, "rep not intact");
        require(now.sub(memberList[_msgSender()].repTime) > repTimeDelay, "last repTime too recent");
        memberList[repairedMember].rep = memberList[repairedMember].rep.add(1);
        emit MemberRepaired(_msgSender(), repairedMember);
    }
    
    function reportMember(address reportedMember) public {
        require(_msgSender() != reportedMember, "cannot report self");
        require(memberList[_msgSender()].rep >= repMin, "rep not intact");
        require(now.sub(memberList[_msgSender()].repTime) > repTimeDelay, "last repTime too recent");
        memberList[reportedMember].rep = memberList[reportedMember].rep.sub(1);
        emit MemberReported(_msgSender(), reportedMember);
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

contract MemberDripDrawFactory {
    MemberDripDraw private DripDraw;
    address[] public dripdraws;

    event newDripDraw(address indexed dripdraw);

    function newMemberDripDraw(
        address payable[] memory _members, 
        address _memberToken,
        uint256 _joinMin,
        uint256 _repMax,
        uint256 _repMin,
        uint256 _repTimeDelay,
        uint256 _rewardTimeDelay,
        uint256 _tapTimeDelay,
        string memory _message) payable public {
            
        DripDraw = (new MemberDripDraw).value(msg.value)(
            _members, 
            _memberToken,
            _joinMin,
            _repMax,
            _repMin,
            _repTimeDelay,
            _rewardTimeDelay,
            _tapTimeDelay,
            _message);
            
        dripdraws.push(address(DripDraw));
        emit newDripDraw(address(DripDraw));
    }
}
