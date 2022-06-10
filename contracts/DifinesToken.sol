// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./interface/IBEP20.sol";
import "./libs/SafeMath.sol";

contract DifinesToken is IBEP20 {
    using SafeMath for uint256;
    string private _name = "DIFINES";
    string private _symbol = "DFS";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10000000000 * 1e18;

    address private _operator;
    address public constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event Burn(address indexed from, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _operator = msg.sender;
        emit OwnershipTransferred(address(0), _operator);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        require(_balances[msg.sender] >= _value, "Not enough tokens");

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _allowances[msg.sender][_to] = _value;

        emit Approval(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(_value <= _balances[_from]);
        require(_value <= _allowances[_from][msg.sender]);

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(
            _value
        );

        emit Transfer(_from, _to, _value);
        return true;
    }

    function getOwner() public view override returns (address) {
        return _operator;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address _self, address _to)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[_self][_to];
    }

    function burn(uint256 _value)
        external
        override
        onlyOperator
        returns (bool success)
    {
        transfer(BURN_ADDRESS, _value);
        _totalSupply = _totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
        return true;
    }

    modifier onlyOperator() {
        require(
            _operator == msg.sender || msg.sender == getOwner(),
            "Difines: caller is not the operator"
        );
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOperator {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner)
        internal
        returns (bool success)
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_operator, newOwner);
        _operator = newOwner;

        return true;
    }
}
