pragma solidity ^0.5.17;

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

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract SecretaryRole is Context {
    using Roles for Roles.Role;

    event SecretaryAdded(address indexed account);
    event SecretaryRemoved(address indexed account);

    Roles.Role private _secretaries;

    modifier onlySecretary() {
        require(isSecretary(_msgSender()), "SecretaryRole: caller does not have the Secretary role");
        _;
    }
    
    function isSecretary(address account) public view returns (bool) {
        return _secretaries.has(account);
    }

    function addSecretary(address account) public onlySecretary {
        _addSecretary(account);
    }

    function renounceSecretary() public {
        _removeSecretary(_msgSender());
    }

    function _addSecretary(address account) internal {
        _secretaries.add(account);
        emit SecretaryAdded(account);
    }

    function _removeSecretary(address account) internal {
        _secretaries.remove(account);
        emit SecretaryRemoved(account);
    }
}

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

contract MemberDripDrop is SecretaryRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    /***************
    INTERNAL DETAILS
    ***************/
    IERC20 public dividendToken;
    IERC20 public dripToken;
    address payable[] members;
    IERC20 memberToken;
    address private vault = address(this);
    uint256 public ethDividend;
    uint256 public ethDrip;
    uint256 public tokenDividend;
    uint256 public tokenDrip;
    string public message;
    
    
    mapping(address => Member) public memberList;
    
   // ["0x4EDdF44116caE5ab15104E07daE66832F31EB878", "0xfff503425970752F18999996752798c1ACBF979d"]
   
    struct Member {
        uint256 memberIndex;
        bool exists;
    }

    // ******
    // EVENTS
    // ******
    event DividendTokenUpdated(address indexed _dividendToken);
    event DripTokenUpdated(address indexed _dripToken);
    event ETHDividendUpdated(uint256 indexed _ethDividend);
    event ETHDripUpdated(uint256 indexed _ethDrip);
    event MemberAdded(address indexed _member);
    event MemberRemoved(address indexed _member);
    event MemberTokenUpgraded(address indexed _memberToken);
    event MessageUpdated(string indexed _message);
    event TokenDripUpdated(uint256 indexed _tokenDrip);
    event TokenDividendUpdated(uint256 indexed _tokenDividend);
    
    function() external payable {} // contract receives ETH

    constructor(
        address _dividendToken,
        address _dripToken, 
        address payable[] memory _members,
        address _memberToken,
        uint256 _ethDividend,
        uint256 _ethDrip, 
        uint256 _tokenDividend,
        uint256 _tokenDrip,  
        string memory _message) payable public { // initializes contract
        for (uint256 i = 0; i < _members.length; i++) {
            require(_members[i] != address(0), "member address cannot be 0");
            memberList[_members[i]].memberIndex = members.push(_members[i]).sub(1);
            memberList[_members[i]].exists = true;
        }
        
        dividendToken = IERC20(_dividendToken);
        dripToken = IERC20(_dripToken);
        memberToken = IERC20(_memberToken);
        ethDividend = _ethDividend;
        ethDrip = _ethDrip;
        tokenDividend = _tokenDividend;
        tokenDrip = _tokenDrip;
        message = _message;
        
        _addSecretary(members[0]); // first address in member array is initial secretary  
    }
    
    /************************
    DRIP/DROP TOKEN FUNCTIONS
    ************************/
    function depositDripTKN() public { // deposit msg.sender drip token in approved amount sufficient for full member drip 
        dripToken.safeTransferFrom(_msgSender(), vault, tokenDrip.mul(members.length));
    }
    
    function dripTKN() public onlySecretary { // transfer deposited dripToken to members per drip amount
        for (uint256 i = 0; i < members.length; i++) {
            dripToken.safeTransfer(members[i], tokenDrip);
        }
    }
    
    
    function balanceDripTKN() public onlySecretary { // transfer deposited dripToken to members per memberToken-balanced drip amounts
        
        uint memberTokenTotals = getMemberTokenTotal(); 
        
        for (uint256 i = 0; i < members.length; i++) {
            require(memberTokenTotals > 0, "members do not have any member tokens");
            dripToken.safeTransfer(members[i], memberToken.balanceOf(members[i]).div(memberTokenTotals));
        }
    }
    
    
    function customDripTKN(uint256[] memory drip, address _dripToken) public onlySecretary { // transfer dripToken to members per index drip amounts
        for (uint256 i = 0; i < members.length; i++) {
            IERC20 token = IERC20(_dripToken);
            token.safeTransfer(members[i], drip[i]);
        }
    }
    
    function dropTKN(uint256 drop, address _dropToken) public { // transfer msg.sender token to members per approved drop amount
        for (uint256 i = 0; i < members.length; i++) {
            IERC20 dropToken = IERC20(_dropToken);
            dropToken.safeTransferFrom(_msgSender(), members[i], drop.div(members.length));
        }
    }
    
    function customDropTKN(uint256[] memory drop, address _dropToken) public { // transfer msg.sender token to members per approved index drop amounts
        for (uint256 i = 0; i < members.length; i++) {
            IERC20 dropToken = IERC20(_dropToken);
            dropToken.safeTransferFrom(_msgSender(), members[i], drop[i]);
        }
    }
    
    /**********************
    DRIP/DROP ETH FUNCTIONS
    **********************/
    function depositDripETH() public payable { // deposit ETH in amount sufficient for full member drip
        require(msg.value == ethDrip.mul(members.length), "msg.value not sufficient for drip");
    }
    
    function dripETH() public onlySecretary { // transfer deposited ETH to members per stored drip amount
        for (uint256 i = 0; i < members.length; i++) {
            members[i].transfer(ethDrip);
        }
    }
    
    function balanceDripETH() public onlySecretary { // transfer deposited ETH to members per memberToken-balanced drip amounts
        
        uint memberTokenTotals = getMemberTokenTotal(); 
        
        for (uint256 i = 0; i < members.length; i++) {
            require(memberTokenTotals > 0, "members do not have any member tokens");
            members[i].transfer(memberToken.balanceOf(members[i]).div(memberTokenTotals));
        }
    }
    
    function customDripETH(uint256[] memory drip) payable public onlySecretary { // transfer deposited ETH to members per index drip amounts
        for (uint256 i = 0; i < members.length; i++) {
            members[i].transfer(drip[i]);
        }
    }

    function dropETH() payable public { // transfer msg.sender ETH to members per attached drop amount
        for (uint256 i = 0; i < members.length; i++) {
            members[i].transfer(msg.value.div(members.length));
        }
    }
    
    function customDropETH(uint256[] memory drop) payable public { // transfer msg.sender ETH to members per index drop amounts
        for (uint256 i = 0; i < members.length; i++) {
            require(msg.value == drop[i], "msg.value not sufficient for drop");
            members[i].transfer(drop[i]);
        }
    }
    
    /*******************
    MANAGEMENT FUNCTIONS
    *******************/
    // ******************
    // DRIP/DROP REGISTRY
    // ******************
    function addMember(address payable _member) public onlySecretary { 
        require(memberList[_member].exists != true, "member already exists");
        memberList[_member].memberIndex = members.push(_member).sub(1);
        memberList[_member].exists = true;
        emit MemberAdded(_member);
    }

    function removeMember(address _member) public onlySecretary {
        require(memberList[_member].exists == true, "no such member to remove");
        uint256 memberToDelete = memberList[_member].memberIndex;
        address payable keyToMove = members[members.length.sub(1)];
        members[memberToDelete] = keyToMove;
        memberList[keyToMove].memberIndex = memberToDelete;
        memberList[_member].exists = false;
        members.length--;
        emit MemberRemoved(_member);
    }
    
    function updateMessage(string memory _message) public onlySecretary {
        message = _message;
        emit MessageUpdated(_message);
    }

    // ****************
    // DIVIDEND DETAILS
    // ****************
    function updateETHDividend(uint256 _ethDividend) public onlySecretary {
        ethDividend = _ethDividend;
        emit ETHDividendUpdated(_ethDividend);
    }
    
    function updateDividendToken(address _dividendToken) public onlySecretary {
        dividendToken = IERC20(_dividendToken);
        emit DividendTokenUpdated(_dividendToken);
    }
    
    function updateTokenDividend(uint256 _tokenDividend) public onlySecretary {
        tokenDividend = _tokenDividend;
        emit TokenDividendUpdated(_tokenDividend);
    }
    
    // ************
    // DRIP DETAILS
    // ************
    function updateETHDrip(uint256 _ethDrip) public onlySecretary {
        ethDrip = _ethDrip;
        emit ETHDripUpdated(_ethDrip);
    }
    
    function updateDripToken(address _dripToken) public onlySecretary {
        dripToken = IERC20(_dripToken);
        emit DripTokenUpdated(_dripToken);
    }
    
    function updateTokenDrip(uint256 _tokenDrip) public onlySecretary {
        tokenDrip = _tokenDrip;
        emit TokenDripUpdated(_tokenDrip);
    }
    
    /***************
    GETTER FUNCTIONS
    ***************/
    // ******
    // MEMBER
    // ******
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
    
    // *****
    // VAULT
    // *****
    function ETHBalance() public view returns (uint256) { // get balance of ETH 
        return vault.balance;
    }
    
    function DividendTokenBalance() public view returns (uint256) { // get balance of dividendToken 
        return dividendToken.balanceOf(vault);
    }
    
    function DripTokenBalance() public view returns (uint256) { // get balance of dripToken 
        return dripToken.balanceOf(vault);
    }
    
    function getMemberTokenTotal() public view returns (uint256 memberTokenTotals)  {
          
        memberTokenTotals = 0; 
        for (uint256 i = 0; i < members.length; i++) {
         memberTokenTotals += memberToken.balanceOf(members[i]);
        }
        
    }  
}

contract MemberDripDropFactory {
    MemberDripDrop private DripDrop;
    address[] public dripdrops;

    event newDripDrop(address indexed dripdrop, address indexed secretary);

    function newMemberDripDrop(
        address _dividendToken,
        address _dripToken, 
        address payable[] memory _members, // first address in member array is initial secretary  
        address _memberToken,
        uint256 _ethDividend,
        uint256 _ethDrip, 
        uint256 _tokenDividend,
        uint256 _tokenDrip,  
        string memory _message) payable public {
            
        DripDrop = (new MemberDripDrop).value(msg.value)(
            _dividendToken,
            _dripToken, 
            _members, 
            _memberToken,
            _ethDividend,
            _ethDrip, 
            _tokenDividend,
            _tokenDrip,  
            _message);
            
        dripdrops.push(address(DripDrop));
        emit newDripDrop(address(DripDrop), _members[0]);
    }
}