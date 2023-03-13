//SPDX-License-Identifier: GL-3.0
pragma solidity ^0.8.17;

// ERC Token Standard #20 Interface
interface ERC20Interface {
    function totalSupply() external view  returns (uint);
    function balanceOf(address account) external view returns (uint balance);
    function allowance(address owner, address spender) external view returns (uint remaining);
    function transfer(address recipient, uint amount) external returns (bool success);
    function approve(address spender, uint amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Blacklist(address indexed owner, address indexed user);
    event Unblacklist(address indexed owner, address indexed user);
}

// Actual token contract
contract G_Naira is ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    address public  Governor;
   

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address=> bool) isBlacklisted;

    constructor() {
        Governor = msg.sender;
        symbol = "gNGN";
        name = "G-Naira";
        decimals = 18;
        _totalSupply = 1_000_001_000_000_000_000_000_000; // A million +1 coins, with 18 zeros for decimal points
        balances[0xaCfd8d7B61DDc02E9c8777475987A0717aEbA4Bd] = _totalSupply;
        emit Transfer(address(0), 0xaCfd8d7B61DDc02E9c8777475987A0717aEbA4Bd,_totalSupply);
    }

    // Modifier to ensure only the governor can call a  function
    modifier onlyGovernor() {
        require(msg.sender == Governor, "Only the Governor can call this function");
        _;
    }
    
      //to add user to black_list by adding this to an array...
  function blackList(address _user) public onlyGovernor
  {
      require(!isBlacklisted[_user],"user is already blacklisted");
      isBlacklisted[_user] = true;
       emit Blacklist(msg.sender, _user);
  }

  function removeFromBlacklist(address _user) public onlyGovernor{
      require(isBlacklisted[_user],"use is already whitelisted");
      isBlacklisted[_user] = false;
      emit Unblacklist(msg.sender, _user);
  }


    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint balance) {
        return balances[account];
    }

    function transfer(address recipient, uint amount) public returns (bool success) {
        require(!isBlacklisted[recipient], "Recipient is blacklisted");
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool success){
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool success){
       require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Recipient is blacklisted");
        balances[sender] = balances[sender] - amount;
        allowed[sender][msg.sender]= allowed[sender][msg.sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint remaining){
        return allowed[owner][spender];
    }

        function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Token: cannot mint to zero address");
        _totalSupply = _totalSupply + amount;
        balances[account] = balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Token: cannot burn from zero address");
        require(balances[account] >= amount, "Token: cannot burn more than account owns");
        balances[account] = balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function burn(address account, uint256 amount) public onlyGovernor returns (bool) {
        _burn(account, amount);
        return true;
    }

    function mint(address account, uint256 amount) public onlyGovernor returns (bool) {
        _mint(account, amount);
        return true;
    }

}
