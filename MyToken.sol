// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC20.sol";

// contract MyToken implementing ERC20 Interface
contract MyToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /* The constructor initializes the token contract with the provided parameters.
It sets the token's name, symbol, decimals, and initial supply.
It assigns the total initial supply to the contract deployer's address.
It emits a Transfer event to reflect the initial supply transfer from the zero address to the contract deployer. totalSupply() */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = initialSupply * 10 ** uint256(_decimals);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /* This function is an external view function that returns the total supply of the token.
balanceOf(address account): */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /* This function is an external view function that returns the balance of the specified account.
transfer(address recipient, uint256 amount):*/
    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    /* This function allows the sender to transfer tokens to the recipient.
It checks if the sender has a sufficient balance to transfer.
It calculates the 10% fee on the transferred amount and deducts it from the sender's balance.
It transfers the remaining amount to the recipient and adds the fee to the contract's balance.
It emits Transfer events for both the transfer and the fee deduction.
allowance(address owner, address spender):*/
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(amount <= _balances[msg.sender], "Insufficient balance");

        uint256 fee = amount / 10; // 10% fee
        uint256 transferAmount = amount - fee;

        _balances[msg.sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[address(this)] += fee; // fee goes to contract

        emit Transfer(msg.sender, recipient, transferAmount);
        emit Transfer(msg.sender, address(this), fee);

        return true;
    }

    /* This function is an external view function that returns the allowance granted from the owner to the spender.
approve(address spender, uint256 amount):*/
    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /* This function allows the owner to approve a spender to spend a certain amount of tokens on their behalf.
It updates the spender's allowance.
It emits an Approval event.
transferFrom(address sender, address recipient, uint256 amount):*/
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /* This function allows a spender to transfer tokens from the owner's account to another account.
It checks if the sender has a sufficient balance and allowance to transfer.
It calculates the 10% fee on the transferred amount and deducts it from the sender's balance.
It transfers the remaining amount to the recipient and adds the fee to the contract's balance.
It emits Transfer events for both the transfer and the fee deduction.
These functions together implement the basic functionality of an ERC20 token along with the feature of deducting a 10% transaction fee from the sender's balance. */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(amount <= _balances[sender], "Insufficient balance");
        require(
            amount <= _allowances[sender][msg.sender],
            "Allowance exceeded"
        );

        uint256 fee = amount / 10; // 10% fee
        uint256 transferAmount = amount - fee;

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[address(this)] += fee; // fee goes to contract
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, address(this), fee);

        return true;
    }
}
