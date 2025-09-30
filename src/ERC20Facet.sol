// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

library ERC20Storage {
    bytes32 constant ERC20_STORAGE_POSITION = keccak256("erc20.storage");

    struct ERC20Store {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        string name;
        string symbol;
        uint8 decimals;
    }

    function erc20Storage() internal pure returns (ERC20Store storage es) {
        bytes32 position = ERC20_STORAGE_POSITION;
        assembly {
            es.slot := position
        }
    }
}

contract ERC20Facet is IERC20 {
    function name() public view returns (string memory) {
        return ERC20Storage.erc20Storage().name;
    }

    function symbol() public view returns (string memory) {
        return ERC20Storage.erc20Storage().symbol;
    }

    function decimals() public view returns (uint8) {
        return ERC20Storage.erc20Storage().decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return ERC20Storage.erc20Storage().totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return ERC20Storage.erc20Storage().balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return ERC20Storage.erc20Storage().allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public {
        require(to != address(0), "ERC20: mint to the zero address");

        ERC20Storage.ERC20Store storage es = ERC20Storage.erc20Storage();
        es.totalSupply += amount;
        es.balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function init(string memory _name, string memory _symbol, uint8 _decimals) public {
        ERC20Storage.ERC20Store storage es = ERC20Storage.erc20Storage();
        es.name = _name;
        es.symbol = _symbol;
        es.decimals = _decimals;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        ERC20Storage.ERC20Store storage es = ERC20Storage.erc20Storage();
        uint256 fromBalance = es.balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            es.balances[from] = fromBalance - amount;
        }
        es.balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ERC20Storage.erc20Storage().allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}
