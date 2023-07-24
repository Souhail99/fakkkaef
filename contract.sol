// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Bank {

    address public owner;
    ERC20 public token;
    uint256 public depositPeriod;
    uint256 public lockPeriod;
    uint256 public rewardPeriod;
    uint256 public rewardPool;

    struct User {
        uint256 depositAmount;
        uint256 withdrawTime;
    }

    mapping(address => User) public users;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    constructor(
        address _token,
        uint256 _depositPeriod,
        uint256 _lockPeriod,
        uint256 _rewardPeriod,
        uint256 _rewardPool
    ) {
        owner = msg.sender;
        token = ERC20(_token);
        depositPeriod = _depositPeriod;
        lockPeriod = _lockPeriod;
        rewardPeriod = _rewardPeriod;
        rewardPool = _rewardPool;
    }

    function deposit(uint256 amount) external {
        require(users[msg.sender].depositAmount == 0, "User already deposited");
        require(token.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokens");
        users[msg.sender].depositAmount = amount;
        users[msg.sender].withdrawTime = block.timestamp + lockPeriod;
        emit Deposit(msg.sender, amount);
    }

    function withdraw() external {
        require(users[msg.sender].depositAmount > 0, "User hasn't deposited");
        require(block.timestamp >= users[msg.sender].withdrawTime, "Tokens are locked");
        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = users[msg.sender].depositAmount + reward;
        delete users[msg.sender];
        require(token.transfer(msg.sender, totalAmount), "Failed to transfer tokens");
        emit Withdraw(msg.sender, users[msg.sender].depositAmount, reward);
    }

    function calculateReward(address user) internal view returns (uint256) {
        uint256 totalStaked = getTotalStaked();
        uint256 reward = 0;
        uint256 time = block.timestamp;
        if(time >= rewardPeriod + lockPeriod) {
            reward = rewardPool;
        } else if (time >= rewardPeriod) {
            reward = rewardPool * 50 / 100;
        } else if (time >= rewardPeriod - lockPeriod) {
            reward = rewardPool * 30 / 100;
        } else {
            reward = rewardPool * 20 / 100;
        }
        
        return reward * users[user].depositAmount / totalStaked;
    }

    function getTotalStaked() internal view returns (uint256) {
        uint256 totalStaked = 0;
        for (address userAddress IN users) {
            totalStaked += users[userAddress].depositAmount;
        }
        return totalStaked;
    }

    function withdrawRemainingReward() external onlyOwner {
        require(block.timestamp >= rewardPeriod + lockPeriod * 2, "Cannot withdraw remaining reward yet");
        require(token.transfer(owner, rewardPool), "Failed to transfer tokens");
    }
}
